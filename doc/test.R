library(stringr)

replace_math <- function(input) {
    # Remplacer $$ par ```math```
    output <- str_replace_all(input, "\\$\\$", "```math```")
    return(output)
}

# Lire le contenu du Rmd
input <- readLines("votre_fichier.Rmd", warn = FALSE, encoding = "UTF-8")

# Appliquer la fonction de remplacement
output <- replace_math(input)

# Écrire le contenu modifié
cat(output, sep = "\n")