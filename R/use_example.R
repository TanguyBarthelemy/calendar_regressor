################################################################################
#####                         Exemples d'utilisation                       #####
################################################################################

source("./R/create_french_calendar.R")

cal1 <- create_french_calendar(
    summary = TRUE, 
    start = 1990, end = 2030, 
    starting_day = "lundi", by = "mois")

cal2 <- cal1 |>
    dplyr::mutate(
        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
        G0 = Off_corr + In1_corr + In7_corr,
        REG1_SAS = G1 - G0 * 5 / 9,
        REG1_RJD = G1 - G0 * 5 / 2,
        Date = as.Date(paste(
            year, sprintf("%02.f", month_number), "01", sep = "-"))) |>
    dplyr::select(Date, REG1_SAS, REG1_RJD)

write.table(cal2, sep = ";", file = "./output/exp_reg1.csv", 
            row.names = FALSE)
