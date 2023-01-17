
search_easter_periodicity <- function(){}

calendar <- data.frame(year = 2000:6000000) |> 
    dplyr::mutate(
        n_cycle_meton = year %% 19, 
        c = year %/% 100, 
        u = year %% 100, 
        s_bissextile = c %/% 4,
        t_bissextile = c %% 4,
        p_cycle_proemptose = (c + 8) %/% 25,
        q_proemptose = (c - p_cycle_proemptose + 1) %/% 3, 
        e_epacte = (19 * n_cycle_meton + c - s_bissextile - q_proemptose + 15) %% 30, 
        b_bissextile = u %/% 4, 
        d_bissextile = u %% 4, 
        L_dominicale = (2 * t_bissextile + 2 * b_bissextile - e_epacte - d_bissextile + 32) %% 7, 
        h_correction = (n_cycle_meton + 11 * e_epacte + 22 * L_dominicale) %/% 451,
        
        month_easter_meeus = (e_epacte + L_dominicale - 7 * h_correction + 114) %/% 31,
        day_easter_meeus = (e_epacte + L_dominicale - 7 * h_correction + 114) %% 31 + 1
    ) |> 
    dplyr::select(year, month_easter_meeus, day_easter_meeus) |>
    dplyr::mutate(
        a = year %% 19, # période 19
        b = year %% 4, # période 4
        c = year %% 7, # période 7
        k = year %/% 100, 
        p = (13 + 8 * k) %/% 25, 
        q = k %/% 4, 
        M = (15 - p + k - q) %% 30, 
        N = (4 + k - q) %% 7, # période 7
        d = (19 * a + M) %% 30, # Période 30
        e = (2 * b + 4 * c + 6 * d + N) %% 7, # période 7
        H = 22 + d + e, # période 30 * 7
        Q = H - 31,
        
        month_easter_gauss = 3 + (H > 31),
        day_easter_gauss = dplyr::case_when(
            month_easter_gauss == 3 ~ H, 
            d == 29 & e == 6 ~ 19, 
            d == 28 & e == 6 & (11 * M + 11) %% 30 < 19 ~ 18, 
            TRUE ~ Q
        )
    ) |> 
    dplyr::select(year, 
                  month_easter_meeus, day_easter_meeus, 
                  month_easter_gauss, day_easter_gauss)
    

find_periodicity <- function(v) {
    
    cond <- TRUE
    p <- 0
    while (cond) {
        p <- p + 1
        
        while (v[1] != v[p + 1]) {
            p <- p + 1
            if (p >= length(v)) {
                warning("La période actuelle est ", p, ". Je n'ai pas trouvé mieux.")
                return(NA)
            }
        }
        
        j <- 1
        cond <- FALSE
        while ((j + p < length(v)) && (v[j] == v[j + p])) {
            j <- j + 1
        }
        if (j + p < length(v)) cond <- TRUE
        if (p >= length(v)) {
            stop("La période actuelle est ", p, ". Je n'ai pas trouvé mieux.")
            return(NA)
        }
    }
    
    return(p)
    
}

res <- sapply(calendar[, -1], FUN = find_periodicity)


cond <- TRUE
p <- 5690000
while (cond) {
    p <- p + 1
    
    while (!all(calendar[1, 2:3] == calendar[1 + p, 2:3])) {
        p <- p + 1
    }
    print(p)
    
    j <- 1
    cond <- FALSE
    while (j < p && all(calendar[j, 2:3] == calendar[j + p, 2:3])) {
        j <- j + 1
        print(j)
    }
    if (j != p) cond <- TRUE
}
print(p)


