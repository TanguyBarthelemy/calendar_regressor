
# Initialisation ---------------------------------------------------------------

source("./R/0_set_up.R")


# REG1 -------------------------------------------------------------------------
# JEU : REG1 classique pour comparer avec version historique
# reg1_rjd_df(wkd1) vs...

## Jeu mensuel -----------------------------------------------------------------

### Création du jeu de régresseur ----------------------------------------------

# objet TS
wkd1_mens_ts <- htd(frenchCalendar, frequency = frequency_mens, 
                    start = start_reg, length = frequency_mens * 40, 
                    groups = groups_reg1, meanCorrection = TRUE, contrasts = FALSE)
colnames(wkd1_mens_ts) <- "reg1_rjd"
# objet data.frame
reg1_rjd_mens_df <- cbind(date = zoo::as.Date(time(wkd1_mens_ts)),
                          as.data.frame(wkd1_mens_ts))


### Comparaison régresseur SAS -------------------------------------------------

# import reg1 classique 
reg1_sas_mens_df <- subset(reg_sas_mens_df, select = c(date, REG1_AC1))

# Traitement des régresseurs
reg1_rjd_tab <- matrix(reg1_rjd_mens_df$reg1_rjd, ncol = 12, byrow = TRUE)
reg1_sas_tab <- matrix(reg1_sas_mens_df$REG1_AC1, ncol = 12, byrow = TRUE)

# fichier de comparaison des régresseurs SAS et rjd+
comp_reg1_mens_ts <- ts(as.data.frame(cbind(1990:2029, 
                                   reg1_rjd_tab[1:40, ], 
                                   reg1_sas_tab[1:40, ])), 
               start = 1990, frequency = 1)
colnames(comp_reg1_mens_ts) <- c("date", 
                        paste0(month.abb, "_RJD"), 
                        paste0(month.abb, "_SAS"))

#Création de modèles linéaires
mod_reg1_mens <- lapply(X = 1:12, FUN = function(i) {
    lm(formula = paste0(month.abb[i], c("_SAS", "_RJD"), collapse = " ~ "), 
       data = comp_reg1_mens_ts)
})

fitted_reg1_mens <- ts(sapply(mod_reg1_mens, FUN = `[[`, "fitted.values"), 
                       start = start_reg, frequency = 1)

comp_reg1_mens_ts <- cbind(comp_reg1_mens_ts, 
                           fitted_reg1_mens)

colnames(comp_reg1_mens_ts) <- c("date", 
                                 paste0(month.abb, "_RJD"), 
                                 paste0(month.abb, "_SAS"), 
                                 paste0(month.abb, "_fitted"))


### Affichage ------------------------------------------------------------------

lapply(1:12, FUN = function(i) {
    comp_reg1_mens_ts[, paste0(month.abb[i], c("_SAS", "_RJD", "_fitted"))] |> 
        dygraphs::dygraph()
})

lapply(mod_reg1_mens, FUN = \(x) summary(x)$r.squared)


### Export et output -------------------------------------------

ch_out <- "./output/Regs_cjo_REG1_mens_by_rjd.xls"
xlsx::write.xlsx(x = reg1_rjd_mens_df, file = ch_out, row.names = FALSE)

ch_out <- "./output/Regs_cjo_REG1_mens_by_sas.xls"
xlsx::write.xlsx(x = reg1_sas_mens_df, file = ch_out, row.names = FALSE)

ch_out <- "./output/REG1_mens_sas_vs_rjd3.xls"
xlsx::write.xlsx(x = comp_reg1_mens_ts, file = ch_out, row.names = FALSE)
