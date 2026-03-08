/**
=========================================================
* Material Dashboard 2 React - v2.2.0
=========================================================
* (Adapted for Poulailler Management Application)
=========================================================
*/

// ************************************************
// NOUVEAUX IMPORTS POUR LE POULAILLER
// VOUS DEVEZ CRÉER CES FICHIERS DANS LE DOSSIER 'layouts'
// ************************************************
import Dashboard from "layouts/dashboard";
import SuiviElevage from "layouts/suivi-elevage";
import DepensesAchats from "layouts/depenses-achats";
import GestionVentes from "layouts/gestion-ventes";
import GestionVagues from "layouts/gestion-vagues";
import MedicamentsPage from "layouts/medicaments/MedicamentsPage";
import AddMedicament from "layouts/medicaments/AddMedicament";
import EditMedicament from "layouts/medicaments/EditMedicament";
import LivraisonsList from "layouts/livraisons";
import AjouterLivraison from "layouts/livraisons/AjouterLivraison";
import ModifierLivraison from "layouts/livraisons/ModifierLivraison";
import RapportsBilan from "layouts/rapports-bilan";

// ************************************************
// IMPORTS SYSTÈME (GARDÉS)
// ************************************************
import Profile from "layouts/profile"; // Gardé pour les paramètres de l'utilisateur ou du système
import SignIn from "layouts/authentication/sign-in";
import SignUp from "layouts/authentication/sign-up";

// @mui icons
import Icon from "@mui/material/Icon";

const routes = [
  // =========================================================================
  // BLOC 1 : FONCTIONNALITÉS PRINCIPALES DU POULAILLER
  // =========================================================================
  {
    type: "collapse",
    name: "Tableau de Bord",
    key: "dashboard",
    icon: <Icon fontSize="small">dashboard</Icon>,
    route: "/dashboard",
    component: <Dashboard />,
  },
  {
    type: "collapse",
    name: "Suivi d'Élevage",
    key: "suivi-elevage",
    icon: <Icon fontSize="small">event_note</Icon>, // Calendrier, rappels de soins
    route: "/suivi-elevage",
    component: <SuiviElevage />,
  },
  {
    type: "collapse",
    name: "Dépenses & Achats",
    key: "depenses-achats",
    icon: <Icon fontSize="small">receipt_long</Icon>, // Factures, coûts
    route: "/depenses-achats",
    component: <DepensesAchats />,
  },
  {
    type: "collapse",
    name: "Gestion des Ventes",
    key: "gestion-ventes",
    icon: <Icon fontSize="small">shopping_cart</Icon>, // Enregistrement des revenus
    route: "/gestion-ventes",
    component: <GestionVentes />,
  },
  {
    type: "collapse",
    name: "Gestion des Vagues",
    key: "gestion-vagues",
    icon: <Icon fontSize="small">repeat</Icon>, // Cycle, démarrer nouveau lot
    route: "/gestion-vagues",
    component: <GestionVagues />,
  },

  {
    type: "collapse",
    name: "Médicaments",
    key: "medicaments",
    icon: <Icon fontSize="small">medical_services</Icon>,
    route: "/medicaments",
    component: <MedicamentsPage />,
  },
  {
    route: "/medicaments/new",
    component: <AddMedicament />,
  },
  {
    route: "/medicaments/edit/:id",
    component: <EditMedicament />,
  },

  {
    type: "collapse",
    name: "Livraisons",
    key: "livraisons",
    icon: <Icon fontSize="small">local_shipping</Icon>,
    route: "/livraisons",
    component: <LivraisonsList />,
  },
  {
    key: "livraisons-new",
    route: "/livraisons/new",
    component: <AjouterLivraison />,
  },
  {
    key: "livraisons-edit",
    route: "/livraisons/edit/:id",
    component: <ModifierLivraison />,
  },

  {
    type: "collapse",
    name: "Rapports & Bilan",
    key: "rapports-bilan",
    icon: <Icon fontSize="small">timeline</Icon>, // Analyse de performance
    route: "/rapports-bilan",
    component: <RapportsBilan />,
  },

  // =========================================================================
  // BLOC 2 : COMPOSANTS SYSTÈMES ET AUTHENTIFICATION
  // =========================================================================

  // Titre séparateur dans la sidebar (facultatif mais recommandé pour la clarté)
  {
    type: "title",
    title: "COMPTES",
    key: "account-pages-title",
  },

  {
    type: "collapse",
    name: "Mon Profil",
    key: "profile",
    icon: <Icon fontSize="small">person</Icon>,
    route: "/profile",
    component: <Profile />,
  },
  {
    type: "collapse",
    name: "Se Connecter",
    key: "sign-in",
    icon: <Icon fontSize="small">login</Icon>,
    route: "/authentication/sign-in",
    component: <SignIn />,
  },
  {
    type: "collapse",
    name: "S'inscrire",
    key: "sign-up",
    icon: <Icon fontSize="small">assignment</Icon>,
    route: "/authentication/sign-up",
    component: <SignUp />,
  },
];

export default routes;
