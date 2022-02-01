# MLD #

## Plan du document ##
- Liste des relations
- Liste des contraintes
- Choix d'héritages
- Vues
- Liste des relations avec leurs contraintes respectives *(afin d'offrir un second choix de présentation en fonction des préférences de chacun)*

## Liste des relations ##
Les relations provenant d'une association ont été nommée à partir des deux relations qu'elles associent. Par exemple, l'association N:M entre Utilisateur et SavoirFaire est nommée UtilisateurSavoirFaire.
- **CoordonneesGeographique**(#longitude:float, #latitude:float)
- **Utilisateur**(#id_utilisateur:integer, utilisateur_nom:string)
- **Personne**(#id_utilisateur=>Utilisateur,id_personne:integer, personne_prenom:string, personne_date_naissance:Date, personne_adresse:text, longitude=>CoordonneesGeographique.longitude, latitude=>CoordonneesGeographique.latitude)
- **Communaute**(#id_utilisateur=>Utilisateur,id_communaute:integer, communaute_description:text, communaute_nombre_de_personnes_max:integer)
- **PersonneCommunaute**(#id_personne=>Personne.id_personne, #id_communaute=>Communaute.id_communaute)
- **Vote**(#id_personne_from=>PersonneCommunaute.id_personne, #id_personne_to=>PersonneCommunaute.id_personne, #id_communaute=>PersonneCommunaute.id_communaute, vote:{0,1})
- **Lien**(#id_utilisateur_from=>Utilisateur, #id_utilisateur_to=>Utilisateur, #lien_description:text)
- **SavoirFaire**(#savoir_faire_nom:string, #savoir_faire_degre:{0,1,2,3,4,5})
- **UtilisateurSavoirFaire**(#idUtilisateur=>Utilisateur, #savoir_faire_nom=>SavoirFaire.savoir_faire_nom)
- **Service**(#service_nom:string, service_type:{1, 2, 3}, service_contrepartie_montant:integer, service_contrepartie_service_nom=>Service)
- **ServiceSavoirFaire**(#service_nom=>Service, #savoir_faire_nom=>SavoirFaire.savoir_faire_nom)
- **UtilisateurService**(#id_utilisateur_from=>Utilisateur, #id_utilisateur_to=>Utilisateur, #service_nom=>Service, utilisateur_service_realise:{0,1})
- **Message**(#id_message, id_utilisateur_from=>Utilisateur, id_utilisateur_to=>Utilisateur, message_texte:text, message_date:timestamp, message_precedent_id=>Message, message_supprime:{0,1})
- **Compte**(#compte_cle_publique:string, compte_solde:integer, id_Utilisateur=>Utilisateur)
## Liste des Contraintes : ##
- Pour l'**héritage par référence de Utilisateur** :
    - PROJECTION(Utilisateur,id_utilisateur) = Projection(Communaute,id_utilisateur) UNION Projection(Personne,id_utilisateur)
- Pour la relation **CoordonneesGeographique** : 
    - -180 <= longitude <= 180
    - -90 <= latitude <= 90 
- Pour la relation **Utilisateur** :
    - utilisateur_nom NOT NULL
- Pour la relation **Personne** :
    - id_personne UNIQUE NOT NULL
    - personne_nom, personne_prenom, personne_adresse, personne_date_naissance NOT NULL
- Pour la relation **Communaute** :
    - id_communaute UNIQUE NOT NULL
    - communaute_nombre_de_personnes_max, communaute_description NOT NULL
    - communaute_nombre_de_personnes_max >= 1
- Pour la relation **Lien** :
    - id_utilisateur_from != id_utilisateur_to
- Pour la relation **Service** :
    - service_type NOT NULL
    - NOT(service_type=3 AND (service_contrepartie_montant OR service_contrepartie_service_nom))
    - NOT(service_type=1 AND service_contrepartie_service_nom)
    - NOT(service_type=2 and service_contrepartie_montant)
    - service_type=1 AND service_contrepartie_montant
    - service_type=2 AND service_contrepartie_service_nom
    - service_contrepartie_montant > 0 
- Pour la relation **UtilisateurService** :
    - utilisateur_service_realise NOT NULL
    - id_utilisateur_from != id_utilisateur_to
- Pour la relation **Message** :
  - id_utilisateur_from, id_utilisateur_to, message_texte, message_date, message_supprime NOT NULL
- Pour la relation **Compte** :
  - id_utilisateur, compte_solde NOT NULL
  - compte_solde >= 0

## Choix d'héritages : ##
- Pour Service et ses trois classes filles, nous avons choisi un héritage par classe mère car il s'agit d'un héritage complet.
    - Cela ne peut pas être un héritage par classe fille car Service possède une association avec Utilisateur.
    - Référence : plus compliqué que par classe mère.
- Pour Utilisateur/Personne/Communauté, nous avons choisi un héritage par référence car :
    - Classe mère  : Héritage non complet/presque complet donc impossible.
    - Classe fille : Utilisateur possède trop d'associations, il est plus simple de faire par référence.

## Liste des relations + contraintes ##
Les relations provenant d'une association ont été nommée à partir des deux relations qu'elles associent. Par exemple, l'association N:M entre Utilisateur et SavoirFaire est nommée UtilisateurSavoirFaire.
- **CoordonneesGeographique**(#longitude:float, #latitude:float)
  - -180 <= longitude <= 180
  - -90 <= latitude <= 90 
- **Utilisateur**(#id_utilisateur:integer, utilisateur_nom:string)
  - utilisateur_nom NOT NULL
- **Personne**(#id_utilisateur=>Utilisateur,id_personne:integer, personne_prenom:string, personne_date_naissance:Date, personne_adresse:text, longitude=>CoordonneesGeographique.longitude, latitude=>CoordonneesGeographique.latitude)
  - id_personne UNIQUE NOT NULL
  - personne_nom, personne_prenom, personne_adresse, personne_date_naissance NOT NULL
- **Communaute**(#id_utilisateur=>Utilisateur,id_communaute:integer, communaute_description:text, communaute_nombre_de_personnes_max:integer)
  - id_communaute UNIQUE NOT NULL
  - communaute_nombre_de_personnes_max, communaute_description NOT NULL
  - communaute_nombre_de_personnes_max >= 1
- **PersonneCommunaute**(#id_personne=>Personne.id_personne, #id_communaute=>Communaute.id_communaute)
- **Vote**(#id_personne_from=>PersonneCommunaute.id_personne, #id_personne_to=>PersonneCommunaute.id_personne, #id_communaute=>PersonneCommunaute.id_communaute, vote:{0,1})
- **Lien**(#id_utilisateur_from=>Utilisateur, #id_utilisateur_to=>Utilisateur, #lien_description:text)
  - id_utilisateur_from != id_utilisateur_to
- **SavoirFaire**(#savoir_faire_nom:string, #savoir_faire_degre:{0,1,2,3,4,5})
- **UtilisateurSavoirFaire**(#idUtilisateur=>Utilisateur, #savoir_faire_nom=>SavoirFaire.savoir_faire_nom)
- **Service**(#service_nom:string, service_type:{1, 2, 3}, service_contrepartie_montant:integer, service_contrepartie_service_nom=>Service)
  - service_type NOT NULL
  - NOT(service_type=3 AND (service_contrepartie_montant OR service_contrepartie_service_nom))
  - NOT(service_type=1 AND service_contrepartie_service_nom)
  - NOT(service_type=2 and service_contrepartie_montant)
  - service_type=1 AND service_contrepartie_montant
  - service_type=2 AND service_contrepartie_service_nom
  - service_contrepartie_montant > 0 
- **ServiceSavoirFaire**(#service_nom=>Service, #savoir_faire_nom=>SavoirFaire.savoir_faire_nom)
- **UtilisateurService**(#id_utilisateur_from=>Utilisateur, #id_utilisateur_to=>Utilisateur, #service_nom=>Service, utilisateur_service_realise:{0,1})
  - utilisateur_service_realise NOT NULL
  - id_utilisateur_from != id_utilisateur_to
- **Message**(#id_message, id_utilisateur_from=>Utilisateur, id_utilisateur_to=>Utilisateur, message_texte:text, message_date:timestamp, message_precedent_id=>Message, message_supprime:{0,1})
  - id_utilisateur_from, id_utilisateur_to, message_texte, message_date, message_supprime NOT NULL
- **Compte**(#compte_cle_publique:string, compte_solde:integer, id_Utilisateur=>Utilisateur)
  - id_utilisateur, compte_solde NOT NULL
  - compte_solde >= 0
