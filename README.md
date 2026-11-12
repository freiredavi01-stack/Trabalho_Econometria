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
Download e importação: baixa a PNADC 2025T2 com get_pnadc e guarda um .rds em dados/, para não baixar de novo.
Conversão de classes: mostra a classe de cada coluna, converte as usadas para número e confere se algum NA novo apareceu.
Amostra: aplica os filtros em sequência (ocupados, 18 a 65 anos, empregados, renda e horas positivas) e salva o funil com n e perdidas.
Construção de variáveis: cria salário-hora, log, área, experiência, dummies (mulher, preta/parda, formal, público), setor, UF e o conglomerado estrato-UPA.
Descritivas: tabela UF por área, percentis, fração abaixo do mínimo, médias por área, correlações e média e variância das variáveis.
Modelos: estima m1 a m4, de só a área até todos os controles, e calcula o prêmio em % com IC.
Erros-padrão: usa EP agrupado por estrato-UPA em tudo (HC1 só aparece como comparação), testa Capital = Resto da RM e monta a tabela .docx.
Decomposição: mostra quanto cada bloco (formal, público, setor) move o coeficiente da capital entre m3 e m4, pela identidade variável omitida.
Robustez: refaz o m4 com peso, sem setor público, cortando 1% de cada ponta e sem o DF, e testa a forma da educação (quadrática e fatores).
Sensibilidade: reúne o coeficiente da capital de todas essas variações em três blocos (especificação ou medida, população, codificação).
Diagnósticos: 5 gráficos dos resíduos do m4 mais o teste de Breusch-Pagan.
Seleção: probit de quem entra na amostra entre todos de 18 a 65 anos, com EP agrupado.
Reprodutibilidade: grava o sessionInfo.txt.

1. Download e importação da PNADC, com cópia local em `.rds`.
2. Conversão de classes e checagem de valores ausentes.
3. Amostra, com a contagem de observações após cada filtro.
4. Construção das variáveis.
5. Estatísticas descritivas.
6. Modelos (1) a (4) por MQO, com erros-padrão agrupados por estrato-UPA.
7. Prêmios em % com intervalos de confiança e teste de igualdade entre Capital e Resto da RM.
8. Tabela dos modelos.
9. Decomposição da diferença entre os modelos (3) e (4).
10. Robustez e sensibilidade, em três blocos: especificação e medida (A), população (B) e checagens de identificação (C).
11. Diagnósticos dos resíduos.
12. Seleção amostral (probit).
13. Registro do ambiente (`sessionInfo`).

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

Rodado em R 4.5.1 (Windows 11). As versões dos pacotes estão em `sessionInfo.txt`.

## Autoria e uso de IA

[Descrever o uso de ferramentas de IA conforme as orientações da disciplina.]

## Autor

Rodrigo Thibes e Davi Freire. FGV EESP, Economia.
