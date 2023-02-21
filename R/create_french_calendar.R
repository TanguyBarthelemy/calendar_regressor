
create_annual_calendar <- function(leap_year = FALSE) {
    month_length <- c(31L, 28L + leap_year, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)
    month_name_vect <- seq(as.Date("0-01-01"), as.Date("0-12-01"), by = "month") |> format("%B")
    
    annual_cal <- data.frame(month_name = rep(x = month_name_vect, times = month_length), 
                             month_number = rep(x = 1L:12L, times = month_length), 
                             leap_year = leap_year) |> 
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
    
    empty_cal <- do.call(rbind, purrr::map2(.x = year, .y = bissextile, 
                                            .f = \(x, y) cbind(year = x, create_annual_calendar(leap_year = y)))) |> 
        dplyr::mutate(
            week_number = as.integer(c(rep(seq_len(dplyr::n() %/% 7L), each = 7L), 
                                       rep(dplyr::n() %/% 7L, times = dplyr::n() %% 7L))), 
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
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_may_day <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            may_day = dplyr::case_when(
                year >= 1947L & month_number == 5L & month_day_number == 1L ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_victory_day <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            victory_day = dplyr::case_when(
                (year >= 1982L | (year %in% 1953L:1958L)) & month_number == 5L & month_day_number == 8L ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_fete_nationale <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            fete_nationale = dplyr::case_when(
                year >= 1880L & month_number == 7L & month_day_number == 14L ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_assumption <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            assumption = dplyr::case_when(
                year >= 1638L & month_number == 8L & month_day_number == 15L ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_all_saints_day <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            all_saints_day = dplyr::case_when(
                year >= 1801L & month_number == 11L & month_day_number == 1L ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_armistice <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            armistice = dplyr::case_when(
                year >= 1922L & month_number == 11L & month_day_number == 11L ~ TRUE, 
                TRUE ~ FALSE)
        )
    return(full_calendar)
}

add_christmas <- function(calendar) {
    full_calendar <- calendar |> 
        dplyr::mutate( 
            christmas = dplyr::case_when(
                year >= 1802L & month_number == 12L & month_day_number == 25L ~ TRUE, 
                TRUE ~ FALSE)
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
            In = Day - Off) |> 
        dplyr::group_by(week_number) |> 
        dplyr::mutate(
            v1 = max(weekday_name == "jeudi" & Off != 0L) & max(weekday_name == "vendredi" & In != 0L), 
            v2 = max(weekday_name == "mardi" & Off != 0L) & max(weekday_name == "lundi" & In != 0L)
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
    
    if (frequency %in% c(4L, 12L)) {
        message("Tu as choisi la fréquence ", c("mensuelle", "trimestrielle")[1L + (frequency == 4L)], ".")
        frequency_num <- frequency |> as.integer()
    } else if (frequency %in% c("mensuelle", "trimestrielle")) {
        frequency_num <- c(12L, 4L)[c("mensuelle", "trimestrielle") == frequency]
    } else if (frequency %in% c("monthly", "quaterly")) {
        frequency_num <- c(12L, 4L)[c("monthly", "quaterly") == frequency]
    } else { 
        stop("L'argument frequency doit être dans la liste suivante :", 
             paste0(c("mensuelle", "trimestrielle", "monthly", "quaterly", 4L, 12L), collapse = ", "))
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
                                                  month_name, temp_nb_day_tot, month_day_number, week_number, weekday_number),  \(x) sum(x, na.rm = TRUE)), 
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
            substr(type, 4L, 4L) == "0" ~ substr(type, 1L, 3L), 
            substr(type, 3L, 3L) == "0" ~ substr(type, 1L, 2L), 
            TRUE ~ type
        )) |> 
        tidyr::pivot_wider(names_from = type, 
                           values_from = c(val, mean, corr), 
                           names_glue = "{type}_{.value}") |> 
        dplyr::rename_with(.cols = dplyr::ends_with("val"), .fn = \(x) gsub(x = x, pattern = "_val", replacement = ""))
    
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
            LeapYear = (month_number == 2L) * (LeapYear - .25)) |> 
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

create_french_calendar <- function(
        start = 1950L, end = 2022L, starting_day = "dimanche", 
        summary = TRUE, by = "month", mean_correction = FALSE) {
    
    if (end < start) {
        stop("L'argument end doit se trouver après start.")
    }
    
    calendar <- create_empty_calendar(start = start, end = end, starting_day = starting_day) |> 
        add_french_publics_holydays()
    
    if (summary) {
        if (by %in% c("month", "mois")) {
            calendar <- calendar |> summarise_by_period(frequency = 12L)
        } else if (by %in% c("quarter", "trimestre")) {
            calendar <- calendar |> summarise_by_period(frequency = 4L)
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

replicate_sas_calendar <- function(
        start = 1950L, end = 2022L, starting_day = "dimanche", 
        summary = TRUE, by = "month") {
    calendar <- create_french_calendar(start = start, end = end, starting_day = starting_day, summary = TRUE, by = "month") |> 
        format_to_sas()
    
    return(calendar)
}


cal1 <- cal1 |> 
    dplyr::mutate(
        G1 = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr, 
        G0 = Off_corr + In1_corr + In7_corr, 
        REG1_SAS = G1 - G0 * 5 / 9, 
        REG1_RJD = G1 - G0 * 5 / 2, 
        Date = as.Date(paste(year, sprintf("%02.f", periode), "01", sep = "-"))) |> 
    dplyr::select(Date, REG1_SAS, REG1_RJD)

write.table(cal1, sep = ";", file = "./output/exp_reg1.csv", row.names = FALSE)

cal2 <- create_french_calendar(summary = FALSE, end = 1960)
cal3 <- replicate_sas_calendar()


