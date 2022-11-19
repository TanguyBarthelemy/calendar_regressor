
library("magrittr")

compute_reg_cjo_tanguy <- function(groups_in = c(0, rep(1, 5), 0), 
                                groups_off = rep(0, 7)) {
    
    # # Vérification des paramètres temporels
    # if (!frequency_reg %in% c(4, 12)) {
    #     stop("La fréquence doit être 4 (trimestrielle) ou 12 (mensuelle).")
    # }
    # 
    # frequency_reg <- as.integer(frequency_reg)
    # 
    # if ((missing(length_reg) & (missing(start_reg) || missing(start_reg))) || 
    #     (missing(start_reg) && missing(start_reg))) {
    #     stop("Il manque les paramètres de début, de fin ou de longueur de la série.")
    # }
    # 
    # if (!missing(start_reg)) {
    #     if ((!is.numeric(start_reg)) || 
    #         (length(start_reg) != 2) ||
    #         (start_reg <= 0) ||
    #         (start_reg[2] > frequency_reg)) {
    #         stop("Les dates start_reg et end_reg doivent être au format c(AAAA, MM) en numeric.\n Le nombre de période doit être cohérent avec la fréquence.\n Il ne peut pas y avoir d'année négatives.")
    #     }
    #     
    #     start_reg <- as.integer(start_reg)
    # }
    # 
    # if (!missing(end_reg)) {
    #     if ((!is.numeric(end_reg)) ||
    #         (length(end_reg) != 2) ||
    #         (end_reg <= 0) ||
    #         (start_reg[1] > end_reg[1]) ||
    #         (end_reg[2] > frequency_reg)) {
    #         stop("Les dates start_reg et end_reg doivent être au format c(AAAA, MM) en numeric.\n Le nombre de période doit être cohérent avec la fréquence.\n Il ne peut pas y avoir d'année négatives.")
    #     }
    #     
    #     end_reg <- as.integer(end_reg)
    # }
    # 
    # if (!missing(start_reg) && !missing(start_reg)) {
    #     if ((start_reg[1] > end_reg[1]) ||
    #         (start_reg[1] == end_reg[1] & start_reg[2] > end_reg[2])) {
    #         stop("Les dates start_reg et end_reg doivent être au format c(AAAA, MM) en numeric.\n Le nombre de période doit être cohérent avec la fréquence.\n Il ne peut pas y avoir d'année négatives.")
    #     }
    # }
    # 
    # if (missing(length_reg)) {
    #     length_reg <- (end_reg[1] - start_reg[1]) * frequency_reg + (end_reg[2] - start_reg[2] + 1)
    # }
    # 
    # if (missing(start_reg)) {
    #     start_reg <- c(end_reg[1] + (end_reg[2] - length_reg - 1) %/% frequency_reg, (end_reg[2] - length_reg - 1) %% frequency_reg + 1)
    # }
    # 
    # if (missing(end_reg)) {
    #     end_reg <- c(start_reg[1] + (start_reg[2] + length_reg - 1) %/% frequency_reg, (start_reg[2] + length_reg - 1) %% frequency_reg + 1)
    # }
    # 
    # if (length_reg != (end_reg[1] - start_reg[1]) * frequency_reg + (end_reg[2] - start_reg[2] + 1)) {
    #     stop("Il y a une incompatibilité temporelle entre length_reg, start_reg et end_reg.")
    # }
    
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
    french_calendar <- create_french_calendar(end = 2030, mean_correction = TRUE)
    
    # Calcul des coeff_vicients régresseurs CJO
    reg_cjo <- french_calendar |> 
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



compute_reg_cjo_tanguy(groups_in = c(0, rep(1, 5), 0))
