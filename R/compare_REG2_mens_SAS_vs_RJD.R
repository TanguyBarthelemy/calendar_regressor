
# Initialisation ----------------------------------------------------------

source("./Programmes/0_set_up.R")

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
