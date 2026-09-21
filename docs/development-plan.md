# Brasa & Bigorna — plano de desenvolvimento

Status: demonstração em integração, aguardando aceite do orquestrador. Godot 4.4.1 foi baixado e executado em Linux; verificações de gameplay, salvamento e QA foram executadas nesse ambiente. Esses resultados não equivalem a testes no iPhone. G2 permanece aberto até a revisão e o aceite do orquestrador. Todas as tarefas futuras estão aguardando início.

## 1. Direção do produto

Jogo individual e offline de ferraria medieval cozy para iPhone, com oficina 2D, gestão leve e clientes recorrentes. O jogador segue processos de fabricação e aprende com consequências determinísticas de materiais, temperatura, tempo e operações. A experiência acolhedora vem de diagnóstico claro, pausa, assistência e recuperação possível, sem apagar a relevância dos erros.

Tecnologia inicial: Godot com GDScript. Simulação separada da apresentação; receitas e materiais configuráveis; salvamento local versionado. Não há justificativa para backend, cadastro, publicidade, multiplayer ou serviços de IA dentro do jogo inicial.

Os parâmetros de fabricação do primeiro incremento são regras de jogo provisórias. Não são instruções reais de metalurgia. O compromisso de realismo exige revisão profissional antes de usar essa promessa comercialmente.

### Escopo do primeiro incremento: demonstração vertical

- Uma oficina, três receitas — gancho (`hook`), talhadeira (`chisel`) e faca (`knife`) — e três clientes com textos simples.
- Seleção de material; forja → bigorna → acabamento → inspeção → entrega.
- Calor abstrato de 0 a 100, alterado em passos discretos por ações; não representa graus Celsius ou simulação térmica contínua.
- Resultados e falhas determinados por regras. Reaquecer recupera calor sem corrigir defeitos; reciclar recupera valor conforme a regra implementada.
- Este incremento não inclui tratamento térmico, montagem, conformação por regiões nem correção de defeitos. Essas capacidades continuam no backlog de evolução e realismo.
- Pausa, assistência básica, salvamento e retomada.
- Interface horizontal com controles de toque.
- Projeto Godot executável e pacote de código reproduzível.

O incremento só pode ser chamado de demonstrado no iPhone depois de build, instalação e teste no aparelho. Execução headless ou em desktop não substitui essa evidência.

### Meta de MVP comercial

Hipótese de escopo, revisável conforme os testes: uma oficina evolutiva, 8–12 receitas, poucos materiais com diferenças claras, seis personagens recorrentes e um arco narrativo curto. Inclui economia equilibrada, onboarding, acessibilidade, som, arte consistente e distribuição iOS validada. Armaduras articuladas, mineração, exploração livre, cloud save e monetização complexa ficam fora do MVP.

## 2. Equipes e contratos de entrega

| Equipe | Responsabilidade | Entregável | Interface com outras equipes |
|---|---|---|---|
| Orquestração | Sequenciar trabalho, eliminar impedimentos, integrar e conferir evidências | Backlog, registro de decisões, relatório de release | Recebe evidências de todas as equipes; não aceita status sem prova |
| Planejamento e requisitos | Escopo, regras, histórias e aceite | Especificação funcional e matriz de rastreabilidade | Define contratos para design, engenharia e QA |
| Design de jogo e UX | Ciclo, feedback, estados de tela, acessibilidade, arte e áudio | Fluxos, parâmetros iniciais, guias visuais | Prototipa com engenharia; valida com jogadores |
| Desenvolvimento | Motor, simulação, interface, conteúdo, persistência e build | Código, dados e instruções de execução | Implementa requisitos e expõe verificações automatizáveis |
| Testes e qualidade | Verificações funcionais, regressão, aparelho e experiência | Casos de teste, resultados, defeitos e evidências | Independência na avaliação de aceite |
| Segurança e privacidade | Dependências, entradas, salvamento, segredos e coleta de dados | Inventário e revisão proporcional ao risco | Revisa instalação de skills, build e release |
| Negócios e publicação | Proposta de valor, público, custos, licença de ativos e loja | Hipóteses comerciais e pacote de publicação | Não promete recursos ou realismo ainda não entregues |

Skills ajudam as equipes; não substituem validação humana, ferramentas de build ou credenciais. Skills públicas só entram após leitura de instruções, origem, licença e necessidade de execução. Instruções externas não ampliam a autorização recebida.

## 3. Backlog por etapas, tasks e subtasks

Legenda: dependências são os IDs das tarefas necessárias antes do aceite. Trabalho reversível de preparação pode ocorrer antes, desde que não seja apresentado como concluído.

### E0 — Preparar execução e definir contratos

| ID | Equipe | Task e subtasks | Depende de | Critério de aceite |
|---|---|---|---|---|
| P-01 | Planejamento | Fechar visão; separar demo/MVP/expansões; registrar hipóteses | — | Escopo e exclusões explícitos e alinhados ao pedido |
| O-01 | Orquestração | Inspecionar runtime; localizar engine; verificar recursos de exportação; registrar limitações | — | Capacidades reais documentadas, sem inferir suporte iOS |
| S-01 | Segurança | Inventariar skills/plugins candidatos; ler instruções; avaliar origem/licença; selecionar apenas úteis | — | Lista com URL, função, restrição e decisão de uso |
| R-01 | Requisitos | Especificar estados da peça; transições válidas; causas de defeitos; critérios da encomenda | P-01 | Cada resultado pode ser explicado pelas entradas e ações |
| R-02 | Requisitos | Definir pausa; retorno do background; autosave; tratamento de save inválido | P-01 | Regras de recuperação e de não avanço durante ausência explícitas |
| O-02 | Orquestração | Definir arquivos de cada agente; contratos; ordem de integração; evidências esperadas | O-01, R-01, R-02 | Edição concorrente sem disputa de arquivos e responsabilidades claras |

Marco G0: escopo e contratos suficientes para construir uma receita completa. Não exige fechar todo o conteúdo do MVP.

### E1 — Construir regras discretas e uma interface funcional

| ID | Equipe | Task e subtasks | Depende de | Critério de aceite |
|---|---|---|---|---|
| D-01 | Design | Desenhar oficina/bancadas; indicadores térmicos; painel da receita; inspeção | R-01 | Cada ação, estado e próximo passo compreensíveis |
| D-02 | Design | Definir feedback de erro; assistência; pausa; alternativas à cor/áudio | R-01, R-02 | Falha comunica causa e possibilidade real de recuperação |
| E-01 | Desenvolvimento | Criar projeto Godot; configurar viewport; organizar cenas/dados/scripts; documentar execução | O-01, O-02 | Projeto importa sem erros na versão declarada |
| E-02 | Desenvolvimento | Implementar calor abstrato 0–100; passos discretos de ações; limites e condições de falha | R-01, E-01 | Mesma sequência de ações produz os mesmos estados; valores de calor ficam dentro dos limites |
| E-03 | Desenvolvimento | Implementar escolha de material; trabalho na bigorna sem regiões; defeitos; acabamento; avaliação | E-02 | Mesma receita e ações geram o mesmo resultado; acabamento não elimina falha crítica |
| E-04 | Desenvolvimento | Conectar UI de toque e mouse; estados de bancada; receita consultável; pausa | D-01, D-02, E-03 | Receita executável do início à inspeção sem comandos de console |
| Q-01 | Testes | Verificar material inválido; condições de calor inadequadas; ações fora de etapa; resultado válido | E-03 | Testes cobrem consequências relevantes e registram execução |

Marco G1: a forja roda no ambiente disponível e suas regras centrais estão verificadas. Arte provisória deve estar identificada.

### E2 — Fechar a demonstração vertical

| ID | Equipe | Task e subtasks | Depende de | Critério de aceite |
|---|---|---|---|---|
| E-05 | Desenvolvimento | Criar três clientes e encomendas para gancho/talhadeira/faca; aceite/rejeição; recompensa; reciclagem com recuperação de valor | E-03, E-04 | Ciclo completo; recompensa não pode ser resgatada duas vezes |
| E-06 | Desenvolvimento | Salvar estado versionado; gravar em pontos seguros; restaurar; cópia de recuperação | R-02, E-05 | Fechar e reabrir preserva progresso; corrupção não bloqueia início de jogo |
| D-03 | Design | Criar tutorial curto; orientar primeira falha; ajustar alvos de toque e legibilidade | E-04, E-05 | Jogador entende objetivo e motivo de falha sem orientação externa |
| Q-02 | Testes | Executar três receitas; reaquecer sem apagar defeitos; reciclar; pause/resume; entrega e restart | E-05, E-06, D-03 | Evidência para cada fluxo e ausência de bloqueadores de progresso |
| S-02 | Segurança | Revisar parsing de saves/dados; limites de entrada; ausência de segredos e rede desnecessária | E-06 | Erros tratados; nenhuma credencial no pacote; dados coletados explicitados |
| O-03 | Orquestração | Integrar; empacotar fonte; escrever README; registrar testes e limitações | Q-01, Q-02, S-02 | Outra pessoa consegue reproduzir execução com ferramentas declaradas |

Marco G2 — AGUARDANDO ACEITE: a demo local só será considerada entregue quando o orquestrador aprovar a integração e suas evidências. Se não houver Mac/aparelho, a pendência iOS aparece como bloqueio específico, não como etapa concluída.

### E3 — Validar no iPhone e decidir expansão

| ID | Equipe | Task e subtasks | Depende de | Critério de aceite |
|---|---|---|---|---|
| I-01 | Desenvolvimento | Confirmar Mac/Xcode; instalar templates; configurar projeto iOS; compilar | E-01 | Build iOS registrado com versões e erros resolvidos |
| I-02 | Desenvolvimento | Configurar assinatura autorizada; instalar em aparelho; validar lançamento | I-01 | Aplicativo abre em iPhone físico definido |
| Q-03 | Testes | Conferir toque, safe areas, áudio, rotação, background, retomada e performance | I-02, G2 | Relatório no dispositivo; metas de desempenho e aparelhos explicitados |
| D-04 | Design | Observar jogadores; registrar compreensão, repetição e frustração; ajustar interação | G2 | Problemas observados priorizados e hipótese de diversão reavaliada |
| R-03 | Requisitos | Revisar processo com especialista; separar abstração de prática real; corrigir alegações | R-01, G2 | Conteúdo e comunicação aprovados para o grau de realismo declarado |
| B-01 | Negócios | Definir público; examinar concorrentes; testar compra única/demo; estimar custo a partir da produção real | D-04 | Hipóteses e evidências separadas; decisão comercial registrada |

Marco G3: experiência comprovada no aparelho e decisão informada sobre escopo comercial. G2/G3 referem-se aos marcos definidos acima.

### E4 — Produzir e equilibrar o MVP

| ID | Equipe | Task e subtasks | Depende de | Critério de aceite |
|---|---|---|---|---|
| C-01 | Design/Desenvolvimento | Ampliar famílias de receitas; alternativas de materiais; diferenças de processo | G3, R-03 | Cada receita acrescenta decisão relevante; dados validados |
| C-02 | Design | Produzir personagens, pedidos, diálogos e arco curto | G3 | Progressão narrativa sem referências a recursos inexistentes |
| E-07 | Desenvolvimento | Implementar upgrades, catálogo, domínio, estoque e progressão | C-01, C-02 | Desbloqueios e economia completáveis sem bloqueio permanente |
| D-05 | Design | Produzir arte/áudio finais; decoração; feedback acessível | G3 | Consistência, autoria/licenças e desempenho verificados |
| Q-04 | Testes | Verificar progressão; exploits econômicos; migração de save; regressão em aparelhos | E-07, D-05 | Fluxos críticos aprovados; defeitos remanescentes classificados |

### E4.R — Evolução necessária para a promessa de realismo

Estas tarefas ainda não foram iniciadas. A demo discreta valida o ciclo de interação, não o processo metalúrgico completo.

| ID | Equipe | Task e subtasks | Depende de | Critério de aceite |
|---|---|---|---|---|
| R-04 | Requisitos/Design | Especificar tratamento térmico por família/material; mapear abstrações e limites | R-03 | Processo revisado profissionalmente e diferente onde o material exigir |
| E-08 | Desenvolvimento | Implementar tratamento térmico; registrar histórico relevante; avaliar consequências | R-04 | Sequência modifica propriedades sem permitir compensar falha crítica por acabamento |
| E-09 | Desenvolvimento/Design | Implementar conformação por regiões; feedback geométrico; controles de toque | D-04, R-03 | A região trabalhada muda a forma e o resultado de modo compreensível |
| E-10 | Desenvolvimento/Design | Implementar componentes e montagem; compatibilidade; integridade do conjunto | R-03, C-01 | Componentes inválidos são tratados e montagem influencia a avaliação |
| E-11 | Desenvolvimento/Design | Implementar correções de defeitos recuperáveis; custos e limites; explicar irreversibilidade | R-03, E-08 | Correções previstas funcionam sem apagar defeitos irreversíveis |
| Q-05 | Testes | Verificar evolução metalúrgica; regressão do ciclo; diagnósticos e salvamento expandido | E-08, E-09, E-10, E-11 | Regras aprovadas e fluxos anteriores continuam reproduzíveis |

Marco G4: conteúdo do MVP completo e candidato a release. Itens opcionais não atrasam correções críticas.

### E5 — Preparar distribuição e operar

| ID | Equipe | Task e subtasks | Depende de | Critério de aceite |
|---|---|---|---|---|
| S-03 | Segurança/Negócios | Inventariar SDKs e dados; revisar privacidade; conferir licenças e obrigações | G4 | Declarações correspondem ao comportamento real do app |
| B-02 | Negócios | Preparar título, descrição, screenshots reais, classificação e modelo de venda | B-01, G4 | Material comercial fiel ao build e requisitos atuais verificados |
| I-03 | Desenvolvimento/QA | Preparar distribuição de teste; coletar defeitos; corrigir bloqueadores | Q-04, S-03 | Build candidato testado por fluxo real de distribuição |
| O-04 | Orquestração | Compilar evidências; documentar pendências; preparar submissão revisável | B-02, I-03 | Release possui código, build, testes e metadados identificados |
| B-03 | Negócios | Executar submissão/publicação quando houver acesso e autorização aplicável | O-04 | Estado da loja confirmado; aprovação externa não presumida |
| O-05 | Orquestração | Triar feedback; corrigir falhas; planejar expansão com base no uso | B-03 | Prioridades vinculadas a problemas observados |

## 4. Requisitos rastreáveis do primeiro incremento

| Requisito | Comportamento | Implementação | Verificação |
|---|---|---|---|
| RF-01 | Material incompatível impede resultado aceito | E-03 | Q-01 |
| RF-02 | Ações térmicas discretas e condições de calor influenciam o resultado | E-02/E-03 | Q-01 |
| RF-03 | Etapas inválidas não produzem recompensa ou progresso indevido | E-03/E-05 | Q-01/Q-02 |
| RF-04 | Erro tem diagnóstico; reaquecer recupera calor e reciclar recupera valor, sem corrigir defeitos | E-03/E-04 | Q-02 |
| RF-05 | Entrega é concluída apenas uma vez | E-05 | Q-02 |
| RNF-01 | Jogo principal funciona offline | E-01/E-06 | Q-02/S-02 |
| RNF-02 | Pausa e background não penalizam peça | E-04/E-06 | Q-02/Q-03 |
| RNF-03 | Progresso pode ser retomado | E-06 | Q-02 |
| RNF-04 | Informações essenciais não dependem só da cor | D-02/E-04 | Q-02/Q-03 |
| RNF-05 | Fluxo funciona em iPhone físico | I-01/I-02 | Q-03 |

## 5. Gestão do orquestrador

Cada task passa por: pendente → em execução → em revisão → concluída. Impedimentos recebem estado bloqueada, causa, responsável e próximo passo concreto.

Para aceitar uma entrega, o orquestrador exige: arquivos alterados identificados, comportamento implementado, verificação executada, resultado observado e limitações. A autodeclaração do agente não substitui integração e revisão. Tarefas de simulação, apresentação e QA podem ocorrer em paralelo depois de definir os contratos; alterações nos mesmos arquivos devem ser serializadas.

Decisões que aumentem muito o escopo — migrar para 3D, adicionar backend, comprar ativos ou publicar — ficam registradas com impacto e justificativa. Não se confunde autorização para desenvolver com disponibilidade de contas, assinatura ou hardware.

## 6. Riscos e mitigação

| Risco | Mitigação | Sinal de resolução |
|---|---|---|
| Forja correta, mas monótona | Testar uma receita antes de produzir conteúdo | Jogadores entendem e querem repetir |
| Falha frustrante | Diagnóstico, assistência e recuperação | Erro é compreendido e não bloqueia progresso |
| Realismo enganoso | Parâmetros provisórios e revisão especializada | Regras e promessa comercial coerentes |
| Mobile difícil de controlar | Touch desde o protótipo e teste físico cedo | Sem alvos essenciais ocultos pelo dedo |
| Escopo 3D/armaduras excessivo | Oficina 2D e famílias limitadas | Demo completa antes de expandir |
| Sem Mac, assinatura ou iPhone | Preparar projeto e documentar dependência | Build e teste reais, não presumidos |
| Saves perdidos | Versionamento, gravação segura e recuperação | Retomada e corrupção verificadas |
| Skills externas inseguras | Ler e revisar antes de executar/instalar | Apenas capacidades necessárias e auditadas |
| Ativos sem licença | Inventário de origem e permissão | Todos os ativos da release rastreáveis |

## 7. Definição de pronto

**Task:** aceite atendido, código/dados integrados, verificação proporcional executada e limitações registradas.

**Demo local:** projeto abre, as três receitas e encomendas funcionam, sucesso e falhas são reproduzíveis, save/retomada funcionam e o pacote contém instruções. Não equivale a aplicativo iOS testado.

**Aplicativo iOS funcional:** build assinado quando necessário, instalado e testado em aparelho físico, com toque, pausa, áudio, salvamento e desempenho aprovados.

**Pronto para publicar:** conteúdo acordado completo, defeitos bloqueadores resolvidos, evidências de teste, licenças, privacidade e material de loja revisados, conta e fluxo de distribuição disponíveis.

**Publicado:** disponibilidade na loja confirmada após revisão externa. A aprovação da Apple e qualquer resultado comercial não são garantidos pelo plano.

## 8. Primeiro movimento autorizado

E0/E1 e verificações Linux já possuem trabalho realizado. O próximo movimento é concluir a revisão integrada de E2 para as três receitas, registrar as evidências e submeter G2 ao aceite do orquestrador. Não há aceite automático por existência de testes ou arquivos. As demais etapas avançam conforme seus critérios e dependências reais, sem declarar testes ou distribuição que o ambiente não permite executar.

## 9. Estado atual e backlog operacional

O arquivo `backlog.json` registra IDs individuais de tasks e subtasks. `em_revisao` significa que há implementação ou evidência aguardando conferência do orquestrador; não significa aceite. `em_integracao` identifica o trabalho em fechamento. `aguardando` é trabalho futuro ainda não iniciado. Quando uma task muda de estado, o orquestrador deve confirmar o estado das subtasks separadamente.

Evidência disponível informada na integração: Godot 4.4.1 executado em Linux e verificações de gameplay, save e QA executadas. Consulte o relatório de QA e o registro de integração para comandos e resultados específicos. Nenhum build, assinatura, instalação, teste físico ou publicação iOS está confirmado neste plano.

| Marco | Estado |
|---|---|
| G0 — contratos | Em revisão pelo orquestrador |
| G1 — regras e interface | Em revisão pelo orquestrador |
| G2 — demo local integrada | Aguardando aceite explícito do orquestrador |
| G3 — iPhone e decisão de expansão | Aguardando início |
| G4 — MVP | Aguardando início |
| Publicação | Aguardando início |
