
source("./R/compare_REG1_mens_SAS_vs_RJD.R")



REG1_RJD <- comp_reg1_mens_ts[, "REG1_RJD"]
REG1_RJD_tab <- do.call(cbind, split(REG1_RJD, f = cycle(REG1_RJD)))

REG1_SAS <- comp_reg1_mens_ts[, "REG1_SAS"]
REG1_SAS_tab <- do.call(cbind, split(REG1_SAS, f = cycle(REG1_SAS)))

TOT_REG1 <- as.data.frame(cbind(REG1_RJD_tab, REG1_SAS_tab))
colnames(TOT_REG1) <- c(paste0(month.abb, "_RJD"), 
                        paste0(month.abb, "_SAS"))

f <- function(n) {
    v_date <- data.frame(nb_month = integer(0), 
                         min = numeric(0), 
                         max = numeric(0), 
                         moy = numeric(0), 
                         med = numeric(0))
    
    for (nb_month in 1:n) {
        v <- numeric(0)
        
        for (start in 1:(31 * 12 - nb_month)) {
            # print(paste("y", y))
            val <- mean(window(a1, start = c(1990, start), end = c(1990, start + nb_month)))
            v <- c(v, val)
        }
        
        v_date <- rbind(v_date, c(nb_month = nb_month, min = min(v), max = max(v), moy = mean(v), med = median(v)))
    }
    
    colnames(v_date) <- c("nb_month", "min", "max", "moy", "med")
    return(v_date)
}

f(24)
