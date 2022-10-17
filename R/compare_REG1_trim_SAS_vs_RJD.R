
# Initialisation ----------------------------------------------------------

source("./Programmes/0_set_up.R")


# REG1 --------------------------------------------------------------------
# JEU : REG1 classique pour comparer avec version historique
# reg1_rjd_df(wkd1) vs...

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
