// src/constants.js

// --- CONFIGURATION FINANCIÈRE ET LOGISTIQUE DE L'ÉLEVAGE ---

export const PRIX_ACHAT = {
  CARTON_POUSSINS_PRIX: 28500, // Prix pour un carton de 50 poussins
  POUSSINS_PAR_CARTON: 50,
};

export const ALIMENTS = {
  SAC_DEMARRAGE_PRIX: 18000,
  SAC_CROISSANCE_PRIX: 18000,
  // Estimation pour 200 poussins :
  DEMARRAGE_SACS_ESTIME: 2,
  CROISSANCE_SACS_ESTIME: 6,
};

export const MEDICAMENTS = {
  ANTISTRESS_PRIX: 3000,
  GUMBORO_PRIX: 500,
  ANTICOCCODICIEN_PRIX: 3000,
  ANTIDOTE_MORTALITE_PRIX: 5000,
  ANTISTRESS_DUREE_J_1: 3, // 3 jours après l'arrivée
  ANTISTRESS_DUREE_J_2: 3, // 3 jours après l'anticoccidien
};

export const LIVRAISONS_FRAIS = 2000;

export const ENTRETIEN_FRAIS = {
  DEPLUMEUSE_PRIX_UNITAIRE: 100, // 100 FR par poulet pour la déplumeuse
};

export const VENTE = {
  PRIX_VENTE_MOYEN: 3500,
  PRIX_VENTE_MIN: 3000,
  PRIX_VENTE_MAX: 4000,
  DUREE_ELEVAGE_MIN_JOURS: 35,
  DUREE_ELEVAGE_MAX_JOURS: 45,
};

// --- CALENDRIER DE SOINS (RAPPELS) ---

// Les jours sont relatifs au JOUR D'ARRIVÉE (Jour 0)
export const CALENDRIER_SOINS = [
  { jour: 0, titre: "Arrivée", description: "Eau + Sucre + Aliment Démarrage (Début de Vague)." },
  { jour: 1, titre: "Soins J+1", description: "Début de l'Antistress (1 sachet/3 jours)." },
  { jour: 4, titre: "Fin Antistress J+1", description: "Fin du premier cycle d'Antistress." },
  { jour: 12, titre: "Gumboro", description: "Administration du Gumboro (J+11 à J+15)." },
  {
    jour: 15,
    titre: "Transition Alimentaire",
    description: "Commencer la transition Démarrage/Croissance (Mélanger les aliments).",
  },
  { jour: 16, titre: "Aliment Croissance", description: "Début de l'Aliment Croissance pur." },
  {
    jour: 25,
    titre: "Anticoccidien/Antistress",
    description:
      "Vérifier la consommation de croissance. Administrer l'Anticoccidien (3 jours) suivi du 2e Antistress.",
  },
];
