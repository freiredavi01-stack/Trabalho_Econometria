# Trabalho_Econometria
“Prêmio salarial da capital, PNAD Contínua 2025 T2 (Econometria I)”


Trabalho empírico da disciplina Econometria I (FGV EESP).

## Pergunta de pesquisa

Trabalhar na capital gera um salário maior que no interior, mesmo para pessoas com a mesma escolaridade e experiência?

Método: MQO (equação de Mincer) com dados em cross-section. Linguagem: R.

## Dados

- Base: PNAD Contínua, IBGE, microdados de 2025, 2º trimestre.
- Fonte: baixada pelo script via pacote `PNADcIBGE` (função `get_pnadc`). Os dados brutos **não** são versionados.
- Documentação e dicionário de variáveis: [inserir link do IBGE].

### Variáveis utilizadas

| Código | Descrição (preencher a partir do dicionário do IBGE) |
|---|---|
| UF | |
| V1023 | |
| V2007 | |
| V2009 | |
| V2010 | |
| VD3005 | |
| VD4002 | |
| VD4009 | |
| VD4010 | |
| VD4016 | |
| V4039 | |
| V1028 | |
| Estrato, UPA | |

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
