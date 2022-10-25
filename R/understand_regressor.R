
groups_in = c(0, rep(1, 5), 0)
groups_off = rep(0, 7)
start_reg = c(1990, 1) 
end_reg = c(1990 + 399, 12) 
frequency_reg = 12
length_reg <- (end_reg[1] - start_reg[1]) * frequency_reg + (end_reg[2] - start_reg[2] + 1)


a <- rjd3modelling::htd(
    frenchCalendar, frequency = frequency_reg, start = start_reg, length = length_reg, 
    groups = c(groups_in[-1], groups_in[1]) |> gsub(pattern = "REG", replacement = "") |> as.numeric(), 
    meanCorrection = TRUE, contrasts = FALSE)

b <- rjd3modelling::htd(
    frenchCalendar, frequency = frequency_reg, start = start_reg, length = length_reg, 
    groups = c(groups_in[-1], groups_in[1]) |> gsub(pattern = "REG", replacement = "") |> as.numeric(), 
    meanCorrection = FALSE, contrasts = FALSE)

d <- rjd3modelling::htd(
    frenchCalendar, frequency = frequency_reg, start = start_reg, length = length_reg, 
    groups = c(groups_in[-1], groups_in[1]) |> gsub(pattern = "REG", replacement = "") |> as.numeric(), 
    meanCorrection = TRUE, contrasts = TRUE)

f <- function(corr = a, non_corr = b, month_2 = 1, group = c(0, 1)) {
    tot <- cbind(corr[, paste0("group-", group)], non_corr[, paste0("group-", group)])
    tot_df <- cbind(Date = zoo::as.Date(time(tot)), 
                    as.data.frame(tot)) |> 
        dplyr::mutate(month_1 = lubridate::month(Date)) |> 
        subset(month_1 == month_2) |> 
        tibble::as_tibble()
    tot_df |> colnames() <- c("Date", paste0("a", group), 
                              paste0("b", group), "month")
    
    return(tot_df)
}

#Results :
#   Janvier : 1/7 et 1/7 - 1
#   Fevrier : aucun changement
#   Mars : lundi de paques --> fréquence paque lundi et - pour le dimanche
#   Juin : compliqué avec le lundi de pentecôte + jeudi de l'ascention
#   Juillet (comme janvier)
#   Août (comme janvier)
#   Septembre (comme fevrier)
#   Octobre (comme fevrier)
#   Novembre : 2/7 et 2/7 - 2
#   Décembre (comme janvier)


tot <- f(month = 5, group = 0:6)

diff_ <- rep(0, 7)
for (k in 0:6) {
    diff <- (tot[, paste0("a", k), drop = TRUE] - tot[, paste0("b", k), drop = TRUE]) |> unique()
    diff <- diff[1]
    
    diff_[k + 1] <- diff
}
print(diff_)
print(diff_ |> sum())
diff_[1] <- -diff_[1]
print(diff_ |> sum())



for (k in 1:6) {
    # print(k)
    # print(tot[, paste0("a", k), drop = TRUE] - tot[, paste0("b", k), drop = TRUE])
    val <- 0
    all.equal(tot[, paste0("a", k), drop = TRUE] - tot[, paste0("b", k), drop = TRUE], 
              rep(val, nrow(tot)),
              tolerance = 10**(-12)) |> 
        print()
}

monthplot(b[, "group-1"])

monthplot(a[, "group-1"])
