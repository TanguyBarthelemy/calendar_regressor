################################################################################
#####                         Exemples d'utilisation                       #####
################################################################################

source("./R/create_french_calendar.R")

cal1 <- create_french_calendar(
    summary = FALSE, 
    start = 1990L, end = 2030L, 
    starting_day = "lundi")

cal2 <- cal1 |> summarise_by_period(frequency = 12L, mean_table = mean_monthly)

cal3 <- cal2 |>
    dplyr::mutate(
        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
        G0 = Off_corr + In1_corr + In7_corr,
        REG1_SAS = G1 - G0 * 5 / 9,
        REG1_RJD = G1 - G0 * 5 / 2,
        Date = as.Date(paste(
            year, sprintf("%02.f", month_number), "01", sep = "-"))) |>
    dplyr::select(Date, REG1_SAS, REG1_RJD)

write.table(cal3, sep = ";", file = "./output/exp_reg1.csv", 
            row.names = FALSE)

# Repr RJD mean ----------------------------------------------------------------

mean_rjd <- mean_monthly |> dplyr::filter(weekday_number > 0L)
mean_rjd$Off_mean <- 0

mois_feries <- c(1L, 5L, 5L, 7L, 8L, 11L, 11L, 12L)
for (m in mois_feries) {
    mean_rjd[mean_rjd$month_number == m, "Off_mean"] <- mean_rjd[mean_rjd$month_number == m, "Off_mean"] + 1/7
}

length_mois <- c(31L, 28L, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)
for (m in 1L:12L) {
    mean_rjd[mean_rjd$month_number == m, "Day_mean"] <- length_mois[m] / 7
}

load("./data/easter_mean_rjd.RData")
mean_rjd[mean_rjd$month_number %in% 3:4 & mean_rjd$weekday_number == 2, "Off_mean"] <- mean_easter_monday
mean_rjd[mean_rjd$month_number %in% 5:6 & mean_rjd$weekday_number == 2, "Off_mean"] <- mean_whit_monday
mean_rjd[mean_rjd$month_number %in% 4:6 & mean_rjd$weekday_number == 5, "Off_mean"] <- mean_ascension

mean_rjd$In_mean <- mean_rjd$Day_mean - mean_rjd$Off_mean

mean_rjd <- mean_rjd |> 
    rbind(
        mean_rjd |> dplyr::summarise(
            weekday_number = 0, 
            Off_mean = sum(Off_mean), 
            Day_mean = sum(Day_mean), 
            In_mean = sum(In_mean),
            periode = dplyr::first(periode),
            .by = "month_number")
    )

cal2_bis <- cal1 |> summarise_by_period(frequency = 12L, mean_table = mean_rjd)

cal3_bis <- cal2_bis |>
    dplyr::mutate(
        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
        G0 = Off_corr + In1_corr + In7_corr,
        REG1_RJD = G1 - G0 * 5 / 2,
        Date = as.Date(paste(
            year, sprintf("%02.f", month_number), "01", sep = "-"))) |>
    dplyr::select(Date, REG1_RJD)

write.table(cal3_bis, sep = ";", file = "./output/repr_rjd.csv", 
            row.names = FALSE)
