# Note de Clarification

Git du Groupe 1 du projet de NA17 "Résilience".
URL du projet : https://gitlab.utc.fr/vilecler/projet-na17-dupil-messaoudi-leclercq

### Livrables

*   README.md (avec les noms des membres du groupe)
*   NDC au format markdown
*   MCD
*   MLD relationnel
*   BBD : base de données, données de test, questions

### Membres du Groupe 1

*   DUPIL Emeric
*   MESSAOUDI Walid
*   LECLERCQ Vivien

### Objet du projet

Le projet Résilience a pour objectif de mettre en réseau des personnes et des communautés dans une logique d'entre-aide. 

Ensuite, trois vues devront être créées :
*   Vue communauté : permet pour chaque personne d'avoir la liste des communautés auxquelles il déclare appartenir avec un booléen qui détermine si la personne est exclue ou non.
*   Vue message :  permet de visualiser chaque message en ajoutant l'identifiant du message d'origine lorsque le message s'inscrit dans un fil historique
*   Vue proches: permet de visualiser les communautés et personnes proches de chaque personne et communauté (à une distance inférieure à 1km)

### Liste des objets qui devront être gérés dans la base de données
*   Personne
*   Communauté
*   Lien
*   Savoir-faire
*   Service
*   Message
*   Compte
*   Coordonnées Géographiques

### Liste des propriétés associées à chaque objet
##### Personne
- Nom  
- Prénom  
- Date de naissance  
- Adresse  
- **Contrainte :**  
    - **(Nom, Prénom, Date de naissance) doit être unique**  

##### Communauté
- Nom  
- Description  
- Nombre de personnes maximal  
- **Contrainte :**  
    - **Nombre_de_personnes_maximal >=1** 
    - **On ne peut pas avoir de liens avec soi-même**

##### Lien
- Description  
- **Contrainte :**
    - **Les liens sont unidirectionnels**  

##### Savoir-faire
- Nom  
- Degré  
- **Contraintes :**
    - **(Nom, Degré) doit être unique**   
    - **Le degré doit être entre 1 et 5**  

##### Service
- Nom  
- Type : {sans-contrepartie ; en contrepartie d'un autre service identifié ou non identifié ; commercialement}  
- Montant (Exclusivement pour le type en contrepartie commerciale)
- Contrepartie (Exclusivement pour le type contrepartie d'un autre service)
- **Contrainte :**  
    - **Pour proposer un service il faut posséder un certain savoir faire dont le degré est supérieur ou égal au degré prérequis**  
    - **Montant doit être > 0** 

##### Message
- Emetteur
- Destinataire
- Texte  
- Heure d'envoie  
- **Contrainte :**
    - **Un message ne peut être supprimé ou modifié par quelqu'un d'autre que son expéditeur** 

##### Compte
- Solde  
- Clé publique  
- **Contraintes :**
    - **Le solde est exprimé en Ğ1**
    - **Le solde doit être positif**  
    - **On ne peut dépenser l'argent d'un compte que si on en est le propriétaire**  
    - **On peut créditer de l'argent sur un compte à l'aide de sa clé publique**  
    - **Tous les comptes possèdent un clé publique unique**  

##### Coordonnées Géographique
- Longitude  
- Latitude  
- **Contraintes :**  
    - **(Longitude, Latitude) sont uniques**
    - **-180 <= longitude <= 180**
    - **-90 <= latitude <= 90**

### Liste des utilisateurs (rôles) appelés à modifier et consulter les données
##### Utilisateur Personne
##### Utiliser Communaute
- Peut modifier peut administrer toutes les informations de cette communauté

### Liste des fonctions que ces utilisateurs pourront effectuer
##### Utilisateur Personne
- Créer une communauté
- Déclarer faire partie d'une communauté
- Déclarer avoir des liens avec d'autres personnes
- Déclarer posséder un savoir-faire
- Proposer des services
- Ourvrir des comptes
- Dépenser l'argent de ses comptes
- Envoyer des messages
- Recevoir des messages
- Modifier et supprimer les messages dont il est l'expéditeur
- Se localiser

##### Utilisateur Communaute
- Déclarer avoir des liens avec d'autres communtauté sous le noms de la communauté
- Administer les informations de la communauté
- Voter pour l'opposition à la présence d'un membre dans la communauté
- Déclarer posséder un savoir-faire sous le noms de la communauté
- Proposer des services sous le noms de la communauté
- Ourvrir des comptes sous le noms de la communauté
- Dépenser l'argent de ses comptes sous le noms de la communauté
- Envoyer des messages sous le noms de la communauté
- Recevoir des messages sous le noms de la communauté
- Modifier et supprimer les messages dont la communauté est l'expéditeur

### Liste des hypothèses faites à partir du sujet
- Il existe une quantité de Coordonnées Géographiques finie définie dans CoordonnéesGéographiques
- Personne et Communauté peuvent être identifiés en tant qu'Utilisateur
- Il est possible de créer une Communauté avec aucun membre de manière temporaire
- Une communauté dispose toujours d'un nombre maximal de membre
- Pour voter pour l'exclusion d'une Personne, la Personne qui vote et la Personne contre qui s'adresse le vote doivent faire partie tous les deux de la Communauté en question
- Il est impossible pour un Utilisateur de créer des liens avec lui-même
- Un Service peut requérir des savoirs faires avec un degré miminum, les utilisateurs ayant ce savoir faire avec un degré supérieur peuvent effectuer ce service
- Un Utilisateur propose des services à un autre Utilisateur
- Un Utilisateur peut posséder plusieurs compte bancaires
- Les Communautés n'ont pas de Coordonnées Géographiques. Pour localiser une Communauté, on localise où se trouve ses membres
- On proposera une gestion des droits utilisateurs UserPersonne et UserCommunauté
- Un utilisateur peut envoyer des messages à soi-même 