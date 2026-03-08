/**
=========================================================
* Material Dashboard 2 React - v2.2.0
=========================================================

* Product Page: https://www.creative-tim.com/product/material-dashboard-react
* Copyright 2023 Creative Tim (https://www.creative-tim.com)

Coded by www.creative-tim.com
=========================================================
*/

import { useState } from "react";
import { createUserWithEmailAndPassword } from "firebase/auth";
import { auth, db } from "../../../firebase";
import { doc, setDoc } from "firebase/firestore";
import { useNavigate, Link } from "react-router-dom";

// @mui material components
import Card from "@mui/material/Card";
import Checkbox from "@mui/material/Checkbox";

// Material Dashboard 2 React components
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import MDInput from "components/MDInput";
import MDButton from "components/MDButton";

// Authentication layout components
import CoverLayout from "layouts/authentication/components/CoverLayout";

// Images
import bgImage from "assets/images/bg-sign-up-cover.jpeg";

function Cover() {
  const navigate = useNavigate();

  const [name, setName] = useState("");
  const [farmName, setFarmName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleRegister = async (e) => {
    e.preventDefault();

    try {
      // 1️⃣ Création du compte Firebase Auth
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // 2️⃣ Création du profil utilisateur dans Firestore
      await setDoc(doc(db, "users", user.uid), {
        name: name,
        farmName: farmName,
        email: email,
        createdAt: new Date(),
      });

      alert("Compte créé avec succès ✅");

      // 3️⃣ redirection dashboard
      navigate("/dashboard");
    } catch (error) {
      alert(error.message);
    }
  };

  return (
    <CoverLayout image={bgImage}>
      <Card>
        <MDBox pt={4} pb={3} px={3}>
          <MDBox component="form" role="form" onSubmit={handleRegister}>
            {/* NOM */}
            <MDBox mb={2}>
              <MDInput
                type="text"
                label="Name"
                variant="standard"
                fullWidth
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
            </MDBox>

            {/* NOM FERME */}
            <MDBox mb={2}>
              <MDInput
                type="text"
                label="Farm Name"
                variant="standard"
                fullWidth
                value={farmName}
                onChange={(e) => setFarmName(e.target.value)}
              />
            </MDBox>

            {/* EMAIL */}
            <MDBox mb={2}>
              <MDInput
                type="email"
                label="Email"
                variant="standard"
                fullWidth
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </MDBox>

            {/* PASSWORD */}
            <MDBox mb={2}>
              <MDInput
                type="password"
                label="Password"
                variant="standard"
                fullWidth
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                inputProps={{ autoComplete: "new-password" }}
              />
            </MDBox>

            {/* CONDITIONS */}
            <MDBox display="flex" alignItems="center" ml={-1}>
              <Checkbox />
              <MDTypography
                variant="button"
                fontWeight="regular"
                color="text"
                sx={{ cursor: "pointer", userSelect: "none", ml: -1 }}
              >
                &nbsp;&nbsp;I agree the&nbsp;
              </MDTypography>
              <MDTypography
                component="a"
                href="#"
                variant="button"
                fontWeight="bold"
                color="info"
                textGradient
              >
                Terms and Conditions
              </MDTypography>
            </MDBox>

            {/* BOUTON */}
            <MDBox mt={4} mb={1}>
              <MDButton type="submit" variant="gradient" color="info" fullWidth>
                Sign Up
              </MDButton>
            </MDBox>

            {/* LOGIN */}
            <MDBox mt={3} mb={1} textAlign="center">
              <MDTypography variant="button" color="text">
                Already have an account?{" "}
                <MDTypography
                  component={Link}
                  to="/authentication/sign-in"
                  variant="button"
                  color="info"
                  fontWeight="medium"
                  textGradient
                >
                  Sign In
                </MDTypography>
              </MDTypography>
            </MDBox>
          </MDBox>
        </MDBox>
      </Card>
    </CoverLayout>
  );
}

export default Cover;
