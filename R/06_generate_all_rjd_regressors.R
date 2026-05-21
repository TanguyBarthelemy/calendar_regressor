################################################################################
#######                   Generate regressors with JD+                   #######
################################################################################

# Chargement packages ----------------------------------------------------------

library("rjd3toolkit")


# Calendar creation ------------------------------------------------------------

french_calendar <- national_calendar(
    days = list(
        fixed_day(7, 14), # Fete nationale
        fixed_day(5, 8, validity = list(start = "1982-05-08")), # Victoire 2nd guerre mondiale
        special_day("NEWYEAR"), # Nouvelle année
        special_day("CHRISTMAS"), # Noël
        special_day("MAYDAY"), # 1er mai
        special_day("EASTERMONDAY"), # Lundi de Pâques
        special_day("ASCENSION"), # attention +39 et pas 40 jeudi ascension
        special_day("WHITMONDAY"), # Lundi de Pentecôte (1/2 en 2005 a verif)
        special_day("ASSUMPTION"), # Assomption
        special_day("ALLSAINTSDAY"), # Toussaint
        special_day("ARMISTICE")
    )
)


# Regressor set creation -------------------------------------------------------

## Regressor monthly -----------------------------------------------------------

regs_mens_rjd <- lapply(
    X = list(
        c(1L, 1L, 1L, 1L, 1L, 0L, 0L),
        c(1L, 1L, 1L, 1L, 1L, 2L, 0L),
        c(1L, 2L, 2L, 2L, 2L, 3L, 0L),
        c(1L, 2L, 3L, 4L, 5L, 0L, 0L),
        c(1L, 2L, 3L, 4L, 5L, 6L, 0L)
    ),
    FUN = \(group) {
        calendar_td(
            calendar = french_calendar,
            frequency = 12L,
            start = c(1990L, 1L),
            length = 492L,
            groups = group
        )
    }
) |>
    do.call(what = cbind)

colnames(regs_mens_rjd) <- sapply(
    c(1, 2, 3, 5, 6),
    \(k) paste0("REG", k, "_AC", 1:k)
) |>
    do.call(what = c)

regs_mens_rjd <- data.frame(
    date = regs_mens_rjd |> time() |> zoo::as.Date(),
    regs_mens_rjd
)

write.table(
    x = regs_mens_rjd,
    sep = ";",
    file = "./output/regs_mens_rjd.csv",
    row.names = FALSE
)

## Regressor quaterly ----------------------------------------------------------

regs_trim_rjd <- lapply(
    X = list(
        c(1L, 1L, 1L, 1L, 1L, 0L, 0L),
        c(1L, 1L, 1L, 1L, 1L, 2L, 0L),
        c(1L, 2L, 2L, 2L, 2L, 3L, 0L),
        c(1L, 2L, 3L, 4L, 5L, 0L, 0L),
        c(1L, 2L, 3L, 4L, 5L, 6L, 0L)
    ),
    FUN = \(group) {
        calendar_td(
            calendar = french_calendar,
            frequency = 4L,
            start = c(1990L, 1L),
            length = 164,
            groups = group
        )
    }
) |>
    do.call(what = cbind)

colnames(regs_trim_rjd) <- sapply(
    c(1, 2, 3, 5, 6),
    \(k) paste0("REG", k, "_AC", 1:k)
) |>
    do.call(what = c)

regs_trim_rjd <- data.frame(
    date = regs_trim_rjd |> time() |> zoo::as.Date(),
    regs_trim_rjd
)

write.table(
    x = regs_trim_rjd,
    sep = ";",
    file = "./output/regs_trim_rjd.csv",
    row.names = FALSE
)
