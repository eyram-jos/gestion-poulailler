import React, { useEffect, useState } from "react";
import { getMedicamentById, updateMedicament } from "../../services/medicamentsService";
import { useParams, useNavigate } from "react-router-dom";

import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Card from "@mui/material/Card";
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import MDInput from "components/MDInput";
import MDButton from "components/MDButton";

export default function EditMedicament() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [form, setForm] = useState({
    nom: "",
    prix: "",
    date: "",
    note: "",
  });

  useEffect(() => {
    const data = getMedicamentById(id);
    if (data) setForm(data);
  }, [id]);

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = (e) => {
    e.preventDefault();
    updateMedicament(id, form);
    navigate("/medicaments");
  };

  return (
    <DashboardLayout>
      <DashboardNavbar />

      <MDBox mt={4} display="flex" justifyContent="center">
        <Card style={{ padding: 20, width: "500px" }}>
          <MDTypography variant="h4" fontWeight="bold" mb={3}>
            Modifier le médicament
          </MDTypography>

          <form onSubmit={handleSubmit}>
            <MDBox mb={2}>
              <MDInput label="Nom" name="nom" value={form.nom} fullWidth onChange={handleChange} />
            </MDBox>

            <MDBox mb={2}>
              <MDInput
                type="number"
                label="Prix (FCFA)"
                name="prix"
                value={form.prix}
                fullWidth
                onChange={handleChange}
              />
            </MDBox>

            <MDBox mb={2}>
              <MDInput
                type="date"
                name="date"
                value={form.date}
                fullWidth
                onChange={handleChange}
              />
            </MDBox>

            <MDBox mb={2}>
              <MDInput
                label="Note"
                name="note"
                value={form.note}
                fullWidth
                multiline
                onChange={handleChange}
              />
            </MDBox>

            <MDButton variant="gradient" color="warning" type="submit" fullWidth>
              Modifier
            </MDButton>
          </form>
        </Card>
      </MDBox>
    </DashboardLayout>
  );
}
