################################################################################
########                 Programme de render du document                ########
################################################################################

rmarkdown::render(
    input = "./doc/Calendar-steps.Rmd",
    output_format = "all",
    output_dir = "./doc"
)

source("./doc/modify_gh_doc.R", encoding = "UTF-8")
file <- "./doc/Calendar-steps.md"
remove_double_dollar(file)
modify_simple_dollar(file)
modify_table(file)
modify_sum(file)
