################################################################################
#####                    Calcul des jeux de régresseurs                    #####
################################################################################


# Introduction ------------------------------------------------------------


## Chargement des packages -------------------------------------------------

library("rjd3toolkit")


## Chargement des fonctions principales ------------------------------------

source("./R/01_create_french_calendar.R")


## Chargement des jeux de données utiles -----------------------------------

load(file = "./data/mean-rjd.RData")
load(file = "./data/mean-sas.RData")


## Création variable générales ---------------------------------------------

cal1 <- create_french_calendar(
    summary = FALSE,
    start = 1990L, end = 2031L,
    starting_day = "lundi"
)


# Replicate Dominique method ----------------------------------------------

cal_sas <- cal1 |> summarise_by_period(frequency = 12L, mean_table = mean_sas)

reg1_sas <- cal_sas |>
    dplyr::mutate(
        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
        G0 = Off_corr + In1_corr + In7_corr,
        REG1_SAS = G1 - G0 * 5 / 9,
        Date = as.Date(paste(
            year, sprintf("%02.f", month_number), "01",
            sep = "-"
        ))
    ) |>
    dplyr::select(Date, REG1_SAS)

write.table(reg1_sas,
    sep = ";", file = "./output/repr_REG1_sas.csv",
    row.names = FALSE
)


# Correct Dominique method ------------------------------------------------

cal_sas <- cal1 |> summarise_by_period(frequency = 12L, mean_table = mean_monthly)

reg1_sas <- cal_sas |>
    dplyr::mutate(
        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
        G0 = Off_corr + In1_corr + In7_corr,
        REG1_SAS = G1 - G0 * 5 / 9,
        Date = as.Date(paste(
            year, sprintf("%02.f", month_number), "01",
            sep = "-"
        ))
    ) |>
    dplyr::select(Date, REG1_SAS)

write.table(reg1_sas,
    sep = ";", file = "./output/repr_REG1_sas.csv",
    row.names = FALSE
)


# With rjd3 packages ------------------------------------------------------


## Calendar creation ---------------------------------------------------------

french_calendar <- national_calendar(days = list(
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
    special_day("ARMISTICE")
))


## Regressor set creation ---------------------------------------------------------

reg1 <- calendar_td(
    calendar = french_calendar,
    frequency = 12L,
    start = c(1990L, 1L),
    length = 480L,
    groups = c(1L, 1L, 1L, 1L, 1L, 0L, 0L)
)

reg1 <- data.frame(
    date = reg1 |> time() |> zoo::as.Date(),
    REG1_RJD = reg1 |> as.double()
)

write.table(reg1,
    sep = ";", file = "./output/REG1_by_rjd.csv",
    row.names = FALSE
)


# Replicate rjd3 package method -------------------------------------------

cal_rjd <- cal1 |> summarise_by_period(frequency = 12L, mean_table = mean_rjd)

reg1_rjd <- cal_rjd |>
    dplyr::mutate(
        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
        G0 = Off_corr + In1_corr + In7_corr,
        REG1_RJD = G1 - G0 * 5 / 2,
        Date = as.Date(paste(
            year, sprintf("%02.f", month_number), "01",
            sep = "-"
        ))
    ) |>
    dplyr::select(Date, REG1_RJD)

write.table(reg1_rjd,
    sep = ";", file = "./output/repr_REG1_rjd.csv",
    row.names = FALSE
)
