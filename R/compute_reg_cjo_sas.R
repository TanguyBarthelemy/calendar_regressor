
library("magrittr")

compute_reg_cjo_sas <- function(groups_in = c(0, rep(1, 5), 0), 
                                groups_off = rep(0, 7), 
                                start_reg = c(1990, 1), 
                                end_reg = c(2029, 4), 
                                frequency_reg = 4, 
                                length_reg = 4) {
    
    # Vérification des paramètres temporels
    if (!frequency_reg %in% c(4, 12)) {
        stop("La fréquence doit être 4 (trimestrielle) ou 12 (mensuelle).")
    }
    
    frequency_reg <- as.integer(frequency_reg)
    
    if ((missing(length_reg) & (missing(start_reg) || missing(start_reg))) || 
        (missing(start_reg) && missing(start_reg))) {
        stop("Il manque les paramètres de début, de fin ou de longueur de la série.")
    }
    
    if (!missing(start_reg)) {
        if ((!is.numeric(start_reg)) || 
            (length(start_reg) != 2) ||
            (start_reg <= 0) ||
            (start_reg[2] > frequency_reg)) {
            stop("Les dates start_reg et end_reg doivent être au format c(AAAA, MM) en numeric.\n Le nombre de période doit être cohérent avec la fréquence.\n Il ne peut pas y avoir d'année négatives.")
        }
        
        start_reg <- as.integer(start_reg)
    }
    
    if (!missing(end_reg)) {
        if ((!is.numeric(end_reg)) ||
            (length(end_reg) != 2) ||
            (end_reg <= 0) ||
            (start_reg[1] > end_reg[1]) ||
            (end_reg[2] > frequency_reg)) {
            stop("Les dates start_reg et end_reg doivent être au format c(AAAA, MM) en numeric.\n Le nombre de période doit être cohérent avec la fréquence.\n Il ne peut pas y avoir d'année négatives.")
        }
        
        end_reg <- as.integer(end_reg)
    }
    
    if (!missing(start_reg) && !missing(start_reg)) {
        if ((start_reg[1] > end_reg[1]) ||
            (start_reg[1] == end_reg[1] & start_reg[2] > end_reg[2])) {
            stop("Les dates start_reg et end_reg doivent être au format c(AAAA, MM) en numeric.\n Le nombre de période doit être cohérent avec la fréquence.\n Il ne peut pas y avoir d'année négatives.")
        }
    }
    
    if (missing(length_reg)) {
        length_reg <- (end_reg[1] - start_reg[1]) * frequency_reg + (end_reg[2] - start_reg[2] + 1)
    }
    
    if (missing(start_reg)) {
        start_reg <- c(end_reg[1] + (end_reg[2] - length_reg - 1) %/% frequency_reg, (end_reg[2] - length_reg - 1) %% frequency_reg + 1)
    }
    
    if (missing(end_reg)) {
        end_reg <- c(start_reg[1] + (start_reg[2] + length_reg - 1) %/% frequency_reg, (start_reg[2] + length_reg - 1) %% frequency_reg + 1)
    }
    
    if (length_reg != (end_reg[1] - start_reg[1]) * frequency_reg + (end_reg[2] - start_reg[2] + 1)) {
        stop("Il y a une incompatibilité temporelle entre length_reg, start_reg et end_reg.")
    }
    
    # Vérification des groupes
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
    
    # Création du calendrier
    frenchCalendar_tab <- haven::read_sas("./data/french_calendar_brut.sas7bdat") |> 
        dplyr::mutate(Date = as.Date(Date, origin = "1960-01-01")) |> 
        dplyr::mutate(periode = dplyr::case_when(frequency_reg == 4 ~ qtr, TRUE ~ month))
    
    if (frequency_reg == 4L) {
        frenchCalendar_tab <- frenchCalendar_tab |> 
            dplyr::group_by(year, periode) |> 
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
    }
    
    # Calcul des moyennes
    means_tab <- frenchCalendar_tab |> 
            dplyr::select(periode, dplyr::starts_with(c("Day", "Off"))) |> 
            dplyr::group_by(periode) |> 
            dplyr::summarise_all(.funs = list(mean = mean))
    
    # Calcul des corrections (dû aux moyennes)
    frenchCalendar_corr <- merge(frenchCalendar_tab, means_tab, 
                                     by = 'periode', all = TRUE) |> 
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
        dplyr::filter((year > start_reg[1] & 
                          year < end_reg[1]) | 
                          (year == start_reg[1] & periode >= start_reg[2]) | 
                          (year == end_reg[1] & periode <= end_reg[2])) |> 
        dplyr::arrange(year, qtr, month)
    
    # Calcul des coeff_vicients régresseurs CJO
    reg_cjo <- frenchCalendar_corr |> 
        dplyr::select(Date, dplyr::starts_with(c("In", "Off"))) |> 
        dplyr::select(Date, dplyr::ends_with("_corr")) |> 
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



compute_reg_cjo_sas(groups_in = c(0, rep(1, 5), 0), 
                    start_reg = c(1990, 1), 
                    end_reg = c(1994, 1), 
                    frequency_reg = 12)
