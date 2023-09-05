################################################################################
#####         Calcul des moyennes de long-terme divergentes en SAS         #####
################################################################################

## Contexte ------------------------------------------

# En l'an 4000, il n'y a pas de 29 fevrier (alors qu'il devrait y en avoir).
# Ainsi, toutes les dates qui suivent le 28 février 4000 correspondent à leur veille
# Exemple : le lundi de paques tombe le 10 avril 4000, et bien le 10 avril 4000 sera alors dans le calendrier de SAS ce sera le dimanche 10 avril 4000

source("./R/01_create_french_calendar.R")

# Calcul de la moyenne des jours fériés liés à Paques --------------------------

cal1 <- create_french_calendar(
    summary = FALSE,
    start = 1990L, end = 4789L,
    starting_day = "lundi"
)

mean_sas <- cal1 |>
    dplyr::filter(year != 4000 | month_number != 2 | month_day_number != 29) |>
    dplyr::select(
        year, month_number, weekday_number,
        dplyr::starts_with(c("Day", "Off", "In"), ignore.case = FALSE)
    ) |>
    dplyr::mutate(
        weekday_number = dplyr::case_when(
            year == 4000 & month_number < 3 ~ weekday_number,
            year >= 4000 ~ (weekday_number - 2) %% 7 + 1,
            TRUE ~ weekday_number
        )
    ) |>
    dplyr::summarise(dplyr::across(dplyr::everything(), sum),
        .by = c(year, month_number, weekday_number)
    ) |>
    dplyr::select(-year) |>
    summarise(across(everything(), mean, na.rm = TRUE),
        .by = c(month_number, weekday_number)
    ) |>
    dplyr::rename(
        Day_mean = Day,
        Off_mean = Off,
        In_mean = In
    ) |>
    dplyr::mutate(periode = month_number)


## Calcul des totaux ------------------------------------------------------------

mean_sas <- mean_sas |>
    rbind(
        mean_sas |> dplyr::summarise(
            weekday_number = 0,
            Off_mean = sum(Off_mean),
            Day_mean = sum(Day_mean),
            In_mean = sum(In_mean),
            periode = dplyr::first(periode),
            .by = month_number
        )
    )


## Enregistrement ------------------------------------------------------------

save(mean_sas, file = "./data/mean-sas.RData")
