import { useState } from "react";
import { useNavigate } from "react-router-dom";
import Grid from "@mui/material/Grid";
import Card from "@mui/material/Card";

import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import MDInput from "components/MDInput";
import MDButton from "components/MDButton";

import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Footer from "examples/Footer";

import { usePoulailler } from "context/PoulaillerContext";

function GestionVagues() {
  const navigate = useNavigate();
  const { demarrerNouvelleVague, vagueActive } = usePoulailler();

  const [vagueData, setVagueData] = useState({
    nomVague: "",
    dateArrivee: new Date().toISOString().split("T")[0],
    poussinsInitiaux: "",
    joursCibleVente: 40,
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setVagueData((prev) => ({
      ...prev,
      [name]: name === "poussinsInitiaux" ? Number(value) : value,
    }));
  };

  const demarrer = () => {
    if (!vagueData.nomVague || vagueData.poussinsInitiaux <= 0) {
      alert("Veuillez remplir correctement les champs");
      return;
    }
    demarrerNouvelleVague(vagueData);
    navigate("/suivi-elevage");
  };

  return (
    <DashboardLayout>
      <DashboardNavbar />
      <MDBox py={3}>
        <Grid container spacing={3}>
          <Grid item xs={12} md={6}>
            <Card>
              <MDBox p={3}>
                <MDTypography variant="h5">Vague actuelle</MDTypography>
                <MDTypography mt={1}>
                  {vagueActive
                    ? `${vagueActive.nom} — ${vagueActive.isActive ? "Active" : "Clôturée"}`
                    : "Aucune vague en cours"}
                </MDTypography>
              </MDBox>
            </Card>
          </Grid>

          <Grid item xs={12} md={6}>
            <Card>
              <MDBox p={3}>
                <MDTypography variant="h5">Démarrer une nouvelle vague</MDTypography>

                <MDInput
                  label="Nom de la vague"
                  name="nomVague"
                  value={vagueData.nomVague}
                  onChange={handleChange}
                  fullWidth
                  sx={{ mb: 2 }}
                />

                <MDInput
                  type="number"
                  label="Nombre de poussins"
                  name="poussinsInitiaux"
                  value={vagueData.poussinsInitiaux}
                  onChange={handleChange}
                  fullWidth
                />

                <MDBox mt={3}>
                  <MDButton color="info" onClick={demarrer}>
                    Démarrer la vague
                  </MDButton>
                </MDBox>
              </MDBox>
            </Card>
          </Grid>
        </Grid>
      </MDBox>
      <Footer />
    </DashboardLayout>
  );
}

export default GestionVagues;
