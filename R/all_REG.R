
# Initialisation ----------------------------------------------------------

source("./Programmes/0_set_up.R")


# REG1 --------------------------------------------------------------------
# JEU : REG1 classique pour comparer avec version historique
# reg1_rjd_df(wkd1) vs...

## Jeu mensuel -------------------------------------------------------------

### Création du jeu de régresseur -------------------------------------------

wkd1_mens <- htd(frenchCalendar, frequency = frequency_mens, start = start_reg, 
                 length = frequency_mens * 40, groups = groups_reg1)
# objet TS
wkd1_mens_ts <- ts(wkd1_mens, start = start_reg, frequency = frequency_mens)
colnames(wkd1_mens_ts) <- "semaine"
# objet data.frame
reg1_rjd_mens_df <- cbind(date = zoo::as.Date(time(wkd1_mens_ts)),
                          as.data.frame(wkd1_mens_ts))


### Comparaison régresseur SAS ----------------------------------------------

# import reg1 classique 
reg1_sas_mens_df <- subset(reg_sas_mens_df, select = c(date, REG1_AC1))

# fichier de comparaison des régresseurs SAS et rjd+
comp_reg1_mens_df <- merge(reg1_sas_mens_df, reg1_rjd_mens_df, 
                           by = "date", all = TRUE)
head(comp_reg1_mens_df)

comp_reg1_mens_ts <- ts(subset(comp_reg1_mens_df, select = -date), 
                        start = start_reg, frequency = frequency_mens)

mod_reg1_mens <- lm(formula = REG1_AC1 ~ semaine, data = comp_reg1_mens_df)
comp_reg1_mens_ts <- cbind(comp_reg1_mens_ts, 
                           fitted = ts(mod_reg1_mens$fitted.values, 
                                       start = start_reg, frequency = frequency_mens))
colnames(comp_reg1_mens_ts) <- c("REG1_SAS", "REG1_RJD", "FITTED")

### Affichage ---------------------------------------------------------------

comp_reg1_mens_ts |> dygraphs::dygraph()


### Export et output -------------------------------------------

ch_out <- "./output/Regs_cjo_REG1_mens_by_rjd.xls"
xlsx::write.xlsx(x = reg1_rjd_mens_df, file = ch_out, row.names = FALSE)

ch_out <- "./output/REG1_mens_sas_vs_rjd3.xls"
xlsx::write.xlsx(x = comp_reg1_mens_df, file = ch_out, row.names = FALSE)


## Jeu trimestriel -------------------------------------------------------------

### Création du jeu de régresseur -------------------------------------------

wkd1_trim <- htd(frenchCalendar, frequency = frequency_trim, start = start_reg, 
                 length = frequency_trim * 40, groups = groups_reg1)
# objet TS
wkd1_trim_ts <- ts(wkd1_trim, start = start_reg, frequency = frequency_trim)
colnames(wkd1_trim_ts) <- "semaine"
# objet data.frame
reg1_rjd_trim_df <- cbind(date = zoo::as.Date(time(wkd1_trim_ts)),
                          as.data.frame(wkd1_trim_ts))


### Comparaison régresseur SAS ----------------------------------------------

# import reg1 classique 
reg1_sas_trim_df <- subset(reg_sas_trim_df, select = c(date, REG1_AC1))

# fichier de comparaison des régresseurs SAS et rjd+
comp_reg1_trim_df <- merge(reg1_sas_trim_df, reg1_rjd_trim_df, 
                           by = "date", all = TRUE)
head(comp_reg1_trim_df)

comp_reg1_trim_ts <- ts(subset(comp_reg1_trim_df, select = -date), 
                        start = start_reg, frequency = frequency_trim)

mod_reg1_trim <- lm(formula = REG1_AC1 ~ semaine, data = comp_reg1_trim_df)
comp_reg1_trim_ts <- cbind(comp_reg1_trim_ts, 
                           fitted = ts(mod_reg1_trim$fitted.values, 
                                       start = start_reg, frequency = frequency_trim))
colnames(comp_reg1_trim_ts) <- c("REG1_SAS", "REG1_RJD", "FITTED")

### Affichage ---------------------------------------------------------------

graph1 <- comp_reg1_trim_ts |> dygraphs::dygraph()


### Export et output -------------------------------------------

ch_out <- "./output/Regs_cjo_REG1_trim_by_rjd.xls"
xlsx::write.xlsx(x = reg1_rjd_trim_df, file = ch_out, row.names = FALSE)

ch_out <- "./output/REG1_trim_sas_vs_rjd3.xls"
xlsx::write.xlsx(x = comp_reg1_trim_df, file = ch_out, row.names = FALSE)


# REG6 --------------------------------------------------------------------
# JEU : REG6 classique pour comparer avec version historique
# reg6_rjd_df(wkd6) vs...

## Jeu mensuel -------------------------------------------------------------

### Création du jeu de régresseur -------------------------------------------

wkd6_mens <- htd(frenchCalendar, frequency = frequency_mens, start = start_reg, 
                 length = frequency_mens * 40, groups = groups_reg6)
# objet TS
wkd6_mens_ts <- ts(wkd6_mens, start = start_reg, frequency = frequency_mens)
colnames(wkd6_mens_ts) <- c("lun", "ma", "me", "jeu", "ven", "sam")
# objet data.frame
reg6_rjd_mens_df <- cbind(date = zoo::as.Date(time(wkd6_mens_ts)),
                          as.data.frame(wkd6_mens_ts))


### Comparaison régresseur SAS ----------------------------------------------

# import reg6 classique 
reg6_sas_mens_df <- subset(reg_sas_mens_df, select = 
                               c(date, REG6_AC1, REG6_AC2, 
                                 REG6_AC3, REG6_AC4, REG6_AC5, REG6_AC6))

# comparaison des régresseurs SAS et rjd+
comp_reg6_mens_df <- merge(reg6_sas_mens_df, reg6_rjd_mens_df, 
                           by = "date", all = TRUE)

head(comp_reg6_mens_df)

comp_reg6_mens_ts <- ts(subset(comp_reg6_mens_df, select = -date), 
                        start = start_reg, frequency = frequency_mens)

#Création de modèles linéaires
mod_reg6_mens <- lapply(X = 1:6, FUN = function(i) {
    jour <- c("lun", "ma", "me", "jeu", "ven", "sam")[i]
    lm(formula = paste0("REG6_AC", i, " ~ ", jour), data = comp_reg6_mens_df)
})

fitted_reg6_mens <- ts(sapply(mod_reg6_mens, FUN = `[[`, "fitted.values"), 
                       start = start_reg, frequency = frequency_mens)

comp_reg6_mens_ts <- cbind(comp_reg6_mens_ts, 
                           fitted_reg6_mens)
colnames(comp_reg6_mens_ts) <- c(paste0("REG6_AC", 1:6, "_SAS"), 
                                 paste0("REG6_AC", 1:6, "_RJD"), 
                                 paste0("REG6_AC", 1:6, "_fitted"))


### Affichage ---------------------------------------------------------------

lapply(1:6, FUN = function(i) {
    comp_reg6_mens_ts[, paste0("REG6_AC", i, c("_SAS", "_RJD", "_fitted"))] |> 
        dygraphs::dygraph()
})

### Export et output -------------------------------------------

ch_out <- "./output/Regs_cjo_REG6_mens_by_rjd.xls"
xlsx::write.xlsx(x = reg6_rjd_mens_df, file = ch_out, row.names = FALSE)

ch_out <- "./output/REG6_mens_sas_vs_rjd3.xls"
xlsx::write.xlsx(x = comp_reg6_mens_df, file = ch_out, row.names = FALSE)



## Jeu trimestriel -------------------------------------------------------------

### Création du jeu de régresseur -------------------------------------------

wkd6_trim <- htd(frenchCalendar, frequency = frequency_trim, start = start_reg, 
                 length = frequency_trim * 40, groups = groups_reg6)
# objet TS
wkd6_trim_ts <- ts(wkd6_trim, start = start_reg, frequency = frequency_trim)
colnames(wkd6_trim_ts) <- c("lun", "ma", "me", "jeu", "ven", "sam")
# objet data.frame
reg6_rjd_trim_df <- cbind(date = zoo::as.Date(time(wkd6_trim_ts)),
                          as.data.frame(wkd6_trim_ts))


### Comparaison régresseur SAS ----------------------------------------------

# import reg6 classique 
reg6_sas_trim_df <- subset(reg_sas_trim_df, select = 
                               c(date, REG6_AC1, REG6_AC2, 
                                 REG6_AC3, REG6_AC4, REG6_AC5, REG6_AC6))

# comparaison des régresseurs SAS et rjd+
comp_reg6_trim_df <- merge(reg6_sas_trim_df, reg6_rjd_trim_df, 
                           by = "date", all = TRUE)

head(comp_reg6_trim_df)

comp_reg6_trim_ts <- ts(subset(comp_reg6_trim_df, select = -date), 
                        start = start_reg, frequency = frequency_trim)

#Création de modèles linéaires
mod_reg6_trim <- lapply(X = 1:6, FUN = function(i) {
    jour <- c("lun", "ma", "me", "jeu", "ven", "sam")[i]
    lm(formula = paste0("REG6_AC", i, " ~ ", jour), data = comp_reg6_trim_df)
})

fitted_reg6_trim <- ts(sapply(mod_reg6_trim, FUN = `[[`, "fitted.values"), 
                       start = start_reg, frequency = frequency_trim)

comp_reg6_trim_ts <- cbind(comp_reg6_trim_ts, 
                           fitted_reg6_trim)
colnames(comp_reg6_trim_ts) <- c(paste0("REG6_AC", 1:6, "_SAS"), 
                                 paste0("REG6_AC", 1:6, "_RJD"), 
                                 paste0("REG6_AC", 1:6, "_fitted"))


### Affichage ---------------------------------------------------------------

lapply(1:6, FUN = function(i) {
    comp_reg6_trim_ts[, paste0("REG6_AC", i, c("_SAS", "_RJD", "_fitted"))] |> 
        dygraphs::dygraph()
})

### Export et output -------------------------------------------

ch_out <- "./output/Regs_cjo_REG6_trim_by_rjd.xls"
xlsx::write.xlsx(x = reg6_rjd_trim_df, file = ch_out, row.names = FALSE)

ch_out <- "./output/REG6_trim_sas_vs_rjd3.xls"
xlsx::write.xlsx(x = comp_reg6_trim_df, file = ch_out, row.names = FALSE)


# REG2 --------------------------------------------------------------------
# JEU : REG2 classique pour comparer avec version historique
# reg2_rjd_df(wkd6) vs...

## Jeu mensuel -------------------------------------------------------------

### Création du jeu de régresseur -------------------------------------------

wkd2_mens <- htd(frenchCalendar, frequency = frequency_mens, start = start_reg, 
                 length = frequency_mens * 40, groups = groups_reg2)
# objet TS
wkd2_mens_ts <- ts(wkd2_mens, start = start_reg, frequency = frequency_mens)
colnames(wkd2_mens_ts) <- c("semaine", "samedi")
# objet data.frame
reg2_rjd_mens_df <- cbind(date = zoo::as.Date(time(wkd2_mens_ts)),
                          as.data.frame(wkd2_mens_ts))


### Comparaison régresseur SAS ----------------------------------------------

# import reg2 classique 
reg2_sas_mens_df <- subset(reg_sas_mens_df, select = 
                               c(date, REG2_AC1, REG2_AC2))

# comparaison des régresseurs SAS et rjd+
comp_reg2_mens_df <- merge(reg2_sas_mens_df, reg2_rjd_mens_df, 
                           by = "date", all = TRUE)

head(comp_reg2_mens_df)

comp_reg2_mens_ts <- ts(subset(comp_reg2_mens_df, select = -date), 
                        start = start_reg, frequency = frequency_mens)

#Création de modèles linéaires
mod_reg2_mens <- lapply(X = 1:2, FUN = function(i) {
    jour <- c("semaine", "samedi")[i]
    lm(formula = paste0("REG2_AC", i, " ~ ", jour), data = comp_reg2_mens_df)
})

fitted_reg2_mens <- ts(sapply(mod_reg2_mens, FUN = `[[`, "fitted.values"), 
                       start = start_reg, frequency = frequency_mens)

comp_reg2_mens_ts <- cbind(comp_reg2_mens_ts, 
                           fitted_reg2_mens)
colnames(comp_reg2_mens_ts) <- c(paste0("REG2_AC", 1:2, "_SAS"), 
                                 paste0("REG2_AC", 1:2, "_RJD"), 
                                 paste0("REG2_AC", 1:2, "_fitted"))


### Affichage ---------------------------------------------------------------

lapply(1:2, FUN = function(i) {
    comp_reg2_mens_ts[, paste0("REG2_AC", i, c("_SAS", "_RJD", "_fitted"))] |> 
        dygraphs::dygraph()
})

### Export et output -------------------------------------------

ch_out <- "./output/Regs_cjo_REG2_mens_by_rjd.xls"
xlsx::write.xlsx(x = reg2_rjd_mens_df, file = ch_out, row.names = FALSE)

ch_out <- "./output/REG2_mens_sas_vs_rjd3.xls"
xlsx::write.xlsx(x = comp_reg2_mens_df, file = ch_out, row.names = FALSE)



## Jeu trimestriel -------------------------------------------------------------

### Création du jeu de régresseur -------------------------------------------

wkd2_trim <- htd(frenchCalendar, frequency = frequency_trim, start = start_reg, 
                 length = frequency_trim * 40, groups = groups_reg2)
# objet TS
wkd2_trim_ts <- ts(wkd2_trim, start = start_reg, frequency = frequency_trim)
colnames(wkd2_trim_ts) <- c("semaine", "samedi")
# objet data.frame
reg2_rjd_trim_df <- cbind(date = zoo::as.Date(time(wkd2_trim_ts)),
                          as.data.frame(wkd2_trim_ts))


### Comparaison régresseur SAS ----------------------------------------------

# import reg2 classique 
reg2_sas_trim_df <- subset(reg_sas_trim_df, select = 
                               c(date, REG2_AC1, REG2_AC2))

# comparaison des régresseurs SAS et rjd+
comp_reg2_trim_df <- merge(reg2_sas_trim_df, reg2_rjd_trim_df, 
                           by = "date", all = TRUE)

head(comp_reg2_trim_df)

comp_reg2_trim_ts <- ts(subset(comp_reg2_trim_df, select = -date), 
                        start = start_reg, frequency = frequency_trim)

#Création de modèles linéaires
mod_reg2_trim <- lapply(X = 1:2, FUN = function(i) {
    jour <- c("semaine", "samedi")[i]
    lm(formula = paste0("REG2_AC", i, " ~ ", jour), data = comp_reg2_trim_df)
})

fitted_reg2_trim <- ts(sapply(mod_reg2_trim, FUN = `[[`, "fitted.values"), 
                       start = start_reg, frequency = frequency_trim)

comp_reg2_trim_ts <- cbind(comp_reg2_trim_ts, 
                           fitted_reg2_trim)
colnames(comp_reg2_trim_ts) <- c(paste0("REG2_AC", 1:2, "_SAS"), 
                                 paste0("REG2_AC", 1:2, "_RJD"), 
                                 paste0("REG2_AC", 1:2, "_fitted"))


### Affichage ---------------------------------------------------------------

lapply(1:2, FUN = function(i) {
    comp_reg2_trim_ts[, paste0("REG2_AC", i, c("_SAS", "_RJD", "_fitted"))] |> 
        dygraphs::dygraph()
})

### Export et output -------------------------------------------

ch_out <- "./output/Regs_cjo_REG2_trim_by_rjd.xls"
xlsx::write.xlsx(x = reg2_rjd_trim_df, file = ch_out, row.names = FALSE)

ch_out <- "./output/REG2_trim_sas_vs_rjd3.xls"
xlsx::write.xlsx(x = comp_reg2_trim_df, file = ch_out, row.names = FALSE)


# REG5 --------------------------------------------------------------------
# JEU : REG5 classique pour comparer avec version historique
# reg5_rjd_df(wkd5) vs...

## Jeu mensuel -------------------------------------------------------------

### Création du jeu de régresseur -------------------------------------------

wkd5_mens <- htd(frenchCalendar, frequency = frequency_mens, start = start_reg, 
                 length = frequency_mens * 40, groups = groups_reg5)
# objet TS
wkd5_mens_ts <- ts(wkd5_mens, start = start_reg, frequency = frequency_mens)
colnames(wkd5_mens_ts) <- c("lun", "ma", "me", "jeu", "ven")
# objet data.frame
reg5_rjd_mens_df <- cbind(date = zoo::as.Date(time(wkd5_mens_ts)),
                          as.data.frame(wkd5_mens_ts))


### Comparaison régresseur SAS ----------------------------------------------

# import reg5 classique 
reg5_sas_mens_df <- subset(reg_sas_mens_df, select = 
                               c(date, REG5_AC1, REG5_AC2, 
                                 REG5_AC3, REG5_AC4, REG5_AC5))

# comparaison des régresseurs SAS et rjd+
comp_reg5_mens_df <- merge(reg5_sas_mens_df, reg5_rjd_mens_df, 
                           by = "date", all = TRUE)

head(comp_reg5_mens_df)

comp_reg5_mens_ts <- ts(subset(comp_reg5_mens_df, select = -date), 
                        start = start_reg, frequency = frequency_mens)

#Création de modèles linéaires
mod_reg5_mens <- lapply(X = 1:5, FUN = function(i) {
    jour <- c("lun", "ma", "me", "jeu", "ven")[i]
    lm(formula = paste0("REG5_AC", i, " ~ ", jour), data = comp_reg5_mens_df)
})

fitted_reg5_mens <- ts(sapply(mod_reg5_mens, FUN = `[[`, "fitted.values"), 
                       start = start_reg, frequency = frequency_mens)

comp_reg5_mens_ts <- cbind(comp_reg5_mens_ts, 
                           fitted_reg5_mens)
colnames(comp_reg5_mens_ts) <- c(paste0("REG5_AC", 1:5, "_SAS"), 
                                 paste0("REG5_AC", 1:5, "_RJD"), 
                                 paste0("REG5_AC", 1:5, "_fitted"))


### Affichage ---------------------------------------------------------------

lapply(1:5, FUN = function(i) {
    comp_reg5_mens_ts[, paste0("REG5_AC", i, c("_SAS", "_RJD", "_fitted"))] |> 
        dygraphs::dygraph()
})

### Export et output -------------------------------------------

ch_out <- "./output/Regs_cjo_REG5_mens_by_rjd.xls"
xlsx::write.xlsx(x = reg5_rjd_mens_df, file = ch_out, row.names = FALSE)

ch_out <- "./output/REG5_mens_sas_vs_rjd3.xls"
xlsx::write.xlsx(x = comp_reg5_mens_df, file = ch_out, row.names = FALSE)



## Jeu trimestriel -------------------------------------------------------------

### Création du jeu de régresseur -------------------------------------------

wkd5_trim <- htd(frenchCalendar, frequency = frequency_trim, start = start_reg, 
                 length = frequency_trim * 40, groups = groups_reg5)
# objet TS
wkd5_trim_ts <- ts(wkd5_trim, start = start_reg, frequency = frequency_trim)
colnames(wkd5_trim_ts) <- c("lun", "ma", "me", "jeu", "ven")
# objet data.frame
reg5_rjd_trim_df <- cbind(date = zoo::as.Date(time(wkd5_trim_ts)),
                          as.data.frame(wkd5_trim_ts))


### Comparaison régresseur SAS ----------------------------------------------

# import reg5 classique 
reg5_sas_trim_df <- subset(reg_sas_trim_df, select = 
                               c(date, REG5_AC1, REG5_AC2, 
                                 REG5_AC3, REG5_AC4, REG5_AC5))

# comparaison des régresseurs SAS et rjd+
comp_reg5_trim_df <- merge(reg5_sas_trim_df, reg5_rjd_trim_df, 
                           by = "date", all = TRUE)

head(comp_reg5_trim_df)

comp_reg5_trim_ts <- ts(subset(comp_reg5_trim_df, select = -date), 
                        start = start_reg, frequency = frequency_trim)

#Création de modèles linéaires
mod_reg5_trim <- lapply(X = 1:5, FUN = function(i) {
    jour <- c("lun", "ma", "me", "jeu", "ven")[i]
    lm(formula = paste0("REG5_AC", i, " ~ ", jour), data = comp_reg5_trim_df)
})

fitted_reg5_trim <- ts(sapply(mod_reg5_trim, FUN = `[[`, "fitted.values"), 
                       start = start_reg, frequency = frequency_trim)

comp_reg5_trim_ts <- cbind(comp_reg5_trim_ts, 
                           fitted_reg5_trim)
colnames(comp_reg5_trim_ts) <- c(paste0("REG5_AC", 1:5, "_SAS"), 
                                 paste0("REG5_AC", 1:5, "_RJD"), 
                                 paste0("REG5_AC", 1:5, "_fitted"))


### Affichage ---------------------------------------------------------------

lapply(1:5, FUN = function(i) {
    comp_reg5_trim_ts[, paste0("REG5_AC", i, c("_SAS", "_RJD", "_fitted"))] |> 
        dygraphs::dygraph()
})

### Export et output -------------------------------------------

ch_out <- "./output/Regs_cjo_REG5_trim_by_rjd.xls"
xlsx::write.xlsx(x = reg5_rjd_trim_df, file = ch_out, row.names = FALSE)

ch_out <- "./output/REG5_trim_sas_vs_rjd3.xls"
xlsx::write.xlsx(x = comp_reg5_trim_df, file = ch_out, row.names = FALSE)

