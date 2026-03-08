import { useState } from "react";
import Grid from "@mui/material/Grid";
import Card from "@mui/material/Card";
import MenuItem from "@mui/material/MenuItem";

import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import MDInput from "components/MDInput";
import MDButton from "components/MDButton";

import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Footer from "examples/Footer";

import { usePoulailler } from "context/PoulaillerContext";

function DepensesAchats() {
  const { vagueActive, ajouterDepense } = usePoulailler();

  const [form, setForm] = useState({
    type: "aliment",
    libelle: "",
    montant: "",
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const enregistrer = () => {
    if (!form.libelle || !form.montant) {
      alert("Veuillez remplir tous les champs");
      return;
    }

    ajouterDepense({
      type: form.type,
      libelle: form.libelle,
      montant: Number(form.montant),
    });

    setForm({
      type: "aliment",
      libelle: "",
      montant: "",
    });
  };

  if (!vagueActive) {
    return (
      <DashboardLayout>
        <DashboardNavbar />
        <MDBox p={3}>
          <MDTypography color="error">Aucune vague active</MDTypography>
        </MDBox>
        <Footer />
      </DashboardLayout>
    );
  }

  // ✅ PROTECTION : si historique_depenses n'existe pas encore
  const depenses = vagueActive.depenses ?? [];

  return (
    <DashboardLayout>
      <DashboardNavbar />

      <MDBox py={3}>
        <Grid container spacing={3}>
          {/* FORMULAIRE */}
          <Grid item xs={12} md={5}>
            <Card>
              <MDBox p={3}>
                <MDTypography variant="h5">Nouvelle dépense</MDTypography>

                <MDBox mt={2}>
                  <MDInput select name="type" value={form.type} onChange={handleChange} fullWidth>
                    <MenuItem value="aliment">Aliment</MenuItem>
                    <MenuItem value="medicament">Médicament</MenuItem>
                    <MenuItem value="autre">Autre</MenuItem>
                  </MDInput>
                </MDBox>

                <MDBox mt={2}>
                  <MDInput
                    label="Libellé"
                    name="libelle"
                    value={form.libelle}
                    onChange={handleChange}
                    fullWidth
                  />
                </MDBox>

                <MDBox mt={2}>
                  <MDInput
                    type="number"
                    label="Montant"
                    name="montant"
                    value={form.montant}
                    onChange={handleChange}
                    fullWidth
                  />
                </MDBox>

                <MDBox mt={3}>
                  <MDButton color="info" fullWidth onClick={enregistrer}>
                    Enregistrer
                  </MDButton>
                </MDBox>
              </MDBox>
            </Card>
          </Grid>

          {/* HISTORIQUE */}
          <Grid item xs={12} md={7}>
            <Card>
              <MDBox p={3}>
                <MDTypography variant="h5">Historique des dépenses</MDTypography>

                {depenses.length === 0 && (
                  <MDTypography mt={2}>Aucune dépense enregistrée</MDTypography>
                )}

                {depenses.map((d, i) => (
                  <MDBox key={i} display="flex" justifyContent="space-between" mt={2}>
                    <MDTypography>
                      {d.libelle} ({d.type})
                    </MDTypography>

                    <MDTypography color="error">
                      {d.montant.toLocaleString("fr-FR")} FR
                    </MDTypography>
                  </MDBox>
                ))}
              </MDBox>
            </Card>
          </Grid>
        </Grid>
      </MDBox>

      <Footer />
    </DashboardLayout>
  );
}

export default DepensesAchats;
