file <- "./doc/Calendar-steps.md"

# Lire le contenu du Rmd
input <- readLines(con = file, warn = FALSE, encoding = "UTF-8")

output <- ""
# Parcourir les lignes
for (line in input) {
    if (grepl("^\\$\\$", line)) {

        new_line <- gsub(pattern = "^\\$\\$|\\$\\$$",
                         replacement = "", x = line)

        output <- paste0(output, paste("```math", new_line, "```", sep = "\n"), "\n")

    } else {
        output <- paste0(output, line, "\n")
    }
}

writeLines(text = output, con = file)




# Lire le contenu du Rmd
input <- readLines(file, warn = FALSE, encoding = "UTF-8")

# Remplacer les occurrences de $...$ par $`...`$
output <- gsub("\\$([^$]+)\\$", "$`\\1`$", input)

# Écrire le contenu modifié dans un nouveau fichier
cat(output, file = file, sep = "\n")

