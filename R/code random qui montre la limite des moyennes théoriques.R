
source("./R/0_set_up.R")


groups_in = c(0, 1:6)
groups_off = rep(0, 7)
start_reg = c(1990, 1) 
end_reg = c(5000, 12) 
frequency_reg = 12
length_reg <- (end_reg[1] - start_reg[1]) * frequency_reg + (end_reg[2] - start_reg[2] + 1)


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

if (!all(c(groups_in, groups_off) %in% paste0("REG", 0:6))) {
    stop("Les groupes doivent contenir des entiers entre 0 et 6 ou des 
               chaines de caractère 'REG0', 'REG1', ... 'REG6'\nLes valeurs", 
         paste0(c(groups_in, groups_off)[!c(groups_in, groups_off) %in% paste0("REG", 0:6)], collapse = ", "), 
         "ne sont pas acceptées.")
}

if (groups_in[1] != "REG0") {
    warning("Le premier jour des groupes est le dimanche et non le lundi.")
}

coeff_v <- table(groups_in) |> as.integer()
names(coeff_v) <- paste0("REG", 0:(length(coeff_v) - 1))

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

length_reg <- (end_reg[1] - start_reg[1]) * frequency_reg + (end_reg[2] - start_reg[2] + 1)

real_rjd_reg_ts <- rjd3modelling::htd(
    frenchCalendar, frequency = frequency_reg, start = start_reg, length = length_reg, 
    groups = c(groups_in[-1], groups_in[1]) |> gsub(pattern = "REG", replacement = "") |> as.numeric(), 
    meanCorrection = TRUE, contrasts = FALSE)
real_rjd_reg_df <- cbind(Date = zoo::as.Date(time(real_rjd_reg_ts)),
                         as.data.frame(real_rjd_reg_ts))
colnames(real_rjd_reg_df) <- real_rjd_reg_df |> 
    colnames() |> 
    gsub(pattern = "-", replacement = "_")

# Import du calendrier
frenchCalendar_tab <- haven::read_sas("./data/french_calendar_brut.sas7bdat") |> 
    dplyr::mutate(Date = as.Date(Date, origin = "1960-01-01")) |> 
    dplyr::mutate(periode = dplyr::case_when(frequency_reg == 4 ~ qtr, TRUE ~ month))

if (frequency_reg == 4L) {
    frenchCalendar_tab <- frenchCalendar_tab |> 
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
}


test <- frenchCalendar_tab |> 
    dplyr::select(Date, month, qtr, periode, dplyr::starts_with(c("In", "Off"))) |> 
    tidyr::pivot_longer(cols = dplyr::starts_with(c("In", "Off")),  names_pattern = "(\\w+)(\\d)",
                 names_to = c(".value", "jour")) |> 
    dplyr::group_by(month, jour) |> 
    dplyr::mutate(Off_mean = mean(Off), 
                  In_corr = In + Off_mean) |> 
    tidyr::pivot_wider(names_from = jour, values_from = c(In, Off, Off_mean, In_corr), names_sep = "")


tot <- merge(test, real_rjd_reg_df, by = "Date") |> 
    mutate(diff = In_corr2 - group_1) |> 
    subset(Date < "2000-01-01")


