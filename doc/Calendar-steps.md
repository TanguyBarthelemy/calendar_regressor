<style>
div.blue { background-color:#e6f0ff; border-radius: 5px; padding: 20px;}
div.green { background-color:#e6ffe8; border-radius: 5px; padding: 20px;}
</style>

## Divergence entre regresseurs Insee (**SAS**) et **RJD**

### Couleur des paragraphes

Dans la suite, les paragraphes verts sont des exemples numériques.

Les paragraphes bleus font référence à ce qui se passe en pratique (sur
**SAS** ou **rjd3modelling**).

### Notation

Dans la suite :

-   *i* désigne le jour de la semaine

-   *j* ou *m**o**i**s*<sub>*j*</sub> désigne le numéro du mois de
    l’année

-   *t* désigne la date à laquelle on se trouve (croisement de *j* et de
    l’anée)

### Préparation du calendrier

*Les formules appliquées ici sont expliquées dans la seconde partie du
document.*

-   On compte les jours (*N**b**D**a**y**s* est le nombre total de jour
    du mois) : *D**a**y*<sub>*i*</sub> est le nombre de jour n°i dans le
    mois (*D**a**y*<sub>1</sub> est le dimanche, *D**a**y*<sub>2</sub>
    le lundi, … *D**a**y*<sub>7</sub> est le samedi)

-   On compte les jours fériés *O**f**f*<sub>*i*</sub> est le nombre de
    jour férié tombant un jour n°i dans le mois (*O**f**f*<sub>1</sub>
    pour tous les dimanches, *O**f**f*<sub>2</sub> les lundis, … et
    *O**f**f*<sub>7</sub> les samedis)

-   On distingue alors jours *I**n* et jours *O**f**f* (selon fériés et
    vacances). En France la liste des jours *O**f**f* est :

    -   1er de l’an (1er janvier)
    -   Lundi de Paques
    -   Jeudi de l’ascension
    -   Lundi de pentecôte
    -   Fête du travail (1er mai)
    -   Armistice de 1945 (8 mai) mais uniquement depuis 1982
    -   Fête nationale (14 juillet)
    -   L’assomption (15 Août)
    -   Toussaint (1 novembre)
    -   Armistice de 1918 (11 novembre)
    -   Noël (25 décembre)
    -   les différents ponts (les lundi et vendredi à chaque fois qu’il
        y a un mardi ou un jeudi de férié) **ne sont pas considérés
        comme jours fériés**

Ainsi on peut définir les jours ouvrables
*I**n*<sub>*i*</sub> = *D**a**y*<sub>*i*</sub> − *O**f**f*<sub>*i*</sub>
pour *i* entre 1 et 7.

-   On créé les jours TD (tradings days) comme contrast par rapport à un
    référence (généralement le dimanche) :
    *T**D*<sub>*i*</sub> = *D**a**y*<sub>*i*</sub> − *D**a**y*<sub>1</sub>
    pour *i* entre 2 et 7. Par abus de notation, des fois i parcourt
    \[1, 6\] et non \[2, 7\] et alors 1 désigne le lundi et 6 le samedi.

-   On créé la variable WD (working days) qui calcule un nombre moyen de
    jours travaillé (en contraste)
    $$ WD = \left(\sum\_{i = 2}^{6} Day\_i\right) - \frac{5}{2} \times \left(Day\_1 + Day\_7\right) $$
    On applique la formule plus générale :

$$ reg\_i = group\_i - group\_0 \times \frac{\\# group\_i}{\\# group\_0} $$
avec ici *i* = 1 et *g**r**o**u**p*<sub>1</sub> = 2, 3, 4, 5, 6 et
*g**r**o**u**p*<sub>0</sub> = 1, 7

-   On créé les “Working week-days” = jours ouvrables (TD), en
    opposition les “Publics Holydays” (PH) et les “Weekday contrast”
    (Weekdays) :
    $$ TD = \sum\_{i = 2}^{6} In\_i $$
    $$ PH = \sum\_{i = 2}^{6} Off\_i $$
    $$ Weekdays = TD - \frac{5}{2} \times \left(PH + Day\_1 + Day\_7\right) $$

Ces variables s’appuient sur la structure de REG1 (lundi au vendredi
contre samedi et dimanche).

### Retrait des moyennes de long-terme

-   On va calculer les moyennes de long-terme pour les variables
    *D**a**y*<sub>*i*</sub> et les *O**f**f*<sub>*i*</sub>. Ces moyennes
    se calculent mois par mois :
    *m**e**a**n*\_*D**a**y*<sub>*i*, *m**o**i**s*\_*j*</sub> = ∑<sub>*a**n**n**e**e**s*</sub>*D**a**y*<sub>*i*, *m**o**i**s*\_*j*</sub>
    avec *i* l’indice du jour de la semaine entre 1 et 7 et
    *m**o**i**s*\_*j* le numéro du mois entre 1 et 12.
    *m**e**a**n*\_*O**f**f*<sub>*i*, *m**o**i**s*\_*j*</sub> = ∑<sub>*a**n**n**e**e**s*</sub>*O**f**f*<sub>*i*, *m**o**i**s*\_*j*</sub>
    avec *i* l’indice du jour de la semaine entre 1 et 7 et
    *m**o**i**s*\_*j* le numéro du mois entre 1 et 12

-   On peut ensuite recalculer de nouvelles variables :
    *D**a**y*<sub>*i*</sub>\_*c**o**r**r* = *D**a**y*<sub>*i*</sub> − *m**e**a**n*\_*D**a**y*<sub>*i*</sub>,
    *O**f**f*<sub>*i*</sub>\_*c**o**r**r* = *O**f**f*<sub>*i*</sub> − *m**e**a**n*\_*O**f**f*<sub>*i*</sub>,
    *I**n*<sub>*i*</sub>\_*c**o**r**r* = *D**a**y*<sub>*i*</sub>\_*c**o**r**r* − *O**f**f*<sub>*i*</sub>\_*c**o**r**r*,
    Ainsi que toutes les autres variables présentées précédemment avec
    les nouveaux *D**a**y*<sub>*i*</sub>\_*c**o**r**r*,
    *O**f**f*<sub>*i*</sub>\_*c**o**r**r* et
    *I**n*<sub>*i*</sub>\_*c**o**r**r*.

Remarques : Pour les régresseurs calculés par *rjd3modeling*, on ne
retire pas les mêmes éléments :
*I**n*<sub>*i*</sub>\_*c**o**r**r*\_*r**j**d* = *I**n*<sub>*i*</sub> + *m**e**a**n*\_*O**f**f*<sub>*i*</sub>

### Calcul des variables de regresseurs à partir des groupes

#### Présentation des différents jeux de régresseurs

Au total, on compte généralement 5 jeux de régresseurs. Un jeu de
régresseur est composé d’un ensemble de groupe. Chaque groupe contient
des types de jours :

-   le jeu REG1 créé 2 groupes de jours :
    -   *G*<sub>1</sub> = jours ouvrables
    -   *G*<sub>0</sub> = les autres
-   le jeu REG2 créé 3 groupes de jours :
    -   *G*<sub>1</sub> = jours ouvrables (sauf samedi)
    -   *G*<sub>2</sub> = les samedis ouvrables
    -   *G*<sub>0</sub> = les autres
-   le jeu REG3 créé 3 groupes de jours :
    -   *G*<sub>1</sub> = les lundis ouvrables
    -   *G*<sub>2</sub> = jours ouvrables (sauflundi et samedi)
    -   *G*<sub>3</sub> = les samedis ouvrables
    -   *G*<sub>0</sub> = les autres
-   le jeu REG5 créé 3 groupes de jours :
    -   *G*<sub>1</sub> = les lundis ouvrables
    -   *G*<sub>2</sub> = les mardis ouvrables
    -   *G*<sub>3</sub> = les mercredis ouvrables
    -   *G*<sub>4</sub> = les jeudis ouvrables
    -   *G*<sub>5</sub> = les vendredis ouvrables
    -   *G*<sub>0</sub> = les autres
-   le jeu REG6 créé 7 groupes de jours
    -   *G*<sub>1</sub> = lundi ouvrables
    -   *G*<sub>2</sub> = mardi ouvrables
    -   *G*<sub>3</sub> = mercredi ouvrables
    -   *G*<sub>4</sub> = jeudi ouvrables
    -   *G*<sub>5</sub> = vendredi ouvrables
    -   *G*<sub>6</sub> = samedi ouvrables
    -   *G*<sub>0</sub> = les autres)

#### Calculs des jeux de régresseurs

Nous allons ensuite créer les regresseurs de calendrier comme variable
de contraste par rapport à une référence. On prend généralement le
groupe 0 comme groupe de référence. Ainsi pour un jeu de régresseur qui
contient *n* groupes, on calcule *n* − 1 régresseurs.

Afin d’introduire de la comparabilité entre les groupes et avoir de
l’homogénéité dans nos contrastes, nous allons pondérer le groupe 0 à la
hauteur de la répartition du nombre de jour entre le groupe i et le
groupe 0.

Nos régresseurs s’écrivent ainsi :

*R**E**G*<sub>*n*</sub>\_*A**C*<sub>*k*</sub> = *R**E**G*<sub>*k*</sub> − *ω*<sub>*k*</sub>*R**E**G*<sub>0</sub>
avec ici *n* qui vaut 1, 3, 5, 6, … et *k* entre 1 et *n*.

De manière générale, les *ω*<sub>*k*</sub> sont calculés à partir de la
taille des groupes :
$$ \omega\_k = \frac{\\# group\_k}{\\# group\_0} $$

-   Pour les jeux de régresseurs issus de JD+ (*package*
    ***rjd3modelling***), les *ω*<sub>*k*</sub> sont calculés entre les
    jours d’une semaine classique. Ainsi, il y a 5 jours ouvrables (du
    lundi au vendredi) et 2 jours de week-end (samedi et dimanche).
    -   pour REG6, *ω*<sub>*k*</sub> = 1 car chaque groupe
        *G*<sub>*i*</sub> ne contient qu’un jour (du lundi au dimanche)
    -   pour REG1, $\omega\_k = \frac{5}{2}$ car le groupe 1
        *G*<sub>1</sub> (jours ouvrables) contient les jours du lundi au
        vendredi et le groupe 0 *G*<sub>0</sub> contient le samedi et le
        dimanche.
    -   … selon les configurations des groupes
-   Pour les jeux de régresseurs issus des programmes **SAS**, les jours
    comptabilisés dans les pondérations sont les jours *I**n* et les
    jours *O**f**f*.
    -   pour REG6, $\omega\_k = \frac{1}{8}$ car chaque groupe
        *G*<sub>*k*</sub> (pour *k* ≠ 0) ne contient qu’un seul jour
        alors que le groupe 0 *G*<sub>0</sub> contient 8 jours dans le
        sens : 1 dimanche en semaine classique (*I**n*) et 7 jours en
        semaine férié / vacances (*O**f**f*)
    -   pour REG1, $\omega\_k = \frac{5}{9}$ car le groupe 1 (jours
        ouvrables) contient 5 jours : les jours *I**n* du lundi au
        vendredi et le groupe 0 *G*<sub>0</sub> contient le samedi et le
        dimanche en semaine classique (*I**n*) et 7 jours en semaine
        férié / vacances (*O**f**f*).
    -   … selon les configurations des groupes

Les espaces formés par la combinaison de chaque jeu de régressurs
(**RJD** ou **SAS**) sont les mêmes. Mais les coefficients seront
différents et interprétés différemment.

## Théorie et pratique

### Présentation du modèle théorique

Le modèle initial s’écrit :

$$ \tag{1} D\_t = \sum ^{7}\_{i=1} \alpha \_{i} \times Day\_{i, t} $$

Avec *α*<sub>*i*</sub> l’effet du jour i (au moment t) sur notre
variable. On appelle *D*<sub>*t*</sub> l’effet déterministe du
calendrier sur variable à étudier.

Malheureusement, ce modèle n’est pas utilisable directement comme ça car
:

-   les régresseurs *D**a**y*<sub>*i*, *t*</sub> sont fortements
    corrélés (exemple : le nombre de lundi dans un mois vaut toujours
    entre 3 et 5, comme tous les autres jours)

-   les régresseurs sont saisonnier (exemple : en moyenne, il y aura
    plus de lundi en janvier qu’en février ou qu’en avril)

Aussi on remarque que $\sum ^{7}\_{i=1} Day\_{i, t} = NbDays\_t$ est
constant (par mois) sauf en février.

Pour contrer cela, on va chercher à séparer l’**effet cummulatif du
nombre total de jour du mois** de l’**effet net du nombre de type de
jour de la semaine** (exemple : nombre de lundi).

On réécrit l’équation en intégrant *N**b**D**a**y**s*<sub>*t*</sub>, le
nombre de jour total du mois et $\overline{\alpha}$ l’effet moyen d’un
type de jour :

$$ \tag{2} D\_t = \overline{\alpha} \times NbDays\_t + \sum ^{7}\_{i=1} \beta\_i \times Day\_{i, t} $$

Avec $\overline{\alpha} = \frac{1}{7} \sum ^{7}\_{i=1} \alpha\_i$ et
$\beta\_i = \alpha \_{i} - \overline{\alpha}$

On remarque alors que $\sum ^{7}\_{i=1} \beta\_i = 0$. Donc
$\beta\_7 = -\sum ^{6}\_{i=1} \beta\_i$ et on peut écrire nos
régresseurs en constraste du dimanche (ou de n’importe quel autre jour)
:

$$ \tag{3} D\_t = \overline{\alpha} \times NbDays\_t + \sum ^{6}\_{i=1} \beta\_i \times (Day\_{i, t} - Day\_{7, t}) $$

Ce modèle correspond *à peu près* au modèle REG6 mais on peut formuler
des hypothèses plus fortes pour créer de nouveaux jeux de régresseurs :

-   Si je suppose que
    *β*<sub>1</sub> = *β*<sub>2</sub> = *β*<sub>3</sub> = *β*<sub>4</sub> = *β*<sub>5</sub>
    et *β*<sub>6</sub> = *β*<sub>7</sub>, j’obtiens le modèle
    $D\_t = \overline{\alpha} \times NbDays\_t + \beta\_1 \times (\sum ^{5}\_{i=1} Day\_{i, t} - \frac{5}{2}(Day\_{6, t} + Day\_{7, t}))$
    qui correpond au jeu de régresseur REG1.

-   Si je suppose que
    *β*<sub>1</sub> = *β*<sub>2</sub> = *β*<sub>3</sub> = *β*<sub>4</sub> = *β*<sub>5</sub>,
    j’obtiens le modèle
    $D\_t = \overline{\alpha} \times NbDays\_t + \beta\_1 \times (\sum ^{5}\_{i=1} Day\_{i, t} - Day\_{7, t}) + \beta\_6 \times (Day\_{6, t} - Day\_{7, t})$
    qui correpond au jeu de régresseur REG2.

-   …

Finalement quelque soit le jeu de régresseur (regroupement de jour) que
l’on choisit, le modèle général s’écrit :

$$ \tag{4} D\_t = \beta\_0 \times LY\_t + \sum ^{n}\_{k=1} \beta \_{k} \times REC\_{n}\\\_AC\_{k, t} $$
Avec *L**Y*<sub>*t*</sub> la variable relative aux années bissextiles,
*β*<sub>*k*</sub> le coefficient de régression relatif au régresseur
*R**E**C*<sub>*n*</sub>\_*A**C*<sub>*k*, *t*</sub>.
$\beta\_0 = \overline{\alpha}$ est l’effet moyen de chaque type de jour.

Attention : les régresseurs que l’on considère
(*R**E**C*<sub>*n*</sub>\_*A**C*<sub>*k*, *t*</sub>,
*L**Y*<sub>*t*</sub>) sont “désaisonnalisés” dans une certaine mesure.
On leur a retiré la moyenne de long-terme. Ainsi *L**Y*<sub>*t*</sub>
diffère de *N**b**D**a**y**s*<sub>*t*</sub> par le retrait de sa moyenne
de long-terme par mois et vaut 0 pour tous les mois de l’année sauf pour
février pour lequel *L**Y*<sub>*t*</sub> vaut -0.25 les années
non-bissetiles et 0.75 les années bissextiles.

Ainsi le modèle présenté ci-dessus (4), diffèrent des modèles (1), (2)
et (3) par le retrait d’un terme purement saisonnier.

Cette remarque est importante car elle conditionne notre interprétation
des coefficients. Le coefficient *β*<sub>0</sub> n’aura plus la même
interprétation que $\overline{\alpha}$ car le régresseur n’est plus le
même.

### Interprétation des coefficients

Finalement lorsqu’on a notre résultat final, on cherche à interpréter
les coefficients finaux et comprendre quel régresseur / jour de la
semaine participe.

Tout d’abord, comme on l’a vu entre l’étape (1) et (2), les coefficients
que l’on a à commenter sont les *β*<sub>*i*</sub> (ou *β*<sub>*k*</sub>
quand on fait des groupes) et non les *α*<sub>*i*</sub>. Donc on ne
commente pas l’effet du type de jour *i* mais sa comparaison par rapport
un type de jour moyen. Cela explique que l’on peut avoir des
coefficients négatifs pour des types de jour où il y a de l’activité.

Exemple : pour le tableau suivant :

<table>
<thead>
<tr class="header">
<th style="text-align: center;">Regresseur</th>
<th style="text-align: center;">Coefficients</th>
<th style="text-align: center;">T-Stat</th>
<th style="text-align: center;">P[|T| &gt; t]</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">Lundi</td>
<td style="text-align: center;">0,0007</td>
<td style="text-align: center;">0,12</td>
<td style="text-align: center;">0,9032</td>
</tr>
<tr class="even">
<td style="text-align: center;">Mardi</td>
<td style="text-align: center;">0,0066</td>
<td style="text-align: center;">0,89</td>
<td style="text-align: center;">0,3856</td>
</tr>
<tr class="odd">
<td style="text-align: center;">Mercredi</td>
<td style="text-align: center;">0,0136</td>
<td style="text-align: center;">1,93</td>
<td style="text-align: center;">0,2280</td>
</tr>
<tr class="even">
<td style="text-align: center;">Jeudi</td>
<td style="text-align: center;">0,0090</td>
<td style="text-align: center;">1,25</td>
<td style="text-align: center;">0,2280</td>
</tr>
<tr class="odd">
<td style="text-align: center;">Vendredi</td>
<td style="text-align: center;">-0,0004</td>
<td style="text-align: center;">-0,05</td>
<td style="text-align: center;">0,9632</td>
</tr>
<tr class="even">
<td style="text-align: center;">Samedi</td>
<td style="text-align: center;">-0,0111</td>
<td style="text-align: center;">-1,43</td>
<td style="text-align: center;">0,1715</td>
</tr>
</tbody>
</table>

Donc $\beta\_7 = -\sum ^{6}\_{k=1} \beta \_{k} = -0,0184$ pour le
coefficient du dimanche.

On aurait envie de commenter : *« L’ajout d’un samedi en plus dans le
mois* **fait baisser l’activité** *de 0.0111. Cela est contradictoire
avec le fait qu’il y a de l’activité le samedi donc un samedi en plus
dans le mois devrait* **faire augmenter l’activité***. »*

Cependant ce n’est pas vrai, ici on commente un effet en comparaison de
l’effet moyen d’un type de jour moyen. La bonne explication est la
suivante : *« Chaque mois a le même nombre de jour. L’ajout d’un samedi
dans le mois retire obligatoirement un autre jour du mois. Il y a des
jours où l’activité est plus intense qu’un samedi. Donc* **en
moyenne***, le jour que l’on retire aurait apporté plus d’activité.
L’ajout d’un samedi “en plus” (= à la place d’un jour moyen) dans le
mois a un impact négatif sur l’activité. »*

#### Remarque 1 : Les régresseurs sont désaisonnalisés

Comme on l’a vu entre les équations (3) et (4), on retire les moyennes
de long-terme. Ainsi les régresseurs ne sont pas EXACTEMENT des nombres
de jours mais ce sont des séries désaisonnalisées (sans leur moyenne de
long-terme par mois).

#### Remarque 2 : le choix la variable mise en contraste n’a pas d’importance.

Si on repart de l’équation (3), on remarque que le choix du dimanche en
constraste est un choix arbitraire. On peut donc réécrire l’équation de
REG1 (par exemple) en conséquence :
$$ D\_t = \overline{\alpha} \times NbDays\_t - \frac{1}{5} \beta\_7 \times (Day\_{6, t} + Day\_{7, t} - \frac{2}{5} \sum ^{5}\_{i=1} Day\_{i, t}) $$
La réestimation de ce modèle donnera un
*β*<sub>7</sub> = *β*<sub>6</sub> identique au modèle REG1 écrit plus
haut et les autres $\beta\_i = -\frac{2}{5} \beta\_7$ (pour *i* entre 1
et 5) seront aussi les mêmes.

#### Remarque 3 : la réalité est plus complexe

Ici on a considéré un modèle simpliste. On a considéré que chaque jour
de l’année se partageait en 7 catégories (lundi, mardi, …, dimanche).
Seulement dans la réalité, les modèles de calendriers sont plus
complexes. Tout d’abord, on peut distinguer les jours *I**n* (jours
ouvrés) et les jours *O**f**f* (jours fériés) : cela nous donne 14 types
de jour différents. On peut aussi considérer des modèles personnalisés
selon l’activité.

Exemple : dans le transport routier, les camions peuvent rouler toute
l’année, jours ouvrés comme fériés. Seulement certains samedis, la
circulation des poids-lourds est interdite. Il faudrait idéalement,
créer un nouveau type de jour “samedi interdit” pour ces samedis.

## Remarques générales

### Ordre des opérations

Enfin on peut formuler une remarque sur l’ordre des opérations.

L’opération de calcul des moyennes prend une série (mensuelle ou
trimestrielle) et retire sa moyenne par période :
$$ \overline{X} = I\_1 \times (X - X\\\_{mean}\_1) + I\_2 \times (X - X\\\_{mean}\_2) + ... + I\_n \times (X - X\\\_{mean}\_n) $$
avec *I*<sub>*i*</sub> l’indicatrice de la période *i* et *n* le nombre
total de période (exemple *n* = 12 pour une fréquence mensuelle).

L’opération de contraste prend 2 séries et en fait une somme pondérée :
*X*\_*c**o**n**t**r**a**s**t**e* = *X* + *ω**Y*

Ces deux opérations sont des opérateurs linéaires ainsi on peut alterner
ces 2 formules lors du calcul des constrastes :
$$ \overline{X + \omega Y} = \overline{X} + \omega \overline{Y} $$

### Occurence du premier de l’an

Les règles de création des calendriers sont stables dans le temps (on
sait quel jour tombera le 26 mars dans 450 ans). Ainsi on peut calculer
les fréquences des jours de la semaine.

Nombre d’occurence en 400 ans :

<table>
<thead>
<tr class="header">
<th style="text-align: right;">Lundi</th>
<th style="text-align: right;">Mardi</th>
<th style="text-align: right;">Mercredi</th>
<th style="text-align: right;">Jeudi</th>
<th style="text-align: right;">Vendredi</th>
<th style="text-align: right;">Samedi</th>
<th style="text-align: right;">Dimanche</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: right;">56</td>
<td style="text-align: right;">58</td>
<td style="text-align: right;">57</td>
<td style="text-align: right;">57</td>
<td style="text-align: right;">58</td>
<td style="text-align: right;">56</td>
<td style="text-align: right;">58</td>
</tr>
</tbody>
</table>

Fréquence d’apparition un premier de l’an :

<table>
<thead>
<tr class="header">
<th style="text-align: right;">Lundi</th>
<th style="text-align: right;">Mardi</th>
<th style="text-align: right;">Mercredi</th>
<th style="text-align: right;">Jeudi</th>
<th style="text-align: right;">Vendredi</th>
<th style="text-align: right;">Samedi</th>
<th style="text-align: right;">Dimanche</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: right;">0.14</td>
<td style="text-align: right;">0.145</td>
<td style="text-align: right;">0.1425</td>
<td style="text-align: right;">0.1425</td>
<td style="text-align: right;">0.145</td>
<td style="text-align: right;">0.14</td>
<td style="text-align: right;">0.145</td>
</tr>
</tbody>
</table>
