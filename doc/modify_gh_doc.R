remove_double_dollar <- function(file) {
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

    return(invisible(output))
}

modify_simple_dollar <- function(file) {
    # Lire le contenu du Rmd
    input <- readLines(file, warn = FALSE, encoding = "UTF-8")

    # Remplacer les occurrences de $...$ par $`...`$
    output <- gsub("\\$([^$]+)\\$", "$`\\1`$", input)

    # Écrire le contenu modifié dans un nouveau fichier
    writeLines(text = output, con = file)

    return(invisible(output))
}

modify_table <- function(file) {
    # Lire le contenu du Rmd
    input <- readLines(file, warn = FALSE, encoding = "UTF-8")

    # Utiliser une expression régulière pour retirer le contenu entre <style> et </style>
    output <- gsub("<style>.*?</style>", "", input, perl = TRUE)

    # Écrire le contenu modifié dans un nouveau fichier
    writeLines(text = output, con = file)

    return(invisible(output))
}
