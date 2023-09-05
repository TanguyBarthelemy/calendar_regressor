Comment créer des régresseurs de calendrier ?
================
Tanguy


$\[mean\_off{i,j}=4\]$



## Divergence entre regresseurs Insee (**SAS**) et **RJD**

### Couleur des paragraphes

<div class="green">

Dans la suite, les paragraphes verts sont des exemples numériques.

</div>

<div class="blue">

Les paragraphes bleus font référence à ce qui se passe en pratique (sur
**SAS** ou **rjd3toolkit**).

</div>

### Notation

Dans la suite :

- $i$ désigne le jour de la semaine

- $j$ ou $mois_j$ désigne le numéro du mois de l’année

- $t$ désigne la date à laquelle on se trouve (croisement de $j$ et de
  l’anée)

### Préparation du calendrier

*Les formules appliquées ici sont expliquées dans la seconde partie du
document.*

- On compte les jours ($NbDays$ est le nombre total de jour du mois) :
  $Day_{i}$ est le nombre de jour n°i dans le mois ($Day_1$ est le
  dimanche, $Day_2$ le lundi, … $Day_7$ est le samedi)

- On compte les jours fériés $Off_{i}$ est le nombre de jour férié
  tombant un jour n°i dans le mois ($Off_1$ pour tous les dimanches,
  $Off_2$ les lundis, … et $Off_7$ les samedis)

- On distingue alors jours $In$ et jours $Off$ (selon fériés et
  vacances). En France la liste des jours $Off$ est :

  - 1er de l’an (1er janvier)
  - Lundi de Pâques
  - Jeudi de l’ascension
  - Lundi de pentecôte
  - Fête du travail (1er mai)
  - Armistice de 1945 (8 mai) mais uniquement depuis 1982
  - Fête nationale (14 juillet)
  - L’assomption (15 Août)
  - Toussaint (1 novembre)
  - Armistice de 1918 (11 novembre)
  - Noël (25 décembre)
  - les différents ponts (les lundi et vendredi à chaque fois qu’il y a
    un mardi ou un jeudi de férié) **ne sont pas considérés comme jours
    fériés**

Ainsi on peut définir les jours ouvrables $In_{i} = Day_{i} - Off_{i}$
pour $i$ entre 1 et 7.

- On créé les jours TD (tradings days) comme contrast par rapport à un
  référence (généralement le dimanche) : $TD_{i} = Day_{i} - Day_1$ pour
  $i$ entre 2 et 7. Par abus de notation, des fois i parcourt \[1, 6\]
  et non \[2, 7\] et alors 1 désigne le lundi et 6 le samedi.

- On créé la variable WD (working days) qui calcule un nombre moyen de
  jours travaillé (en contraste)

$$ WD = \left(\sum_{i = 2}^{6} Day_{i}\right) - \frac{5}{2} \times \left(Day_1 + Day_7\right) $$

On applique la formule plus générale :

$$ reg_{i} = group_{i} - group_0 \times \frac{Card(group_{i})}{Card(group_0)} $$

avec ici $i = 1$ et $group_1 = {2, 3, 4, 5, 6}$, $group_0 = {1, 7}$,
$Card(x)$ le cardinal d’un ensemble.

- On créé les “Working week-days” = jours ouvrables (TD), en opposition
  les “Publics Holydays” (PH) et les “Weekday contrast” (Weekdays) :

$$ TD = \sum_{i = 2}^{6} In_{i} $$

$$ PH = \sum_{i = 2}^{6} Off_{i} $$

$$ Weekdays = TD - \frac{5}{2} \times \left(PH + Day_1 + Day_7\right) $$

Ces variables s’appuient sur la structure de REG1 (lundi au vendredi
contre samedi et dimanche).

### Retrait des moyennes de long-terme

- On va calculer les moyennes de long-terme pour les variables $Day_{i}$
  et les $Off_{i}$. Ces moyennes se calculent mois par mois :

$$ mean\_Day_{i, mois\_j} = \sum_{annees} Day_{i, mois\_j} $$

$$ \text{mean_}Day_{i, mois\_j} = \sum_{annees} Day_{i, mois\_j} $$

avec $i$ l’indice du jour de la semaine entre 1 et 7 et $mois\\_j$ le
numéro du mois entre 1 et 12.

$$ mean\\_Off_{i, mois\\_j} = \sum_{annees} Off_{i, mois\\_j} $$

avec $i$ l’indice du jour de la semaine entre 1 et 7 et $mois\\_j$ le
numéro du mois entre 1 et 12

- On peut ensuite recalculer de nouvelles variables :
  $Day_{i}\\_corr = Day_{i} - mean\\_Day_{i}$,
  $Off_{i}\\_corr = Off_{i} - mean\\_Off_{i}$ et
  $In_{i}\\_corr = Day_{i}\\_corr - Off_{i}\\_corr$.

Ainsi que toutes les autres variables présentées précédemment avec les
nouveaux $Day_{i}\\_corr$, $Off_{i}\\_corr$ et $In_{i}\\_corr$.

<div class="blue">

Remarques : Pour les régresseurs calculés par *rjd3toolkit*, les
moyennes de long-terme sont calculés de manière théorique. On suppose
que chaque jour de l’année a autant de chance d’être un lundi, un mardi,
…, un dimanche. Ainsi les moyennes de long-termes sont calculées par une
somme de $1/7$.

Par exemple, pour les jours Off du mois de janvier, les moyennes de
long-terme des 7 types de jours valent $1/7$. Pour le mois de novembre,
c’est $2/7$.

Le calcul est aussi théorique pour les moyennes de la variable Day.
Ainsi on retire le 29ème jour de février (pour les années bissextiles)
pour laisser sont influence calculées par le régresseur LY (leap-year).

</div>

### Calcul des variables de regresseurs à partir des groupes

#### Présentation des différents jeux de régresseurs

Au total, on compte généralement 5 jeux de régresseurs. Un jeu de
régresseur est composé d’un ensemble de groupe. Chaque groupe contient
des types de jours :

- le jeu REG1 créé 2 groupes de jours :
  - $G_1$ = jours ouvrables
  - $G_0$ = les autres
- le jeu REG2 créé 3 groupes de jours :
  - $G_1$ = jours ouvrables (sauf samedi)
  - $G_2$ = les samedis ouvrables
  - $G_0$ = les autres
- le jeu REG3 créé 3 groupes de jours :
  - $G_1$ = les lundis ouvrables
  - $G_2$ = jours ouvrables (sauflundi et samedi)
  - $G_3$ = les samedis ouvrables
  - $G_0$ = les autres
- le jeu REG5 créé 3 groupes de jours :
  - $G_1$ = les lundis ouvrables
  - $G_2$ = les mardis ouvrables
  - $G_3$ = les mercredis ouvrables
  - $G_4$ = les jeudis ouvrables
  - $G_5$ = les vendredis ouvrables
  - $G_0$ = les autres
- le jeu REG6 créé 7 groupes de jours
  - $G_1$ = lundi ouvrables
  - $G_2$ = mardi ouvrables
  - $G_3$ = mercredi ouvrables
  - $G_4$ = jeudi ouvrables
  - $G_5$ = vendredi ouvrables
  - $G_6$ = samedi ouvrables
  - $G_0$ = les autres)

<div class="tabwid"><style>.cl-1995abd8{}.cl-1983dcdc{font-family:'Arial';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-1983dcfa{font-family:'Arial';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(246, 206, 182, 1.00);background-color:transparent;}.cl-1983dd04{font-family:'Arial';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(179, 226, 205, 1.00);background-color:transparent;}.cl-1983dd0e{font-family:'Arial';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(217, 210, 231, 1.00);background-color:transparent;}.cl-1983dd0f{font-family:'Arial';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(238, 224, 215, 1.00);background-color:transparent;}.cl-1983dd18{font-family:'Arial';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(247, 243, 183, 1.00);background-color:transparent;}.cl-1983dd19{font-family:'Arial';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(244, 229, 199, 1.00);background-color:transparent;}.cl-1983dd22{font-family:'Arial';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(204, 204, 204, 1.00);background-color:transparent;}.cl-1989a072{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-1989a086{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-1989a090{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-1989d0a6{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0ba{width:0.4in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0c4{width:0.4in;background-color:rgba(215, 255, 242, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0c5{width:0.4in;background-color:rgba(255, 253, 215, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0ce{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0cf{width:0.4in;background-color:rgba(246, 206, 182, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0d8{width:0.4in;background-color:rgba(179, 226, 205, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0d9{width:0.4in;background-color:rgba(217, 210, 231, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0e2{width:0.4in;background-color:rgba(238, 224, 215, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0e3{width:0.4in;background-color:rgba(247, 243, 183, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0ec{width:0.4in;background-color:rgba(244, 229, 199, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0ed{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0f6{width:0.4in;background-color:rgba(246, 206, 182, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d0f7{width:0.4in;background-color:rgba(217, 210, 231, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d100{width:0.4in;background-color:rgba(238, 224, 215, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d10a{width:0.4in;background-color:rgba(247, 243, 183, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d10b{width:0.4in;background-color:rgba(244, 229, 199, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d114{width:0.4in;background-color:rgba(204, 204, 204, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1989d115{width:0.4in;background-color:rgba(179, 226, 205, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}</style><table data-quarto-disable-processing='true' class='cl-1995abd8'><thead><tr style="overflow-wrap:break-word;"><th  colspan="8"class="cl-1989d0a6"><p class="cl-1989a072"><span class="cl-1983dcdc">Ouvrable</span></p></th><th  colspan="7"class="cl-1989d0ba"><p class="cl-1989a072"><span class="cl-1983dcdc">Férié</span></p></th></tr><tr style="overflow-wrap:break-word;"><th class="cl-1989d0a6"><p class="cl-1989a072"><span class="cl-1983dcdc">REG</span></p></th><th class="cl-1989d0c4"><p class="cl-1989a072"><span class="cl-1983dcdc">Lun</span></p></th><th class="cl-1989d0c4"><p class="cl-1989a072"><span class="cl-1983dcdc">Mar</span></p></th><th class="cl-1989d0c4"><p class="cl-1989a072"><span class="cl-1983dcdc">Mer</span></p></th><th class="cl-1989d0c4"><p class="cl-1989a072"><span class="cl-1983dcdc">Jeu</span></p></th><th class="cl-1989d0c4"><p class="cl-1989a072"><span class="cl-1983dcdc">Ven</span></p></th><th class="cl-1989d0c4"><p class="cl-1989a072"><span class="cl-1983dcdc">Sam</span></p></th><th class="cl-1989d0c4"><p class="cl-1989a072"><span class="cl-1983dcdc">Dim</span></p></th><th class="cl-1989d0c5"><p class="cl-1989a072"><span class="cl-1983dcdc">Lun</span></p></th><th class="cl-1989d0c5"><p class="cl-1989a072"><span class="cl-1983dcdc">Mar</span></p></th><th class="cl-1989d0c5"><p class="cl-1989a072"><span class="cl-1983dcdc">Mer</span></p></th><th class="cl-1989d0c5"><p class="cl-1989a072"><span class="cl-1983dcdc">Jeu</span></p></th><th class="cl-1989d0c5"><p class="cl-1989a072"><span class="cl-1983dcdc">Ven</span></p></th><th class="cl-1989d0c5"><p class="cl-1989a072"><span class="cl-1983dcdc">Sam</span></p></th><th class="cl-1989d0c5"><p class="cl-1989a072"><span class="cl-1983dcdc">Dim</span></p></th></tr></thead><tbody><tr style="overflow-wrap:break-word;"><td class="cl-1989d0ce"><p class="cl-1989a086"><span class="cl-1983dcdc">REG1</span></p></td><td class="cl-1989d0cf"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0cf"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0cf"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0cf"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0cf"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-1989d0ce"><p class="cl-1989a086"><span class="cl-1983dcdc">REG2</span></p></td><td class="cl-1989d0cf"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0cf"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0cf"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0cf"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0cf"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0d9"><p class="cl-1989a090"><span class="cl-1983dd0e">2</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-1989d0ce"><p class="cl-1989a086"><span class="cl-1983dcdc">REG3</span></p></td><td class="cl-1989d0cf"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0d9"><p class="cl-1989a090"><span class="cl-1983dd0e">2</span></p></td><td class="cl-1989d0d9"><p class="cl-1989a090"><span class="cl-1983dd0e">2</span></p></td><td class="cl-1989d0d9"><p class="cl-1989a090"><span class="cl-1983dd0e">2</span></p></td><td class="cl-1989d0d9"><p class="cl-1989a090"><span class="cl-1983dd0e">2</span></p></td><td class="cl-1989d0e2"><p class="cl-1989a090"><span class="cl-1983dd0f">3</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-1989d0ce"><p class="cl-1989a086"><span class="cl-1983dcdc">REG5</span></p></td><td class="cl-1989d0cf"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0d9"><p class="cl-1989a090"><span class="cl-1983dd0e">2</span></p></td><td class="cl-1989d0e2"><p class="cl-1989a090"><span class="cl-1983dd0f">3</span></p></td><td class="cl-1989d0e3"><p class="cl-1989a090"><span class="cl-1983dd18">4</span></p></td><td class="cl-1989d0ec"><p class="cl-1989a090"><span class="cl-1983dd19">5</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d0d8"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-1989d0ed"><p class="cl-1989a086"><span class="cl-1983dcdc">REG6</span></p></td><td class="cl-1989d0f6"><p class="cl-1989a090"><span class="cl-1983dcfa">1</span></p></td><td class="cl-1989d0f7"><p class="cl-1989a090"><span class="cl-1983dd0e">2</span></p></td><td class="cl-1989d100"><p class="cl-1989a090"><span class="cl-1983dd0f">3</span></p></td><td class="cl-1989d10a"><p class="cl-1989a090"><span class="cl-1983dd18">4</span></p></td><td class="cl-1989d10b"><p class="cl-1989a090"><span class="cl-1983dd19">5</span></p></td><td class="cl-1989d114"><p class="cl-1989a090"><span class="cl-1983dd22">6</span></p></td><td class="cl-1989d115"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d115"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d115"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d115"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d115"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d115"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d115"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td><td class="cl-1989d115"><p class="cl-1989a090"><span class="cl-1983dd04">0</span></p></td></tr></tbody></table></div>

#### Calculs des jeux de régresseurs

Nous allons ensuite créer les regresseurs de calendrier comme variable
de contraste par rapport à une référence. On prend généralement le
groupe 0 comme groupe de référence. Ainsi pour un jeu de régresseur qui
contient $n$ groupes, on calcule $n-1$ régresseurs.

Afin d’introduire de la comparabilité entre les groupes et avoir de
l’homogénéité dans nos contrastes, nous allons pondérer le groupe 0 à la
hauteur de la répartition du nombre de jour entre le groupe i et le
groupe 0.

Nos régresseurs s’écrivent ainsi :

$$ REG_n\\_AC_k = REG_k - \omega_k REG_0 $$ avec ici $n$ qui vaut 1, 3,
5, 6, … et $k$ entre 1 et $n$.

De manière générale, les $\omega_k$ sont calculés à partir de la taille
des groupes : $$ \omega_k = \frac{\# group_k}{\# group_0} $$

<div class="blue">

- Pour les jeux de régresseurs issus de JD+ (*package*
  ***rjd3modelling***), les $\omega_k$ sont calculés entre les jours
  d’une semaine classique. Ainsi, il y a 5 jours ouvrables (du lundi au
  vendredi) et 2 jours de week-end (samedi et dimanche).
  - pour REG6, $\omega_k = 1$ car chaque groupe $G_{i}$ ne contient
    qu’un jour (du lundi au dimanche)
  - pour REG1, $\omega_k = \frac{5}{2}$ car le groupe 1 $G_1$ (jours
    ouvrables) contient les jours du lundi au vendredi et le groupe 0
    $G_0$ contient le samedi et le dimanche.
  - … selon les configurations des groupes
- Pour les jeux de régresseurs issus des programmes **SAS**, les jours
  comptabilisés dans les pondérations sont les jours $In$ et les jours
  $Off$.
  - pour REG6, $\omega_k = \frac{1}{8}$ car chaque groupe $G_k$ (pour
    $k \neq 0$) ne contient qu’un seul jour alors que le groupe 0 $G_0$
    contient 8 jours dans le sens : 1 dimanche en semaine classique
    ($In$) et 7 jours en semaine férié / vacances ($Off$)
  - pour REG1, $\omega_k = \frac{5}{9}$ car le groupe 1 (jours
    ouvrables) contient 5 jours : les jours $In$ du lundi au vendredi et
    le groupe 0 $G_0$ contient le samedi et le dimanche en semaine
    classique ($In$) et 7 jours en semaine férié / vacances ($Off$).
  - … selon les configurations des groupes

Les espaces formés par la combinaison de chaque jeu de régressurs
(**RJD** ou **SAS**) sont les mêmes. Mais les coefficients seront
différents et interprétés différemment.

</div>

## Théorie et pratique

### Présentation du modèle théorique

Le modèle initial s’écrit :

$$ \tag{1} D_t = \sum ^{7}_{i=1} \alpha _{i} \times Day_{i, t} $$

Avec $\alpha_{i}$ l’effet du jour i (au moment t) sur notre variable. On
appelle $D_t$ l’effet déterministe du calendrier sur variable à étudier.

Malheureusement, ce modèle n’est pas utilisable directement comme ça car
:

- les régresseurs $Day_{i, t}$ sont fortements corrélés (exemple : le
  nombre de lundi dans un mois vaut toujours entre 3 et 5, comme tous
  les autres jours)

- les régresseurs sont saisonnier (exemple : en moyenne, il y aura plus
  de lundi en janvier qu’en février ou qu’en avril)

Aussi on remarque que $\sum ^{7}_{i=1} Day_{i, t} = NbDays_t$ est
constant (par mois) sauf en février.

Pour contrer cela, on va chercher à séparer l’**effet cummulatif du
nombre total de jour du mois** de l’**effet net du nombre de type de
jour de la semaine** (exemple : nombre de lundi).

On réécrit l’équation en intégrant $NbDays_t$, le nombre de jour total
du mois et $\overline{\alpha}$ l’effet moyen d’un type de jour :

$$ \tag{2} D_t = \overline{\alpha} \times NbDays_t + \sum ^{7}_{i=1} \beta_{i} \times Day_{i, t} $$

Avec $\overline{\alpha} = \frac{1}{7} \sum ^{7}_{i=1} \alpha_{i}$ et
$\beta_{i} = \alpha _{i} - \overline{\alpha}$

On remarque alors que $\sum ^{7}_{i=1} \beta_{i} = 0$. Donc
$\beta_7 = -\sum ^{6}_{i=1} \beta_{i}$ et on peut écrire nos régresseurs
en constraste du dimanche (ou de n’importe quel autre jour) :

$$ \tag{3} D_t = \overline{\alpha} \times NbDays_t + \sum ^{6}_{i=1} \beta_{i} \times (Day_{i, t} - Day_{7, t}) $$

Ce modèle correspond *à peu près* au modèle REG6 mais on peut formuler
des hypothèses plus fortes pour créer de nouveaux jeux de régresseurs :

- Si je suppose que $\beta_1 = \beta_2 = \beta_3 = \beta_4 = \beta_5$ et
  $\beta_6 = \beta_7$, j’obtiens le modèle
  $D_t = \overline{\alpha} \times NbDays_t + \beta_1 \times (\sum ^{5}_{i=1} Day_{i, t} - \frac{5}{2}(Day_{6, t} + Day_{7, t}))$
  qui correpond au jeu de régresseur REG1.

- Si je suppose que $\beta_1 = \beta_2 = \beta_3 = \beta_4 = \beta_5$,
  j’obtiens le modèle
  $D_t = \overline{\alpha} \times NbDays_t + \beta_1 \times (\sum ^{5}_{i=1} Day_{i, t} - Day_{7, t}) + \beta_6 \times (Day_{6, t} - Day_{7, t})$
  qui correpond au jeu de régresseur REG2.

- …

Finalement quelque soit le jeu de régresseur (regroupement de jour) que
l’on choisit, le modèle général s’écrit :

$$ \tag{4} D_t = \beta_0 \times LY_t + \sum ^{n}_{k=1} \beta _{k} \times REC_{n}\\_AC_{k, t} $$
Avec $LY_t$ la variable relative aux années bissextiles, $\beta_k$ le
coefficient de régression relatif au régresseur $REC_{n}\\_AC_{k, t}$.
$\beta_0 = \overline{\alpha}$ est l’effet moyen de chaque type de jour.

Attention : les régresseurs que l’on considère ($REC_{n}\\_AC_{k, t}$,
$LY_t$) sont “désaisonnalisés” dans une certaine mesure. On leur a
retiré la moyenne de long-terme. Ainsi $LY_t$ diffère de $NbDays_t$ par
le retrait de sa moyenne de long-terme par mois et vaut 0 pour tous les
mois de l’année sauf pour février pour lequel $LY_t$ vaut -0.25 les
années non-bissetiles et 0.75 les années bissextiles.

Ainsi le modèle présenté ci-dessus (4), diffèrent des modèles (1), (2)
et (3) par le retrait d’un terme purement saisonnier.

Cette remarque est importante car elle conditionne notre interprétation
des coefficients. Le coefficient $\beta_0$ n’aura plus la même
interprétation que $\overline{\alpha}$ car le régresseur n’est plus le
même.

### Interprétation des coefficients

Finalement lorsqu’on a notre résultat final, on cherche à interpréter
les coefficients finaux et comprendre quel régresseur / jour de la
semaine participe.

Tout d’abord, comme on l’a vu entre l’étape (1) et (2), les coefficients
que l’on a à commenter sont les $\beta_{i}$ (ou $\beta_k$ quand on fait
des groupes) et non les $\alpha_{i}$. Donc on ne commente pas l’effet du
type de jour $i$ mais sa comparaison par rapport un type de jour moyen.
Cela explique que l’on peut avoir des coefficients négatifs pour des
types de jour où il y a de l’activité.

<div class="green">

Exemple : pour le tableau suivant :

| Regresseur | Coefficients | T-Stat | P\[\|T\| \> t\] |
|:----------:|:------------:|:------:|:---------------:|
|   Lundi    |    0,0007    |  0,12  |     0,9032      |
|   Mardi    |    0,0066    |  0,89  |     0,3856      |
|  Mercredi  |    0,0136    |  1,93  |     0,2280      |
|   Jeudi    |    0,0090    |  1,25  |     0,2280      |
|  Vendredi  |   -0,0004    | -0,05  |     0,9632      |
|   Samedi   |   -0,0111    | -1,43  |     0,1715      |

Donc $\beta_7 = -\sum ^{6}_{k=1} \beta _{k} = -0,0184$ pour le
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

</div>

#### Remarque 1 : Les régresseurs sont désaisonnalisés

Comme on l’a vu entre les équations (3) et (4), on retire les moyennes
de long-terme. Ainsi les régresseurs ne sont pas EXACTEMENT des nombres
de jours mais ce sont des séries désaisonnalisées (sans leur moyenne de
long-terme par mois).

#### Remarque 2 : le choix la variable mise en contraste n’a pas d’importance.

Si on repart de l’équation (3), on remarque que le choix du dimanche en
constraste est un choix arbitraire. On peut donc réécrire l’équation de
REG1 (par exemple) en conséquence :
$$ D_t = \overline{\alpha} \times NbDays_t - \frac{1}{5} \beta_7 \times (Day_{6, t} + Day_{7, t} - \frac{2}{5} \sum ^{5}_{i=1} Day_{i, t}) $$
La réestimation de ce modèle donnera un $\beta_7 = \beta_6$ identique au
modèle REG1 écrit plus haut et les autres
$\beta_{i} = -\frac{2}{5} \beta_7$ (pour $i$ entre 1 et 5) seront aussi
les mêmes.

#### Remarque 3 : la réalité est plus complexe

Ici on a considéré un modèle simpliste. On a considéré que chaque jour
de l’année se partageait en 7 catégories (lundi, mardi, …, dimanche).
Seulement dans la réalité, les modèles de calendriers sont plus
complexes. Tout d’abord, on peut distinguer les jours $In$ (jours
ouvrés) et les jours $Off$ (jours fériés) : cela nous donne 14 types de
jour différents. On peut aussi considérer des modèles personnalisés
selon l’activité.

<div class="green">

Exemple : dans le transport routier, les camions peuvent rouler toute
l’année, jours ouvrés comme fériés. Seulement certains samedis, la
circulation des poids-lourds est interdite. Il faudrait idéalement,
créer un nouveau type de jour “samedi interdit” pour ces samedis.

</div>

## Remarques générales

### Ordre des opérations

Enfin on peut formuler une remarque sur l’ordre des opérations.

L’opération de calcul des moyennes prend une série (mensuelle ou
trimestrielle) et retire sa moyenne par période :
$$ \overline{X} = I_1 \times (X - X\\_{mean}_1) + I_2 \times (X - X\\_{mean}_2) + ... + I_n \times (X - X\\_{mean}_n) $$
avec $I_{i}$ l’indicatrice de la période $i$ et $n$ le nombre total de
période (exemple $n = 12$ pour une fréquence mensuelle).

L’opération de contraste prend 2 séries et en fait une somme pondérée :
$$ X\\_contraste = X + \omega Y $$

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
<tr>
<th style="text-align:right;">
Lundi
</th>
<th style="text-align:right;">
Mardi
</th>
<th style="text-align:right;">
Mercredi
</th>
<th style="text-align:right;">
Jeudi
</th>
<th style="text-align:right;">
Vendredi
</th>
<th style="text-align:right;">
Samedi
</th>
<th style="text-align:right;">
Dimanche
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
56
</td>
<td style="text-align:right;">
58
</td>
<td style="text-align:right;">
57
</td>
<td style="text-align:right;">
57
</td>
<td style="text-align:right;">
58
</td>
<td style="text-align:right;">
56
</td>
<td style="text-align:right;">
58
</td>
</tr>
</tbody>
</table>
Fréquence d’apparition un premier de l’an :
<table>
<thead>
<tr>
<th style="text-align:right;">
Lundi
</th>
<th style="text-align:right;">
Mardi
</th>
<th style="text-align:right;">
Mercredi
</th>
<th style="text-align:right;">
Jeudi
</th>
<th style="text-align:right;">
Vendredi
</th>
<th style="text-align:right;">
Samedi
</th>
<th style="text-align:right;">
Dimanche
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0.14
</td>
<td style="text-align:right;">
0.145
</td>
<td style="text-align:right;">
0.1425
</td>
<td style="text-align:right;">
0.1425
</td>
<td style="text-align:right;">
0.145
</td>
<td style="text-align:right;">
0.14
</td>
<td style="text-align:right;">
0.145
</td>
</tr>
</tbody>
</table>

### Fréquence de Pâques

On peut classer en 2 catégories les jours fériés français : - ceux qui
tombent chaque année à la même date (1er janvier, 25 décembre, …) - ceux
qui tombent chaque année sur le même type de jour (lundi, mardi, …) mais
à des dates différentes (lundi de Pâques, jeudi de l’ascension, …)

Il existe 3 jours fériés de la seconde catégories et ils dépendent tous
les 3 de la date de Pâques : lundi de Pâques, jeudi de l’ascension et
lundi de pentecôte.

Seulement la date de Pâques suit le calendrier lunaire. Et la fréquence
de Pâques (combinant calendrier grégorien et calendrier lunaire) est de
5700000 ans.

La répartition des occurences de la date de Paques sur 57000000 ans est
la suivante :

![](C:\Users\UTZK0M\DOCUME~1\Projets%20R\PROJET~3\RECHER~1\0_DIV_~1\doc\Calendar-steps_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

Mais cette répartition des jours de Pâques est différente selon la
période que l’on considère.

Sur la période 2000-2399 (cycle du calendrier) :

![](C:\Users\UTZK0M\DOCUME~1\Projets%20R\PROJET~3\RECHER~1\0_DIV_~1\doc\Calendar-steps_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

Sur la période 1970-2050 (cycle du calendrier) :

![](C:\Users\UTZK0M\DOCUME~1\Projets%20R\PROJET~3\RECHER~1\0_DIV_~1\doc\Calendar-steps_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

En comparant le nombre de jour fériés par mois :

<table>
<thead>
<tr>
<th style="text-align:right;">
periode
</th>
<th style="text-align:right;">
type
</th>
<th style="text-align:right;">
1-5700000
</th>
<th style="text-align:right;">
2000-2399
</th>
<th style="text-align:right;">
1970-2050
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
0.2000000
</td>
<td style="text-align:right;">
0.1875
</td>
<td style="text-align:right;">
0.1728395
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
0.8000000
</td>
<td style="text-align:right;">
0.8125
</td>
<td style="text-align:right;">
0.8271605
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
0.5995833
</td>
<td style="text-align:right;">
0.6000
</td>
<td style="text-align:right;">
0.5925926
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
0.4004167
</td>
<td style="text-align:right;">
0.4000
</td>
<td style="text-align:right;">
0.4074074
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
0.0048333
</td>
<td style="text-align:right;">
0.0050
</td>
<td style="text-align:right;">
NA
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
0.9546316
</td>
<td style="text-align:right;">
0.9625
</td>
<td style="text-align:right;">
0.9629630
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
0.0405351
</td>
<td style="text-align:right;">
0.0325
</td>
<td style="text-align:right;">
0.0370370
</td>
</tr>
</tbody>
</table>

Et par trimestre :

<table>
<thead>
<tr>
<th style="text-align:right;">
periode
</th>
<th style="text-align:right;">
type
</th>
<th style="text-align:right;">
1-5700000
</th>
<th style="text-align:right;">
2000-2399
</th>
<th style="text-align:right;">
1970-2050
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0.2
</td>
<td style="text-align:right;">
0.195
</td>
<td style="text-align:right;">
0.1728395
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
1.8
</td>
<td style="text-align:right;">
1.805
</td>
<td style="text-align:right;">
1.8271605
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
1.0
</td>
<td style="text-align:right;">
1.000
</td>
<td style="text-align:right;">
1.0000000
</td>
</tr>
</tbody>
</table>

Nos moyennes de long-terme diffèrent !

### Moyennes de long-terme

La remarque précédente est vraie pour tous les types de jours fériés.
Les autres jours fériés (hors Paques) sont périodiques de période 400
ans.

Mais est ce une raison pour prendre en compte la totalité de la série ou
peut-on se satisfaire d’un extrait avec les années sur lesquelles on
effectue nos analyses ?

<table>
<thead>
<tr>
<th style="text-align:right;">
month_number
</th>
<th style="text-align:right;">
weekday_number
</th>
<th style="text-align:right;">
Day.x
</th>
<th style="text-align:right;">
Off.x
</th>
<th style="text-align:right;">
Day.y
</th>
<th style="text-align:right;">
Off.y
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1450
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.1358025
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4.4250
</td>
<td style="text-align:right;">
0.1400
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.1358025
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1450
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.1425
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.1358025
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1425
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1450
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.1400
</td>
<td style="text-align:right;">
4.444444
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4.4250
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.444444
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
11
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4.2875
</td>
<td style="text-align:right;">
0.2900
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.2962963
</td>
</tr>
<tr>
<td style="text-align:right;">
11
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.2825
</td>
<td style="text-align:right;">
4.296296
</td>
<td style="text-align:right;">
0.2839506
</td>
</tr>
<tr>
<td style="text-align:right;">
11
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.2875
</td>
<td style="text-align:right;">
4.296296
</td>
<td style="text-align:right;">
0.2839506
</td>
</tr>
<tr>
<td style="text-align:right;">
11
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.2850
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.2839506
</td>
</tr>
<tr>
<td style="text-align:right;">
11
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.2850
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.2962963
</td>
</tr>
<tr>
<td style="text-align:right;">
11
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4.2875
</td>
<td style="text-align:right;">
0.2875
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.2839506
</td>
</tr>
<tr>
<td style="text-align:right;">
11
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.2825
</td>
<td style="text-align:right;">
4.271605
</td>
<td style="text-align:right;">
0.2716049
</td>
</tr>
<tr>
<td style="text-align:right;">
12
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.1450
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
12
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1400
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.1358025
</td>
</tr>
<tr>
<td style="text-align:right;">
12
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1450
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
12
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.1425
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.1358025
</td>
</tr>
<tr>
<td style="text-align:right;">
12
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1425
</td>
<td style="text-align:right;">
4.444444
</td>
<td style="text-align:right;">
0.1358025
</td>
</tr>
<tr>
<td style="text-align:right;">
12
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4.4250
</td>
<td style="text-align:right;">
0.1450
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
12
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1400
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4.0325
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.037037
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4.0375
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.037037
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4.0325
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.037037
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4.0375
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.037037
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4.0325
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.024691
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4.0350
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.037037
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4.0350
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.037037
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.444444
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4.4250
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4.2875
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.271605
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4.2875
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.296296
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.296296
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.2900
</td>
<td style="text-align:right;">
4.444444
</td>
<td style="text-align:right;">
0.2839506
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4.4250
</td>
<td style="text-align:right;">
0.2800
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.2469136
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.2900
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.2716049
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.2850
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.2592593
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.2850
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.2469136
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.2900
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.2716049
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.2800
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.2716049
</td>
</tr>
<tr>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.271605
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4.2875
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.296296
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.296296
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4.2875
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1425
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.1358025
</td>
</tr>
<tr>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.1425
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.1358025
</td>
</tr>
<tr>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1450
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1400
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.1450
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1400
</td>
<td style="text-align:right;">
4.444444
</td>
<td style="text-align:right;">
0.1358025
</td>
</tr>
<tr>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4.4250
</td>
<td style="text-align:right;">
0.1450
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.1400
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1450
</td>
<td style="text-align:right;">
4.444444
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4.4250
</td>
<td style="text-align:right;">
0.1400
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.1358025
</td>
</tr>
<tr>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1450
</td>
<td style="text-align:right;">
4.432099
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4.4275
</td>
<td style="text-align:right;">
0.1425
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.1358025
</td>
</tr>
<tr>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1425
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.1358025
</td>
</tr>
<tr>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4.4300
</td>
<td style="text-align:right;">
0.1450
</td>
<td style="text-align:right;">
4.419753
</td>
<td style="text-align:right;">
0.1481481
</td>
</tr>
<tr>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4.2875
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.271605
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
4.2875
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.296296
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.296296
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
<tr>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
4.2850
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
4.283951
</td>
<td style="text-align:right;">
0.0000000
</td>
</tr>
</tbody>
</table>

### Calcul sous **SAS**

En **SAS**, le calcul de l’année bissextile se fait suivant des règles
particulières.

Règle classique : on considère que toutes les années divisibles par 4
sont bissextiles à l’exception des années divisibles par 100 mais pas
par 400.

<div class="green">

Exemple :

- Les années 2003, 2021 et 2027 ne sont pas bissextiles.
- Les années 2016, 2020 et 2024 sont bissextiles.
- Les années 2100, 2200 et 1900 ne sont pas bissextiles.
- Enfin, les années 2000, 1600 et 2400 sont bissextiles.

</div>

Ces règles permettent d’affiner la durée moyenne d’une année pour coller
avec la durée de révolution de la terre autour du soleil (durée qui
n’est pas un multiple de 24h…).

Sur 400 ans, une année moyenne dure 365.2425 jours = 8765.82 h =
31556952 s. La période de révolution du soleil dure environ 365.242190

Pour approcher un peu plus la période de révolution de la Terre, en SAS,
les années divisibles par 4000 sont non bissextiles. Cette règle n’est
pas la règle officielle et n’est pas compatibles avec les calculs de
date de Pâques (Gauss, Meeus, Conway…)

Pourtant, **SAS** utilise cette règle pour son calcul de calendrier !
Attention alors aux calculs des moyennes de long-terme sur ces
calendriers qui peuvent être faussé (notamment pour les jours fériés
relatifs à Pâques).

Ainsi en l’an 4000, il n’y a pas de 29 fevrier (alors qu’il devrait y en
avoir). Toutes les dates qui suivent le 28 février 4000 correspondent au
type de jour de leur veille.

<div class="green">

Exemple : Le lundi de Pâques tombe le 10 avril 4000, et bien le 10 avril
4000 sera alors (dans le calendrier de SAS) un dimanche.

</div>

Ainsi les jour férié ne changent pas de période (même année, même mois)
mais de type de jour !

Seulement en pratique, comme on l’a expliqué dans la remarque
précédente, il y a de grandes chances que les moyennes de long-terme ne
soit pas calculés sur des très grandes périodes.
