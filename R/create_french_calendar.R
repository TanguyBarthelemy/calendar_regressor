
create_annual_calendar <- function(leap_year = FALSE) {
    month_length <- c(31, 28 + leap_year, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
    month_name_vect <- seq(as.Date("0-01-01"), as.Date("0-12-01"), by = "month") |> format("%B")
    
    annual_cal <- data.frame(month_name = rep(x = month_name_vect, times = month_length), 
                             month_number = rep(x = 1:12, times = month_length), 
                             leap_year = leap_year) |> 
        dplyr::group_by(month_name) |>  
        dplyr::mutate(month_day_number = dplyr::row_number())
    
    return(annual_cal)
}

create_empty_calendar <- function(start = 1950, end = 2022, starting_day = "dimanche") {
    
    starting_day <- tolower(starting_day)
    weekday_en <- c("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
    weekday_fr <- c("dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi")
    
    if (starting_day %in% 1:7) {
        message("Tu as choisi le ", weekday_fr[starting_day], " comme jour de début.")
        index_day <- starting_day
        starting_day <- weekday_fr[starting_day]
    } else if (starting_day %in% weekday_fr) {
        index_day <- (1:7)[weekday_fr == starting_day]
    } else if (starting_day %in% weekday_en) {
        index_day <- (1:7)[weekday_en == starting_day]
        starting_day <- weekday_fr[index_day]
    } else { 
        stop("L'argument starting_day doit être dans la liste suivante :", paste0(c(weekday_fr, weekday_en, 1:7), collapse = ", "))
    }
    
    weekday_name_vect <- weekday_fr
    
    year <- start:end
    bissextile <- (year %% 400 == 0) | (year %% 4 == 0 & year %% 100 != 0)
    
    empty_cal <- do.call(rbind, purrr::map2(.x = year, .y = bissextile, 
                                            .f = \(x, y) cbind(year = x, create_annual_calendar(leap_year = y)))) |> 
        dplyr::mutate(
            week_number = as.integer(c(rep(seq_len(dplyr::n() %/% 7), each = 7), 
                            rep(dplyr::n() %/% 7, times = dplyr::n() %% 7))), 
            Date = as.Date(paste(year, sprintf("%02.f", month_number), sprintf("%02.f", month_day_number), sep = "-")), 
            quarter_number = as.integer(((month_number - 1) %/% 3) + 1)
        ) |> 
        dplyr::group_by(year, month_name, month_number) |> 
        dplyr::mutate(NbDays = dplyr::n()) |> 
        dplyr::ungroup() |> 
        dplyr::mutate(
            temp_nb_day_tot = 0:(dplyr::n() - 1) + index_day, 
            weekday_number = (temp_nb_day_tot - 1) %% 7 + 1, 
            weekday_name = weekday_name_vect[weekday_number]
        )
    
    return(empty_cal)
}

add_new_year <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            new_year = dplyr::case_when(
                year >= 1811 & month_number == 1 & month_day_number == 1 ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_may_day <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            may_day = dplyr::case_when(
                year >= 1947 & month_number == 5 & month_day_number == 1 ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_victory_day <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            victory_day = dplyr::case_when(
                (year >= 1982 | (year %in% 1953:1958)) & month_number == 5 & month_day_number == 8 ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_fete_nationale <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            fete_nationale = dplyr::case_when(
                year >= 1880 & month_number == 7 & month_day_number == 14 ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_assumption <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            assumption = dplyr::case_when(
                year >= 1638 & month_number == 8 & month_day_number == 15 ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_all_saints_day <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            all_saints_day = dplyr::case_when(
                year >= 1801 & month_number == 11 & month_day_number == 1 ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_armistice <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            armistice = dplyr::case_when(
                year >= 1922 & month_number == 11 & month_day_number == 11 ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_christmas <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            christmas = dplyr::case_when(
                year >= 1802 & month_number == 12 & month_day_number == 25 ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

compute_easter <- function(calendar) {
    full_calendar <- calendar |> 
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
            
            month_easter = (e_epacte + L_dominicale - 7 * h_correction + 114) %/% 31,
            day_easter = (e_epacte + L_dominicale - 7 * h_correction + 114) %% 31 + 1
        ) |> 
        dplyr::group_by(year) |> 
        dplyr::mutate(
            easter = dplyr::case_when(
                year >= 1583 & month_day_number == day_easter & month_number == month_easter ~ TRUE, 
                TRUE ~ FALSE)
        ) |> 
        dplyr::ungroup() |> 
        dplyr::select(-n_cycle_meton, -c, -u, -s_bissextile, 
                      -t_bissextile, -p_cycle_proemptose, -q_proemptose, -e_epacte, 
                      -b_bissextile, -d_bissextile, -L_dominicale, -h_correction)
    return(full_calendar)
}

add_easter_monday <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::group_by(year) |> 
        dplyr::mutate(
            day_easter_monday = max(easter * temp_nb_day_tot + 1), 
            easter_monday = dplyr::case_when(
                year >= 1801 & temp_nb_day_tot == day_easter_monday ~ TRUE, 
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
            day_ascension = max(easter * temp_nb_day_tot + 39), 
            ascension = dplyr::case_when(
                year >= 1801 & temp_nb_day_tot == day_ascension ~ TRUE, 
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
            day_whit_monday = max(easter * temp_nb_day_tot + 50), 
            whit_monday = dplyr::case_when(
                year == 2005 & temp_nb_day_tot == day_whit_monday ~ 0.5,
                year >= 1886 & temp_nb_day_tot == day_whit_monday ~ 1., 
                TRUE ~ 0.
            )
        ) |> 
        dplyr::ungroup() |> 
        dplyr::select(-day_whit_monday)
    return(full_calendar)
}

add_in_off <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate(
            Day = 1, 
            Off = pmin(new_year + may_day + victory_day + easter_monday + 
                           ascension + whit_monday + fete_nationale + 
                           assumption + all_saints_day + armistice + 
                           christmas, 1), 
            In = Day - Off) |> 
        dplyr::group_by(week_number) |> 
        dplyr::mutate(
            v1 = max(weekday_name == "jeudi" & Off != 0) & max(weekday_name == "vendredi" & In != 0), 
            v2 = max(weekday_name == "mardi" & Off != 0) & max(weekday_name == "lundi" & In != 0)
        ) |> 
        dplyr::ungroup() |> 
        dplyr::mutate(
            friday_bridge = v1 & weekday_name == "vendredi", 
            monday_bridge = v2 & weekday_name == "lundi") |> 
        dplyr::select(-v1, -v2) |> 
        dplyr::mutate(temp_weekday_number = weekday_number, 
                      temp_Day = Day, 
                      temp_In = In, 
                      temp_Off = Off) |>
        tidyr::pivot_wider(names_from = temp_weekday_number, values_from = c(Day, In, Off), names_sep = "", values_fill = 0L) |> 
        dplyr::rename(Day = temp_Day, 
                      In = temp_In, 
                      Off = temp_Off)
    return(full_calendar)
}

add_french_publics_holydays <- function(calendar) {
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
        add_in_off()
    return(full_calendar)
}

summarise_by_period <- function(calendar, frequency = "mensuelle") {
    
    frequency <- tolower(frequency)
    
    if (frequency %in% c(4, 12)) {
        message("Tu as choisi la fréquence ", c("mensuelle", "trimestrielle")[1 + (frequency == 4)], ".")
        frequency_num <- frequency |> as.integer()
    } else if (frequency %in% c("mensuelle", "trimestrielle")) {
        frequency_num <- c(12, 4)[c("mensuelle", "trimestrielle") == frequency]
    } else if (frequency %in% c("monthly", "quaterly")) {
        frequency_num <- c(12, 4)[c("monthly", "quaterly") == frequency]
    } else { 
        stop("L'argument frequency doit être dans la liste suivante :", 
             paste0(c("mensuelle", "trimestrielle", "monthly", "quaterly", 4, 12), collapse = ", "))
    }
    
    full_calendar <- calendar |> 
        dplyr::mutate(
            EasterG = dplyr::case_when(
                easter ~ format(Date, "%d%h%Y") |> toupper(), 
                TRUE ~ ""), 
            periode = dplyr::case_when(frequency_num == 4 ~ quarter_number, TRUE ~ month_number)) |> 
        dplyr::group_by(year, periode) |> 
        dplyr::summarise(dplyr::across(.cols = -c(NbDays, leap_year, Date, EasterG, easter, 
                                                  weekday_name, quarter_number, month_number, 
                                                  month_name, temp_nb_day_tot, month_day_number, week_number, weekday_number), sum, na.rm = TRUE), 
                         NbDays = length(NbDays), LeapYear = dplyr::first(leap_year), 
                         month_number = dplyr::first(month_number), 
                         quarter_number = dplyr::first(quarter_number), 
                         month_name = dplyr::first(month_name), 
                         EasterG = max(EasterG), 
                         easter = any(easter), 
                         Date = dplyr::first(Date)) |> 
        dplyr::ungroup()
    
    return(full_calendar)
}

add_means <- function(summarised_calendar) {
    full_calendar <- summarised_calendar |> 
        dplyr::rename(Day0 = Day, Off0 = Off, In0 = In) |>
        tidyr::pivot_longer(cols = dplyr::starts_with(c("Day", "Off", "In"), ignore.case = FALSE), 
                            names_to = c("type"), values_to = "val") |> 
        dplyr::group_by(periode, type) |> 
        dplyr::mutate(
            mean = mean(val, na.rm = TRUE), 
            corr = val - mean) |>  
        dplyr::ungroup() |> 
        dplyr::mutate(type = dplyr::case_when(
            substr(type, 4, 4) == "0" ~ substr(type, 1, 3), 
            substr(type, 3, 3) == "0" ~ substr(type, 1, 2), 
            TRUE ~ type
        )) |> 
        tidyr::pivot_wider(names_from = type, 
                           values_from = c(val, mean, corr), 
                           names_glue = "{type}_{.value}") |> 
        dplyr::rename_with(.cols = ends_with("val"), .fn = \(x) gsub(x = x, pattern = "_val", replacement = ""))
    
    return(full_calendar)
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
            WeekDays = TD - 5/2 * (PH + Day1 + Day7), 
            Bridges = monday_bridge + friday_bridge, 
            LeapYear = (month_number == 2) * (LeapYear - 0.25)) |> 
        dplyr::rename(month = month_number, 
                      qtr = quarter_number, 
                      Monday_B = monday_bridge, Friday_B = friday_bridge) |> 
        dplyr::select(Date, year, month, qtr, NbDays, 
                      dplyr::starts_with("Day", ignore.case = FALSE), 
                      dplyr::starts_with("Off", ignore.case = FALSE), 
                      dplyr::starts_with("In", ignore.case = FALSE), 
                      dplyr::starts_with("TD", ignore.case = FALSE), 
                      WD, Monday_B, Friday_B, PH, Bridges,
                      LeapYear, WeekDays, EasterG, -Day, -In, -Off) |> 
        dplyr::relocate(TD, .after = PH)
    
    return(full_calendar)
}

create_french_calendar <- function(start = 1950, end = 2022, starting_day = "dimanche", summary = TRUE, by = "month", mean_correction = FALSE) {
    
    if (end < start) {
        stop("L'argument end doit se trouver après start.")
    }
    
    calendar <- create_empty_calendar(start = start, end = end, starting_day = starting_day) |> 
        add_french_publics_holydays()
    
    if (summary) {
        if (by %in% c("month", "mois")) {
            calendar <- calendar |> summarise_by_period(frequency = 12)
        } else if (by %in% c("quarter", "trimestre")) {
            calendar <- calendar |> summarise_by_period(frequency = 4)
        } else {
            stop("L'argument frequency doit être dans la liste suivante :", 
                 paste0(c("mois", "trimestre", "month", "quater"), collapse = ", "))
        }
        
        if (mean_correction) {
            calendar <- calendar |> add_means()
        }
    }
    
    return(calendar)
}

replicate_sas_calendar <- function(start = 1950, end = 2022, starting_day = "dimanche", summary = TRUE, by = "month") {
    calendar <- create_french_calendar(start = start, end = end, starting_day = starting_day, summary = TRUE, by = "month") |> 
        format_to_sas()
    
    return(calendar)
}

cal1 <- create_french_calendar(end = 2000, by = "month", mean_correction = TRUE)
cal2 <- create_french_calendar(summary = FALSE, end = 1960)
cal3 <- replicate_sas_calendar()
