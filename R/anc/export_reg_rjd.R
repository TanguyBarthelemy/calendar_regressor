export_cjo_rjd <- function(name = "reg_cjo_m_rjd.csv",
                           start_reg = c(1990, 1),
                           end_reg = c(2029, 4),
                           frequency_reg = 4) {
    length_reg <- (end_reg[1] - start_reg[1]) * frequency_reg + (end_reg[2] - start_reg[2] + 1)

    reg1 <- rjd3modelling::htd(
        calendar = frenchCalendar, frequency = frequency_reg, start = start_reg, length = length_reg,
        groups = c(rep(1, 5), 0, 0), meanCorrection = TRUE, contrasts = TRUE, holiday = 7
    )
    colnames(reg1) <- "REG1_AC1"

    reg2 <- rjd3modelling::htd(
        calendar = frenchCalendar, frequency = frequency_reg, start = start_reg, length = length_reg,
        groups = c(rep(1, 5), 2, 0), meanCorrection = TRUE, contrasts = TRUE, holiday = 7
    )
    colnames(reg2) <- paste0("REG2_AC", 1:2)

    reg3 <- rjd3modelling::htd(
        calendar = frenchCalendar, frequency = frequency_reg, start = start_reg, length = length_reg,
        groups = c(1, rep(2, 4), 3, 0), meanCorrection = TRUE, contrasts = TRUE, holiday = 7
    )
    colnames(reg3) <- paste0("REG3_AC", 1:3)

    reg5 <- rjd3modelling::htd(
        calendar = frenchCalendar, frequency = frequency_reg, start = start_reg, length = length_reg,
        groups = c(1:5, 0, 0), meanCorrection = TRUE, contrasts = TRUE, holiday = 7
    )
    colnames(reg5) <- paste0("REG5_AC", 1:5)

    reg6 <- rjd3modelling::htd(
        calendar = frenchCalendar, frequency = frequency_reg, start = start_reg, length = length_reg,
        groups = c(1:6, 0), meanCorrection = TRUE, contrasts = TRUE, holiday = 7
    )
    colnames(reg6) <- paste0("REG6_AC", 1:6)

    jeu_reg <- cbind(reg1, reg2, reg3, reg5, reg6)
    colnames(jeu_reg) <- c(
        colnames(reg1),
        colnames(reg2),
        colnames(reg3),
        colnames(reg5),
        colnames(reg6)
    )

    jeu_reg_df <- data.frame(
        date = zoo::as.Date(time(jeu_reg)),
        jeu_reg
    )

    write.table(x = jeu_reg_df, file = paste0("./output/", name), row.names = FALSE, quote = FALSE, sep = ";", dec = ".")
}

export_cjo_rjd(name = "reg_cjo_m_rjd.csv", start_reg = c(1990, 1), end_reg = c(2030, 12), frequency_reg = 12)
export_cjo_rjd(name = "reg_cjo_t_rjd.csv", start_reg = c(1990, 1), end_reg = c(2030, 4), frequency_reg = 4)
