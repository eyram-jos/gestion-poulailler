/**
=========================================================
* PoultryPro - Profil utilisateur
=========================================================
*/

import { useEffect, useState } from "react";

// firebase
import { auth, db } from "../../firebase";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { onAuthStateChanged } from "firebase/auth";

// @mui material components
import Grid from "@mui/material/Grid";
import Divider from "@mui/material/Divider";

// components
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";

// layout
import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Footer from "examples/Footer";

// cards
import ProfileInfoCard from "examples/Cards/InfoCards/ProfileInfoCard";

// header
import Header from "layouts/profile/components/Header";

function Overview() {
  const [userData, setUserData] = useState(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (!user) return;

      const docRef = doc(db, "users", user.uid);
      const docSnap = await getDoc(docRef);

      if (docSnap.exists()) {
        setUserData(docSnap.data());
      } else {
        // créer profil automatiquement
        const newUser = {
          name: user.displayName || "Utilisateur",
          email: user.email,
          farmName: "Ma ferme",
        };

        await setDoc(docRef, newUser);

        setUserData(newUser);
      }
    });

    return () => unsubscribe();
  }, []);

  if (!userData) {
    return (
      <DashboardLayout>
        <DashboardNavbar />
        <MDBox p={4}>
          <MDTypography>Chargement du profil...</MDTypography>
        </MDBox>
        <Footer />
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <DashboardNavbar />

      <MDBox mb={2} />

      <Header>
        <MDBox mt={5} mb={3}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6} xl={6}>
              <ProfileInfoCard
                title="Informations utilisateur"
                description="Profil de votre compte PoultryPro"
                info={{
                  Nom: userData?.name || "-",
                  Email: userData?.email || "-",
                  Ferme: userData?.farmName || "-",
                }}
                social={[]}
                action={{
                  route: "/profile",
                  tooltrip: "modifier profil",
                }}
              />
            </Grid>

            <Grid item xs={12} md={6} xl={6}>
              <Divider orientation="vertical" sx={{ ml: -2, mr: 1 }} />

              <MDBox p={3}>
                <MDTypography variant="h5">Votre ferme</MDTypography>

                <MDBox mt={2}>
                  <MDTypography variant="button">
                    🐔 Nom de la ferme : {userData.farmName}
                  </MDTypography>

                  <MDBox mt={2} />

                  <MDTypography variant="button">📧 Email : {userData.email}</MDTypography>

                  <MDBox mt={2} />

                  <MDTypography variant="button">👤 Propriétaire : {userData.name}</MDTypography>
                </MDBox>
              </MDBox>
            </Grid>
          </Grid>
        </MDBox>
      </Header>

      <Footer />
    </DashboardLayout>
  );
}

export default Overview;
