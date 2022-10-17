
source("./R/0_set_up.R")

# Etude pour le calendrier non corrigé ------------------------------------

## Préparation des données ------------------------------------

# used_calendar <- newCalendar
used_calendar <- frenchCalendar

wkd1_mens_ts <- htd(used_calendar, frequency = frequency_mens, 
                    start = start_reg, length = frequency_mens * 40, 
                    groups = groups_reg1, meanCorrection = FALSE, 
                    contrasts = FALSE)

# objet data.frame
reg1_rjd_mens_df <- cbind(date = zoo::as.Date(time(wkd1_mens_ts)),
                          as.data.frame(wkd1_mens_ts))
colnames(reg1_rjd_mens_df) <- c("date", "reg1_r0_rjd", "reg1_r1_rjd")
reg1_rjd_mens_df <- reg1_rjd_mens_df |> 
    dplyr::mutate(reg1_rjd = reg1_r1_rjd - 5/2 * reg1_r0_rjd)

### Etude de la création des WD ------------------------------------------------

# Qqs infos :
#   - PH = NbOffW
#   - TD = NbInW
#   - WD = NbW - 5/2 * NbWE
#   - WeekDays = NbInW - 5/2 * (NbOff + NbInWE)

wkd1_sas <- haven::read_sas("./output_calendar_sas/frenchcalendar.sas7bdat") |> 
    dplyr::mutate(
        NbOffWE = Off1 + Off7, 
        NbOffW = Off2 + Off3 + Off4 + Off5 + Off6, 
        NbOff = NbOffW + NbOffWE, 
        NbInWE = In1 + In7, 
        NbInW = In2 + In3 + In4 + In5 + In6, 
        NbIn = NbInW + NbInWE, 
        NbW = NbInW + NbOffW, 
        NbWE = NbInWE + NbOffWE)

wkd1_rjd <- reg1_rjd_mens_df

wkd1_rjd$year <- lubridate::year(wkd1_rjd$date)
wkd1_rjd$month <- lubridate::month(wkd1_rjd$date)

tot_wd <- merge(wkd1_sas, wkd1_rjd, by = c("year", "month"), all = TRUE)

tot2 <- tot_wd
tot2 <- tot2 |> 
    subset(!is.na(reg1_rjd)) |> 
    subset(!is.na(WD)) |> 
    dplyr::mutate(
        easter2 = (!EasterG == ""), 
        diff_rjd = purrr::map2_lgl(reg1_rjd, WeekDays, 
                                   .f = \(x, y) !isTRUE(all.equal(x, y)))) |> 
    dplyr::relocate(reg1_rjd, WD, .after = month) |> 
    dplyr::relocate(c(NbInWE, NbInW, NbIn, 
                      NbOffWE, NbOffW, NbOff), .after = WD)


tot2 |> subset(diff_rjd)
#Ici la différence se voit pour le mois de mai 2005.
#Pour une raison ou une autre le lundi de pentecote a été marqué 0.5 en Off et 0.5 en In


# Etude pour le calendrier corrigé ------------------------------------

## Préparation des données ------------------------------------

# used_calendar <- newCalendar
used_calendar <- frenchCalendar

wkd1_mens_ts_corr <- htd(used_calendar, frequency = frequency_mens, 
                         start = start_reg, length = frequency_mens * 40, 
                         groups = groups_reg1, meanCorrection = TRUE, 
                         contrasts = FALSE)
# objet data.frame
reg1_rjd_mens_df <- cbind(date = zoo::as.Date(time(wkd1_mens_ts_corr)),
                          as.data.frame(wkd1_mens_ts_corr))
colnames(reg1_rjd_mens_df) <- c("date", "reg1_r0_rjd_corr", "reg1_r1_rjd_corr")
reg1_rjd_mens_df <- reg1_rjd_mens_df |> 
    dplyr::mutate(reg1_rjd_corr = reg1_r1_rjd_corr - 5/2 * reg1_r0_rjd_corr)

### Etude de la création des WD ------------------------------------------------


wkd1_sas <- haven::read_sas("./output_calendar_sas/frenchcalendar_c.sas7bdat") |> 
    dplyr::mutate(
        NbOffWE = Off1 + Off7, 
        NbOffW = Off2 + Off3 + Off4 + Off5 + Off6, 
        NbOff = NbOffW + NbOffWE, 
        NbInWE = In1 + In7, 
        NbInW = In2 + In3 + In4 + In5 + In6, 
        NbIn = NbInW + NbInWE, 
        NbW = NbInW + NbOffW, 
        NbWE = NbInWE + NbOffWE)

wkd1_rjd <- reg1_rjd_mens_df

wkd1_rjd$year <- lubridate::year(wkd1_rjd$date)
wkd1_rjd$month <- lubridate::month(wkd1_rjd$date)

tot_wd <- merge(wkd1_sas, wkd1_rjd, by = c("year", "month"), all = TRUE)

tot2 <- tot_wd

mean_v <- c()
for (k in 1:12) {
    if (k == 5) {
        mod <- lm(reg1_rjd_corr ~ WeekDays, tot2 |> 
                      subset(month == 5 & year != 2005)) |> summary()
    } else {
        mod <- lm(reg1_rjd_corr ~ WeekDays, 
              tot2 |> subset(month == k)) |> summary()
    }
    
    print(mod$r.squared)
    print(mod$coefficients[, 1])
    mean_v <- c(mean_v, mod$coefficients[1, 1])
}

tot2 <- tot2 |> 
    subset(!is.na(reg1_rjd_corr)) |> 
    subset(!is.na(WD)) |> 
    dplyr::mutate(
        easter2 = (!EasterG == ""), 
        test_reg = mean_v[month] + WeekDays, 
        diff_rjd = purrr::map2_lgl(reg1_rjd_corr, test_reg, 
                                   .f = \(x, y) !isTRUE(all.equal(x, y)))) |> 
    dplyr::relocate(reg1_rjd_corr, WD, .after = month) |> 
    dplyr::relocate(c(NbInWE, NbInW, NbIn, 
                      NbOffWE, NbOffW, NbOff), .after = WD)

tot2 |> subset(diff_rjd) |> View()


