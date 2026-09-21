# Brasa & Bigorna

Protótipo de jogo cozy de ferraria medieval em Godot 4.4.1 e GDScript. Plataforma-alvo: iOS. O incremento atual roda no Godot e foi testado em Linux; ainda não há build iOS ou publicação na App Store.

## Executar

1. Instale Godot **4.4.1 Standard** (não é necessário .NET) pela distribuição oficial: https://godotengine.org/download/archive/4.4.1-stable/.
2. Importe `project.godot`.
3. Pressione F6 na cena principal ou F5 para jogar.

Pelo terminal: `godot --path .`.

O jogo funciona offline. Não usa contas, backend, publicidade, telemetria ou chaves de API.

## O que já funciona

- Três encomendas: gancho, talhadeira e faca, com materiais e faixas próprias.
- Seleção de material, aquecimento, resfriamento, bigorna, acabamento e inspeção.
- Falha explicada por material incompatível, trabalho fora da faixa e exposição térmica acumulada.
- Entrega, moedas, reputação, compras, reciclagem e auxílio para oficina sem recursos.
- Caderno, pausa e persistência local com cópia anterior e validação dos dados.

O calor usa escala **abstrata de 0 a 100**; as ações avançam intervalos discretos. Não são temperaturas nem receitas reais. Não há tratamento térmico, montagem, armaduras ou conformação por regiões neste incremento.

## Primeira encomenda

Selecione gancho e ferro. Comece a forjar e aqueça três vezes (+2 tempos por toque), chegando a 72. Leve à bigorna, dê quatro marteladas, siga ao acabamento, faça quatro passes de polimento, inspecione e entregue. Depois experimente outra receita e acompanhe sua faixa de trabalho.

Consultar o caderno ou pausar impede as ações de produção. Não há avanço automático enquanto o aplicativo está fechado.

## Testes

Em macOS/Linux com `godot` no PATH:

```sh
bash tools/test.sh
```

Para outro caminho:

```sh
GODOT_BIN=/caminho/para/godot bash tools/test.sh
```

No Windows, execute cada script com o executável Godot:

```text
Godot.exe --headless --path . --script res://tests/test_forge.gd
Godot.exe --headless --path . --script res://tests/test_save.gd
Godot.exe --headless --path . --script res://tests/test_review.gd
Godot.exe --headless --path . --script res://tests/test_ui.gd
```

Cada suíte retorna código diferente de zero ao falhar. Os testes de arquivo usam nomes isolados e não apagam o progresso normal.

## Organização

| Caminho | Responsabilidade |
|---|---|
| `scripts/forge_simulation.gd` | Regras e máquina de estados determinística |
| `scripts/save_store.gd` | JSON versionado, limites, checksum e backup |
| `scripts/main.gd` | Interface e ligação dos comandos |
| `scripts/workshop_art.gd` | Oficina desenhada com primitivas nativas |
| `data/recipes.json` | Conteúdo configurável |
| `tests/` | Testes de simulação, persistência, regressão e integração UI |
| `docs/development-plan.md` | Etapas, equipes, tarefas e critérios de aceite |
| `docs/backlog.json` | Backlog com IDs, dependências e estados |
| `docs/qa-review.md` | Achados de QA e limitações |
| `docs/skills-research.md` | Pesquisa de skills e plugins |
| `docs/ios-release.md` | Preparação para validação no iPhone |

## Salvamento

O arquivo `user://brasa_save.json` é gravado após ações válidas. A versão anterior válida fica em `.bak`. Arquivos rejeitados são preservados em `.rejected`. Um save de versão mais nova bloqueia sobrescrita por esta versão.

O checksum detecta corrupção, não impede adulteração por quem controla o dispositivo. Não há competição online neste protótipo.

## Próximos marcos

Validar legibilidade e alvos de toque em iPhone, gerar build com Mac/Xcode, testar background/retomada no aparelho e observar jogadores. Em seguida, evoluir processos de fabricação e conteúdo conforme o plano. A arte atual é provisória; áudio e vibração não estão implementados.

O código foi criado para este projeto. Nenhuma licença de distribuição pública foi escolhida. As licenças da engine e dos ativos futuros devem ser incluídas no pacote de lançamento.
