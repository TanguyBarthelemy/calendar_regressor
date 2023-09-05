################################################################################
#####                       Création des calendriers                       #####
################################################################################

load("./data/mean.RData")

create_annual_calendar <- function(leap_year = FALSE) {
    month_length <- c(31L, 28L + leap_year, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)
    month_name_vect <- seq(as.Date("0-01-01"), as.Date("0-12-01"), by = "month") |> format("%B")

    annual_cal <- data.frame(
        month_name = rep(x = month_name_vect, times = month_length),
        month_number = rep(x = 1L:12L, times = month_length),
        leap_year = leap_year
    ) |>
        dplyr::group_by(month_name) |>
        dplyr::mutate(month_day_number = dplyr::row_number())

    return(annual_cal)
}

create_empty_calendar <- function(start = 1950L, end = 2022L, starting_day = "dimanche") {
    starting_day <- tolower(starting_day)
    weekday_en <- c("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
    weekday_fr <- c("dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi")

    if (starting_day %in% 1L:7L) {
        message("Tu as choisi le ", weekday_fr[starting_day], " comme jour de début.")
        index_day <- starting_day
        starting_day <- weekday_fr[starting_day]
    } else if (starting_day %in% weekday_fr) {
        index_day <- (1L:7L)[weekday_fr == starting_day]
    } else if (starting_day %in% weekday_en) {
        index_day <- (1L:7L)[weekday_en == starting_day]
        starting_day <- weekday_fr[index_day]
    } else {
        stop("L'argument starting_day doit être dans la liste suivante :", paste0(c(weekday_fr, weekday_en, 1L:7L), collapse = ", "))
    }

    weekday_name_vect <- weekday_fr

    year <- start:end
    bissextile <- (year %% 400L == 0L) | (year %% 4L == 0L & year %% 100L != 0L)

    empty_cal <- do.call(rbind, purrr::map2(
        .x = year, .y = bissextile,
        .f = \(x, y) cbind(year = x, create_annual_calendar(leap_year = y))
    )) |>
        dplyr::mutate(
            week_number = as.integer(c(
                rep(seq_len(dplyr::n() %/% 7L), each = 7L),
                rep(dplyr::n() %/% 7L, times = dplyr::n() %% 7L)
            )),
            Date = as.Date(paste(year, sprintf("%02.f", month_number), sprintf("%02.f", month_day_number), sep = "-")),
            quarter_number = as.integer(((month_number - 1L) %/% 3L) + 1L)
        ) |>
        dplyr::group_by(year, month_name, month_number) |>
        dplyr::mutate(NbDays = dplyr::n()) |>
        dplyr::ungroup() |>
        dplyr::mutate(
            temp_nb_day_tot = seq_len(dplyr::n()) - 1L + index_day,
            weekday_number = (temp_nb_day_tot - 1L) %% 7L + 1L,
            weekday_name = weekday_name_vect[weekday_number]
        )

    return(empty_cal)
}

add_new_year <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::mutate(
            new_year = dplyr::case_when(
                year >= 1811L & month_number == 1L & month_day_number == 1L ~ TRUE,
                TRUE ~ FALSE
            )
        )
    return(full_calendar)
}

add_may_day <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::mutate(
            may_day = dplyr::case_when(
                year >= 1947L & month_number == 5L & month_day_number == 1L ~ TRUE,
                TRUE ~ FALSE
            )
        )
    return(full_calendar)
}

add_victory_day <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::mutate(
            victory_day = dplyr::case_when(
                (year >= 1982L | (year %in% 1953L:1958L)) & month_number == 5L & month_day_number == 8L ~ TRUE,
                TRUE ~ FALSE
            )
        )
    return(full_calendar)
}

add_fete_nationale <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::mutate(
            fete_nationale = dplyr::case_when(
                year >= 1880L & month_number == 7L & month_day_number == 14L ~ TRUE,
                TRUE ~ FALSE
            )
        )
    return(full_calendar)
}

add_assumption <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::mutate(
            assumption = dplyr::case_when(
                year >= 1638L & month_number == 8L & month_day_number == 15L ~ TRUE,
                TRUE ~ FALSE
            )
        )
    return(full_calendar)
}

add_all_saints_day <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::mutate(
            all_saints_day = dplyr::case_when(
                year >= 1801L & month_number == 11L & month_day_number == 1L ~ TRUE,
                TRUE ~ FALSE
            )
        )
    return(full_calendar)
}

add_armistice <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::mutate(
            armistice = dplyr::case_when(
                year >= 1922L & month_number == 11L & month_day_number == 11L ~ TRUE,
                TRUE ~ FALSE
            )
        )
    return(full_calendar)
}

add_christmas <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::mutate(
            christmas = dplyr::case_when(
                year >= 1802L & month_number == 12L & month_day_number == 25L ~ TRUE,
                TRUE ~ FALSE
            )
        )
    return(full_calendar)
}

compute_easter <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::mutate(
            n_cycle_meton = year %% 19L,
            c = year %/% 100L,
            u = year %% 100L,
            s_bissextile = c %/% 4L,
            t_bissextile = c %% 4L,
            p_cycle_proemptose = (c + 8L) %/% 25L,
            q_proemptose = (c - p_cycle_proemptose + 1L) %/% 3L,
            e_epacte = (19L * n_cycle_meton + c - s_bissextile - q_proemptose + 15L) %% 30L,
            b_bissextile = u %/% 4L,
            d_bissextile = u %% 4L,
            L_dominicale = (2L * t_bissextile + 2L * b_bissextile - e_epacte - d_bissextile + 32L) %% 7L,
            h_correction = (n_cycle_meton + 11L * e_epacte + 22L * L_dominicale) %/% 451L,
            month_easter = (e_epacte + L_dominicale - 7L * h_correction + 114L) %/% 31L,
            day_easter = (e_epacte + L_dominicale - 7L * h_correction + 114L) %% 31L + 1L
        ) |>
        dplyr::group_by(year) |>
        dplyr::mutate(
            easter = dplyr::case_when(
                year >= 1583L & month_day_number == day_easter & month_number == month_easter ~ TRUE,
                TRUE ~ FALSE
            )
        ) |>
        dplyr::ungroup() |>
        dplyr::select(
            -n_cycle_meton, -c, -u, -s_bissextile,
            -t_bissextile, -p_cycle_proemptose, -q_proemptose, -e_epacte,
            -b_bissextile, -d_bissextile, -L_dominicale, -h_correction
        )
    return(full_calendar)
}

add_easter_monday <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::group_by(year) |>
        dplyr::mutate(
            day_easter_monday = max(easter * temp_nb_day_tot + 1L),
            easter_monday = dplyr::case_when(
                year >= 1801L & temp_nb_day_tot == day_easter_monday ~ TRUE,
                TRUE ~ FALSE
            )
        ) |>
        dplyr::ungroup() |>
        dplyr::select(-day_easter_monday)
    return(full_calendar)
}

add_ascension <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::group_by(year) |>
        dplyr::mutate(
            day_ascension = max(easter * temp_nb_day_tot + 39L),
            ascension = dplyr::case_when(
                year >= 1801L & temp_nb_day_tot == day_ascension ~ TRUE,
                TRUE ~ FALSE
            )
        ) |>
        dplyr::ungroup() |>
        dplyr::select(-day_ascension)
    return(full_calendar)
}

add_whit_monday <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::group_by(year) |>
        dplyr::mutate(
            day_whit_monday = max(easter * temp_nb_day_tot + 50L),
            whit_monday = dplyr::case_when(
                year == 2005L & temp_nb_day_tot == day_whit_monday ~ .5,
                year >= 1886L & temp_nb_day_tot == day_whit_monday ~ 1,
                TRUE ~ 0
            )
        ) |>
        dplyr::ungroup() |>
        dplyr::select(-day_whit_monday)
    return(full_calendar)
}

add_in_off <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::mutate(
            Day = 1L,
            Off = pmin(new_year + may_day + victory_day + easter_monday +
                ascension + whit_monday + fete_nationale +
                assumption + all_saints_day + armistice +
                christmas, 1L),
            In = Day - Off
        )
    return(full_calendar)
}

add_bridges <- function(calendar) {
    full_calendar <- calendar |>
        dplyr::group_by(week_number) |>
        dplyr::mutate(
            v1 = max(weekday_name == "jeudi" & Off != 0L) & max(weekday_name == "vendredi" & In != 0L),
            v2 = max(weekday_name == "mardi" & Off != 0L) & max(weekday_name == "lundi" & In != 0L)
        ) |>
        dplyr::ungroup() |>
        dplyr::mutate(
            friday_bridge = v1 & weekday_name == "vendredi",
            monday_bridge = v2 & weekday_name == "lundi"
        ) |>
        dplyr::select(-v1, -v2)
    return(full_calendar)
}

add_french_publics_holidays <- function(calendar, bridges = FALSE) {
    full_calendar <- calendar |>
        add_new_year() |>
        add_may_day() |>
        add_victory_day() |>
        add_fete_nationale() |>
        add_assumption() |>
        add_all_saints_day() |>
        add_armistice() |>
        add_christmas() |>
        add_new_year() |>
        compute_easter() |>
        add_easter_monday() |>
        add_ascension() |>
        add_whit_monday() |>
        add_in_off() |>
        add_bridges()

    return(full_calendar)
}

summarise_by_period <- function(calendar,
                                frequency = "mensuelle",
                                mean_table = mean_monthly) {
    frequency <- tolower(frequency)

    if (frequency %in% c(4L, 12L)) {
        message("Tu as choisi la fréquence ", c("mensuelle", "trimestrielle")[1L + (frequency == 4L)], ".")
        frequency_num <- frequency |> as.integer()
    } else if (frequency %in% c("mensuelle", "trimestrielle")) {
        frequency_num <- c(12L, 4L)[c("mensuelle", "trimestrielle") == frequency]
    } else if (frequency %in% c("monthly", "quaterly")) {
        frequency_num <- c(12L, 4L)[c("monthly", "quaterly") == frequency]
    } else {
        stop(
            "L'argument frequency doit être dans la liste suivante :",
            paste0(c("mensuelle", "trimestrielle", "monthly", "quaterly", 4L, 12L), collapse = ", ")
        )
    }

    if (frequency_num == 4L) {
        calendar <- calendar |>
            dplyr::mutate(periode = quarter_number)
    } else if (frequency_num == 12L) {
        calendar <- calendar |>
            dplyr::mutate(periode = month_number)
    }

    cal_day_type <- calendar |>
        dplyr::select(
            year, periode, weekday_number,
            dplyr::starts_with(c("Day", "Off", "In"), ignore.case = FALSE)
        ) |>
        dplyr::summarise(dplyr::across(dplyr::everything(), sum),
            .by = c(year, periode, weekday_number)
        )

    cal_day_general <- cal_day_type |>
        dplyr::summarise(dplyr::across(dplyr::everything(), sum),
            .by = c(year, periode)
        ) |>
        dplyr::mutate(weekday_number = 0L)

    full_calendar <-
        rbind(cal_day_type, cal_day_general) |>
        merge(y = mean_table, by = c("periode", "weekday_number"), all = TRUE) |>
        dplyr::mutate(
            Day_corr = Day - Day_mean,
            Off_corr = Off - Off_mean,
            In_corr = In - In_mean,
        ) |>
        tidyr::pivot_wider(
            names_from = weekday_number,
            values_from = dplyr::starts_with(c("Day", "Off", "In"), ignore.case = FALSE)
        ) |>
        dplyr::arrange(year, periode) |>
        dplyr::rename_with(
            ~ substr(x = .x, start = 1, stop = nchar(.x) - 2),
            dplyr::ends_with("0")
        ) |>
        dplyr::rename_with(
            ~ gsub("(\\w)_(mean|corr)_(\\d)", "\\1\\3_\\2", .x, perl = TRUE),
            dplyr::matches("mean|corr")
        )

    full_calendar <- full_calendar |>
        dplyr::select(-periode)

    return(full_calendar)
}

create_french_calendar <- function(start = 1950L, end = 2022L, starting_day = "dimanche",
                                   summary = TRUE, by = "month") {
    if (end < start) {
        stop("L'argument end doit se trouver après start.")
    }

    calendar <- create_empty_calendar(start = start, end = end, starting_day = starting_day) |>
        add_french_publics_holidays()

    if (summary) {
        if (by %in% c("month", "mois")) {
            calendar <- calendar |> summarise_by_period(frequency = 12L, mean = mean_monthly)
        } else if (by %in% c("quarter", "trimestre")) {
            calendar <- calendar |> summarise_by_period(frequency = 4L, mean = mean_quaterly)
        } else {
            stop(
                "L'argument frequency doit être dans la liste suivante : ",
                paste0(c("mois", "trimestre", "month", "quater"), collapse = ", ")
            )
        }
    }

    return(calendar)
}

format_to_sas <- function(summarised_calendar, frequency = "mensuelle") {
    Sys.setlocale("LC_TIME", "English")

    full_calendar <- summarised_calendar |>
        dplyr::mutate(
            PH = Off2 + Off3 + Off4 + Off5 + Off6,
            WD = Day2 + Day3 + Day4 + Day5 + Day6 - 5 / 2 * (Day1 + Day7),
            TD1 = Day2 - Day1,
            TD2 = Day3 - Day1,
            TD3 = Day4 - Day1,
            TD4 = Day5 - Day1,
            TD5 = Day6 - Day1,
            TD6 = Day7 - Day1,
            TD = In2 + In3 + In4 + In5 + In6,
            WeekDays = TD - 5 / 2 * (PH + Day1 + Day7),
            Bridges = monday_bridge + friday_bridge,
            LeapYear = (month_number == 2L) * (LeapYear - .25)
        ) |>
        dplyr::rename(
            month = month_number,
            qtr = quarter_number,
            Monday_B = monday_bridge, Friday_B = friday_bridge
        ) |>
        dplyr::select(
            Date, year, month, qtr, NbDays,
            dplyr::starts_with("Day", ignore.case = FALSE),
            dplyr::starts_with("Off", ignore.case = FALSE),
            dplyr::starts_with("In", ignore.case = FALSE),
            dplyr::starts_with("TD", ignore.case = FALSE),
            WD, Monday_B, Friday_B, PH, Bridges,
            LeapYear, WeekDays, EasterG, -Day, -In, -Off
        ) |>
        dplyr::relocate(TD, .after = PH)

    return(full_calendar)
}

replicate_sas_calendar <- function(start = 1950L, end = 2022L, starting_day = "dimanche",
                                   summary = TRUE, by = "month") {
    calendar <- create_french_calendar(start = start, end = end, starting_day = starting_day, summary = TRUE, by = "month") |>
        format_to_sas()

    return(calendar)
}
