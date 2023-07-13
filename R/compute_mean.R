################################################################################
#####                  Calcul des moyennes de long-terme                   #####
################################################################################

source("./R/create_french_calendar.R")

# Calcul de la moyenne des jours fériés liés à Paques --------------------------

## Create easter calendar ------------------------------------------------------

calendar_easter <- data.frame(year = 0:(5700000 - 1)) |>
    # calendar_easter <- data.frame(year = 1990:4789) |> 
    dplyr::mutate(
        n_cycle_meton = year %% 19, 
        c = year %/% 100, 
        u = year %% 100, 
        s_bissextile = c %/% 4,
        t_bissextile = c %% 4,
        p_cycle_proemptose = (c + 8) %/% 25,
        q_proemptose = (c - p_cycle_proemptose + 1) %/% 3, 
        e_epacte = (19 * n_cycle_meton + c - s_bissextile - q_proemptose + 15) %% 30, 
        b_bissextile = u %/% 4, 
        d_bissextile = u %% 4, 
        L_dominicale = (2 * t_bissextile + 2 * b_bissextile - e_epacte - d_bissextile + 32) %% 7, 
        h_correction = (n_cycle_meton + 11 * e_epacte + 22 * L_dominicale) %/% 451,
        
        month_easter_meeus = (e_epacte + L_dominicale - 7 * h_correction + 114) %/% 31,
        day_easter_meeus = (e_epacte + L_dominicale - 7 * h_correction + 114) %% 31 + 1, 
        
        date_easter_meeus = paste0("2000-", sprintf("%02.f", month_easter_meeus), "-", sprintf("%02.f", day_easter_meeus))
        # date_easter_meeus = as.Date(paste0("2000-", sprintf("%02.f", month_easter_meeus), "-", day_easter_meeus))
    ) |> 
    dplyr::select(year, month_easter_meeus, day_easter_meeus, date_easter_meeus)


## Plot the easter dates -------------------------------------------------------

easter_occurence <- calendar_easter$date_easter_meeus |> table()
easter_occurence |> plot()


## Summarise easter holidays ---------------------------------------------------

### Easter table ---------------------------------------------------------------

summary_table <- calendar_easter$date_easter_meeus |> 
    table() |> 
    data.frame() |> 
    dplyr::mutate(date = as.Date(Var1)) |> 
    dplyr::select(-Var1)

summary_table <- rbind(
    # summary_table |> dplyr::mutate(
    #     month_number = date, 
    #     weekday_number = 1), 
    summary_table |> dplyr::mutate(
        date = date + 1, 
        weekday_number = 2), 
    summary_table |> dplyr::mutate(
        date = date + 39, 
        weekday_number = 5), 
    summary_table |> dplyr::mutate(
        date = date + 50, 
        weekday_number = 2)
) |> dplyr::mutate(
    month_number = format(date, format = "%m") |> as.integer(), 
    quarter_number = ((month_number - 1L) %/% 3L) |> as.integer() + 1L)

### Calcul des moyennes autres jours fériés ------------------------------------

calendar_other_holidays <- create_empty_calendar(start = 2000, end = 2399, 
                                                 starting_day = "samedi") |> 
    add_new_year() |> 
    add_may_day() |> 
    add_victory_day() |> 
    add_fete_nationale() |> 
    add_assumption() |> 
    add_all_saints_day() |> 
    add_armistice() |> 
    add_christmas() |> 
    add_new_year() |> 
    dplyr::select(
        year, month_number, quarter_number, weekday_number,
        new_year, may_day, victory_day, fete_nationale, assumption, 
        all_saints_day, armistice, christmas)

### Monthly --------------------------------------------------------------------

#### All easter ----------------------------------------------------------------

all_easter_holidays_monthly <- summary_table |> 
    dplyr::summarise(Off_easter = sum(Freq) / 5700000, #(4789 - 1989), 
                     .by = c(month_number, weekday_number))

#### Pure easter ---------------------------------------------------------------

# Remove other french holiday to keep only the pure easter holyday

pure_easter_holidays_monthly <- summary_table |> 
    dplyr::filter(!date %in% c(as.Date("2000-05-01"), 
                               as.Date("2000-05-08"))) |> 
    dplyr::summarise(Off_easter = sum(Freq) / 5700000, #(4789 - 1989), 
                     .by = c(month_number, weekday_number))

#### Other holydays ------------------------------------------------------------

other_holidays_monthly <- calendar_other_holidays |> 
    dplyr::summarise(
        Day = dplyr::n(), 
        Off = sum(new_year, may_day, victory_day, fete_nationale, 
                  assumption, all_saints_day, armistice, christmas), 
        .by = c(year, month_number, weekday_number)
    ) |> 
    dplyr::summarise(Day = mean(Day),
                     Off = mean(Off),
                     .by = c(month_number, weekday_number))


#### Réunion des différents types de jours fériés ------------------------------

all_holidays_type_monthly <- merge(other_holidays_monthly, 
                                   pure_easter_holidays_monthly, all = TRUE) |> 
    dplyr::mutate(
        Off_mean = ifelse(is.na(Off_easter), Off, Off + Off_easter), 
        Day_mean = Day, 
        In_mean = Day_mean - Off_mean) |> 
    dplyr::select(month_number, weekday_number, 
                  Day_mean, Off_mean, In_mean)

all_holidays_general_monthly <- all_holidays_type_monthly |> 
    dplyr::summarise(dplyr::across(dplyr::everything(), sum), 
                     .by = month_number) |> 
    dplyr::mutate(weekday_number = 0L)

all_holidays_monthly <- rbind(
    all_holidays_type_monthly, 
    all_holidays_general_monthly)


### quarterly ------------------------------------------------------------------

#### All easter ----------------------------------------------------------------

all_easter_holidays_quarterly <- summary_table |> 
    dplyr::summarise(Off_easter = sum(Freq) / 5700000, #(4789 - 1989), 
                     .by = c(quarter_number, weekday_number))

#### Pure easter ---------------------------------------------------------------

# Remove other french holiday to keep only the pure easter holyday

pure_easter_holidays_quarterly <- summary_table |> 
    dplyr::filter(!date %in% c(as.Date("2000-05-01"), 
                               as.Date("2000-05-08"))) |> 
    dplyr::summarise(Off_easter = sum(Freq) / 5700000, #(4789 - 1989), 
                     .by = c(quarter_number, weekday_number))

#### Other holydays ------------------------------------------------------------

other_holidays_quarterly <- calendar_other_holidays |> 
    dplyr::summarise(
        Day = dplyr::n(), 
        Off = sum(new_year, may_day, victory_day, fete_nationale, 
                  assumption, all_saints_day, armistice, christmas), 
        .by = c(year, quarter_number, weekday_number)
    ) |> 
    dplyr::summarise(Day = mean(Day),
                     Off = mean(Off),
                     .by = c(quarter_number, weekday_number))


#### Réunion des différents types de jours fériés ------------------------------

all_holidays_type_quarterly <- merge(other_holidays_quarterly, 
                                     pure_easter_holidays_quarterly, 
                                     all = TRUE) |> 
    dplyr::mutate(
        Off_mean = ifelse(is.na(Off_easter), Off, Off + Off_easter), 
        Day_mean = Day, 
        In_mean = Day_mean - Off_mean) |> 
    dplyr::select(quarter_number, weekday_number, 
                  Day_mean, Off_mean, In_mean)

all_holidays_general_quarterly <- all_holidays_type_quarterly |> 
    dplyr::summarise(dplyr::across(dplyr::everything(), sum), 
                     .by = quarter_number) |> 
    dplyr::mutate(weekday_number = 0L)

all_holidays_quarterly <- rbind(
    all_holidays_type_quarterly, 
    all_holidays_general_quarterly)

## Export mean -----------------------------------------------------------------

mean_monthly <- all_holidays_monthly |> 
    dplyr::mutate(periode = month_number)
mean_quarterly <- all_holidays_quarterly |> 
    dplyr::mutate(periode = quarter_number)

save(mean_monthly, mean_quarterly, file = "./data/mean.RData")
easter_occurence |> 
    write.table("output/easter_occurence.csv", quote = FALSE, 
                row.names = FALSE, sep = ";")
