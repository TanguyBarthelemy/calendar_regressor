Mon Document
================

    ## ---
    ## title: "Mon Document"
    ## output:
    ##   github_document: default
    ## ---
    ## 
    ## ```{r setup, include=FALSE}
    ## knitr::opts_chunk$set(echo = TRUE)
    ## ```
    ## 
    ## 
    ## Ainsi on peut définir les jours ouvrables $In_{i} = Day_{i} - Off_{i}$
    ## pour $i$ entre 1 et 7.
    ## 
    ## - On créé les jours TD (tradings days) comme contrast par rapport à un
    ##   référence (généralement le dimanche) : $TD_{i} = Day_{i} - Day_1$ pour
    ##   $i$ entre 2 et 7. Par abus de notation, des fois i parcourt \[1, 6\]
    ##   et non \[2, 7\] et alors 1 désigne le lundi et 6 le samedi.
    ## 
    ## - On créé la variable WD (working days) qui calcule un nombre moyen de
    ##   jours travaillé (en contraste)
    ## 
    ## ```math``` WD = \left(\sum_{i = 2}^{6} Day_{i}\right) - \frac{5}{2} \times \left(Day_1 + Day_7\right) ```math```
    ## 
    ## On applique la formule plus générale :
    ## 
    ## ``` math
    ## reg_{i} = group_{i} - group_0 \times \frac{#group_{i}}{#group_0}
    ## ```
    ## 
    ## ```math``` reg_{i} = group_{i} - group_0 \times \frac{Card(group_{i})}{Card(group_0)} ```math```
    ## 
    ## avec ici $i = 1$ et $group_1 = {2, 3, 4, 5, 6}$, $group_0 = {1, 7}$,
    ## $Card(x)$ le cardinal d’un ensemble.
