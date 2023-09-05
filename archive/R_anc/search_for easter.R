################################################################################
#####                  Calcul des moyennes de long-terme                   #####
################################################################################


# Calcul de la moyenne des jours fériés liés à Paques --------------------------

## Create easter calendar ------------------------------------------------------

calendar_easter <- data.frame(year = 0:(5700000 - 1)) |>
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
        date_easter_meeus = paste0("2000-", sprintf("%02.f", month_easter_meeus), "-", sprintf("%02.f", day_easter_meeus)),
        weekday_easter_number = (6L + dplyr::row_number() - 1L) %% 7L + 1L
        # date_easter_meeus = as.Date(paste0("2000-", sprintf("%02.f", month_easter_meeus), "-", day_easter_meeus))
    ) |>
    dplyr::select(year, month_easter_meeus, day_easter_meeus, date_easter_meeus, weekday_easter_number)


## Plot the easter dates ---------------------------------------------------

calendar_easter$date_easter_meeus |>
    table() |>
    plot()


## Summarise easter holidays -----------------------------------------------

summary_table <- calendar_easter[, c("date_easter_meeus", "weekday_easter_number")] |>
    table() |>
    data.frame() |>
    dplyr::mutate(
        date = as.Date(date_easter_meeus),
        weekday_number = weekday_easter_number
    )

### All easter -----------------------------------------------------------------

all_easter_holidays <- rbind(
    summary_table |> dplyr::mutate(date = format(date + 1, format = "%B")),
    summary_table |> dplyr::mutate(date = format(date + 39, format = "%B")),
    summary_table |> dplyr::mutate(date = format(date + 50, format = "%B"))
) |>
    dplyr::summarise(count = sum(Freq) / 5700000, .by = c(date, weekday_number))

### Pure easter ----------------------------------------------------------------

# Remove other french holiday to keep only the pure easter holyday

pure_easter_holidays <- rbind(
    summary_table |>
        dplyr::mutate(date = date + 1) |>
        dplyr::filter(!date %in% c(as.Date("2000-05-01"), as.Date("2000-05-08"))),
    summary_table |>
        dplyr::mutate(date = date + 39) |>
        dplyr::filter(!date %in% c(as.Date("2000-05-01"), as.Date("2000-05-08"))),
    summary_table |>
        dplyr::mutate(date = date + 50) |>
        dplyr::filter(!date %in% c(as.Date("2000-05-01"), as.Date("2000-05-08")))
) |>
    dplyr::mutate(month_name = format(date, format = "%B")) |>
    dplyr::summarise(Off_easter = sum(Freq) / 5700000, .by = c(month_name, weekday_number))


# Calcul des moyennes autres jours fériés --------------------------------------

calendar_other_holidays <- create_empty_calendar(
    start = 2000, end = 2399,
    starting_day = "samedi"
) |>
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
        year, month_name, weekday_number,
        new_year, may_day, victory_day, fete_nationale, assumption,
        all_saints_day, armistice, christmas
    )

other_holidays <- calendar_other_holidays |>
    dplyr::summarise(
        Day = dplyr::n(),
        Off = sum(
            new_year, may_day, victory_day, fete_nationale,
            assumption, all_saints_day, armistice, christmas
        ),
        .by = c(year, month_name, weekday_number)
    ) |>
    dplyr::summarise(
        Day = mean(Day),
        Off = mean(Off),
        .by = c(month_name, weekday_number)
    )


# Réunion des différents types de jours fériés ----------------------------

all_holidays <- merge(other_holidays, pure_easter_holidays, all = TRUE) |>
    dplyr::rowwise() |>
    dplyr::mutate(
        Off_mean = sum(Off, Off_easter, na.rm = TRUE),
        Day_mean = Day,
        In_mean = Day_mean - Off_mean
    ) |>
    dplyr::select(
        month_name, weekday_number,
        Day_mean, Off_mean, In_mean
    ) |>
    tidyr::pivot_wider(
        names_from = weekday_number,
        values_from = c(Day_mean, Off_mean, In_mean),
        names_sep = ""
    )
