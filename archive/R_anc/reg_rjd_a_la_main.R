source("./R/0_set_up.R")

compute_reg_cjo_rjd <- function(groups_in = c(0, rep(1, 5), 0),
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

    if ((missing(length_reg) && (missing(start_reg) || missing(start_reg)))
        || (missing(start_reg) && missing(start_reg))) {
        stop("Il manque les paramètres de début, de fin ou de longueur de la série.")
    }

    if (!missing(start_reg)) {
        if ((!is.numeric(start_reg))
            || (length(start_reg) != 2)
            || (start_reg <= 0)
            || (start_reg[2] > frequency_reg)) {
            stop("Les dates start_reg et end_reg doivent être au format c(AAAA, MM) en numeric.\n Le nombre de période doit être cohérent avec la fréquence.\n Il ne peut pas y avoir d'année négatives.")
        }

        start_reg <- as.integer(start_reg)
    }

    if (!missing(end_reg)) {
        if ((!is.numeric(end_reg))
            || (length(end_reg) != 2)
            || (end_reg <= 0)
            || (start_reg[1] > end_reg[1])
            || (end_reg[2] > frequency_reg)) {
            stop("Les dates start_reg et end_reg doivent être au format c(AAAA, MM) en numeric.\n Le nombre de période doit être cohérent avec la fréquence.\n Il ne peut pas y avoir d'année négatives.")
        }

        end_reg <- as.integer(end_reg)
    }

    if (!missing(start_reg) && !missing(start_reg)) {
        if ((start_reg[1] > end_reg[1])
            || (start_reg[1] == end_reg[1] && start_reg[2] > end_reg[2])) {
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
        stop(
            "Les groupes doivent contenir des entiers entre 0 et 6 ou des
               chaines de caractère 'REG0', 'REG1', ... 'REG6'\nLes valeurs",
            paste0(c(groups_in, groups_off)[!c(groups_in, groups_off) %in% paste0("REG", 0:6)], collapse = ", "),
            "ne sont pas acceptées."
        )
    }

    if (groups_in[1] != "REG0") {
        warning("Le premier jour des groupes est le dimanche et non le lundi.")
    }

    coeff_v <- table(groups_in) |> as.integer()
    names(coeff_v) <- paste0("REG", 0:(length(coeff_v) - 1))

    real_rjd_reg_ts <- rjd3modelling::htd(
        french_calendar,
        frequency = frequency_reg, start = start_reg, length = length_reg,
        groups = c(groups_in[-1], groups_in[1]) |> gsub(pattern = "REG", replacement = "") |> as.numeric(),
        meanCorrection = TRUE, contrasts = FALSE
    )
    real_rjd_reg_df <- cbind(
        Date = zoo::as.Date(time(real_rjd_reg_ts)),
        as.data.frame(real_rjd_reg_ts)
    )
    colnames(real_rjd_reg_df) <- real_rjd_reg_df |>
        colnames() |>
        gsub(pattern = "-", replacement = "_")

    # Import du calendrier
    french_calendar_tab <- haven::read_sas("./data/french_calendar_brut.sas7bdat") |>
        dplyr::mutate(Date = as.Date(Date, origin = "1960-01-01")) |>
        dplyr::mutate(periode = dplyr::case_when(frequency_reg == 4 ~ qtr, TRUE ~ month))

    if (frequency_reg == 4L) {
        french_calendar_tab <- french_calendar_tab |>
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
                Date = as.Date(paste0(year, "-", sprintf("%02.f", month), "-01"))
            ) |>
            dplyr::ungroup()
    }

    # Calcul des variables REG par groupes
    reg_tab <- french_calendar_tab |>
        dplyr::filter(year >= start_reg[1] & year <= end_reg[1]) |>
        dplyr::select(Date, dplyr::starts_with(c("In", "Off"))) |>
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
            year = lubridate::year(Date),
            qtr = lubridate::quarter(Date)
        )

    # Calcul des moyennes de long-terme
    tot_temp <- merge(reg_tab, real_rjd_reg_df, by = "Date", all = TRUE)
    means_mat <- cbind(
        seq.int(frequency_reg),
        matrix(NA, nrow = frequency_reg, ncol = length(coeff_v))
    )
    colnames(means_mat) <- c("periode", paste0("REG_mean", 0:(length(coeff_v) - 1)))

    base::suppressWarnings({
        for (periode in seq.int(frequency_reg)) {
            for (i in 0:(length(coeff_v) - 1)) {
                if (frequency_reg == 12) {
                    if (periode == 5) {
                        mod_temp <- lm(
                            formula = paste0("REG", i, " ~ ", "group_", i),
                            tot_temp |> subset(month == periode & year != 2005)
                        ) |>
                            summary()
                    } else {
                        mod_temp <- lm(
                            formula = paste0("REG", i, " ~ ", "group_", i),
                            tot_temp |> subset(month == periode)
                        ) |>
                            summary()
                    }
                } else {
                    if (periode == 2) {
                        mod_temp <- lm(
                            formula = paste0("REG", i, " ~ ", "group_", i),
                            tot_temp |> subset(qtr == periode & year != 2005)
                        ) |>
                            summary()
                    } else {
                        mod_temp <- lm(
                            formula = paste0("REG", i, " ~ ", "group_", i),
                            tot_temp |> subset(qtr == periode)
                        ) |>
                            summary()
                    }
                }

                if (mod_temp$r.squared != 1) {
                    stop(
                        "Il y a un problème de relation pour la période ",
                        periode, " et la variable de régression ", i, "."
                    )
                }
                means_mat[periode, i + 2] <- mod_temp$coefficients[1, 1]
            }
        }
    })

    print(means_mat)

    # Calcul des contrastes
    reg_cjo <- merge(reg_tab, means_mat, by = "periode") |>
        dplyr::mutate(ref = REG0 - REG_mean0) |>
        tidyr::pivot_longer(
            cols = c(dplyr::starts_with("REG")),
            names_to = c(".value", "var"), values_to = "VAL",
            names_pattern = "(\\w+)(\\d)"
        ) |>
        dplyr::mutate(
            REG_corr = REG - REG_mean,
            REG_AC = REG_corr - coeff_v[paste0("REG", var)] / coeff_v["REG0"] * ref
        ) |>
        tidyr::pivot_wider(names_from = var, values_from = c(REG_AC, REG, REG_mean, REG_corr), names_sep = "") |>
        dplyr::rename(REG0_corr = ref) |>
        dplyr::select(-REG_AC0) |>
        dplyr::arrange(year, qtr, month)

    return(reg_cjo)
}

compute_reg_cjo_rjd(groups_in = c(0, rep(1, 5), 0), start_reg = c(1990, 1), end_reg = c(2000, 1), frequency_reg = 12)
