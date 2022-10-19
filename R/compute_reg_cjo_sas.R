
library("magrittr")

compute_reg_cjo_sas <- function(groups_in = c(0, rep(1, 5), 0), 
                                groups_off = rep(0, 7)) {
    
    if (is.numeric(groups_in)) {
        groups_in <- paste0("REG", groups_in)
    }
    if (is.numeric(groups_off)) {
        groups_off <- paste0("REG", groups_off)
    }
    
    if (!all(c(groups_in, groups_off) %in% paste0("REG", 0:6))) {
        stop("Les groupes doivent contenir des entiers entre 0 et 6 ou des valeurs 'REG0', 'REG1', ... 'REG6'")
    }
    
    coeff_v <- table(c(groups_in, groups_off)) |> as.integer()
    names(coeff_v) <- paste0("REG", 0:(length(coeff_v) - 1))
    
    #Import du calendrier
    frenchCalendar_tab <- haven::read_sas("./output_calendar_sas/cal/cal1.sas7bdat") |> 
        dplyr::mutate(Date = as.Date(Date, origin = "1960-01-01"))
    
    #Calcul des moyennes
    means_tab <- frenchCalendar_tab |> 
        dplyr::select(c("month", dplyr::starts_with(c("Day", "Off")))) |> 
        dplyr::group_by(month) |> 
        dplyr::summarise_all(.funs = list(mean = mean))
    
    #Calcul des corrections (dû aux moyennes)
    frenchCalendar_corr <- merge(frenchCalendar_tab, means_tab, 
                                 by = 'month', all = TRUE) |> 
        dplyr::mutate(
            Day1_corr = Day1 - Day1_mean, 
            Day2_corr = Day2 - Day2_mean, 
            Day3_corr = Day3 - Day3_mean, 
            Day4_corr = Day4 - Day4_mean, 
            Day5_corr = Day5 - Day5_mean, 
            Day6_corr = Day6 - Day6_mean, 
            Day7_corr = Day7 - Day7_mean, 
            
            Off1_corr = Off1 - Off1_mean, 
            Off2_corr = Off2 - Off2_mean, 
            Off3_corr = Off3 - Off3_mean, 
            Off4_corr = Off4 - Off4_mean, 
            Off5_corr = Off5 - Off5_mean, 
            Off6_corr = Off6 - Off6_mean, 
            Off7_corr = Off7 - Off7_mean,
            
            In1_corr = Day1_corr - Off1_corr,
            In2_corr = Day2_corr - Off2_corr,
            In3_corr = Day3_corr - Off3_corr,
            In4_corr = Day4_corr - Off4_corr,
            In5_corr = Day5_corr - Off5_corr,
            In6_corr = Day6_corr - Off6_corr,
            In7_corr = Day7_corr - Off7_corr, 
            
            PH_corr = Off2_corr + Off3_corr + Off4_corr + Off5_corr + Off6_corr, 
            TD_corr = In2_corr + In3_corr + In4_corr + In5_corr + In6_corr,
            
            REG1 = In2_corr - (Day1_corr + PH_corr + Off7_corr),
            REG2 = In3_corr - (Day1_corr + PH_corr + Off7_corr),
            REG3 = In4_corr - (Day1_corr + PH_corr + Off7_corr),
            REG4 = In5_corr - (Day1_corr + PH_corr + Off7_corr),
            REG5 = In6_corr - (Day1_corr + PH_corr + Off7_corr),
            REG6 = In7_corr - (Day1_corr + PH_corr + Off7_corr),
            
            WeekDays_corr = TD_corr - 5 * (PH_corr + Day1_corr + Day7_corr) / 2, 
            
            TD1_corr = Day2_corr - Day1_corr,
            TD2_corr = Day3_corr - Day1_corr,
            TD3_corr = Day4_corr - Day1_corr,
            TD4_corr = Day5_corr - Day1_corr,
            TD5_corr = Day6_corr - Day1_corr,
            TD6_corr = Day7_corr - Day1_corr, 
            
            WD_corr = Day1_corr + Day2_corr + Day3_corr + Day4_corr +
                Day5_corr + Day6_corr - 5 * (Day1_corr + Day7_corr) / 2
        ) |> 
        dplyr::filter(year >= 1990 & year < 2031) |> 
        dplyr::arrange(year, month)
    
    #Calcul des coeff_vicients régresseurs CJO
    
    reg_cjo <- frenchCalendar_corr |> 
        dplyr::select(c("Date", dplyr::starts_with(c("In", "Off")))) |> 
        dplyr::select(c("Date", dplyr::ends_with("_corr"))) |> 
        tidyr::pivot_longer(cols = -Date, names_to = "VAR", values_to = "VAL") |> 
        tidyr::pivot_wider(names_from = "Date", values_from = "VAL") |> 
        dplyr::mutate(GROUP = c(groups_in, groups_off)) %>% 
        dplyr::bind_rows(... = . |> dplyr::mutate(GROUP = "Nbdays")) |> 
        dplyr::group_by(GROUP) |> 
        dplyr::select(-VAR) |>
        dplyr::summarise_all(sum) |> 
        tidyr::pivot_longer(cols = -GROUP, names_to = "Date", values_to = "VAL") |> 
        tidyr::pivot_wider(names_from = "GROUP", values_from = "VAL") |> 
        dplyr::mutate(Date = as.Date(Date)) |> 
        dplyr::rename(ref = REG0) |> 
        tidyr::pivot_longer(cols = c(dplyr::starts_with("REG")), 
                            names_to = c(".value", "var"), 
                            names_pattern = "(REG)(\\d)") |>  
        dplyr::mutate(REG_AC = REG - coeff_v[paste0("REG", var)] / coeff_v["REG0"] * ref) |> 
        tidyr::pivot_wider(names_from = var, values_from = c(REG_AC, REG), names_sep = "") |> 
        dplyr::rename(REG0 = ref)
    
    return(reg_cjo)
}



compute_reg_cjo_sas(groups_in = c(0, rep(1, 5), 0))
