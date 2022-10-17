
# Initialisation ----------------------------------------------------------

source("./Programmes/0_set_up.R")


# REG5 --------------------------------------------------------------------
# JEU : REG5 classique pour comparer avec version historique
# reg5_rjd_df(wkd5) vs...

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
