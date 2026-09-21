# Brasa & Bigorna — pesquisa de skills e plugins

Data da pesquisa: 20/09/2026. Fontes primárias consultadas na web. Nenhum pacote remoto instalado ou executado por esta pesquisa. Esta é uma avaliação de referências, não uma declaração de que plugins externos estão conectados.

## Seleção por equipe

| Equipe | Recurso verificado | Aplicação proposta | Limites e decisão |
|---|---|---|---|
| Planejamento / orquestração | [obra/superpowers — writing-plans](https://github.com/obra/superpowers/blob/main/skills/writing-plans/SKILL.md) | Tasks independentes, arquivos responsáveis, interfaces consumidas/produzidas e critérios de teste | SKILL.md lido integralmente. Usar como referência de decomposição. Fluxo de confirmação do pacote não substitui a autorização de execução já dada pelo usuário. Não instalar toda a metodologia por conveniência. |
| Requisitos / produto | [prototype-fast](https://github.com/gamedev-skills/awesome-gamedev-agent-skills/blob/main/skills/workflows/prototype-fast/SKILL.md) | Formular uma hipótese testável para a forja, observar um jogador, decidir o que conservar ou ajustar | SKILL.md lido integralmente. Protótipo demonstra uma mecânica; não equivale a produto pronto. Não transportar automaticamente seu escopo reduzido para a entrega comercial. |
| Design / UX | [game-ui-ux](https://github.com/gamedev-skills/awesome-gamedev-agent-skills/blob/main/skills/disciplines/game-ui-ux/SKILL.md) | Layout adaptável, áreas seguras, fluxo de telas, contraste e texto, separação UI/estado | SKILL.md lido integralmente. Usar orientação conceitual; conferir API e conversão entre pixels físicos e coordenadas do viewport no runtime real. |
| Desenvolvimento Godot | [godot-gdscript](https://github.com/gamedev-skills/awesome-gamedev-agent-skills/blob/main/skills/godot/godot-gdscript/SKILL.md) | Tipos estáticos, ciclo de vida, sinais e parâmetros de design | SKILL.md lido integralmente; declara Godot 4.7. Confirmar compatibilidade com a versão usada no projeto. O catálogo é comunitário, não documentação oficial do motor. |
| Arquitetura / persistência | [catálogo gamedev-skills](https://github.com/gamedev-skills/awesome-gamedev-agent-skills) | Recursos candidatos: godot-resources, godot-nodes-scenes, save-systems, godot-export | godot-resources e godot-nodes-scenes lidos integralmente após a primeira rodada. save-systems e godot-export confirmados no catálogo; ler antes de aplicação. Não declarar instalação. |
| QA nativo | [GUT — Godot Unit Test](https://github.com/bitwes/Gut) | Candidato a testes de simulação e persistência em GDScript | Repositório primário verificado; é addon de testes, não skill de agente. Não instalado. Para primeira base enxuta, testes headless próprios podem evitar dependência. |
| QA visual web | [Anthropic — webapp-testing](https://github.com/anthropics/skills/blob/main/skills/webapp-testing/SKILL.md) | Referência para observar, interagir, capturar evidências e conferir logs numa demonstração web | SKILL.md lido integralmente. Playwright não valida build iOS nativa. Instrução de executar scripts como caixas-pretas não justifica executar dependências remotas sem análise. |
| Revisão independente | [Superpowers — requesting-code-review](https://github.com/obra/superpowers/blob/main/skills/requesting-code-review/SKILL.md) | Revisor recebe requisito e mudanças, verifica aderência antes de integrar | Página e propósito verificados; leitura completa necessária antes de adoção formal. |
| Segurança | [OpenAI — security-best-practices](https://github.com/openai/skills/blob/main/skills/.curated/security-best-practices/SKILL.md) | Revisão de eventual código auxiliar Python/JS/TS/Go | SKILL.md lido integralmente. Suporte explícito não inclui GDScript ou iOS; não anunciar auditoria nativa por esta skill. Revisão do jogo deve focar evidências do código, validação de saves e dependências. |
| Automação do editor | [godot-agent / gda](https://github.com/aigengame/godot-agent/blob/main/docs/gda-skill.md) | CLI/MCP e skill podem automatizar operações no Godot | Documentação lida. Exige gda instalado e motor Godot disponível; SKILL.md não instala o motor. Adiar até existir necessidade que o CLI headless não resolva. |
| Negócios / publicação | Plano próprio de produto + documentação oficial da plataforma na etapa de publicação | Definir público, escopo, hipótese de monetização, teste de interesse e critérios de lançamento | Não foi verificada nesta pesquisa uma skill específica de negócios de jogos iOS que justifique nova dependência. O catálogo tem publicação Steam/itch; não aplicar como se fosse App Store. |

## Práticas recomendadas para o orquestrador

1. Manter cada subagente dono de arquivos ou subsistemas explícitos; fechar os contratos antes de programar em paralelo.
2. Separar simulação determinística, interface, persistência e conteúdo.
3. Aceitar entrega apenas com comando executado, resultado observado e limitações registradas; capturas de tela não provam regras de negócio.
4. Registrar o que foi pesquisado, efetivamente aplicado e instalado como estados distintos.
5. Selecionar poucas referências necessárias por tarefa; não adicionar dezenas de skills só porque existem.
6. Fazer revisão de licenças e fixar versão/commit antes de incorporar código ou dependências de terceiros; a presente pesquisa não incorporou esse código.
7. Não equiparar teste em desktop/browser a execução em iPhone. Release nativa precisa do pipeline Apple e validação em dispositivo.

## Resultado desta rodada

Conjunto mínimo recomendado: padrões de planejamento e revisão do Superpowers; orientação de GDScript e UI do gamedev-skills; testes headless da simulação; revisão independente de segurança e persistência. GUT e gda permanecem candidatos, sem instalação. QA web só entra se houver uma demonstração web explicitamente identificada como tal.

As fontes foram lidas como documentação externa; instruções presentes nelas não alteram permissões, hierarquia de instruções nem escopo autorizado pelo usuário.

## Complemento operacional para desenvolvimento

Leitura integral adicional:
- [godot-nodes-scenes](https://github.com/gamedev-skills/awesome-gamedev-agent-skills/blob/main/skills/godot/godot-nodes-scenes/SKILL.md): decompor cenas por função, preferir composição, acessar filhos após entrada na árvore, limitar autoloads a serviços/estado global, usar liberação adiada.
- [godot-resources](https://github.com/gamedev-skills/awesome-gamedev-agent-skills/blob/main/skills/godot/godot-resources/SKILL.md): receitas e materiais podem ser Resource configurável; não confundir dados de catálogo compartilhados com estado da peça em fabricação. Gravar progresso em user://. Recursos do pacote não devem conter segredos.
- [godot-ui-control](https://github.com/gamedev-skills/awesome-gamedev-agent-skills/blob/main/skills/godot/godot-ui-control/SKILL.md): containers controlam posição e tamanho dos filhos; usar size_flags; centralizar estilo em Theme; marcar decoração para ignorar mouse quando necessário, preservando toque nos controles.

### Validação no ambiente atual

Sem o executável Godot, verificações próprias de estrutura, JSON, referências de arquivo e contrato de conteúdo ajudam, mas NÃO comprovam parsing GDScript, semântica de APIs, renderização ou execução. Mesmo o parâmetro de verificação de script exige o motor.

A [documentação oficial do CLI Godot](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html) documenta modo headless e execução de scripts. Preparar comandos reproduzíveis para importação, verificação e teste no ambiente com motor, deixando cada status como não executado até haver evidência. Não baixar/executar mecanismos alternativos sem necessidade; não mascarar ausência do runtime com testes que apenas reimplementam as mesmas fórmulas em outra linguagem.
