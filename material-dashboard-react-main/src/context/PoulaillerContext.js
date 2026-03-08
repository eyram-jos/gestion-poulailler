import React, { createContext, useContext, useEffect, useState } from "react";
import PropTypes from "prop-types";

const PoulaillerContext = createContext();

const STORAGE_KEY = "POULAILLER_APP_DATA";

const initialState = {
  vagueActive: null,
  vagues: [],
};

export function PoulaillerProvider({ children }) {
  const [data, setData] = useState(() => {
    const saved = localStorage.getItem(STORAGE_KEY);
    return saved ? JSON.parse(saved) : initialState;
  });

  // ✅ Sauvegarde automatique
  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  }, [data]);

  // =========================================================
  // ✅ DÉMARRER UNE NOUVELLE VAGUE
  // =========================================================
  const demarrerNouvelleVague = (vagueData) => {
    const nouvelleVague = {
      id: Date.now(),

      nom: vagueData.nomVague,
      dateArrivee: vagueData.dateArrivee,
      nbPoussinsInitial: vagueData.poussinsInitiaux,

      mortalites_totales: 0,

      historique_depenses: [],
      ventes: [],

      finances: {
        depenses_totales: 0,
        ventes_totales: 0,
        benefice: 0,
      },

      isActive: true,
    };

    setData((prev) => ({
      ...prev,
      vagueActive: nouvelleVague,
      vagues: [...prev.vagues, nouvelleVague],
    }));
  };

  // =========================================================
  // ✅ METTRE À JOUR UNE VAGUE ACTIVE
  // =========================================================
  const setVagueActive = (updatedVague) => {
    setData((prev) => ({
      ...prev,
      vagueActive: updatedVague,
      vagues: prev.vagues.map((v) => (v.id === updatedVague.id ? updatedVague : v)),
    }));
  };

  // =========================================================
  // ✅ AJOUTER UNE VENTE (PAGE GestionVentes)
  // =========================================================

  // ✅ Ajouter une vente
  const ajouterVente = (vente) => {
    if (!data.vagueActive) return;

    const montant = vente.montant;

    const nouvelleVente = {
      ...vente,
      id: Date.now(),
      date: new Date().toLocaleDateString("fr-FR"),
    };

    const updatedVague = {
      ...data.vagueActive,
      ventes: [...(data.vagueActive.ventes ?? []), nouvelleVente],
      finances: {
        ...data.vagueActive.finances,
        ventes_totales: (data.vagueActive.finances?.ventes_totales ?? 0) + montant,
        benefice: (data.vagueActive.finances?.benefice ?? 0) + montant,
      },
    };

    setVagueActive(updatedVague);
  };

  // ✅ Ajouter une dépense
  const ajouterDepense = (depense) => {
    if (!data.vagueActive) return;

    const montant = depense.montant;

    const nouvelleDepense = {
      ...depense,
      id: Date.now(),
      date: new Date().toLocaleDateString("fr-FR"),
    };

    const updatedVague = {
      ...data.vagueActive,
      depenses: [...(data.vagueActive.depenses ?? []), nouvelleDepense],
      finances: {
        ...data.vagueActive.finances,
        depenses_totales: (data.vagueActive.finances?.depenses_totales ?? 0) + montant,
        benefice: (data.vagueActive.finances?.benefice ?? 0) - montant,
      },
    };

    setVagueActive(updatedVague);
  };

  // =========================================================
  // ✅ CALCULER ÂGE EN JOURS
  // =========================================================
  const calculerAge = (dateArrivee) => {
    if (!dateArrivee) return 0;

    const debut = new Date(dateArrivee);
    const aujourdHui = new Date();

    return Math.floor((aujourdHui - debut) / (1000 * 60 * 60 * 24));
  };

  // =========================================================
  // ✅ CLÔTURER LA VAGUE (PAGE SuiviElevage)
  // =========================================================
  const cloturerVague = () => {
    if (!data.vagueActive) return;

    const updatedVague = {
      ...data.vagueActive,
      isActive: false,
    };

    setVagueActive(updatedVague);
  };

  return (
    <PoulaillerContext.Provider
      value={{
        vagueActive: data.vagueActive,
        vagues: data.vagues,

        demarrerNouvelleVague,
        setVagueActive,

        ajouterDepense,
        ajouterVente,

        calculerAge,
        cloturerVague,
      }}
    >
      {children}
    </PoulaillerContext.Provider>
  );
}

PoulaillerProvider.propTypes = {
  children: PropTypes.node.isRequired,
};

export const usePoulailler = () => useContext(PoulaillerContext);
