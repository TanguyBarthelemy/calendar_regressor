# Régresseurs de calendrier Stock


``` r
library("rjd3toolkit")
```


    Attaching package: 'rjd3toolkit'

    The following objects are masked from 'package:stats':

        aggregate, mad

## Introduction

Les variables stocks sont des régresseurs de calendrier basées sur un
certain jour de la période (mois ou trimestre).

## Structure des régresseurs

Les variables stock sont un jeu de 6 régresseurs composant les 6
premiers jours de la semaine (et dimanche par contraste). Ils prennent
pour valeur 0, 1 ou -1.

## Construction

### Séries trimestrielles

Les régresseurs de calendrier trimestriels sont égaux aux régresseurs
mensuels pour le dernier mois du trimestre.

Exemple : les régresseurs pour le T1 2024 prennent les mêmes valeurs que
mars 2024.

6 premiers mois de 2024 :

``` r
stock_td(frequency = 12L, c(2024L, 1L), length = 6L)
```

             Monday Tuesday Wednesday Thursday Friday Saturday
    Jan 2024      0       0         1        0      0        0
    Feb 2024      0       0         0        1      0        0
    Mar 2024     -1      -1        -1       -1     -1       -1
    Apr 2024      0       1         0        0      0        0
    May 2024      0       0         0        0      1        0
    Jun 2024     -1      -1        -1       -1     -1       -1

2 premiers trimestres de 2024 :

``` r
stock_td(frequency = 4L, c(2024L, 1L), length = 2L)
```

            Monday Tuesday Wednesday Thursday Friday Saturday
    2024 Q1     -1      -1        -1       -1     -1       -1
    2024 Q2     -1      -1        -1       -1     -1       -1

Pour la suite on étudie la construction des régresseurs mensuels

### Cas $1 <= w <= 31$

Ici w désigne un jour du mois.

Pour chaque période (exemple janvier 2025), le régresseur i (par exemple
lundi) vaut :

- 1 si le w<sup>ème</sup> jour de la période est de type i
- -1 si le w<sup>ème</sup> jour de la période est un dimanche
- 0 sinon

Par exemple, pour les 6 premiers mois de l’année 2025,

- le 13/01 est un lundi
- le 13/02 est un jeudi
- le 13/03 est un jeudi
- le 13/04 est un dimanche
- le 13/05 est un mardi
- le 13/06 est un vendredi

``` r
stock_td(frequency = 12L, c(2025L, 1L), length = 6L, w = 13L)
```

             Monday Tuesday Wednesday Thursday Friday Saturday
    Jan 2025      1       0         0        0      0        0
    Feb 2025      0       0         0        1      0        0
    Mar 2025      0       0         0        1      0        0
    Apr 2025     -1      -1        -1       -1     -1       -1
    May 2025      0       1         0        0      0        0
    Jun 2025      0       0         0        0      1        0

### Cas $w > 31$

Même comportement que pour $w = 31$.

### Cas $w <= 0$

Pour $w <= 0$, on considère les derniers jours du mois.

Ainsi :

- si $w = 0$, on regarde le dernier jour du mois,
- si $w = -1$, on regarde l’avant dernier jour du mois,
- …

Par exemple, pour le début d’année 2025,

- le 31/01 est un vendredi
- le 28/02 est un vendredi
- le 31/03 est un lundi
- le 30/04 est un mercredi
- le 31/05 est un samedi
- le 30/06 est un lundi

``` r
stock_td(frequency = 12L, c(2025L, 1L), length = 6L, w = 0L)
```

             Monday Tuesday Wednesday Thursday Friday Saturday
    Jan 2025      0       0         0        0      1        0
    Feb 2025      0       0         0        0      1        0
    Mar 2025      1       0         0        0      0        0
    Apr 2025      0       0         1        0      0        0
    May 2025      0       0         0        0      0        1
    Jun 2025      1       0         0        0      0        0
