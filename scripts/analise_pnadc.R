library(PNADcIBGE)
library(dplyr)
library(lmtest)
library(sandwich)
library(modelsummary)

#download da base 
if (!dir.exists("dados")) dir.create("dados")
if (file.exists("dados/pnadc_2025_t2.rds")) {
  pnadc <- readRDS("dados/pnadc_2025_t2.rds")
} else {
  pnadc <- get_pnadc(year = 2025, quarter = 2, vars = NULL,
                     labels = FALSE, deflator = FALSE, design = FALSE,
                     savedir = "dados")
  saveRDS(pnadc, "dados/pnadc_2025_t2.rds")
}
#classes e conversao 
colunas <- c("UF","V1023","V2007","V2009","V2010","VD3005",
             "VD4002","VD4009","VD4010","VD4016","V4039")
sapply(pnadc[, colunas], class)       
na_antes <- sapply(pnadc[, colunas], function(x) sum(is.na(x)))
pnadc <- pnadc %>% mutate(across(all_of(colunas), as.numeric))
pnadc$V1028 <- as.numeric(pnadc$V1028)
pnadc$id <- 1:nrow(pnadc)    
na_depois <- sapply(pnadc[, colunas], function(x) sum(is.na(x)))
data.frame(antes = na_antes, depois = na_depois)   

#amostra 
n <- c(inicial = nrow(pnadc))
d1 <- filter(pnadc, VD4002 == 1);                n["ocupados"]      <- nrow(d1)
d2 <- filter(d1, V2009 >= 18, V2009 <= 65);      n["18 a 65 anos"]  <- nrow(d2)
d3 <- filter(d2, VD4009 %in% 1:7);               n["empregados"]    <- nrow(d3)
d4 <- filter(d3, VD4016 > 0, V4039 > 0);         n["renda e horas > 0"] <- nrow(d4)
funil <- data.frame(etapa = names(n), n = n, perdidas = c(NA, -diff(n)))
funil
if (!dir.exists("resultados")) dir.create("resultados")
write.csv(funil, "resultados/funil_amostra.csv", row.names = FALSE)
base <- d4 %>%
  mutate(sal_hora = VD4016 / (V4039 * 4.33),
         lw = log(sal_hora),
         area = factor(V1023, levels = c(4, 1, 2, 3),
                       labels = c("Interior", "Capital", "Resto RM", "Resto RIDE")),
         educ = VD3005,
         exper = pmax(V2009 - VD3005 - 6, 0),
         mulher = ifelse(V2007 == 2, 1, 0),
         preta_parda = ifelse(V2010 %in% c(2, 4), 1, 0),
         formal = ifelse(VD4009 %in% c(1, 3, 5, 7), 1, 0),
         publico = ifelse(VD4009 %in% c(5, 6, 7), 1, 0),
         setor = factor(VD4010),
         uf = factor(UF))

nrow(base)
colSums(is.na(base[, c("lw", "area", "educ", "exper", "mulher", "preta_parda",
                       "formal", "publico", "setor", "uf")]))   
sum(base$V2009 - base$VD3005 - 6 < 0)    
table(base$formal, base$publico)         
table(base$setor)                       
table(base$VD4009, base$setor == 11)     
table(base$VD4009, base$setor == 12)

table(tapply(pnadc$Estrato, pnadc$UPA, function(x) length(unique(x))))
base$cluster <- paste(base$Estrato, base$UPA)     # conglomerado = par estrato-UPA
length(unique(base$cluster))
cl <- function(m) vcovCL(m, cluster = ~cluster, type = "HC1")   # EP agrupado, usado em tudo

#descritivas 
uf_area <- addmargins(table(base$uf, base$area))
uf_area
write.csv(as.data.frame.matrix(uf_area), "resultados/uf_por_area.csv")
quantile(base$sal_hora, c(.01, .05, .25, .5, .75, .95, .99))

mean(base$VD4016 < 1518)
tapply(base$VD4016 < 1518, base$area, mean)     
baixo <- base$sal_hora <= quantile(base$sal_hora, .01)
summary(base$V4039[baixo])       
summary(base$VD4016[baixo])      
tapply(base$sal_hora, base$area, mean)
tapply(base$educ, base$area, mean)
tapply(base$formal, base$area, mean)
tapply(base$publico, base$area, mean)
medias_area <- data.frame(area = levels(base$area),
                          n = as.vector(table(base$area)),
                          sal_hora = as.vector(tapply(base$sal_hora, base$area, mean)),
                          educ = as.vector(tapply(base$educ, base$area, mean)),
                          formal = as.vector(tapply(base$formal, base$area, mean)),
                          publico = as.vector(tapply(base$publico, base$area, mean)),
                          abaixo_minimo = as.vector(tapply(base$VD4016 < 1518, base$area, mean)))
medias_area
write.csv(medias_area, "resultados/medias_por_area.csv", row.names = FALSE)
cor(base[, c("educ", "exper", "mulher", "preta_parda", "formal", "publico")])

if (!dir.exists("resultados")) dir.create("resultados")
vars <- c("sal_hora", "lw", "educ", "exper", "mulher", "preta_parda", "formal", "publico")
desc <- data.frame(variavel = vars,
                   N = sapply(vars, function(v) sum(!is.na(base[[v]]))),
                   media = sapply(vars, function(v) mean(base[[v]])),
                   variancia = sapply(vars, function(v) var(base[[v]])))
desc
write.csv(desc, "resultados/descritivas.csv", row.names = FALSE)

if (!dir.exists("graficos")) dir.create("graficos")
png("graficos/hist_lw.png", width = 800, height = 600)
hist(base$lw, breaks = 50, main = "", xlab = "log do salario-hora")
dev.off()
png("graficos/boxplot_lw_area.png", width = 800, height = 600)
boxplot(lw ~ area, data = base, xlab = "", ylab = "log do salario-hora", outline = FALSE)
dev.off()

#regressoes, premio e teste capital

m1 <- lm(lw ~ area, data = base)
m2 <- update(m1, . ~ . + educ + exper + I(exper^2) + mulher + preta_parda)
m3 <- update(m2, . ~ . + uf)
m4 <- update(m3, . ~ . + formal + publico + setor)
sapply(list(m1, m2, m3, m4), nobs)     

#erros-padrao agrupados por estrato-UPA
coeftest(m1, vcov = cl(m1))
coeftest(m2, vcov = cl(m2))
coeftest(m3, vcov = cl(m3))
coeftest(m4, vcov = cl(m4))
coeftest(m4, vcov = vcovHC(m4, type = "HC1"))     


nomes <- c("areaCapital", "areaResto RM", "areaResto RIDE")
100 * (exp(coef(m4)[nomes]) - 1)
sqrt(diag(cl(m4)))["areaCapital"]       
vc4 <- cl(m4)
100 * (exp(coefci(m4, vcov. = vc4)[nomes, ]) - 1)            
premios <- do.call(rbind, lapply(c("m1", "m2", "m3", "m4"), function(nm) {
  m <- get(nm)
  ic <- coefci(m, vcov. = cl(m))[nomes, ]
  data.frame(modelo = nm, area = nomes, coef = coef(m)[nomes],
             premio = 100 * (exp(coef(m)[nomes]) - 1),
             ic_inf = 100 * (exp(ic[, 1]) - 1), ic_sup = 100 * (exp(ic[, 2]) - 1))
}))
premios
write.csv(premios, "resultados/premios_ic_agrupado.csv", row.names = FALSE)

cap <- subset(premios, area == "areaCapital")
png("graficos/premio_capital.png", width = 800, height = 600)
plot(1:4, cap$premio, ylim = range(cap$ic_inf, cap$ic_sup), pch = 19, xaxt = "n",
     xlab = "modelo", ylab = "premio da capital (%)")
axis(1, at = 1:4, labels = c("(1)", "(2)", "(3)", "(4)"))
arrows(1:4, cap$ic_inf, 1:4, cap$ic_sup, angle = 90, code = 3, length = 0.05)
dev.off()
100 * (exp(coefci(m4, vcov. = vcovHC(m4, type = "HC1"))[nomes, ]) - 1)  
sapply(list(m1, m2, m3, m4), function(m) 100 * (exp(coef(m)["areaCapital"]) - 1))
#teste da hipotese
testa <- function(m) {
  L <- rep(0, length(coef(m))); names(L) <- names(coef(m))
  L["areaCapital"] <- 1
  L["areaResto RM"] <- -1
  dif <- sum(L * coef(m))
  ep <- sqrt(t(L) %*% cl(m) %*% L)
  c(diferenca = dif, ep = ep, t = dif / ep, p = 2 * pt(-abs(dif / ep), df.residual(m)))
}
teste_capital_rm <- t(sapply(list(m1 = m1, m2 = m2, m3 = m3, m4 = m4), testa))
round(teste_capital_rm, 4)       
write.csv(teste_capital_rm, "resultados/teste_capital_igual_RM.csv")

#tabela unica
modelsummary(list("(1)" = m1, "(2)" = m2, "(3)" = m3, "(4)" = m4),
             vcov = ~cluster, stars = TRUE,
             coef_map = c("areaCapital" = "Capital", "areaResto RM" = "Resto da RM",
                          "areaResto RIDE" = "Resto da RIDE", "educ" = "Anos de estudo",
                          "exper" = "Experiencia", "I(exper^2)" = "Experiencia ao quadrado",
                          "mulher" = "Mulher", "preta_parda" = "Preta ou parda",
                          "formal" = "Formal", "publico" = "Setor publico"),
             add_rows = data.frame(termo = c("Efeito fixo de UF", "Efeito fixo de setor"),
                                   a = c("Nao", "Nao"), b = c("Nao", "Nao"),
                                   c = c("Sim", "Nao"), d = c("Sim", "Sim")),
             gof_omit = "AIC|BIC|Log|F|RMSE",
             notes = paste0("Erros-padrao entre parenteses, agrupados por estrato-UPA (", length(unique(base$cluster)), " conglomerados)."),
             output = "resultados/tabela_modelos.docx")

#decomposicao
m3a <- update(m3, . ~ . + formal)
m3b <- update(m3, . ~ . + publico)
m3c <- update(m3, . ~ . + setor)
sapply(list(m3 = m3, formal = m3a, publico = m3b, setor = m3c, m4 = m4),
       function(m) coef(m)["areaCapital"])

aux <- lm(publico ~ area + educ + exper + I(exper^2) + mulher + preta_parda + uf, data = base)
coef(m3)["areaCapital"]
coef(m3b)["areaCapital"] + coef(m3b)["publico"] * coef(aux)["areaCapital"]
all.equal(unname(coef(m3)["areaCapital"]),
          unname(coef(m3b)["areaCapital"] + coef(m3b)["publico"] * coef(aux)["areaCapital"]))

aux_sem_educ <- lm(publico ~ area + exper + I(exper^2) + mulher + preta_parda + uf, data = base)
coef(aux)["areaCapital"]               # com educ
coef(aux_sem_educ)["areaCapital"]      # sem educ

omitidas <- model.matrix(~ formal + publico + setor, data = base)[, -1]
aux_todas <- lm(omitidas ~ area + educ + exper + I(exper^2) + mulher + preta_parda + uf, data = base)
delta <- coef(aux_todas)["areaCapital", ]          
gamma <- coef(m4)[colnames(omitidas)]             
contrib <- gamma * delta
decomp <- data.frame(variavel = names(gamma), gamma = gamma, delta = delta, contrib = contrib)
decomp
write.csv(decomp, "resultados/decomposicao_m3_m4.csv", row.names = FALSE)
c(formal = contrib["formal"], publico = contrib["publico"],
  setor = sum(contrib[grep("^setor", names(contrib))]))
sum(contrib)
coef(m3)["areaCapital"] - coef(m4)["areaCapital"]  
all.equal(unname(sum(contrib)), unname(coef(m3)["areaCapital"] - coef(m4)["areaCapital"]))

#robustez

m4_peso <- update(m4, weights = V1028)
coeftest(m4_peso, vcov = cl(m4_peso))[1:4, ]

#inferencia
coeftest(m4, vcov = vc4)[1:4, ]

#populacao
base_priv <- droplevels(subset(base, publico == 0))
m4_priv <- lm(lw ~ area + educ + exper + I(exper^2) + mulher + preta_parda + uf +
                formal + setor, data = base_priv)
coeftest(m4_priv, vcov = cl(m4_priv))[1:4, ]

# medida
lim <- quantile(base$sal_hora, c(.01, .99), na.rm = TRUE)
base_corte <- droplevels(subset(base, sal_hora >= lim[1] & sal_hora <= lim[2]))
m4_corte <- update(m4, data = base_corte)
coeftest(m4_corte, vcov = cl(m4_corte))[1:4, ]

#identificacao 
base_sem_df <- droplevels(subset(base, UF != 53))
m4_sem_df <- update(m4, data = base_sem_df)
which(is.na(coef(m4_sem_df)))          
coeftest(m4_sem_df, vcov = cl(m4_sem_df))[1:4, ]

#forma funcional da educacao 
m4_quad <- update(m4, . ~ . + I(educ^2))
m4_fat  <- update(m4, . ~ . - educ + factor(educ))
coeftest(m4_quad, vcov = cl(m4_quad))["I(educ^2)", ]
waldtest(m4, m4_quad, vcov = cl)
sapply(list(linear = m4, quadratica = m4_quad, fatores = m4_fat),
       function(m) coef(m)["areaCapital"])
sapply(list(linear = m4, quadratica = m4_quad, fatores = m4_fat),
       function(m) coef(m)[c("exper", "I(exper^2)")])      

#sensibilidade do coeficiente da capital
m4_pos <- update(m4, . ~ . - formal - publico + factor(VD4009))
m4_s12 <- update(m4, data = droplevels(subset(base, setor != 12)))
base$setor_agr <- factor(ifelse(base$VD4010 == 12, 10, base$VD4010))
m4_agr <- update(m4, . ~ . - setor + setor_agr)

linha <- function(m) {
  b <- coef(m)["areaCapital"]
  ep <- sqrt(vcovCL(m, cluster = ~cluster, type = "HC1")["areaCapital", "areaCapital"])
  c(coef = unname(b), ep = ep, premio = unname(100 * (exp(b) - 1)))
}
bloco_A <- t(sapply(list(m4 = m4, educ_quad = m4_quad, educ_fatores = m4_fat, posicao_VD4009 = m4_pos,
                         corte_1pct = m4_corte, com_peso = m4_peso), linha))

bloco_B <- t(sapply(list(m4 = m4, sem_publico = m4_priv), linha))
bloco_C <- t(sapply(list(m4 = m4, sem_setor12 = m4_s12, setor12_no_10 = m4_agr, sem_DF = m4_sem_df), linha))
round(bloco_A, 4)       
round(bloco_B, 4)
round(bloco_C, 4)
sens <- rbind(data.frame(bloco = "A", especificacao = rownames(bloco_A), bloco_A),
              data.frame(bloco = "B", especificacao = rownames(bloco_B), bloco_B),
              data.frame(bloco = "C", especificacao = rownames(bloco_C), bloco_C))
write.csv(sens, "resultados/sensibilidade.csv", row.names = FALSE)

#diagnosticos dos residuos
if (!dir.exists("graficos")) dir.create("graficos")
png("graficos/diag_residuos_ajustados.png", width = 800, height = 600)
smoothScatter(fitted(m4), resid(m4), xlab = "valores ajustados", ylab = "residuos")
abline(h = 0)
dev.off()
png("graficos/diag_qq.png", width = 800, height = 600)
plot(m4, which = 2)
dev.off()
png("graficos/diag_hist_residuos.png", width = 800, height = 600)
hist(resid(m4), breaks = 30, main = "Residuos do m4", xlab = "residuos")
dev.off()
png("graficos/diag_residuos_educ.png", width = 800, height = 600)
plot(base$educ, resid(m4), pch = ".", xlab = "anos de estudo", ylab = "residuos")
abline(h = 0)
dev.off()
png("graficos/diag_residuos_exper.png", width = 800, height = 600)
plot(base$exper, resid(m4), pch = ".", xlab = "experiencia", ylab = "residuos")
abline(h = 0)
dev.off()

summary(resid(m4))
bptest(m4)
# selecao
pop <- filter(pnadc, V2009 >= 18, V2009 <= 65) %>%
  mutate(entra = ifelse(id %in% base$id, 1, 0),      
         area = factor(V1023, levels = c(4, 1, 2, 3),
                       labels = c("Interior", "Capital", "Resto RM", "Resto RIDE")),
         mulher = ifelse(V2007 == 2, 1, 0),
         preta_parda = ifelse(V2010 %in% c(2, 4), 1, 0))
pop$cluster <- paste(pop$Estrato, pop$UPA)    
nrow(pop)
table(pop$entra, useNA = "ifany")
colSums(is.na(pop[, c("entra", "area", "VD3005", "V2009", "mulher", "preta_parda")]))
mean(pop$entra)
sel <- glm(entra ~ area + VD3005 + V2009 + mulher + preta_parda,
           data = pop, family = binomial(link = "probit"))
summary(sel)
nobs(sel)
ct_sel <- coeftest(sel, vcov = vcovCL(sel, cluster = ~cluster, type = "HC1"))   
ct_sel
write.csv(unclass(ct_sel), "resultados/probit_selecao.csv")
tapply(pop$VD3005, pop$entra, mean)
#reprodutibilidade 
sessionInfo()
writeLines(capture.output(sessionInfo()), "sessionInfo.txt")



