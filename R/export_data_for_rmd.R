# Appel fonctions calendar ------------------------------------------------

source("./R/01_create_french_calendar.R")

# Création fonction -------------------------------------------------------

reduce_calendar <- function(start = 0, end = 399) {
    if (start > end) stop("Erreur de date", call. = FALSE)
    return(dplyr::filter(.data = calendar_easter, year >= start, year <= end))
}

add_easter_holidays <- function(x) {
    summary_table <- x$date_easter_meeus |>
        table() |>
        data.frame() |>
        dplyr::mutate(
            date = as.Date(Var1)
        ) |>
        dplyr::select(-Var1)

    output <- rbind(
        dplyr::mutate(
            .data = summary_table,
            date = date + 1,
            weekday_number = 2
        ),
        dplyr::mutate(
            .data = summary_table,
            date = date + 39,
            weekday_number = 5
        ),
        dplyr::mutate(
            .data = summary_table,
            date = date + 50,
            weekday_number = 2
        )
    ) |>
        dplyr::mutate(
            month_number = as.integer(format(date, format = "%m")),
            quarter_number = as.integer((month_number - 1L) %/% 3L) + 1L
        )

    return(output)
}

summarise_by_easter <- function(x, freq = 12, name = "aha") {
    if (freq == 12) {
        x <- x |>
            dplyr::summarise(
                e = sum(Freq),
                .by = c(weekday_number, month_number)
            )
    } else if (freq == 4) {
        x <- x |>
            dplyr::summarise(
                e = sum(Freq),
                .by = c(weekday_number, quarter_number)
            )
    }
    x$e <- x$e * 3 / sum(x$e)
    colnames(x) <- c("periode", "type", name)
    return(x)
}

# Création calendar easter ------------------------------------------------

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
        h_correction = (n_cycle_meton + 11 * e_epacte + 22 * L_dominicale) %/%
            451,
        month_easter_meeus = (e_epacte + L_dominicale - 7 * h_correction + 114) %/% 31,
        day_easter_meeus = (e_epacte + L_dominicale - 7 * h_correction + 114) %%
            31 +
            1,
        date_easter_meeus = paste0(
            "2000-",
            sprintf("%02.f", month_easter_meeus),
            "-",
            sprintf("%02.f", day_easter_meeus)
        )
    ) |>
    dplyr::select(year, month_easter_meeus, day_easter_meeus, date_easter_meeus)

# Création calendar other holidays ------------------------------------------------

calendar_other_holidays <- create_empty_calendar(
    start = 1970,
    end = 2399,
    starting_day = "jeudi"
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
        year,
        month_number,
        quarter_number,
        weekday_number,
        new_year,
        may_day,
        victory_day,
        fete_nationale,
        assumption,
        all_saints_day,
        armistice,
        christmas
    )

save.image("./data/data4rmd.RData")
