class_name SaveStore
extends RefCounted
## Local, bounded JSON saves. No object deserialization, network or secrets.

const Simulation = preload("res://scripts/forge_simulation.gd")
const VERSION: int = 1
const MAX_BYTES: int = 262144
var last_error: String = ""
var recovered_backup: bool = false
var _path: String
var _future_version: bool = false


func _init(path: String = "user://brasa_save.json") -> void:
	_path = path


func load_state() -> Dictionary:
	last_error = ""
	recovered_backup = false
	_future_version = false
	var primary: Dictionary = _read(_path)
	if not primary.is_empty():
		return primary
	# A newer save is deliberately preserved, not downgraded via its backup.
	if _future_version:
		last_error = "Este progresso foi salvo por uma versão mais nova. Atualize o jogo."
		return {}
	var backup: Dictionary = _read(_path + ".bak")
	if not backup.is_empty():
		recovered_backup = true
		last_error = "Progresso recuperado da cópia de segurança."
		return backup
	if FileAccess.file_exists(_path) or FileAccess.file_exists(_path + ".bak"):
		last_error = "Não foi possível ler o progresso. Uma nova sessão foi aberta."
	return {}


func save_state(state: Dictionary) -> bool:
	if _future_version:
		last_error = "Atualize o jogo para salvar sem substituir um progresso mais novo."
		return false
	var validator = Simulation.new()
	if not validator.restore(state):
		last_error = "O progresso não passou na validação e não foi substituído."
		return false
	var payload: String = JSON.stringify(state)
	var serialized: String = JSON.stringify({
		"version": VERSION, "payload": payload, "checksum": payload.sha256_text()
	})
	if serialized.to_utf8_buffer().size() > MAX_BYTES:
		last_error = "O progresso excedeu o limite de tamanho."
		return false
	var temp: String = _path + ".tmp"
	var stream: FileAccess = FileAccess.open(temp, FileAccess.WRITE)
	if stream == null:
		last_error = "Não foi possível abrir o arquivo de progresso."
		return false
	stream.store_string(serialized)
	stream.flush()
	var write_error: Error = stream.get_error()
	stream.close()
	if write_error != OK:
		last_error = "Falha ao gravar o progresso. A cópia anterior foi mantida."
		return false
	# Rotate only a valid primary: a corrupt primary must not replace a good backup.
	var primary: Dictionary = _read(_path)
	if _future_version:
		last_error = "Encontrado progresso de uma versão mais nova; gravação cancelada."
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temp))
		return false
	if not primary.is_empty():
		if FileAccess.file_exists(_path + ".bak"):
			if DirAccess.remove_absolute(ProjectSettings.globalize_path(_path + ".bak")) != OK:
				last_error = "Não foi possível atualizar a cópia de segurança."
				return false
		if DirAccess.rename_absolute(ProjectSettings.globalize_path(_path),
			ProjectSettings.globalize_path(_path + ".bak")) != OK:
			last_error = "Não foi possível preservar o progresso anterior."
			return false
	elif FileAccess.file_exists(_path):
		# Preserve the rejected file for local diagnosis, without trusting its contents.
		if FileAccess.file_exists(_path + ".rejected"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(_path + ".rejected"))
		if DirAccess.rename_absolute(ProjectSettings.globalize_path(_path),
			ProjectSettings.globalize_path(_path + ".rejected")) != OK:
			last_error = "Não foi possível preservar o arquivo de progresso inválido."
			return false
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(temp),
		ProjectSettings.globalize_path(_path)) != OK:
		last_error = "Não foi possível finalizar o salvamento; a cópia anterior está preservada."
		return false
	last_error = ""
	return true


func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var stream: FileAccess = FileAccess.open(path, FileAccess.READ)
	if stream == null:
		return {}
	if stream.get_length() > MAX_BYTES:
		stream.close()
		return {}
	var text: String = stream.get_as_text()
	stream.close()
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return {}
	var wrapper: Dictionary = parser.data
	var version: Variant = wrapper.get("version")
	if not (version is int or version is float):
		return {}
	if not is_finite(float(version)):
		return {}
	if float(version) > VERSION:
		_future_version = true
		return {}
	if float(version) != VERSION:
		return {}
	if not wrapper.get("payload") is String or not wrapper.get("checksum") is String:
		return {}
	var payload: String = wrapper["payload"]
	if payload.sha256_text() != wrapper["checksum"]:
		return {}
	if parser.parse(payload) != OK or not parser.data is Dictionary:
		return {}
	var data: Dictionary = parser.data
	var validator = Simulation.new()
	if not validator.restore(data):
		return {}
	return validator.snapshot()
