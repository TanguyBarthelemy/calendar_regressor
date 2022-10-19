################################################################################
#############################        SET UP        #############################
################################################################################


# Initialisation ----------------------------------------------------------

options(stringasfactors = FALSE)

library("rjd3modelling")
library("magrittr")


# Création du calendrier --------------------------------------------------
### French calendar regressors with rjd3modelling

newCalendar <- rjd3modelling::calendar.new()
frenchCalendar <- rjd3modelling::calendar.new()
calendar.fixedday(frenchCalendar, month = 7, day = 14)
# # att depuis 1982
calendar.fixedday(frenchCalendar, month = 5, day = 8, start = "1982-05-08")
calendar.easter(frenchCalendar,offset = 39) ## attention +39 et pas 40 jeudi ascension
calendar.holiday(frenchCalendar, "NEWYEAR") # Nouvelle année
calendar.holiday(frenchCalendar, "EASTERMONDAY") # Lundi de Pâques
calendar.holiday(frenchCalendar, "MAYDAY") # 1er mai
calendar.holiday(frenchCalendar, "WHITMONDAY") # Lundi de Pentecôte (1/2 en 2005 a verif)
calendar.holiday(frenchCalendar, "ASSUMPTION") # Assomption
calendar.holiday(frenchCalendar, "ALLSAINTSDAY") # Toussaint
calendar.holiday(frenchCalendar, "ARMISTICE")
calendar.holiday(frenchCalendar, "CHRISTMAS") # Noël


# Import des données ------------------------------------------------------

reg_sas_trim_df <- xlsx::read.xlsx("./data/reg_cjo_t.xls", sheetIndex = 1)
reg_sas_mens_df <- xlsx::read.xlsx("./data/reg_cjo_m.xls", sheetIndex = 1)
reg_sas_trim_df$date <- base::as.Date(reg_sas_trim_df$date)
reg_sas_mens_df$date <- base::as.Date(reg_sas_mens_df$Date)


# Paramètres des jeux de regresseurs --------------------------------------

groups_reg1 <- c(rep(1, 5), 0, 0)
# groups_reg1 <- c(rep(1, 6), 0)
groups_reg2 <- c(rep(1, 5), 2, 0)
groups_reg5 <- c(1:5, 0, 0)
groups_reg6 <- c(1:6, 0)
frequency_mens <- 12
frequency_trim <- 4
# start doit être de taille 2
start_reg <- c(1990, 1)
