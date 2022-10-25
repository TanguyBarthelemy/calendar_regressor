premier <- rep(0, 7)

jour = 6 # samedi
for (year in 0:(400 * 1 - 1)) {
    # print(year)
    # print(jour)
    premier[jour + 1] <- premier[jour + 1] + 1
    if (year %% 400 == 0) {
        jour <- jour + 366
    } else if (year %% 100 == 0) {
        jour <- jour + 365
    } else if (year %% 4 == 0) {
        jour <- jour + 366
    } else {
        jour <- jour + 365
    }
    jour <- jour %% 7
}

print(premier)
print(premier / sum(premier))