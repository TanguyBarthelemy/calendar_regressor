# Try to replicate stock td

library("rjd3toolkit")
library("dplyr")


source("./R/01_create_french_calendar.R")

# Stock 12 ----------------------------------------------------------------

compute_stock <- function(frequency = 12L, start = 2000, end = 2020, w = 15L) {
    if (length(end) == 1L) end <- c(end, 1L)
    weekday_df <- data.frame(
        name = weekdays(as.Date(3:9), abbreviate = FALSE),
        number = 1:7
    )
    shift <- 0L
    if (w <= 0) {
        shift <- w
        w <- 31L
    }

    if (frequency == 12L) {
        regs <- create_empty_calendar(start = start, end = end) |>
            dplyr::mutate(period_number = month_number)
    } else if (frequency == 4L) {
        end[2] <- end[2] * 3L
        start2 <- start
        start2[2] <- start2[2] * 3L
        regs <- create_empty_calendar(start = start2, end = end) |>
            dplyr::mutate(
                last_month = month_number %% 3L == 0L,
                period_number = as.integer(((month_number - 1L) %/% 3L) + 1L)
            ) |>
            dplyr::filter(last_month)
    } else {
        stop("wrong frequency", call. = FALSE)
    }
    regs <- regs |>
        dplyr::filter(
            ((w <= NbDays) & (month_day_number == w)) |
                ((w > NbDays) & (month_day_number == NbDays))
        ) |>
        dplyr::select(year, period_number, weekday_number) |>
        dplyr::mutate(
            weekday_number = (weekday_number + shift - 1L) %% 7L + 1L,
            value = 1.0
        ) |>
        merge(y = weekday_df, by.x = "weekday_number", by.y = "number") |>
        dplyr::select(-weekday_number) |>
        tidyr::pivot_wider(names_from = "name", values_fill = 0.0)

    regs[setdiff(weekday_df$name, colnames(regs))] <- 0.0

    regs <- regs |>
        dplyr::mutate(dplyr::across(
            .cols = dplyr::contains("day"),
            .fns = ~ dplyr::case_when(
                Sunday == 1.0 ~ -1.0,
                TRUE ~ .x
            )
        )) |>
        dplyr::arrange(year, period_number) |>
        dplyr::select(any_of(weekdays(as.Date(4:9), abbreviate = FALSE))) |>
        ts(start = start, frequency = frequency)

    return(regs)
}

for (k in 1:100) {
    w <- sample(-100:100, size = 1)
    frequency <- sample(c(4, 12), size = 1)
    start <- c(sample(1950:2020, size = 1), sample.int(frequency, size = 1))
    end <- c(
        sample((start[1] + 1):2025, size = 1),
        sample.int(frequency, size = 1)
    )
    print(start)
    print(end)
    length <- (end[1L] - start[1] + 1) *
        frequency -
        start[2L] +
        1L -
        (frequency - end[2L])

    stock_tb <- compute_stock(
        frequency = frequency,
        w = w,
        start = start,
        end = end
    )
    stock_rjd <- stock_td(
        frequency = frequency,
        start = start,
        length = length,
        w = w
    )

    print(waldo::compare(stock_rjd, stock_tb))
}
