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
calendar.easter(frenchCalendar, offset = 39) ## attention +39 et pas 40 jeudi ascension
calendar.holiday(frenchCalendar, "NEWYEAR") # Nouvelle année
calendar.holiday(frenchCalendar, "EASTERMONDAY") # Lundi de Pâques
calendar.holiday(frenchCalendar, "MAYDAY") # 1er mai
calendar.holiday(frenchCalendar, "WHITMONDAY") # Lundi de Pentecôte (1/2 en 2005 a verif)
calendar.holiday(frenchCalendar, "ASSUMPTION") # Assomption
calendar.holiday(frenchCalendar, "ALLSAINTSDAY") # Toussaint
calendar.holiday(frenchCalendar, "ARMISTICE")
calendar.holiday(frenchCalendar, "CHRISTMAS") # Noël

rjd3modelling::htd(
    calendar = frenchCalendar, frequency = 12, start = c(1990, 1), length = 490,
    groups = c(1:6, 0), meanCorrection = TRUE, contrasts = TRUE, holiday = 7
) |> window(start = 2025)
