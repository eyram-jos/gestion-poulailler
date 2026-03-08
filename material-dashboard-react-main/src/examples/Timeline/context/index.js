/* eslint-disable react/prop-types */
import { createContext, useContext } from "react";

// Le contexte principal de la chronologie
const Timeline = createContext();

// Fournisseur de contexte de la chronologie
function TimelineProvider({ children, value }) {
  return <Timeline.Provider value={value}>{children}</Timeline.Provider>;
}

// Hook de contexte personnalisé pour utiliser la chronologie
function useTimeline() {
  return useContext(Timeline);
}

// 🎯 LIGNE CLÉ : Exportation par défaut de l'objet
export default { TimelineProvider, useTimeline };
/* eslint-enable react/prop-types */
