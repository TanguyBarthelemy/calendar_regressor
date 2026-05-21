# find mean easter rjd

source("./R/01_create_french_calendar.R")

# etude des easter calcul par rjd

cal1 <- create_french_calendar(
    summary = FALSE,
    start = 1990L,
    end = 2031L,
    starting_day = "lundi"
)

# On ne garde que les jeudi
cal1_bis <- cal1 |>
    dplyr::filter(weekday_number == 5) |>
    dplyr::summarise(
        # whit_monday = sum(whit_monday),
        # easter_monday = sum(easter_monday),
        ascension = sum(ascension),
        Days = dplyr::n(),
        NbDays = dplyr::first(NbDays),
        .by = c("year", "month_number")
    )


simplified_calendar <- national_calendar(
    days = list(
        # fixed_day(7, 14) # Fete nationale
        # fixed_day(5, 8, validity = list(start = "1982-05-08")), # Victoire 2nd guerre mondiale
        # special_day("NEWYEAR"), # Nouvelle année
        # special_day("CHRISTMAS"), # Noël
        # special_day("MAYDAY"), # 1er mai
        # special_day("EASTERMONDAY"), # Lundi de Pâques
        special_day("ASCENSION") # , # attention +39 et pas 40 jeudi ascension
        # special_day("WHITMONDAY")#, # Lundi de Pentecôte (1/2 en 2005 a verif)
        # special_day("ASSUMPTION"), # Assomption
        # special_day("ALLSAINTSDAY"), # Toussaint
        # special_day("ARMISTICE")
    )
)

reg_test <- calendar_td(
    calendar = simplified_calendar,
    frequency = 12L,
    start = c(1990L, 1L),
    length = 480L,
    groups = c(0L, 0L, 0L, 1L, 0L, 0L, 0L)
)

out <- cbind(
    year = reg_test |> time() |> zoo::as.Date() |> format("%Y") |> as.integer(),
    month_number = reg_test |>
        time() |>
        zoo::as.Date() |>
        format("%m") |>
        as.integer(),
    REG1_tuesday = as.double(reg_test)
) |>
    as.data.frame() |>
    merge(y = cal1_bis) |>
    # dplyr::filter(month_number > 2 & month_number < 7) |>
    dplyr::mutate(
        reg_tuesday = -(NbDays / 6) + (Days - ascension) * (1 + 1 / 6),
        mean_tuesday = (REG1_tuesday - reg_tuesday) / (1 + 1 / 6),
        mean_round = round(mean_tuesday, 3)
    )

mean_ascension_tuesday <- out |>
    dplyr::filter(year == 1990, month_number %in% 4:6) |>
    dplyr::pull(mean_tuesday)
