import Grid from "@mui/material/Grid";
import Card from "@mui/material/Card";

import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import MDButton from "components/MDButton";

import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Footer from "examples/Footer";

import { usePoulailler } from "context/PoulaillerContext";

function SuiviElevage() {
  const { vagueActive, calculerAge, cloturerVague } = usePoulailler();

  if (!vagueActive) {
    return (
      <DashboardLayout>
        <DashboardNavbar />
        <MDBox p={3}>
          <MDTypography>Aucune vague active</MDTypography>
        </MDBox>
        <Footer />
      </DashboardLayout>
    );
  }

  const age = calculerAge(vagueActive.dateArrivee);
  const poussinsRestants = vagueActive.nbPoussinsInitial - vagueActive.mortalites_totales;

  return (
    <DashboardLayout>
      <DashboardNavbar />
      <MDBox py={3}>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <Card>
              <MDBox p={3}>
                <MDTypography variant="h4">{vagueActive.nom}</MDTypography>

                <MDTypography>Âge : {age} jours</MDTypography>
                <MDTypography>Poussins restants : {poussinsRestants}</MDTypography>
                <MDTypography>Mortalités : {vagueActive.mortalites_totales}</MDTypography>

                <MDTypography mt={2}>
                  Dépenses : {vagueActive.finances.depenses_totales} FR
                </MDTypography>
                <MDTypography>Ventes : {vagueActive.finances.ventes_totales} FR</MDTypography>

                {vagueActive.isActive && (
                  <MDBox mt={3}>
                    <MDButton color="error" onClick={cloturerVague}>
                      Clôturer la vague
                    </MDButton>
                  </MDBox>
                )}
              </MDBox>
            </Card>
          </Grid>
        </Grid>
      </MDBox>
      <Footer />
    </DashboardLayout>
  );
}

export default SuiviElevage;
