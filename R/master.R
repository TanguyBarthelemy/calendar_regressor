################################################################################
#####                    Calcul des jeux de régresseurs                    #####
################################################################################

# Introduction -----------------------------------------------------------------

## Chargement des packages -----------------------------------------------------

library("rjd3toolkit")
library("dplyr")
library("openxlsx")


## Chargement des fonctions principales ----------------------------------------

source("./R/01_create_french_calendar.R")


## Chargement des jeux de données utiles ---------------------------------------

load(file = "./data/mean-rjd.RData")
load(file = "./data/mean-sas.RData")


## Création variable générales -------------------------------------------------

cal1 <- create_french_calendar(
    summary = FALSE,
    start = 1990L,
    end = 2030L
)

# Actual SAS regressors --------------------------------------------------------

regs_mens_sas <- read.csv("./regresseurs/reg_cjo_m.csv", sep = ";")

# Replicate Dominique method ---------------------------------------------------

cal_sas <- summarise_by_period(calendar = cal1, frequency = 12L, mean_table = mean_sas)

repr_regs_mens_sas <- cal_sas |>
    dplyr::mutate(
        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
        G0 = Off_corr + In1_corr + In7_corr,
        REG1_AC1 = G1 - G0 * 5 / 9,

        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
        G2 = In7_corr,
        G0 = Off_corr + In1_corr,
        REG2_AC1 = G1 - G0 * 5 / 8,
        REG2_AC2 = G2 - G0 * 1 / 8,

        G1 = In2_corr,
        G2 = In3_corr + In4_corr + In5_corr + In6_corr,
        G3 = In7_corr,
        G0 = Off_corr + In1_corr,
        REG3_AC1 = G1 - G0 * 1 / 8,
        REG3_AC2 = G2 - G0 * 4 / 8,
        REG3_AC3 = G3 - G0 * 1 / 8,

        G1 = In2_corr,
        G2 = In3_corr,
        G3 = In4_corr,
        G4 = In5_corr,
        G5 = In6_corr,
        G0 = Off_corr + In1_corr + In7_corr,
        REG5_AC1 = G1 - G0 * 1 / 9,
        REG5_AC2 = G2 - G0 * 1 / 9,
        REG5_AC3 = G3 - G0 * 1 / 9,
        REG5_AC4 = G4 - G0 * 1 / 9,
        REG5_AC5 = G5 - G0 * 1 / 9,

        G1 = In2_corr,
        G2 = In3_corr,
        G3 = In4_corr,
        G4 = In5_corr,
        G5 = In6_corr,
        G6 = In7_corr,
        G0 = Off_corr + In1_corr,
        REG6_AC1 = G1 - G0 * 1 / 8,
        REG6_AC2 = G2 - G0 * 1 / 8,
        REG6_AC3 = G3 - G0 * 1 / 8,
        REG6_AC4 = G4 - G0 * 1 / 8,
        REG6_AC5 = G5 - G0 * 1 / 8,
        REG6_AC6 = G6 - G0 * 1 / 8,

        date = as.Date(paste(
            year,
            sprintf("%02.f", month_number),
            "01",
            sep = "-"
        ))
    ) |>
    dplyr::select(date, dplyr::starts_with("REG"))

write.table(
    x = repr_regs_mens_sas,
    sep = ";",
    file = "./output/repr_regs_mens_sas.csv",
    row.names = FALSE
)


# Correct Dominique method -----------------------------------------------------

cal_sas_corrected <- summarise_by_period(calendar = cal1, frequency = 12L, mean_table = mean_monthly)

regs_mens_sas_corrected <- cal_sas_corrected |>
    dplyr::mutate(
        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
        G0 = Off_corr + In1_corr + In7_corr,
        REG1_AC1 = G1 - G0 * 5 / 9,

        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
        G2 = In7_corr,
        G0 = Off_corr + In1_corr,
        REG2_AC1 = G1 - G0 * 5 / 8,
        REG2_AC2 = G2 - G0 * 1 / 8,

        G1 = In2_corr,
        G2 = In3_corr + In4_corr + In5_corr + In6_corr,
        G3 = In7_corr,
        G0 = Off_corr + In1_corr,
        REG3_AC1 = G1 - G0 * 1 / 8,
        REG3_AC2 = G2 - G0 * 4 / 8,
        REG3_AC3 = G3 - G0 * 1 / 8,

        G1 = In2_corr,
        G2 = In3_corr,
        G3 = In4_corr,
        G4 = In5_corr,
        G5 = In6_corr,
        G0 = Off_corr + In1_corr + In7_corr,
        REG5_AC1 = G1 - G0 * 1 / 9,
        REG5_AC2 = G2 - G0 * 1 / 9,
        REG5_AC3 = G3 - G0 * 1 / 9,
        REG5_AC4 = G4 - G0 * 1 / 9,
        REG5_AC5 = G5 - G0 * 1 / 9,

        G1 = In2_corr,
        G2 = In3_corr,
        G3 = In4_corr,
        G4 = In5_corr,
        G5 = In6_corr,
        G6 = In7_corr,
        G0 = Off_corr + In1_corr,
        REG6_AC1 = G1 - G0 * 1 / 8,
        REG6_AC2 = G2 - G0 * 1 / 8,
        REG6_AC3 = G3 - G0 * 1 / 8,
        REG6_AC4 = G4 - G0 * 1 / 8,
        REG6_AC5 = G5 - G0 * 1 / 8,
        REG6_AC6 = G6 - G0 * 1 / 8,

        date = as.Date(paste(
            year,
            sprintf("%02.f", month_number),
            "01",
            sep = "-"
        ))
    ) |>
    dplyr::select(date, dplyr::starts_with("REG"))

write.table(
    x = regs_mens_sas_corrected,
    sep = ";",
    file = "./output/regs_mens_sas_corrected.csv",
    row.names = FALSE
)


# With rjd3 packages -----------------------------------------------------------

## Calendar creation -----------------------------------------------------------

french_calendar <- national_calendar(
    days = list(
        Bastille_day = fixed_day(7, 14), # Bastille Day
        Victory_day = fixed_day(5, 8, validity = list(start = "1982-05-08")), # Victoire 2nd guerre mondiale
        NEWYEAR = special_day("NEWYEAR"), # Nouvelle année
        CHRISTMAS = special_day("CHRISTMAS"), # Noël
        MAYDAY = special_day("MAYDAY"), # 1er mai
        EASTERMONDAY = special_day("EASTERMONDAY"), # Lundi de Pâques
        ASCENSION = special_day("ASCENSION"), # attention +39 et pas 40 jeudi ascension
        WHITMONDAY = special_day("WHITMONDAY"), # Lundi de Pentecôte (1/2 en 2005 a verif)
        ASSUMPTION = special_day("ASSUMPTION"), # Assomption
        ALLSAINTSDAY = special_day("ALLSAINTSDAY"), # Toussaint
        ARMISTICE = special_day("ARMISTICE")
    )
)


## Regressor set creation ------------------------------------------------------

### Regressor monthly ----------------------------------------------------------

regs_mens_rjd <- lapply(
    X = list(
        c(1L, 1L, 1L, 1L, 1L, 0L, 0L),
        c(1L, 1L, 1L, 1L, 1L, 2L, 0L),
        c(1L, 2L, 2L, 2L, 2L, 3L, 0L),
        c(1L, 2L, 3L, 4L, 5L, 0L, 0L),
        c(1L, 2L, 3L, 4L, 5L, 6L, 0L)
    ),
    FUN = \(group) {
        calendar_td(
            calendar = french_calendar,
            frequency = 12L,
            start = c(1990L, 1L),
            length = 492L,
            groups = group
        )
    }
) |>
    do.call(what = cbind)

colnames(regs_mens_rjd) <- sapply(
    c(1, 2, 3, 5, 6),
    \(k) paste0("REG", k, "_AC", 1:k)
) |>
    do.call(what = c)

regs_mens_rjd <- data.frame(
    date = regs_mens_rjd |> time() |> zoo::as.Date(),
    LY = lp_variable(
        frequency = 12L,
        start = c(1990L, 1L),
        length = 492L,
        type = "LeapYear"
    ),
    regs_mens_rjd
)


openxlsx::write.xlsx(x = regs_mens_rjd, file = "./output/regs_mens_rjd.xlsx")

regs_mens_rjd <- regs_mens_rjd |>
    mutate(date = as.character(date))

write.table(
    x = regs_mens_rjd,
    sep = ";",
    file = "./output/regs_mens_rjd.csv",
    row.names = FALSE
)

### Regressor quaterly ---------------------------------------------------------

regs_trim_rjd <- lapply(
    X = list(
        c(1L, 1L, 1L, 1L, 1L, 0L, 0L),
        c(1L, 1L, 1L, 1L, 1L, 2L, 0L),
        c(1L, 2L, 2L, 2L, 2L, 3L, 0L),
        c(1L, 2L, 3L, 4L, 5L, 0L, 0L),
        c(1L, 2L, 3L, 4L, 5L, 6L, 0L)
    ),
    FUN = \(group) {
        calendar_td(
            calendar = french_calendar,
            frequency = 4L,
            start = c(1990L, 1L),
            length = 164L,
            groups = group
        )
    }
) |>
    do.call(what = cbind)

colnames(regs_trim_rjd) <- sapply(
    c(1, 2, 3, 5, 6),
    \(k) paste0("REG", k, "_AC", 1:k)
) |>
    do.call(what = c)

regs_trim_rjd <- data.frame(
    date = regs_trim_rjd |> time() |> zoo::as.Date(),
    LY = lp_variable(
        frequency = 4L,
        start = c(1990L, 1L),
        length = 164,
        type = "LeapYear"
    ),
    regs_trim_rjd
)

write.xlsx(x = regs_trim_rjd, file = "./output/regs_trim_rjd.xlsx")

regs_trim_rjd <- regs_trim_rjd |>
    mutate(date = as.character(date))

write.table(
    x = regs_trim_rjd,
    sep = ";",
    file = "./output/regs_trim_rjd.csv",
    row.names = FALSE
)

# Replicate rjd3 package method ------------------------------------------------

repr_cal_rjd <- summarise_by_period(calendar = cal1, frequency = 12L, mean_table = mean_rjd)

repr_regs_mens_rjd <- repr_cal_rjd |>
    dplyr::mutate(
        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
        G0 = Off_corr + In1_corr + In7_corr,
        REG1_AC1 = G1 - G0 * 5 / 2,

        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
        G2 = In7_corr,
        G0 = Off_corr + In1_corr,
        REG2_AC1 = G1 - G0 * 5 / 1,
        REG2_AC2 = G2 - G0 * 1 / 1,

        G1 = In2_corr,
        G2 = In3_corr + In4_corr + In5_corr + In6_corr,
        G3 = In7_corr,
        G0 = Off_corr + In1_corr,
        REG3_AC1 = G1 - G0 * 1 / 1,
        REG3_AC2 = G2 - G0 * 4 / 1,
        REG3_AC3 = G3 - G0 * 1 / 1,

        G1 = In2_corr,
        G2 = In3_corr,
        G3 = In4_corr,
        G4 = In5_corr,
        G5 = In6_corr,
        G0 = Off_corr + In1_corr + In7_corr,
        REG5_AC1 = G1 - G0 * 1 / 2,
        REG5_AC2 = G2 - G0 * 1 / 2,
        REG5_AC3 = G3 - G0 * 1 / 2,
        REG5_AC4 = G4 - G0 * 1 / 2,
        REG5_AC5 = G5 - G0 * 1 / 2,

        G1 = In2_corr,
        G2 = In3_corr,
        G3 = In4_corr,
        G4 = In5_corr,
        G5 = In6_corr,
        G6 = In7_corr,
        G0 = Off_corr + In1_corr,
        REG6_AC1 = G1 - G0 * 1 / 1,
        REG6_AC2 = G2 - G0 * 1 / 1,
        REG6_AC3 = G3 - G0 * 1 / 1,
        REG6_AC4 = G4 - G0 * 1 / 1,
        REG6_AC5 = G5 - G0 * 1 / 1,
        REG6_AC6 = G6 - G0 * 1 / 1,

        date = as.Date(paste(
            year,
            sprintf("%02.f", month_number),
            "01",
            sep = "-"
        ))
    ) |>
    dplyr::select(date, dplyr::starts_with("REG"))

write.table(
    x = repr_regs_mens_rjd,
    sep = ";",
    file = "./output/repr_regs_mens_rjd.csv",
    row.names = FALSE
)
