import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Footer from "examples/Footer";

import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import Grid from "@mui/material/Grid";

import ComplexStatisticsCard from "examples/Cards/StatisticsCards/ComplexStatisticsCard";
import ReportsBarChart from "examples/Charts/BarCharts/ReportsBarChart";

import { usePoulailler } from "context/PoulaillerContext";

import jsPDF from "jspdf";

const exportPDF = () => {
  const totalVentes = 0;
  const totalDepenses = 0;
  const benefice = totalVentes - totalDepenses;

  const doc = new jsPDF();

  doc.text("Bilan PoultryPro", 20, 20);
  doc.text(`Revenus: ${totalVentes} FCFA`, 20, 40);
  doc.text(`Depenses: ${totalDepenses} FCFA`, 20, 50);
  doc.text(`Benefice: ${benefice} FCFA`, 20, 60);

  doc.save("bilan-poulailler.pdf");
};
function RapportsBilan() {
  const { vagueActive } = usePoulailler();

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
  const depenses = vagueActive.depenses ?? [];

  const totalDepenses = depenses.reduce((a, b) => a + b.montant, 0);

  const totalVentes = ventes.reduce((a, b) => a + b.montant, 0);

  const benefice = totalVentes - totalDepenses;

  const categories = {};

  depenses.forEach((d) => {
    categories[d.type] = (categories[d.type] || 0) + d.montant;
  });

  const labelsDepenses = Object.keys(categories);
  const dataDepenses = Object.values(categories);

  return (
    <DashboardLayout>
      <DashboardNavbar />

      <MDBox pt={6} pb={3}>
        <MDTypography variant="h4" mb={3}>
          Bilan de la vague
        </MDTypography>

        <Grid container spacing={3}>
          <Grid item xs={12} md={4}>
            <ComplexStatisticsCard
              icon="paid"
              title="Revenus"
              count={`${totalVentes.toLocaleString()} FCFA`}
            />
          </Grid>

          <Grid item xs={12} md={4}>
            <ComplexStatisticsCard
              icon="money_off"
              title="Dépenses"
              count={`${totalDepenses.toLocaleString()} FCFA`}
            />
          </Grid>

          <Grid item xs={12} md={4}>
            <ComplexStatisticsCard
              icon="trending_up"
              title="Bénéfice"
              count={`${benefice.toLocaleString()} FCFA`}
            />
          </Grid>
        </Grid>

        <MDBox mt={4}>
          <ReportsBarChart
            title="Répartition des dépenses"
            description="Par catégorie"
            chart={{
              labels: labelsDepenses,
              datasets: [{ label: "Montant", data: dataDepenses }],
            }}
          />
        </MDBox>
      </MDBox>

      <button onClick={exportPDF}>Exporter PDF</button>

      <Footer />
    </DashboardLayout>
  );
}

export default RapportsBilan;
