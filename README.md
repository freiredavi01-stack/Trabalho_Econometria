# Trabalho_Econometria
“Prêmio salarial da capital, PNAD Contínua 2025 T2 (Econometria I)”


Trabalho empírico da disciplina Econometria I (FGV EESP).

## Pergunta de pesquisa

Trabalhar na capital gera um salário maior que no interior, mesmo para pessoas com a mesma escolaridade e experiência?

Método: MQO (equação de Mincer) com dados em cross-section. Linguagem: R.

## Dados

- Base: PNAD Contínua, IBGE, microdados de 2025, 2º trimestre.
- Fonte: baixada pelo script via pacote `PNADcIBGE` (função `get_pnadc`). Os dados brutos **não** são versionados.
- Documentação e dicionário de variáveis: https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Trimestral/Microdados/2025/

### Variáveis utilizadas

| Código | Descrição (preencher a partir do dicionário do IBGE) |
|---|---|
| UF | unidade da federação. |
| V1023 | tipo de área: 1 capital, 2 resto da RM, 3 resto da RIDE, 4 resto da UF (interior). |
| V2007 | sexo: 1 homem, 2 mulher.|
| V2009 |idade em anos.|
| V2010 |cor ou raça: 1 branca, 2 preta, 3 amarela, 4 parda, 5 indígena.|
| VD3005 |anos de estudo.|
| VD4002 |condição de ocupação: 1 ocupada, 2 desocupada.|
| VD4009 |posição na ocupação e categoria do emprego (privado, doméstico, público, militar, empregador, conta própria, etc.).|
| VD4010 |grupamento de atividade (setor).|
| VD4016 |rendimento mensal habitual do trabalho principal, em reais.|
| V4039 |horas trabalhadas por semana no trabalho principal.|
| V1028 |peso amostral (o fator de expansão da pessoa).|
| Estrato, UPA |o estrato e a unidade primária de amostragem (área sorteada). Servem para agrupar os erros-padrão por conglomerado.|

## Estrutura do repositório

```
.
├── README.md
├── .gitignore
├── scripts/
│   └── analise_pnadc.R         # script completo e comentado
├── dados/                      # criada pelo script; não versionada
├── resultados/                 # tabelas e arquivos .csv/.docx gerados
├── graficos/                   # figuras de diagnóstico (.png)
└── sessionInfo.txt             # versões de R e pacotes usados
```

## Como reproduzir

1. Instale o R e os pacotes: `PNADcIBGE`, `dplyr`, `lmtest`, `sandwich`, `modelsummary`.
2. Defina o diretório de trabalho na raiz do repositório.
3. Rode o script do início ao fim, por exemplo `Rscript scripts/analise_pnadc.R`.
4. Na primeira execução o script baixa os microdados (precisa de internet) e salva uma cópia em `dados/pnadc_2025_t2.rds`. Nas execuções seguintes lê essa cópia.

Não há componente aleatório, então não é necessário fixar semente.

## O que o script faz

1. **Download e importação:** baixa a PNADC 2025T2 com `get_pnadc` e guarda um `.rds` em `dados/`, para não baixar de novo.
2. **Conversão de classes:** mostra a classe de cada coluna, converte as usadas para número e confere se algum NA novo apareceu.
3. **Amostra:** aplica os filtros em sequência (ocupados, 18 a 65 anos, empregados, renda e horas positivas) e salva o funil com n e perdidas.
4. **Construção de variáveis:** cria salário-hora, log, área, experiência, dummies (mulher, preta/parda, formal, público), setor, UF e o conglomerado estrato-UPA.
5. **Descritivas:** tabela UF por área, percentis, fração abaixo do mínimo, médias por área, correlações, média e variância das variáveis.
6. **Modelos:** estima os modelos (1) a (4), de só a área até todos os controles, e calcula o prêmio em % com intervalo de confiança.
7. **Erros-padrão:** usa EP agrupado por estrato-UPA em tudo (o HC1 aparece só como comparação), testa Capital = Resto da RM e monta a tabela `.docx`.
8. **Decomposição:** mostra quanto cada bloco (formal, público, setor) move o coeficiente da capital entre os modelos (3) e (4).
9. **Robustez:** refaz o modelo (4) com peso, sem setor público, cortando 1% de cada ponta e sem o DF, e testa a forma da educação (quadrática e fatores).
10. **Sensibilidade:** reúne o coeficiente da capital de todas essas variações em três blocos (especificação ou medida, população, codificação).
11. **Diagnósticos:** 5 gráficos dos resíduos do modelo (4) e o teste de Breusch-Pagan.
12. **Seleção:** probit de quem entra na amostra entre todos de 18 a 65 anos, com EP agrupado.
13. **Reprodutibilidade:** grava o `sessionInfo.txt`.

## Arquivos de saída

Ao rodar o script, as pastas abaixo são criadas automaticamente dentro da pasta de trabalho do R, que é a pasta onde o script está salvo (confira com `getwd()`):

- `dados/`: a base baixada (`pnadc_2025_t2.rds`). Não é incluída no repositório, por ser grande demais (199 MB).
- `resultados/`: os arquivos `.csv` e a `tabela_modelos.docx`.
- `graficos/`: as figuras `diag_*.png`, de diagnóstico dos resíduos.
- `sessionInfo.txt`: fica direto na pasta de trabalho, fora das subpastas.

Para reproduzir, abra o script, defina a pasta de trabalho, reinicie o R e rode o script inteiro.

| Arquivo | Conteúdo |
|---|---|
| `resultados/funil_amostra.csv` | Funil da amostra (etapa, n e perdidas) |
| `resultados/uf_por_area.csv` | Tabela UF por área |
| `resultados/descritivas.csv` | Estatísticas descritivas |
| `resultados/medias_por_area.csv` | Médias por área |
| `resultados/premios_ic_agrupado.csv` | Prêmios em % com intervalo de confiança agrupado |
| `resultados/tabela_modelos.docx` | Tabela dos modelos (1) a (4) |
| `resultados/teste_capital_igual_RM.csv` | Teste de igualdade entre os coeficientes de Capital e Resto da RM |
| `resultados/decomposicao_m3_m4.csv` | Decomposição da diferença entre os modelos (3) e (4) |
| `resultados/sensibilidade.csv` | Sensibilidade do coeficiente da capital a especificações alternativas |
| `resultados/probit_selecao.csv` | Probit de seleção amostral |
| `graficos/diag_*.png` | Gráficos de diagnóstico dos resíduos |
| `sessionInfo.txt` | Ambiente de execução |
| `resultados/funil_amostra.csv` | Observações após cada filtro da amostra |
| `resultados/uf_por_area.csv` | Observações por UF e tipo de área |
| `resultados/medias_por_area.csv` | Médias de variáveis selecionadas por tipo de área |
| `resultados/premios_ic_agrupado.csv` | Prêmios em % com IC, erros-padrão agrupados |

## Ambiente

Rodado em R 4.5.2 (Windows 11). As versões dos pacotes estão em `sessionInfo.txt`.

## Autoria e uso de IA
Usei o Claude como apoio, seguindo as orientações da disciplina, em uma única conversa (link público: https://claude.ai/share/fc64df71-2c31-47ee-a9cd 3a11ad93cc99). A IA atuou como tutora, mentora ou ferramenta, nunca como autora: a pergunta, as escolhas econométricas, a interpretação dos resultados e o texto são meus.

Como tutora e mentora, ajudou a testar a clareza e a viabilidade da pergunta, a montar a estratégia de busca de artigos (sem listar referências), a explicar funções e erros do R com exemplos genéricos e a depurar o código. Como mentora, comentou o que produzi primeiro: a narrativa da revisão, a escolha de controles, forma funcional e método, os critérios de amostra, os testes de diagnóstico, as limitações e a argumentação do relatório. Como ferramenta, identificou bases candidatas, escreveu o código de download e importação, sugeriu a estrutura de seções, revisou a gramática sem alterar o conteúdo e ajudou na formatação ABNT e no repositório.
## Autor

Rodrigo Thibes e Davi Freire. FGV EESP, Economia.
