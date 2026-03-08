import { useState } from "react";
import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Footer from "examples/Footer";

import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import MDInput from "components/MDInput";
import MDButton from "components/MDButton";

import { usePoulailler } from "context/PoulaillerContext";

function GestionVentes() {
  const { vagueActive, ajouterVente } = usePoulailler();

  const [quantite, setQuantite] = useState("");
  const [prix, setPrix] = useState(3000);

  if (!vagueActive) {
    return (
      <DashboardLayout>
        <DashboardNavbar />
        <MDBox p={4}>
          <MDTypography color="error">Aucune vague active</MDTypography>
        </MDBox>
        <Footer />
      </DashboardLayout>
    );
  }

  const ventes = vagueActive.ventes ?? [];

  const handleVente = () => {
    const qte = Number(quantite);
    const p = Number(prix);

    if (qte <= 0 || p <= 0) {
      alert("Veuillez entrer des valeurs correctes");
      return;
    }

    const montant = qte * p;

    ajouterVente({
      quantite: qte,
      prixUnitaire: p,
      montant,
      date: new Date().toLocaleDateString("fr-FR"),
      id: Date.now(),
    });

    setQuantite("");
  };

  return (
    <DashboardLayout>
      <DashboardNavbar />

      <MDBox p={4}>
        <MDTypography variant="h4" mb={3}>
          Nouvelle vente
        </MDTypography>

        <MDInput
          label="Quantité vendue"
          type="number"
          value={quantite}
          onChange={(e) => setQuantite(e.target.value)}
          fullWidth
        />

        <MDBox mt={2}>
          <MDInput
            label="Prix unitaire"
            type="number"
            value={prix}
            onChange={(e) => setPrix(e.target.value)}
            fullWidth
          />
        </MDBox>

        <MDButton color="success" onClick={handleVente} sx={{ mt: 2 }}>
          Enregistrer la vente
        </MDButton>

        <MDBox mt={4}>
          <MDTypography variant="h6">Historique des ventes</MDTypography>

          {ventes.length === 0 ? (
            <MDTypography>Aucune vente enregistrée</MDTypography>
          ) : (
            ventes.map((v) => (
              <MDBox
                key={v.id}
                display="flex"
                justifyContent="space-between"
                borderBottom="1px solid #eee"
                py={1}
              >
                <span>{v.date}</span>
                <span>{v.quantite} poulets</span>
                <strong>{v.montant.toLocaleString("fr-FR")} FR</strong>
              </MDBox>
            ))
          )}
        </MDBox>
      </MDBox>

      <Footer />
    </DashboardLayout>
  );
}

export default GestionVentes;
