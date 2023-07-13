
# Créer des régresseurs CJO avec rjd3

library("rjd3toolkit")

frenchCalendar <- national_calendar(days = list(
    fixed_day(7, 14), # Fete nationale
    fixed_day(5, 8, validity = list(start = "1982-05-08")), # Victoire 2nd guerre mondiale
    special_day("NEWYEAR"), # Nouvelle année
    special_day("CHRISTMAS"), # Noël
    special_day("MAYDAY"), # 1er mai
    special_day("EASTERMONDAY"), # Lundi de Pâques
    special_day("ASCENSION"), # attention +39 et pas 40 jeudi ascension
    special_day("WHITMONDAY"), # Lundi de Pentecôte (1/2 en 2005 a verif)
    special_day("ASSUMPTION"), # Assomption
    special_day("ALLSAINTSDAY"), # Toussaint
    special_day("ARMISTICE"))
)

# RegCJO

reg1 <- calendar_td(calendar = frenchCalendar, frequency = 12L, start = c(1990L, 1L), length = 480L, groups = c(1L, 1L, 1L, 1L, 1L, 0L, 0L))
reg_test <- calendar_td(calendar = frenchCalendar, frequency = 12L, start = c(1990L, 1L), length = 480L, groups = c(1L, 0L, 0L, 2L, 0L, 0L, 0L))

out <- cbind(
    date = reg1 |> time() |> zoo::as.Date(), 
    REG1_RJD = reg1 |> as.double()
)

write.table(out, sep = ";", file = "./output/REG1_RJD.csv", 
            row.names = FALSE)
