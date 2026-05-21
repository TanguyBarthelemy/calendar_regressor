################################################################################
#####               Calcul des moyennes de long-terme par rjd              #####
################################################################################

# Chargement des tables --------------------------------------------------------

# Moyennes de long-terme "théoriques" liés à Paques par rjd
load("./data/easter_mean_rjd.RData")


# Calcul des moyennes de long-terme --------------------------------------------

## Calcul des jours Off --------------------------------------------------------

length_mois <- c(31L, 28L, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)

mean_rjd <- crossing(month_number = 1:12, weekday_number = 1:7) |>
    dplyr::mutate(
        Day_mean = rep(length_mois / 7, each = 7),
        Off_mean = 0,
        In_mean = 0,
        periode = month_number
    )

# Moyennes liés aux jours fériés non-easter
mean_rjd <- mean_rjd |>
    dplyr::mutate(
        Off_mean = dplyr::case_when(
            month_number %in% c(5L, 11L) ~ 2 / 7,
            month_number %in% c(1L, 7L, 8L, 12L) ~ 1 / 7,
            TRUE ~ 0
        )
    )

# Moyennes liés aux jours fériés easter
mean_rjd[
    mean_rjd$month_number %in% 3:4 & mean_rjd$weekday_number == 2,
    "Off_mean"
] <- mean_easter_monday +
    mean_rjd[
        mean_rjd$month_number %in% 3:4 & mean_rjd$weekday_number == 2,
        "Off_mean"
    ]
mean_rjd[
    mean_rjd$month_number %in% 5:6 & mean_rjd$weekday_number == 2,
    "Off_mean"
] <- mean_whit_monday +
    mean_rjd[
        mean_rjd$month_number %in% 5:6 & mean_rjd$weekday_number == 2,
        "Off_mean"
    ]
mean_rjd[
    mean_rjd$month_number %in% 4:6 & mean_rjd$weekday_number == 5,
    "Off_mean"
] <- mean_ascension +
    mean_rjd[
        mean_rjd$month_number %in% 4:6 & mean_rjd$weekday_number == 5,
        "Off_mean"
    ]


## Calcul des jours In ---------------------------------------------------------

mean_rjd$In_mean <- mean_rjd$Day_mean - mean_rjd$Off_mean


## Calcul des totaux -----------------------------------------------------------

mean_rjd <- rbind(
    mean_rjd,
    dplyr::summarise(
        data = mean_rjd,
        weekday_number = 0,
        Day_mean = sum(Day_mean),
        Off_mean = sum(Off_mean),
        In_mean = sum(In_mean),
        periode = dplyr::first(periode),
        .by = "month_number"
    )
)


## Enregistrement --------------------------------------------------------------

save(mean_rjd, file = "./data/mean-rjd.RData")
