import React, { useState } from "react";
import { addMedicament } from "../../services/medicamentsService";
import { useNavigate } from "react-router-dom";

import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Card from "@mui/material/Card";
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import MDInput from "components/MDInput";
import MDButton from "components/MDButton";

export default function AddMedicament() {
  const navigate = useNavigate();

  const [form, setForm] = useState({
    nom: "",
    prix: "",
    date: "",
    note: "",
  });

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = (e) => {
    e.preventDefault();
    addMedicament(form);
    navigate("/medicaments");
  };

  return (
    <DashboardLayout>
      <DashboardNavbar />

      <MDBox mt={4} display="flex" justifyContent="center">
        <Card style={{ padding: 20, width: "500px" }}>
          <MDTypography variant="h4" fontWeight="bold" mb={3}>
            Ajouter un médicament
          </MDTypography>

          <form onSubmit={handleSubmit}>
            <MDBox mb={2}>
              <MDInput label="Nom" name="nom" fullWidth onChange={handleChange} />
            </MDBox>

            <MDBox mb={2}>
              <MDInput
                type="number"
                label="Prix (FCFA)"
                name="prix"
                fullWidth
                onChange={handleChange}
              />
            </MDBox>

            <MDBox mb={2}>
              <MDInput type="date" name="date" fullWidth onChange={handleChange} />
            </MDBox>

            <MDBox mb={2}>
              <MDInput label="Note" name="note" fullWidth multiline onChange={handleChange} />
            </MDBox>

            <MDButton type="submit" variant="gradient" color="success" fullWidth>
              Ajouter
            </MDButton>
          </form>
        </Card>
      </MDBox>
    </DashboardLayout>
  );
}
