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
│   └── [nome_do_script].R      # script completo e comentado
├── dados/                      # criada pelo script; não versionada
├── resultados/                 # tabelas e arquivos .csv/.docx gerados
├── graficos/                   # figuras de diagnóstico (.png)
└── sessionInfo.txt             # versões de R e pacotes usados
```

## Como reproduzir

1. Instale o R e os pacotes: `PNADcIBGE`, `dplyr`, `lmtest`, `sandwich`, `modelsummary`.
2. Defina o diretório de trabalho na raiz do repositório.
3. Rode o script do início ao fim, por exemplo `Rscript scripts/[nome_do_script].R`.
4. Na primeira execução o script baixa os microdados (precisa de internet) e salva uma cópia em `dados/pnadc_2025_t2.rds`. Nas execuções seguintes lê essa cópia.

Não há componente aleatório, então não é necessário fixar semente.

## O que o script faz

[Descrever, em uma linha por etapa, as seções do script: download e importação, conversão de classes, amostra, construção de variáveis, descritivas, modelos, erros-padrão, decomposição, robustez, diagnósticos e seleção.]

## Arquivos de saída

| Arquivo | Conteúdo |
|---|---|
| `resultados/descritivas.csv` | Estatísticas descritivas |
| `resultados/tabela_modelos.docx` | Tabela dos modelos (1) a (4) |
| `resultados/teste_capital_igual_RM.csv` | Teste de igualdade entre os coeficientes de Capital e Resto da RM |
| `resultados/decomposicao_m3_m4.csv` | Decomposição da diferença entre os modelos (3) e (4) |
| `resultados/sensibilidade.csv` | Sensibilidade do coeficiente da capital a especificações alternativas |
| `resultados/probit_selecao.csv` | Probit de seleção amostral |
| `graficos/diag_*.png` | Gráficos de diagnóstico dos resíduos |
| `sessionInfo.txt` | Ambiente de execução |
| [outros arquivos] | [completar] |

## Ambiente

Rodado em R 4.5.1 (Windows 11). As versões dos pacotes estão em `sessionInfo.txt`.

## Autoria e uso de IA

[Descrever o uso de ferramentas de IA conforme as orientações da disciplina.]

## Autor

Davi Freire. FGV EESP, Economia.
