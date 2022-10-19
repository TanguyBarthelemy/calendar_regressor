

start_reg <- c(1990, 1)
end_reg <- c(2029, 2)
frequency_reg <- 4

groups_in = c(0, 1:6)
groups_off = rep(0, 7)



if (!frequency_reg %in% c(4, 12)) {
    stop("La fréquence doit être 4 (trimestrielle) ou 12 (mensuelle).")
}

frequency_reg <- as.integer(frequency_reg)

if (is.numeric(groups_in)) {
    groups_in <- paste0("REG", groups_in)
}
if (is.numeric(groups_off)) {
    groups_off <- paste0("REG", groups_off)
}

if ((!is.numeric(start_reg)) || 
    (!is.numeric(end_reg)) ||
    (length(start_reg) != 2) ||
    (length(end_reg) != 2) ||
    (any(c(start_reg, end_reg) <= 0)) ||
    (start_reg[1] > end_reg[1]) ||
    (start_reg[1] == end_reg[1] & start_reg[2] > end_reg[2]) ||
    (start_reg[2] > frequency_reg) ||
    (end_reg[2] > frequency_reg)) {
    stop("Les dates start_reg et end_reg doivent être au format c(AAAA, MM) en numeric.\n Le nombre de période doit être cohérent avec la fréquence.\n Il ne peut pas y avoir d'année négatives.")
}

start_reg <- as.integer(start_reg)
end_reg <- as.integer(end_reg)

if (!all(c(groups_in, groups_off) %in% paste0("REG", 0:6))) {
    stop("Les groupes doivent contenir des entiers entre 0 et 6 ou des 
               chaines de caractère 'REG0', 'REG1', ... 'REG6'\nLes valeurs", 
         paste0(c(groups_in, groups_off)[!c(groups_in, groups_off) %in% paste0("REG", 0:6)], collapse = ", "), 
         "ne sont pas acceptées.")
}

length_reg <- (end_reg[1] - start_reg[1]) * frequency_reg + (end_reg[2] - start_reg[2] + 1)

real_rjd_reg_ts <- rjd3modelling::htd(
    frenchCalendar, frequency = frequency_reg, start = start_reg, length = length_reg, 
    groups = groups_in |> gsub(pattern = "REG", replacement = "") |> as.numeric(), 
    meanCorrection = TRUE, contrasts = FALSE)
real_rjd_reg_df <- cbind(Date = zoo::as.Date(time(real_rjd_reg_ts)),
                         as.data.frame(real_rjd_reg_ts))
colnames(real_rjd_reg_df) <- real_rjd_reg_df |> 
    colnames() |> 
    gsub(pattern = "-", replacement = "_")

coeff_v <- table(groups_in) |> as.integer()
names(coeff_v) <- paste0("REG", 0:(length(coeff_v) - 1))

# Import du calendrier
frenchCalendar_tab <- haven::read_sas("./output_calendar_sas/cal/cal1.sas7bdat") |> 
    dplyr::mutate(Date = as.Date(Date, origin = "1960-01-01"))

stop("Il faut traiter le french calendar et rejoindre les variables qtr dans le cas où la fréquence est 4.")

# Calcul des variables REG par groupes
REG_tab <- frenchCalendar_tab |> 
    dplyr::filter(year >= start_reg[1] & year <= end_reg[1]) |> 
    dplyr::select(c("Date", dplyr::starts_with(c("In", "Off")))) |> 
    tidyr::pivot_longer(cols = -Date, names_to = "VAR", values_to = "VAL") |> 
    tidyr::pivot_wider(names_from = "Date", values_from = "VAL") |> 
    dplyr::mutate(GROUP = c(groups_in, groups_off)) |> 
    dplyr::group_by(GROUP) |> 
    dplyr::select(-VAR) |>
    dplyr::summarise_all(sum) |> 
    tidyr::pivot_longer(cols = -GROUP, names_to = "Date", values_to = "VAL") |> 
    tidyr::pivot_wider(names_from = "GROUP", values_from = "VAL") |> 
    dplyr::mutate(Date = as.Date(Date)) |> 
    dplyr::mutate(
        month = lubridate::month(Date), 
        year = lubridate::year(Date))

# Calcul des moyennes de long-termes

tot_temp <- merge(REG_tab, real_rjd_reg_df, by = 'Date', all = TRUE)
means_mat <- cbind(seq.int(frequency_reg), 
                   matrix(NA, nrow = frequency_reg, ncol = length(coeff_v)))
colnames(means_mat) <- c("month", paste0("REG_mean", 0:(length(coeff_v) - 1)))
for (m in seq.int(frequency_reg)) {
    for (i in 0:(length(coeff_v) - 1)) {
        if (m == 5) {
            mod_temp <- lm(formula = paste0("REG", i, " ~ ", "group_", i), 
                           tot_temp |> subset(month == m & year != 2005)) |> 
                summary()
        } else {
            mod_temp <- lm(formula = paste0("REG", i, " ~ ", "group_", i), 
                           tot_temp |> subset(month == m)) |> 
                summary()
        }
        if (mod_temp$r.squared != 1) 
            stop("Il y a un problème de relation pour le mois ", 
                 m, " et la variable de régression ", i, ".")
        means_mat[m, i + 2] <- mod_temp$coefficients[1, 1]
    }
}

# Calcul des contrastes
reg_cjo <- merge(REG_tab, means_mat, by = "month") |> head() |> 
    dplyr::mutate(ref = REG0 - REG_mean0) |> 
    tidyr::pivot_longer(cols = c(dplyr::starts_with("REG")), 
                        names_to = c(".value", "var"), values_to = "VAL", 
                        names_pattern = "(\\w+)(\\d)") |>  
    dplyr::mutate(
        REG_corr = REG - REG_mean, 
        REG_AC = REG_corr - coeff_v[paste0("REG", var)] / coeff_v["REG0"] * ref) |>  
    tidyr::pivot_wider(names_from = var, values_from = c(REG_AC, REG, REG_mean, REG_corr), names_sep = "") |> 
    dplyr::rename(REG0_corr = ref) |> 
    dplyr::select(-REG_AC0)



