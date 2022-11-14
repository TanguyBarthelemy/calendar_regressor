
fr_cal_mens <- haven::read_sas("./data/french_calendar_brut.sas7bdat") |> 
    dplyr::mutate(Date = as.Date(Date, origin = "1960-01-01")) |> 
    dplyr::mutate(periode = month)

data_custom_mens <- fr_cal_mens |> 
    dplyr::filter(year > 1990, year < 2020) |> 
    dplyr::mutate(y1 = 4 * In2 + In3 + In4 + 4 * In5 + In6 + 5 * In7, 
                  y2 = 4 * Day2 + Day3 + Day4 + 4 * Day5 + Day6 + 5 * Day7, 
                  y3 = 4 * In2 + 5 * In7)

fr_cal_trim <- fr_cal_mens |> 
    dplyr::group_by(year, qtr) |> 
    dplyr::select(-Date, -EasterG) |>
    dplyr::summarise_all(sum) |> 
    dplyr::mutate(
        month = dplyr::case_when(
            month == 6 ~ 1, 
            month == 15 ~ 4, 
            month == 24 ~ 7, 
            TRUE ~ 10, 
        ), 
        Date = as.Date(paste0(year, "-", sprintf("%02.f", month), "-01"))) |> 
    dplyr::ungroup()

data_custom_trim <- fr_cal_trim |> 
    dplyr::filter(year > 1990, year < 2020) |> 
    dplyr::mutate(y1 = 4 * In2 + In3 + In4 + 4 * In5 + In6 + 5 * In7, 
                  y2 = 4 * Day2 + Day3 + Day4 + 4 * Day5 + Day6 + 5 * Day7, 
                  y3 = 4 * In2 + 5 * In7)

write.table(data_custom_mens |> dplyr::select(Date, y1, y2, y3), 
            file = "./data/simul_mens.csv", sep = ";", quote = FALSE, row.names = FALSE)
write.table(data_custom_trim |> dplyr::select(Date, y1, y2, y3), 
            file = "./data/simul_trim.csv", sep = ";", quote = FALSE, row.names = FALSE)
