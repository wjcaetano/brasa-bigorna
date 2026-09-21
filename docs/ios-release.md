# Preparação iOS

Estado: pendente. O teste no motor Linux não comprova execução ou usabilidade no iPhone.

## Pré-requisitos e sequência

1. Mac com Xcode e SDK iOS compatíveis com a versão da engine escolhida para release.
2. Importar o projeto e instalar os templates de exportação correspondentes à engine.
3. Criar preset iOS no editor. Definir o Bundle Identifier definitivo e o Team ID da conta responsável. Não versionar certificados, chaves privadas ou perfis.
4. Exportar para pasta `build/ios/` e abrir o projeto gerado no Xcode.
5. Configurar assinatura na conta autorizada; executar em um iPhone físico.
6. Verificar áreas seguras, legibilidade, tamanho dos alvos de toque, suspensão, fechamento, retomada, falta de armazenamento e desempenho.
7. Somente depois, preparar ícones, privacidade, licenças e distribuição de teste.

O projeto usa o renderer Compatibility e orientação horizontal. A interface atual usa viewport de referência 1280×800; precisa de validação e adaptação física antes do aceite mobile. Não há preset com identificadores fictícios ou alegação de build pronto.

Documentação oficial consultada: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html
