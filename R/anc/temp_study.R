cal_sas <- frenchCalendar_corr
mean_sas <- means_tab

cal_R <- cal1
mean_R <- mean_monthly

tab1 <- mean_sas |> pivot_longer(-periode) |> 
    mutate(wn = substr(name, 4, 4) |> as.integer(), 
           mn = periode, 
           n = substr(name, 1, nchar(name) - 6), 
           v = value) |> 
    select(mn, wn, n, v) |> 
    arrange(mn, wn, n)

tab2 <- mean_R |> pivot_longer(-c(month_number, weekday_number)) |> 
    mutate(wn = weekday_number, 
           mn = month_number, 
           n = substr(name, 1, nchar(name) - 5), 
           v = value) |> 
    select(mn, wn, n, v) |> 
    filter(n != "In", wn != 0)|> 
    arrange(mn, wn, n)

cbind(tab1, tab2$v) |> 
    mutate(SAS = v, 
           R = tab2$v, 
           diff = abs(SAS - R)) |> View()

a <- frenchCalendar_tab$EasterG |> 
    gsub(pattern = "APR", replacement = "04") |> 
    gsub(pattern = "MAR", replacement = "03") |> 
    substr(1, 4) |> paste0("2000") |> 
    as.Date(format = "%d%m%Y")
a <- a[!is.na(a)] + 1
b <- a |> format(format = "%B") |> table()
b[2] / sum(b)

frenchCalendar_tab |> 
    dplyr::mutate(Off1 = case_when(
        month >= 3 & month <= 6 ~ 0, 
        TRUE ~ Off1
    )) |> 
    dplyr::select(periode, dplyr::starts_with(c("Day", "Off"))) |> 
    dplyr::filter(periode == 3) |> 
    dplyr::summarise_all(.funs = list(mean = mean)) |> t()





