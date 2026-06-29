# Appel fonctions calendar ------------------------------------------------

source("./R/01_create_french_calendar.R")

# Création fonction -------------------------------------------------------

reduce_calendar <- function(start = 0L, end = 399L) {
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
            date = date + 1L,
            weekday_number = 2L
        ),
        dplyr::mutate(
            .data = summary_table,
            date = date + 39L,
            weekday_number = 5L
        ),
        dplyr::mutate(
            .data = summary_table,
            date = date + 50L,
            weekday_number = 2L
        )
    ) |>
        dplyr::mutate(
            month_number = as.integer(format(date, format = "%m")),
            quarter_number = as.integer((month_number - 1L) %/% 3L) + 1L
        )

    return(output)
}

summarise_by_easter <- function(x, freq = 12L, name = "aha") {
    if (freq == 12L) {
        x <- x |>
            dplyr::summarise(
                e = sum(Freq),
                .by = c(weekday_number, month_number)
            )
    } else if (freq == 4L) {
        x <- x |>
            dplyr::summarise(
                e = sum(Freq),
                .by = c(weekday_number, quarter_number)
            )
    }
    x$e <- x$e * 3L / sum(x$e)
    colnames(x) <- c("periode", "type", name)
    return(x)
}

# Création calendar easter ------------------------------------------------

calendar_easter <- data.frame(year = seq_len(5700000L) - 1L) |>
    # calendar_easter <- data.frame(year = 1990:4789) |>
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
        h_correction = (n_cycle_meton + 11L * e_epacte + 22L * L_dominicale) %/%
            451L,
        month_easter_meeus = (e_epacte + L_dominicale - 7L * h_correction + 114L) %/% 31L,
        day_easter_meeus = (e_epacte + L_dominicale - 7L * h_correction + 114L) %%
            31L +
            1L,
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
    start = 1970L,
    end = 2399L,
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
