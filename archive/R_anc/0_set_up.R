################################################################################
#############################        SET UP        #############################
################################################################################


# Initialisation ----------------------------------------------------------

options(stringasfactors = FALSE)

library("rjd3modelling")
library("magrittr")


# Création du calendrier --------------------------------------------------
### French calendar regressors with rjd3modelling

new_calendar <- rjd3modelling::calendar.new()
french_calendar <- rjd3modelling::calendar.new()
calendar.fixedday(french_calendar, month = 7, day = 14)
# # att depuis 1982
calendar.fixedday(french_calendar, month = 5, day = 8, start = "1982-05-08")
calendar.easter(french_calendar, offset = 39) ## attention +39 et pas 40 jeudi ascension
calendar.holiday(french_calendar, "NEWYEAR") # Nouvelle année
calendar.holiday(french_calendar, "EASTERMONDAY") # Lundi de Pâques
calendar.holiday(french_calendar, "MAYDAY") # 1er mai
calendar.holiday(french_calendar, "WHITMONDAY") # Lundi de Pentecôte (1/2 en 2005 a verif)
calendar.holiday(french_calendar, "ASSUMPTION") # Assomption
calendar.holiday(french_calendar, "ALLSAINTSDAY") # Toussaint
calendar.holiday(french_calendar, "ARMISTICE")
calendar.holiday(french_calendar, "CHRISTMAS") # Noël

rjd3modelling::htd(
    calendar = french_calendar, frequency = 12, start = c(1990, 1), length = 490,
    groups = c(1:6, 0), meanCorrection = TRUE, contrasts = TRUE, holiday = 7
) |> window(start = 2025)
