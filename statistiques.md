
# **Statistiques descriptives**

<br><br>
Pour les variables numériques, nous repporterons les statistiques suivantes : <i>minimum, médiane, maximum, moyenne, écart-type, nombre de manquants. </i><br>
Pour les variables chaîne de caractères nous repporterons : <i> les cinq valeurs qui ont le plus grand nombre de brevets </i> ou <i> les cinq valeurs qui ont le plus haut salaire.</i>
<br><br>


## 1) Base de données des brevets (base_brevets)
### &nbsp;&nbsp;a) Variable numérique : n_patents

<br>

Le nombre de brevets déposés par entreprise :
- minimum : 1 brevet,
- médiane : 4 brevets,
- maximum : 18803 brevets,
- moyenne : 12 brevets,
- écart-type : 474,
- nombre de manquants : il n'y a pas de valeurs manquantes.


<br>
<br>


### &nbsp;&nbsp;b) Variables chaîne de caractère : firm_name, ipc_main_desc, addr_city_main, addr_dept_main


<br>

Les 5 entreprises ayant déposé le plus de brevets sont :
1. Commissariat A L'Energie Atomique - CEA,
2. Université de Lorraine,
3. Centre National de la Recherche Scientifique (CNRS),
4. Valeo Embrayages,
5. Alcatel Lucent.

<br>

Les 5 descriptions de codes IPC ayant le plus de brevets sont :
1. Preparations for medical, dental, or toilet purposes (code IPC : A61K),
2. Semiconductor devices; electric solid state devices not otherwise provided for (code IPC : H01L),
3. Wireless communication networks (code IPC : H04W),
4. Pictorial communication, e.g. television (code IPC : H04N),
5. Non-portable lighting devices or systems thereof (code IPC : F21S).

<br>

Les 5 villes ayant le plus de brevets sont :
1. Paris,
2. Nancy,
3. Boulogne Billancourt,
4. Velizy Villacoublay,
5. Amiens.

<br>

Les 5 départements ayant le plus de brevets sont :
1. 75 : Paris,
2. 92 : Hauts-de-Seine,
3. 78 : Yvelines,
4. 54 : Meurthe-et-Moselle,
5. 80 : Somme.


<br><br>

## 2) Base de données des entreprises (base_emp)
### &nbsp;&nbsp;a) Variables numériques : n_offres, avg_wage

<br>

Le nombre d'offres déposées par entreprise :
- minimum : 1 offre,
- médiane : 2 offres,
- maximum : 68 offres,
- moyenne : 5 offres,
- écart-type : 9,
- nombre de manquants : il n'y a pas de valeurs manquantes.


<br>


Le salaire moyen en €/an par entreprise :
- minimum : 218,
- médiane : 46000,
- maximum : 560066,
- moyenne : 60111,
- écart-type : 63384,
- nombre de manquants : il y a 496 valeurs manquantes.


<br>
<br>


### &nbsp;&nbsp;b) Variables chaîne de caractère : firm_name, sector_main, addr_dept_main 


<br>

Les 5 entreprises ayant le salaire moyen le plus élevé :
1. La Relève,
2. Repro-IT,
3. VO2 GROUP,
4. Wekey,
5. SURICATE IT.


<br>

Les 5 secteurs ayant le salaire moyen le plus élevé :
1. prout,
2. caca,
3. pipi,
4. popo,
5. culotte.


<br>

Les 5 départements ayant le salaire moyen le plus élevé :
1. 75 : Paris,
2. 59 : Nord,
3. 92 : Hauts-de-Seine,
4. 44 : Loire-Atlantique,
5. 69 : Rhône.


<br>
<br>


## 3) Base de données de l'innovation dans les entreprises (base_emp_inno)
### &nbsp;&nbsp;a) Variables numériques : n_patents, n_offers, avg_wage 


<br>

Le nombre de brevets déposés par entreprise :
- minimum : 1 brevet,
- médiane : 4 brevets,
- maximum : 18803 brevets,
- moyenne : 38 brevets,
- écart-type : 474,
- nombre de manquants : il y a 523 valeurs manquantes.


<br>

Le nombre d'offres déposées par entreprise :
- minimum : 1 offre,
- médiane : 2 offres,
- maximum : 68 offres,
- moyenne : 5 offres,
- écart-type : 9,
- nombre de manquants : il y a 8600 valeurs manquantes.


<br>


Le salaire moyen en €/an par entreprise :
- minimum : 218,
- médiane : 46000,
- maximum : 560066,
- moyenne : 60111,
- écart-type : 63384,
- nombre de manquants : il y a 9096 valeurs manquantes.


<br>
<br>

