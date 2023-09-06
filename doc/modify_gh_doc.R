# En double dollar, il y a des problème pour certains symboles (#, _) donc on passe en balise math
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

# En simple dollar, il y a des problème pour certains symboles (#, _) donc on passe en $`...`$
modify_simple_dollar <- function(file) {
    # Lire le contenu du Rmd
    input <- readLines(file, warn = FALSE, encoding = "UTF-8")

    # Remplacer les occurrences de $...$ par $`...`$
    output <- gsub("\\$([^$]+)\\$", "$`\\1`$", input)

    # Écrire le contenu modifié dans un nouveau fichier
    writeLines(text = output, con = file)

    return(invisible(output))
}

# Les tables formattable génèrent des styles non pris en main par github_document
modify_table <- function(file) {
    # Lire le contenu du Rmd
    input <- readLines(file, warn = FALSE, encoding = "UTF-8")

    # Utiliser une expression régulière pour retirer le contenu entre <style> et </style>
    output <- gsub("<style>.*?</style>", "", input, perl = TRUE)

    # Écrire le contenu modifié dans un nouveau fichier
    writeLines(text = output, con = file)

    return(invisible(output))
}

modify_sum <- function(file) {
    input <- readLines(file, warn = FALSE, encoding = "UTF-8")

    output <- ""
    pattern <- "\\$`[^$]*\\\\sum[^$]*`\\$"

    for (k in seq_along(input)) {

        line <- input[k]
        new_lines <- line

        if (grepl(pattern, line)) {

            matches <- gregexpr(pattern, line)
            texts <- stringr::str_split(line, pattern) |> unlist()
            math <- regmatches(line, matches) |> unlist()
            math <- math |> substr(3, nchar(math))
            math <- math |> substr(1, nchar(math) - 2)

            math <- paste0("\n\n```math\n", math, "\n```\n\n")

            new_lines <- paste(texts, c(math, ""))
        }
        output <- paste0(output, new_lines, "\n")
    }

    # Écrire le contenu modifié dans un nouveau fichier
    writeLines(text = output, con = file)

    return(invisible(output))
}
