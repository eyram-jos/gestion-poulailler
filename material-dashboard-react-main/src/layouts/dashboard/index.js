import { useEffect, useState } from "react";
import { onAuthStateChanged, signOut } from "firebase/auth";
import { auth } from "../../firebase";
import { useNavigate } from "react-router-dom";

import { collection, addDoc } from "firebase/firestore";
import { db } from "../../firebase";

import Grid from "@mui/material/Grid";
import Card from "@mui/material/Card";

import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import MDButton from "components/MDButton";

import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Footer from "examples/Footer";

import ComplexStatisticsCard from "examples/Cards/StatisticsCards/ComplexStatisticsCard";

import { usePoulailler } from "context/PoulaillerContext";

function Dashboard() {
  const navigate = useNavigate();
  const { vagueActive } = usePoulailler();

  const [currentUser, setCurrentUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (!user) {
        navigate("/authentication/sign-in");
      } else {
        setCurrentUser(user);
      }

      setLoading(false);
    });

    return () => unsubscribe();
  }, [navigate]);

  const handleLogout = async () => {
    try {
      await signOut(auth);

      navigate("/authentication/sign-in");
    } catch (error) {
      alert(error.message);
    }
  };

  const mortalites = vagueActive?.mortalites ?? [];

  const totalMorts = mortalites.reduce((a, b) => a + b.nombre, 0);

  const poussinsInitial = vagueActive?.nombrePoussins ?? 0;

  const tauxMortalite = poussinsInitial > 0 ? ((totalMorts / poussinsInitial) * 100).toFixed(1) : 0;

  const pouletsRestants = poussinsInitial - totalMorts;

  const testFirestore = async () => {
    try {
      await addDoc(collection(db, "testCollection"), {
        message: "Firestore fonctionne",

        createdAt: new Date(),

        user: currentUser?.email,
      });

      alert("Document ajouté dans Firestore ✅");
    } catch (error) {
      alert(error.message);
    }
  };

  const format = (n) => Number(n || 0).toLocaleString("fr-FR");

  if (loading) {
    return (
      <DashboardLayout>
        <DashboardNavbar />

        <MDBox py={6} textAlign="center">
          <MDTypography variant="h5">Chargement du profil...</MDTypography>
        </MDBox>
      </DashboardLayout>
    );
  }

  if (!vagueActive) {
    return (
      <DashboardLayout>
        <DashboardNavbar />

        <MDBox py={6} textAlign="center">
          <Card>
            <MDBox p={5}>
              <MDTypography variant="h4" color="error" fontWeight="bold">
                🚫 Aucune vague active
              </MDTypography>

              <MDTypography mt={2}>
                Lance une nouvelle vague pour commencer ton élevage
              </MDTypography>

              <MDBox mt={3} display="flex" justifyContent="center" gap={2}>
                <MDButton color="success" onClick={testFirestore}>
                  Tester Firestore
                </MDButton>

                <MDButton color="error" onClick={handleLogout}>
                  Logout
                </MDButton>
              </MDBox>
            </MDBox>
          </Card>
        </MDBox>

        <Footer />
      </DashboardLayout>
    );
  }

  const poussinsRestants = vagueActive.nbPoussinsInitial - vagueActive.mortalites_totales;

  return (
    <DashboardLayout>
      <DashboardNavbar />

      <MDBox py={3}>
        <MDBox mb={3}>
          <Card>
            <MDBox p={3}>
              <MDTypography variant="h4" fontWeight="bold">
                📌 Vague : {vagueActive.nom}
              </MDTypography>

              <MDTypography>
                Statut : {vagueActive.isActive ? "🟢 En cours" : "🔴 Clôturée"}
              </MDTypography>
            </MDBox>
          </Card>
        </MDBox>

        <Grid container spacing={3}>
          <Grid item xs={12} md={6} lg={3}>
            <ComplexStatisticsCard icon="pets" title="Poulets restants" count={pouletsRestants} />
          </Grid>

          <Grid item xs={12} md={6} lg={3}>
            <ComplexStatisticsCard
              icon="warning"
              title="Taux mortalité"
              count={`${tauxMortalite}%`}
            />
          </Grid>

          <Grid item xs={12} md={6} lg={3}>
            <ComplexStatisticsCard
              color="error"
              icon="shopping_cart"
              title="Total Dépenses"
              count={`${format(vagueActive.finances.depenses_totales)} FCFA`}
            />
          </Grid>

          <Grid item xs={12} md={6} lg={3}>
            <ComplexStatisticsCard
              color="success"
              icon="paid"
              title="Total Ventes"
              count={`${format(vagueActive.finances.ventes_totales)} FCFA`}
            />
          </Grid>
        </Grid>

        <MDBox mt={4}>
          <Card>
            <MDBox p={4} display="flex" justifyContent="space-between" alignItems="center">
              <MDTypography variant="h5" fontWeight="bold">
                📊 Bénéfice Global
              </MDTypography>

              <MDTypography
                variant="h3"
                fontWeight="bold"
                color={vagueActive.finances.benefice >= 0 ? "success" : "error"}
              >
                {format(vagueActive.finances.benefice)} FCFA
              </MDTypography>
            </MDBox>
          </Card>
        </MDBox>

        <MDBox mt={4} textAlign="center">
          <MDButton color="error" onClick={handleLogout}>
            Se déconnecter
          </MDButton>
        </MDBox>
      </MDBox>

      <Footer />
    </DashboardLayout>
  );
}

export default Dashboard;
