################################################################################
########                 Programme de render du document                ########
################################################################################

rmarkdown::render("./doc/Calendar-steps.Rmd",
    output_format = "all", output_dir = "./doc"
)

source("./doc/modify_gh_doc.R", encoding = "UTF-8")

# rmarkdown::render("./doc/Calendar-steps.Rmd",
#                   output_format = "html_document", output_dir = "./doc")
# rmarkdown::render("./doc/Calendar-steps.Rmd",
#                   output_format = "pdf_document", output_dir = "./doc")
# rmarkdown::render("./doc/Calendar-steps.Rmd",
#                   output_format = "github_document", output_dir = "./doc")
