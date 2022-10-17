
# Initialisation ----------------------------------------------------------

source("./Programmes/0_set_up.R")

# REG6 --------------------------------------------------------------------
# JEU : REG6 classique pour comparer avec version historique
# reg6_rjd_df(wkd6) vs...

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

