--SUPPRESSION DES ANCIENNES DONNEES SI PRESENTES

DROP VIEW IF EXISTS MessageList;
DROP VIEW IF EXISTS View_Communaute;
DROP VIEW IF EXISTS View_Message;
DROP VIEW IF EXISTS View_Proches;
DROP VIEW IF EXISTS View_Communaute_Distance;
DROP VIEW IF EXISTS View_Communautes_Membres_Count;
DROP VIEW IF EXISTS View_Services_Etat;
DROP VIEW IF EXISTS View_PersonneCommunaute;

DROP TABLE IF EXISTS Vote;
DROP TABLE IF EXISTS Lien;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS ServiceSavoirFaire;
DROP TABLE IF EXISTS UtilisateurSavoirFaire;
DROP TABLE IF EXISTS UtilisateurService;
DROP TABLE IF EXISTS PersonneCommunaute;
DROP TABLE IF EXISTS Personne;
DROP TABLE IF EXISTS Communaute;
DROP TABLE IF EXISTS Service;
DROP TABLE IF EXISTS SavoirFaire;
DROP TABLE IF EXISTS CoordonneesGeographiques;
DROP TABLE IF EXISTS Compte;
DROP TABLE IF EXISTS Utilisateur;

DROP ROLE IF EXISTS UserPersonne;
DROP ROLE IF EXISTS UserCommunaute;

--CREATION DES TABLES

CREATE TABLE IF NOT EXISTS public.CoordonneesGeographiques(
  longitude FLOAT NOT NULL,
  latitude FLOAT NOT NULL,
  CONSTRAINT PK_CoordonneesGeographiques PRIMARY KEY (longitude, latitude),
  CONSTRAINT longitude_values CHECK (longitude >= -180.0 AND longitude <= 180),
  CONSTRAINT latitude_values CHECK (latitude >= -90.0 AND latitude <= 90)
);

CREATE TABLE IF NOT EXISTS public.Utilisateur(
  id_utilisateur SERIAL PRIMARY KEY,
  utilisateur_nom VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.Personne(
  id_personne SERIAL,
  id_utilisateur INTEGER NOT NULL PRIMARY KEY,
  personne_prenom VARCHAR(50) NOT NULL,
  personne_date_naissance DATE NOT NULL,
  personne_adresse TEXT NOT NULL,
  longitude FLOAT NOT NULL,
  latitude FLOAT NOT NULL,
  FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur),
  CONSTRAINT id_personne_unique UNIQUE (id_personne),
  FOREIGN KEY (longitude, latitude) REFERENCES CoordonneesGeographiques(longitude, latitude)
);

CREATE TABLE IF NOT EXISTS public.Communaute(
  id_communaute SERIAL,
  id_utilisateur INTEGER NOT NULL PRIMARY KEY,
  communaute_description TEXT NOT NULL,
  communaute_nombre_de_personnes_max INTEGER NOT NULL,
  FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur),
  CONSTRAINT communaute_nombre_de_personnes_max_positif CHECK (communaute_nombre_de_personnes_max >= 1),
  CONSTRAINT id_communaute_unique UNIQUE (id_communaute)
);

CREATE TABLE IF NOT EXISTS public.PersonneCommunaute(
  id_personne INTEGER NOT NULL,
  id_communaute INTEGER NOT NULL,
  FOREIGN KEY (id_personne) REFERENCES Personne(id_personne),
  FOREIGN KEY (id_communaute) REFERENCES Communaute(id_communaute),
  CONSTRAINT PK_PersonneCommunaute PRIMARY KEY (id_personne, id_communaute)
);

CREATE TABLE IF NOT EXISTS public.Vote(
  id_personne_from INTEGER NOT NULL,
  id_personne_to INTEGER NOT NULL,
  id_communaute INTEGER NOT NULL,
  vote SMALLINT NOT NULL,
  FOREIGN KEY (id_personne_from, id_communaute) REFERENCES PersonneCommunaute(id_personne, id_communaute),
  FOREIGN KEY (id_personne_to, id_communaute) REFERENCES PersonneCommunaute(id_personne, id_communaute),
  CONSTRAINT vote_values CHECK (vote = 0 OR vote = 1),
  CONSTRAINT PK_Vote PRIMARY KEY (id_personne_from, id_personne_to, id_communaute)
);

CREATE TABLE IF NOT EXISTS public.Lien(
  id_utilisateur_from INTEGER NOT NULL,
  id_utilisateur_to INTEGER NOT NULL,
  lien_description TEXT NOT NULL,
  FOREIGN KEY (id_utilisateur_from) REFERENCES Utilisateur(id_utilisateur),
  FOREIGN KEY (id_utilisateur_to) REFERENCES Utilisateur(id_utilisateur),
  CONSTRAINT PK_Lien PRIMARY KEY (id_utilisateur_from, id_utilisateur_to, lien_description),
  CONSTRAINT id_differents CHECK (id_utilisateur_from != id_utilisateur_to)
);

CREATE TABLE IF NOT EXISTS public.SavoirFaire(
  savoir_faire_nom VARCHAR(100) NOT NULL,
  savoir_faire_degre SMALLINT NOT NULL,
  CONSTRAINT PK_SavoirFaire PRIMARY KEY (savoir_faire_nom, savoir_faire_degre),
  CONSTRAINT savoir_faire_degre_valeurs CHECK (savoir_faire_degre >= 0  AND savoir_faire_degre <= 5)
);

CREATE TABLE IF NOT EXISTS public.UtilisateurSavoirFaire(
  id_utilisateur INTEGER NOT NULL,
  savoir_faire_nom VARCHAR(100) NOT NULL,
  savoir_faire_degre SMALLINT NOT NULL,
  FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur),
  FOREIGN KEY (savoir_faire_nom, savoir_faire_degre) REFERENCES SavoirFaire(savoir_faire_nom, savoir_faire_degre),
  CONSTRAINT PK_UtilisateurSavoirFaire PRIMARY KEY (id_utilisateur, savoir_faire_nom)
);

CREATE TABLE IF NOT EXISTS public.Service(
  service_nom VARCHAR(50) PRIMARY KEY NOT NULL,
  service_type INTEGER NOT NULL,
  service_contrepartie_montant INTEGER,
  service_contrepartie_service_nom VARCHAR(50),
  CONSTRAINT service_contrepartie_montant_positif CHECK (service_contrepartie_montant > 0),
  CONSTRAINT service_type_values CHECK (service_type >= 1 AND service_type <= 3),
  CONSTRAINT heritage CHECK ((service_type = 1 AND service_contrepartie_montant IS NOT NULL AND service_contrepartie_service_nom IS NULL) OR (service_type = 2 AND service_contrepartie_montant IS NULL AND service_contrepartie_service_nom IS NULL) OR (service_type = 3 AND service_contrepartie_montant
  IS NULL AND service_contrepartie_service_nom IS NOT NULL)),
  FOREIGN KEY (service_contrepartie_service_nom) REFERENCES Service(service_nom)
);

CREATE TABLE IF NOT EXISTS public.ServiceSavoirFaire(
  service_nom VARCHAR(50) NOT NULL,
  savoir_faire_nom VARCHAR(100) NOT NULL,
  savoir_faire_degre SMALLINT NOT NULL,
  FOREIGN KEY (service_nom) REFERENCES Service(service_nom),
  FOREIGN KEY (savoir_faire_nom, savoir_faire_degre) REFERENCES SavoirFaire(savoir_faire_nom, savoir_faire_degre),
  CONSTRAINT PK_ServiceSavoirFaire PRIMARY KEY (service_nom, savoir_faire_nom)
);

CREATE TABLE IF NOT EXISTS public.UtilisateurService(
  id_utilisateur_from INTEGER NOT NULL,
  id_utilisateur_to INTEGER NOT NULL,
  service_nom VARCHAR(50) NOT NULL,
  utilisateur_service_realise SMALLINT NOT NULL,
  CONSTRAINT utilisateur_service_realise_valeurs CHECK (utilisateur_service_realise = 0 OR utilisateur_service_realise = 1),
  FOREIGN KEY (id_utilisateur_from) REFERENCES Utilisateur(id_utilisateur),
  FOREIGN KEY (id_utilisateur_to) REFERENCES Utilisateur(id_utilisateur),
  CONSTRAINT id_differents CHECK (id_utilisateur_from != id_utilisateur_to),
  FOREIGN KEY (service_nom) REFERENCES Service(service_nom),
  CONSTRAINT PK_UtilisateurService PRIMARY KEY (id_utilisateur_from, id_utilisateur_to, service_nom)
);

CREATE TABLE IF NOT EXISTS public.Message(
  id_message SERIAL PRIMARY KEY,
  id_utilisateur_from INTEGER NOT NULL,
  id_utilisateur_to INTEGER NOT NULL,
  message_texte TEXT NOT NULL,
  message_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  message_precedent_id INTEGER,
  message_supprime INTEGER NOT NULL,
  FOREIGN KEY (id_utilisateur_from) REFERENCES Utilisateur(id_utilisateur),
  FOREIGN KEY (id_utilisateur_to) REFERENCES Utilisateur(id_utilisateur),
  CONSTRAINT message_supprime_valeurs CHECK (message_supprime = 0 OR message_supprime = 1),
  FOREIGN KEY (message_precedent_id) REFERENCES Message(id_message)
);

CREATE TABLE IF NOT EXISTS public.Compte(
  compte_solde INTEGER NOT NULL,
  compte_cle_publique VARCHAR(10) NOT NULL PRIMARY KEY,
  id_utilisateur INTEGER NOT NULL,
  CONSTRAINT compte_solde_positif CHECK (compte_solde >= 0),
  FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur)
);

-- PROPRIETAIRE DES TABLES

ALTER TABLE public.Utilisateur OWNER to postgres;
ALTER TABLE public.Personne OWNER to postgres;
ALTER TABLE public.Communaute OWNER to postgres;
ALTER TABLE public.Lien OWNER to postgres;
ALTER TABLE public.SavoirFaire OWNER to postgres;
ALTER TABLE public.Service OWNER to postgres;
ALTER TABLE public.Message OWNER to postgres;
ALTER TABLE public.Compte OWNER to postgres;
ALTER TABLE public.CoordonneesGeographiques OWNER to postgres;

-- INSERTION DES JEUX DE DONNEES

INSERT INTO public.CoordonneesGeographiques(longitude, latitude) VALUES
	(2.8261, 49.4179),
	(2.0833, 49.4333),
	(2.1333, 49.2333),
	(3.0667, 50.6333),
	(2.3488, 48.8534),
	(3.3333, 49.3667),
	(5.9333, 43.1167),
	(1.4437, 43.6043),
	(-2.1417, 37.7167),
	(-4.95, 39.5667),
	(-0.1277, 51.5073),
	(7.7500, 48.5833),
	(12.4963, 41.9027),
	(4.8356, 45.7640);

INSERT INTO public.Utilisateur(id_utilisateur, utilisateur_nom) VALUES
	(1, 'Leclercq'),
	(2, 'Martin'),
	(3, 'Robert'),
	(4, 'Petit'),
	(5, 'Les Chevaliers de la Table Ronde'),
	(6, 'Morel'),
	(7, 'La Communauté de l Anneau'),
	(8, 'Les Chevaliers de Ren'),
	(9, 'La Garde de Nuit'),
	(10, 'Dubois'),
	(11, 'Fournier'),
	(12, 'Vidal'),
	(13, 'Lemoine'),
	(14, 'Payet'),
	(15, 'Les Disciples de Satan'),
	(16, 'Huet'),
	(17, 'Lebrun'),
	(18, 'Boulanger'),
	(19, 'Marchal'),
	(20, 'Lejeune'),
	(21, 'Lopez'),
	(22, 'Duval'),
	(23, 'Poulain'),
	(24, 'Pasquier');

INSERT INTO public.Personne(id_utilisateur, personne_prenom, personne_date_naissance, personne_adresse, longitude, latitude) VALUES
  (1, 'Vivien', '1999-12-14', '62 rue du Val', 2.8261, 49.4179),
  (2, 'Martin', '2001-05-03', '6 rue des Champignons', 2.3488, 48.8534),
  (3, 'Jean', '1987-11-08', '458 rue des Tomates', 2.0833, 49.4333),
  (4, 'Hugue', '1967-12-30', '12 boulevard des Chaussettes Mouillées', -0.1277, 51.5073),
  (6, 'Martine', '1996-04-04', '42 rue de la Force',-4.95, 39.5667),
  (10, 'Henry', '1987-03-18', '269 rue du Fromage', -2.1417, 37.7167),
  (11, 'Charles', '1982-10-21', '1 rue des Saucisses', 5.9333, 43.1167),
  (12, 'Patricia', '1984-11-24', '59 rue du Val', 2.0833, 49.4333),
  (13, 'Vivien', '1990-12-05', '68 rue du Thon', 2.0833, 49.4333),
  (14, 'Vivien', '1999-03-09', '230 Grande Rue', 3.3333, 49.3667),
  (16, 'Alice', '1999-08-22', '3 impasse des Fossés', 4.8356, 45.7640),
  (17, 'Charles', '1978-08-10', '87 avenue Jean Moulin', 2.1333, 49.2333),
  (18, 'Vivien', '1972-01-15', '920 rue du Soleil', 1.4437, 43.6043),
  (19, 'Julie', '1979-03-19', '12 rue de Dr Froma', 2.8261, 49.4179),
  (20, 'Fabien', '1980-09-26', '2 impasse des Licornes', 2.0833, 49.4333),
  (21, 'Robert', '1992-02-08', '36 rue du Sel', 12.4963, 41.9027),
  (22, 'Sylvain', '1998-06-29', '62 avanue de Satan', 2.0833, 49.4333),
  (23, 'Jeanne', '1997-01-31', '92 rue de la Victoire', 7.7500, 48.5833),
  (24, 'Romane', '1999-10-24', '59 rue des Vignes', 2.3488, 48.8534);

INSERT INTO public.Communaute(id_utilisateur, communaute_description, communaute_nombre_de_personnes_max) VALUES
  (5, 'Arthur est notre roi.', 6),
  (7, 'Pour Frodon !', 10),
  (8, 'Rejoignez le côté obscur de la force.', 3),
  (9, 'Jusque la fin des temps et à jamais', 15),
  (15, 'Pour la gloire de Satan notre sauveur !', 2);

INSERT INTO public.PersonneCommunaute(id_personne, id_communaute) VALUES
  (1, 1),
  (1, 4),
  (2, 4),
  (4, 4),
  (6, 4),
  (19, 4),
  (14, 4),
  (17, 4),
  (18, 4),
  (11, 4),
  (9, 1),
  (12, 4),
  (10, 4),
  (7, 3),
  (13, 4),
  (3, 1),
  (19, 1),
  (6, 1),
  (19, 5),
  (5, 5),
  (1, 2),
  (17, 2),
  (15, 2),
  (2, 3);

INSERT INTO public.Vote(id_personne_from, id_personne_to, id_communaute, vote) VALUES
  (1, 6, 4, 1),
  (10, 6, 4, 1),
  (17, 6, 4, 1),
  (14, 6, 4, 1),
  (18, 6, 4, 1),
  (19, 6, 4, 1),
  (4, 6, 4, 1),
  (13, 6, 4, 1),
  (12, 6, 4, 1),
  (1, 12, 4, 1),
  (1, 10, 4, 1),
  (10, 1, 4, 1),
  (19, 5, 5, 1),
  (17, 1, 2, 1),
  (17, 15, 2, 1),
  (17, 11, 4, 1),
  (5, 19, 5, 1),
  (10, 12, 4, 1),
  (2, 7, 3, 1);

INSERT INTO public.Lien(id_utilisateur_from, id_utilisateur_to, lien_description) VALUES
  (1, 6, 'apprécie beaucoup'),
  (14, 9, 'apprécie beaucoup'),
  (15, 9, 'a envie de détruire'),
  (5, 1, 'voudrait avoir pour roi'),
  (6, 18, 'est la soeur de'),
  (23, 24, 'est la voisine de'),
  (8, 6, 'a envie de tuer'),
  (12, 8, 'est la soeur de'),
  (11, 12, 'a envie de tuer'),
  (10, 20, 'apprécie beaucoup'),
  (2, 19, 'a envie de tuer'),
  (18, 21, 'est le frere de');

INSERT INTO public.SavoirFaire(savoir_faire_nom, savoir_faire_degre) VALUES
  ('Assassinat', 1),
  ('Assassinat', 2),
  ('Assassinat', 3),
  ('Assassinat', 4),
  ('Assassinat', 5),
  ('Cuisine', 1),
  ('Cuisine', 2),
  ('Cuisine', 3),
  ('Cuisine', 4),
  ('Cuisine', 5),
  ('Alchimie', 1),
  ('Alchimie', 2),
  ('Alchimie', 3),
  ('Alchimie', 4),
  ('Alchimie', 5),
  ('Magie', 1),
  ('Magie', 2),
  ('Magie', 3),
  ('Magie', 4),
  ('Magie', 5),
  ('Mathématiques', 1),
  ('Mathématiques', 2),
  ('Mathématiques', 3),
  ('Mathématiques', 4),
  ('Mathématiques', 5),
  ('Français', 1),
  ('Français', 2),
  ('Français', 3),
  ('Français', 4),
  ('Français', 5),
  ('Monter à cheval', 1),
  ('Monter à cheval', 2),
  ('Monter à cheval', 3),
  ('Monter à cheval', 4),
  ('Monter à cheval', 5),
  ('Sabre laser', 1),
  ('Sabre laser', 2),
  ('Sabre laser', 3),
  ('Sabre laser', 4),
  ('Sabre laser', 5);

INSERT INTO public.UtilisateurSavoirFaire(id_utilisateur, savoir_faire_nom, savoir_faire_degre) VALUES
  (1, 'Cuisine', 4),
  (1, 'Monter à cheval', 1),
  (1, 'Français', 3),
  (2, 'Cuisine', 1),
  (3, 'Sabre laser', 4),
  (4, 'Magie', 5),
  (5, 'Monter à cheval', 5),
  (6, 'Mathématiques', 2),
  (7, 'Assassinat', 4),
  (7, 'Magie', 4),
  (7, 'Monter à cheval', 5),
  (8, 'Sabre laser', 5),
  (8, 'Assassinat', 4),
  (8, 'Monter à cheval', 3),
  (9, 'Assassinat', 4),
  (9, 'Monter à cheval', 4),
  (9, 'Français', 4),
  (10, 'Assassinat', 4),
  (11, 'Alchimie', 2),
  (11, 'Magie', 4),
  (12, 'Alchimie', 3),
  (13, 'Cuisine', 2),
  (14, 'Monter à cheval', 1),
  (15, 'Assassinat', 5),
  (15, 'Magie', 5),
  (15, 'Mathématiques', 1),
  (16, 'Alchimie', 4),
  (17, 'Assassinat', 4),
  (18, 'Assassinat', 4),
  (19, 'Monter à cheval', 1),
  (20, 'Assassinat', 4),
  (20, 'Sabre laser', 3),
  (21, 'Mathématiques', 4),
  (21, 'Français', 1),
  (21, 'Alchimie', 3),
  (22, 'Sabre laser', 4),
  (23, 'Mathématiques', 2),
  (24, 'Cuisine', 1);

INSERT INTO public.Service(service_nom, service_type, service_contrepartie_montant, service_contrepartie_service_nom) VALUES
  ('Tuer un utilisateur', 1, 10000, NULL),
  ('Nuir à un utilisateur', 2, NULL, NULL),
  ('Donner la main', 2, NULL, NULL),
  ('Faire une pizza', 3, NULL, 'Donner la main'),
  ('Faire un tour de magie', 3, NULL, 'Donner la main'),
  ('Ecrire une lettre à un utilisateur', 1, 200, NULL),
  ('Faire des calculs complexes', 3, NULL, 'Faire une pizza'),
  ('Enchanter un utilisateur', 3, NULL, 'Faire une pizza'),
  ('Partir en guerre', 2, NULL, NULL);

INSERT INTO public.ServiceSavoirFaire(service_nom, savoir_faire_nom, savoir_faire_degre) VALUES
  ('Tuer un utilisateur', 'Assassinat', 3),
  ('Faire une pizza', 'Cuisine', 3),
  ('Faire un tour de magie', 'Magie', 3),
  ('Ecrire une lettre à un utilisateur', 'Français', 3),
  ('Faire des calculs complexes', 'Mathématiques', 3),
  ('Enchanter un utilisateur', 'Alchimie', 2),
  ('Partir en guerre', 'Monter à cheval', 3),
  ('Partir en guerre', 'Assassinat', 3);

INSERT INTO public.UtilisateurService(id_utilisateur_from, id_utilisateur_to, service_nom, utilisateur_service_realise) VALUES
  (1, 3, 'Faire une pizza', 0),
  (3, 1, 'Donner la main', 1),
  (14, 7, 'Donner la main', 1),
  (9, 8, 'Ecrire une lettre à un utilisateur', 1),
  (20, 5, 'Tuer un utilisateur', 0),
  (5, 15, 'Partir en guerre', 0),
  (16, 1, 'Enchanter un utilisateur', 0),
  (1, 16, 'Faire une pizza', 0),
  (16, 1, 'Donner la main', 1),
  (21, 10, 'Faire des calculs complexes', 0),
  (10, 21, 'Faire une pizza', 0),
  (21, 10, 'Donner la main', 1),
  (15, 17, 'Nuir à un utilisateur', 0);

INSERT INTO public.Message(id_utilisateur_from, id_utilisateur_to, message_texte, message_precedent_id, message_supprime) VALUES
  	(1, 2, 'Tu es vraiment moche', NULL, 0),
    (2, 1, 'De quoi tu parles ?', 1, 0),
    (1, 2, 'De toi.', 2, 0),
    (9, 4, 'Un plus un ça fait deux ?', NULL, 0),
    (4, 9, 'Je crois bien que oui', 4, 0),
    (4, 9, 'Je crois bien que oui', 5, 0),
    (10, 12, 'Science sans conscience n est que ruine de l ame', NULL, 1),
    (1, 2, 'Moi aimer toi', NULL, 0),
    (8, 5, 'Cette conversation n a pas de sens', NULL, 0),
    (3, 3, 'Puis-je me parler tout seul ?', NULL,  0),
    (19, 21, 'Qui es-tu', NULL, 0),
    (21, 19, 'Je suis ton père', 10, 0),
    (12, 15, 'Vous êtes vraiment méchantes', NULL, 0),
    (6, 15, 'Personne ne vous aime', NULL, 0),
    (18, 9, 'Où êtes-vous ?', NULL, 0),
    (5, 23, 'Bonjour', NULL, 0),
    (24, 2, 'Tu es vraiment moche', NULL, 0),
    (1, 2, 'Veux-tu tuer un utilisateur pour moi ?', NULL, 0),
    (21, 8, 'Je ne comprends pas', NULL, 0),
    (1, 2, 'Tu es vraiment moche', NULL, 0),
    (1, 9, 'Moi ne plus aimer toi', NULL, 0),
    (19, 8, 'Tu es vraiment moche', NULL, 0),
    (16, 4, 'Tu es vraiment moche', NULL, 0),
    (12, 1, 'Bien ou bien ?', NULL, 0),
    (1, 19, 'Tu es vraiment moche', NULL, 0),
    (1, 9, 'Tu es vraiment moche', NULL, 0),
    (14, 2, 'Toi ne pas savoir parler français', NULL, 0),
    (18, 22, 'Qui es-tu ?', NULL, 0),
    (19, 2, 'Tu es vraiment moche', NULL, 0),
    (1, 16, 'Tu es vraiment moche', NULL, 0),
    (13, 2, 'Coucou maman', NULL, 0),
    (1, 2, 'Salut', NULL, 0),
    (11, 2, 'Tu es vraiment moche', NULL, 0),
    (17, 5, 'Mdr.', NULL, 0),
    (23, 6, 'Vivement la fin.', NULL, 0),
    (16, 2, 'Moi avoir beaucoup faim', NULL, 0);

INSERT INTO public.Compte(compte_solde, compte_cle_publique, id_utilisateur) VALUES
  (10000, 'AZERTY', 1),
  (10, 'ZKCBD', 1),
  (666, 'CHDUE', 15),
  (289, 'JRUEG', 9),
  (265, 'ZVUIE', 7),
  (10, 'JRHRD', 9),
  (0, 'DJEYC', 4),
  (10, 'NDHDH', 13),
  (10, 'SSBDG', 21),
  (10, 'DJEYR', 14),
  (2910, 'EFSC', 9),
  (10, 'AFILRD', 22),
  (1180, 'CHDGD', 8),
  (10, 'LGOTI', 3),
  (2810, 'CJHEU', 15),
  (10, 'MFPJFV', 14),
  (2810, 'CBJJE', 17),
  (0, 'MGKOO', 2),
  (10, 'XZRTJ', 3),
  (10, 'HOUGD', 2),
  (10, 'CEGEC', 4),
  (10, 'DIVFFF', 7),
  (0, 'EIFBCH', 14),
  (100, 'DHEEBZ', 13),
  (0, 'CHUEN', 20),
  (10, 'VPOEC', 10),
  (10, 'CKFBD', 12),
  (1780, 'CHETYE', 17),
  (980, 'CHEPT', 18),
  (100, 'UHEYE', 20),
  (0, 'SHFYE', 1),
  (0, 'CKIE54', 10),
  (10, 'FKFO9', 12),
  (10, 'CKEUE', 18),
  (10, 'BCYEB', 10),
  (1000, 'CJBEI', 18),
  (10, 'MFHUE', 10),
  (0, 'CHETD', 18),
  (10, 'CHETE', 10);


  --CREATION DES VUES

  CREATE VIEW View_PersonneCommunaute AS
    (SELECT id_personne, id_communaute, personne_exclue_communaute(id_personne, id_communaute) FROM PersonneCommunaute);


  --Vue communauté du sujet
  CREATE VIEW View_Communaute AS
    (SELECT id_personne, personne_nom, personne_prenom, personne_date_naissance, utilisateur_nom AS communaute_nom, communaute_description, personne_exclue_communaute FROM

    (SELECT Personne.id_personne, utilisateur_nom AS personne_nom, personne_prenom, personne_date_naissance, Communaute.id_utilisateur, communaute_description, personne_exclue_communaute FROM View_PersonneCommunaute
    	INNER JOIN Personne ON Personne.id_personne = View_PersonneCommunaute.id_personne
    	INNER JOIN Communaute ON Communaute.id_communaute = View_PersonneCommunaute.id_communaute
    	INNER JOIN Utilisateur ON Personne.id_utilisateur = Utilisateur.id_utilisateur) AS request

    INNER JOIN Utilisateur ON Utilisateur.id_utilisateur = request.id_utilisateur);


  --Vue message du sujet
  CREATE VIEW View_Message AS
    (SELECT id_message, id_utilisateur_from, id_utilisateur_to, message_texte, message_date, message_precedent_id, message_supprime, message_racine(id_message) FROM Message);

  --Vue utilisée dans View_Proches
  CREATE VIEW View_Communaute_Distance AS
  (SELECT id_personne, personne_nom, personne_prenom, personne_date_naissance, latitude, longitude, utilisateur_nom AS communaute_nom, communaute_description FROM

  (SELECT Personne.id_personne, utilisateur_nom AS personne_nom, personne_prenom, personne_date_naissance, latitude, longitude, Communaute.id_utilisateur, communaute_description FROM Personne
    LEFT JOIN PersonneCommunaute ON Personne.id_personne = PersonneCommunaute.id_personne
    LEFT JOIN Communaute ON Communaute.id_communaute = PersonneCommunaute.id_communaute
    LEFT JOIN Utilisateur ON Personne.id_utilisateur = Utilisateur.id_utilisateur) AS request

  LEFT JOIN Utilisateur ON Utilisateur.id_utilisateur = request.id_utilisateur);

  --Vue proches du sujet
  CREATE VIEW View_Proches AS (SELECT DISTINCT calculer_distance_km(Request1.latitude, Request1.longitude, Request2.latitude, Request2.longitude) AS distance_en_km,
    Request1.id_personne AS id_personne,
    Request1.personne_nom AS personne_nom,
    Request1.personne_prenom AS personne_prenom,
    Request1.personne_date_naissance AS personne_date_naissance,

    Request1.communaute_nom AS personne_communaute,

    Request2.personne_nom AS personne_proche_nom,
    Request2.personne_prenom AS personne_proche_prenom,
    Request2.personne_date_naissance AS personne_proche_date_naissance,

    Request2.communaute_nom AS personne_proche_communaute

    FROM View_Communaute_Distance AS Request1, View_Communaute_Distance AS Request2
    WHERE calculer_distance_km(Request1.latitude, Request1.longitude, Request2.latitude, Request2.longitude) <= 1
    AND Request1.id_personne != Request2.id_personne);

    -- Pour voir les communauté proches d'un utilisateur
    -- SELECT count(*), personne_proche_communaute, personne_nom FROM View_Proches
    --   WHERE personne_nom = 'Leclercq'
    --   GROUP BY personne_proche_communaute

    -- Vue pour voir le nombre de personnes dans chaque communaute
    CREATE VIEW View_Communautes_Membres_Count AS
    (SELECT count(*) AS nombre_de_personnes, utilisateur_nom
    	FROM public.PersonneCommunaute
    	INNER JOIN Communaute ON Communaute.id_communaute = PersonneCommunaute.id_communaute
    	INNER JOIN Utilisateur ON Communaute.id_utilisateur = Utilisateur.id_utilisateur
    	GROUP BY Communaute.id_communaute, utilisateur_nom);

    -- Vue pour voir l'état des services entre UtilisateurService
    CREATE VIEW View_Services_Etat AS
    (SELECT service_nom,
    		service_realise,
    		savoir_faire_nom,
    		savoir_faire_degre,
    		utilisateur_nom_from,
    		utilisateur_nom AS utilisateur_nom_to

    FROM (SELECT UtilisateurService.service_nom AS service_nom,
    		utilisateur_service_realise AS service_realise,
    		savoir_faire_nom,
    		savoir_faire_degre,
    		utilisateur_nom AS utilisateur_nom_from,
    		UtilisateurService.id_utilisateur_to
    	FROM UtilisateurService
    	INNER JOIN ServiceSavoirFaire ON UtilisateurService.service_nom = ServiceSavoirFaire.service_nom
    	INNER JOIN Utilisateur ON UtilisateurService.id_utilisateur_from = Utilisateur.id_utilisateur) AS request

    	INNER JOIN Utilisateur ON request.id_utilisateur_to = Utilisateur.id_utilisateur);

--CREATION DES FONCTIONS

-- Fonction pour calculer la distance en km à partir de deux coordonnées géographiques
CREATE OR REPLACE FUNCTION calculer_distance_km(lat1 float, lon1 float, lat2 float, lon2 float)
RETURNS float AS $dist$
    DECLARE
        dist float = 0;
        radlat1 float;
        radlat2 float;
        theta float;
        radtheta float;
    BEGIN
        IF lat1 = lat2 OR lon1 = lon2
            THEN RETURN dist;
        ELSE
            radlat1 = pi() * lat1 / 180;
            radlat2 = pi() * lat2 / 180;
            theta = lon1 - lon2;
            radtheta = pi() * theta / 180;
            dist = sin(radlat1) * sin(radlat2) + cos(radlat1) * cos(radlat2) * cos(radtheta);

            IF dist > 1 THEN dist = 1; END IF;

            dist = acos(dist);
            dist = dist * 180 / pi();
            dist = dist * 60 * 1.1515;

            dist = dist * 1.609344;
            RETURN dist;
        END IF;
    END;
$dist$ LANGUAGE plpgsql;

--Fonction pour obtenir l'identifiant du message à la racine
CREATE OR REPLACE FUNCTION message_racine(message_id INTEGER)
	RETURNS INTEGER AS $$
DECLARE
   _id INTEGER := message_id ;
   _id_precedent INTEGER := 10 ;
BEGIN
   WHILE _id != 0 LOOP
     _id_precedent := _id ;
	   _id = (SELECT message_precedent_id FROM public.Message WHERE id_message = _id) ;
   END LOOP ;

   RETURN _id_precedent ;
END ;
$$ LANGUAGE plpgsql;

--Fonction pour savoir si un membre est exclue
CREATE OR REPLACE FUNCTION personne_exclue_communaute(id_pers INTEGER, id_commu INTEGER)
	RETURNS INTEGER AS $$
DECLARE
   nb_votes_contres INTEGER := 0 ;
   nb_personnes_communaute INTEGER := 0 ;
BEGIN
   nb_votes_contres = (SELECT count(*) AS vote_contres FROM Vote WHERE id_personne_to = id_pers AND id_communaute = id_commu GROUP BY id_personne_to, id_communaute) ;
   nb_personnes_communaute = (SELECT count(*) as nb_personnes FROM PersonneCommunaute WHERE id_communaute = id_commu GROUP BY id_communaute);
   IF nb_votes_contres > (nb_personnes_communaute/2)
      THEN RETURN 1;
   ELSE
      RETURN 0;
   END IF;
END ;
$$ LANGUAGE plpgsql;

--GESTION DES DROITS UTILISATEURS

CREATE ROLE UserPersonne;
CREATE ROLE UserCommunaute;

-- Chacun pourra :
    --s'ajouter à la base de données
    --créer des communautés
    --ajouter un savoir-faire
    --Proposer des services

--Chaque personne peut déclarer possèdent éventuellement des comptes
-- Les personnes peuvent par ailleurs déclarer faire partie de communautés et/ou avoir des liens avec d'autres personnes. Les communautés peuvent déclarer avoir des liens avec d'autres communautés.
--Chaque personne peut déclarer posséder un savoir-faire
--Une personne peut s'opposer à la présence d'une autre personne dans la communauté
--Les personnes et communauté peuvent s'échanger des messages
--Les personnes peuvent se localiser

GRANT INSERT
ON  Utilisateur, Personne, Communaute, PersonneCommunaute, SavoirFaire, UtilisateurSavoirFaire, Service, ServiceSavoirFaire, Compte, Vote, Message, Lien, CoordonneesGeographiques
TO UserPersonne;

--Toute personne membre d'une communauté peut administrer toutes les informations de cette communauté
GRANT SELECT, INSERT, DELETE, UPDATE
ON View_Communaute
TO UserPersonne;


CREATE VIEW MessageList AS
(SELECT * FROM Message NATURAL JOIN Personne WHERE Message.id_utilisateur_from = Personne.id_utilisateur) ;

--Un message est la propriété intégrale de son expéditeur.
GRANT UPDATE, DELETE, SELECT
ON MessageList
TO UserPersonne;

--Chaque communauté peut déclarer posséder un savoir-faire
--Chaque communauté peut déclarer posséder éventuellement des comptes
--Les personnes et communauté peuvent s'échanger des messages
--Les communautés peuvent déclarer avoir des liens avec d'autres communautés.

GRANT INSERT
ON SavoirFaire, Service, ServiceSavoirFaire, UtilisateurSavoirFaire, Compte, Message, Lien
TO UserCommunaute WITH GRANT OPTION;


GRANT SELECT
ON View_Communaute, View_Proches, View_Message
TO UserPersonne ;
