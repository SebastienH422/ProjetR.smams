# ProjetR.smams
# Page d'aaceuil  : 
<div style="background-color: #ffb787; margin-top: 20px; padding: 20px; position: relative;">
    <p>&nbsp;</p> <!-- Un espace vide -->
    <p>&nbsp;</p> <!-- Un espace vide -->
    <p style="color:#FFF; background:#ffb787; padding:12px; font-size:20px; font-style:italic; text-align:center;">
        <span style="font-size:48px; font-style:normal;"><b>Remédiation R : Rendu de projet</b></span><br>
    </p>
    <p>&nbsp;</p> <!-- Un espace vide -->
    <p>&nbsp;</p> <!-- Un espace vide -->
    <p>&nbsp;</p> <!-- Un espace vide --> 
    <!-- Centrer les prénoms -->
    <p style="width:100%; text-align:center; font-size:20px; color:#FFF;">HEIN Sébastien - FRAILE Simon - DURRIEUX Ahina - PERIAT Matilin - BOIVENT Maïna</p>
    <p style="width:100%; text-align:center; font-size:20px; color:#FFF;">Professeur : Laurent R. Bergé</p>
    <p>&nbsp;</p> <!-- Un espace vide -->
    <p>&nbsp;</p> <!-- Un espace vide -->
    <p>&nbsp;</p> <!-- Un espace vide -->
    <p>&nbsp;</p> <!-- Un espace vide -->
    <span style="position: absolute; bottom: 25px; right: 25px; font-size:20px; color:#FFF;">Automne 2024</span>
</div>

# $$\text{Sommaire}$$
## I. Présentation du projet
## II. Nos statistiques descriptives
### &nbsp;&nbsp;1) Brevets
### &nbsp;&nbsp;2) Offres d'emploi
## III. Analyse de données

Page à laquelle on accède en cliquant sur "I. Présentation du projet : 
# $$\text{Présentation du projet}$$
<span style="font-size: 20px;">L'ojectif de ce projet est de comprendre le lien entre la performance d’innovation des entreprises (mesurée par les dépots de brevets) et leur demande de compétences.<br>
Pour cela nous allons traiter plusieurs jeux de données à l'aide du logiciel RStudio. <br><br>
Une fois le "nettoyage" et le traitement des données effectués, nous essaieront de répondre à différentes questions telles que : <br><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - quelle entreprise a déposé le plus de brevets ? <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - dans quel secteur retrouve-t-on le plus de brevets ? <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - dans quel département y a-t-il le plus d'entreprises qui ont déposé des brevets ? <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - quel secteur d'activité recrute le plus ? <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - dans quel département retrouve-t-on le plus d'offres d'emploi ? <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - quelle entreprise recrute le plus de data scientists ? <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - quelle entreprise demande le plus de compétences en machine learning ? <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - quelle entreprise rémunère le mieux ? <br>
</i></span><br>

#Page à laquelle on accède en cliquant sur "1) Brevets" : 
# $$\text{Nos statistiques descriptives}$$

<span style="font-size: 20px;">Pour les variables numériques nous repporterons les statistiques suivantes : <i>minimum, maximum, médiane, moyenne, écart-type, nombre de manquant. </i></span><br>
<span style="font-size: 20px;">Pour les variables chaîne de caractères nous repporterons : <i> les 5 valeurs qui ont leplus grand nombre de brevets </i> et <i> les 5 valeurs qui ont le plus haut salaire.</i></span>

## 1) base_brevets
### &nbsp;&nbsp;a) Variable numérique : n_patents
### &nbsp;&nbsp;b) Variables chaîne de caractère : firm_name, ipc_main_desc, addr_city_main, addr_dept_main


#Page à laquelle on accède en cliquant sur "2) Offres d'emploi" : 
# $$\text{Nos statistiques descriptives}$$

<span style="font-size: 20px;">Pour les variables numériques nous repporterons les statistiques suivantes : <i>minimum, maximum, médiane, moyenne, écart-type, nombre de manquant. </i></span><br>
<span style="font-size: 20px;">Pour les variables chaîne de caractères nous repporterons : <i> les 5 valeurs qui ont leplus grand nombre de brevets </i> et <i> les 5 valeurs qui ont le plus haut salaire.</i></span>


## 1) base_emp
### &nbsp;&nbsp;a) Variables numériques : n_offres, 
### &nbsp;&nbsp;b) Variables chaîne de caractère : firm_name, sector_main, addr_dept_main 

## 2) base_emp_inno
### &nbsp;&nbsp;a) Variables numériques : n_patents, n_offers, avg_wage 

Page à laquelle on accède en cliquant sur "III Analyse de données"
# $$\text{Analyse de données}$$

<span style="font-size: 20px;">Grâce aux analyses statistiques que nous avons effectuées précédemment, nous cherchons à reporter des relations entre l'innovation des entrprises et la demande de compétences en data science.</span><br>
