# Revisão independente de QA e segurança

Data: 20/09/2026. Alvo: protótipo Godot 4.4.1 em Linux.

## Escopo e evidência

A suíte `tests/test_review.gd` cobre produção válida, pagamento único, reciclagem única, rejeição atômica de dados inválidos, números JSON, integridade da recompensa, retomada determinística, ações fora de ordem, recuperação econômica e persistência real em arquivo isolado. Também verifica recuperação da cópia anterior quando o principal está corrompido ou o conteúdo não corresponde ao checksum.

Comando reproduzível, substituindo `godot` pelo executável instalado:

```sh
godot --headless --path /caminho/brasa-bigorna --script res://tests/test_review.gd
```

Verificação integrada em 21/09/2026 com Godot 4.4.1: simulação 92, salvamento 12, revisão independente 52 e integração da UI 32 verificações, todas aprovadas (188 no total). Importação pelo editor headless e todas as suítes terminaram com código 0. O teste de UI aciona sinais de botões reais, sem simular toque físico.

Correções de restauração JSON, recuperação com seis/sete moedas e exposição durante resfriamento foram integradas. Também foi corrigida a rotação do backup ao executar ações inválidas pela interface, com regressão em `test_ui.gd`.

Tentativa de renderização visual nesta sessão ficou bloqueada pela indisponibilidade de um display local utilizável (Xvfb não conseguiu estabelecer os sockets). Nenhuma captura do jogo ou aprovação visual é alegada.

## Defeitos encontrados pela revisão

1. **Restauração de peça inspecionada:** o JSON transforma números em floats e a comparação de dicionários rejeitava `reward`/`quality` legítimos. Reproduzido pela suíte independente, comunicado e corrigido pelo responsável de gameplay mediante validação por campo e normalização. O caso passou após a correção.
2. **Oficina sem saída econômica:** inventário vazio e seis moedas não permitiam comprar ferro (oito moedas), nem receber auxílio. A interface não vende cobre. Reproduzido pela suíte e encaminhado para correção do limiar de auxílio.
3. **Receita só após consumo de material:** a interface solicitava conferir a receita antes de começar, mas só a mostrava na etapa seguinte. Corrigido pelo responsável da interface: receita no pedido e caderno.
4. **Mensagem de recuperação incorreta:** carregar uma cópia válida de segurança era apresentado como falha de carga. Interface corrigida para exibir a mensagem original do armazenamento.
5. **Exposição térmica durante resfriamento:** versão inicial só integrava exposição ao aquecer. Encaminhado para integração também no resfriamento; trata-se de regra abstrata do jogo, não validação de metalurgia.

## Segurança e integridade offline

- Persistência usa JSON e listas de valores permitidos; não carrega objetos executáveis.
- Leitura de save limitada a 262.144 bytes antes do parsing. Não há histórico de ações que cresça indefinidamente.
- Números não finitos, negativos, fracionários em contadores e valores acima dos limites são rejeitados na restauração.
- Defeitos conhecidos e condições de cada etapa são conferidos antes da alteração do estado vivo.
- Recompensa de inspeção é reconstruída da receita e dos defeitos. Entrega muda a etapa, impedindo segundo pagamento da mesma peça na sessão normal.
- Gravação temporária, rotação de cópia válida e preservação de arquivo rejeitado reduzem perda de progresso. Não equivalem a garantia absoluta contra falha de hardware ou interrupção em qualquer ponto.
- SHA-256 detecta corrupção/acidente; **não autentica um save contra seu proprietário**. Uma pessoa com acesso ao arquivo pode alterar dados e recalcular o checksum ou restaurar uma cópia antiga. Não há economia online nem ranking a proteger no protótipo.
- Não foram identificados rede, credenciais, contas, telemetria, publicidade ou pagamentos no código revisado.

## Limites da entrega

Os testes são executados no motor Linux. Não demonstram instalação, desempenho, acessibilidade, toque, suspensão ou assinatura no iPhone. A revisão de interface descrita acima é por código; avaliação visual e de usabilidade deve ser registrada separadamente. Não foi feita auditoria independente do binário do motor nem teste de penetração de serviços externos, pois não há backend neste protótipo.

Antes da versão comercial: verificar exportação no Mac/Xcode, aparelhos físicos e áreas seguras, interrupções durante gravação, migração de saves, acessibilidade e economia após a expansão do conteúdo. A simulação atual usa calor e ações abstratos e não constitui receita real de fabricação.
