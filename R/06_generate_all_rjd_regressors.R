library("rjd3toolkit")


## Calendar creation -----------------------------------------------------------

french_calendar <- national_calendar(days = list(
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
))


## Regressor set creation ------------------------------------------------------

groups <- list(
    REG1 = c(1L, 1L, 1L, 1L, 1L, 0L, 0L),
    REG2 = c(1L, 1L, 1L, 1L, 1L, 2L, 0L),
    REG3 = c(1L, 2L, 2L, 2L, 2L, 3L, 0L),
    REG5 = c(1L, 2L, 3L, 4L, 5L, 0L, 0L),
    REG6 = c(1L, 2L, 3L, 4L, 5L, 6L, 0L)
)

reg_mens <- lapply(
    X = groups, FUN = calendar_td,
    calendar = french_calendar,
    frequency = 12L,
    start = c(1990L, 1L),
    length = 480L,
    s = NULL
) |>
    data.frame(date = seq.Date(
        from = as.Date("1990-01-01"),
        length.out = 480L, by = "month"
    )) |>
    dplyr::relocate(date, .before = 1L) |>
    dplyr::rename(REG1 = group_1) |>
    dplyr::rename_all(~ gsub(pattern = ".group_", replacement = "_AC", .))

write.table(
    reg_mens,
    sep = ";", file = "./regresseurs/regs_mens_rjd.csv",
    row.names = FALSE
)
openxlsx::write.xlsx(reg_mens, file = "./regresseurs/regs_mens_rjd.xlsx")
