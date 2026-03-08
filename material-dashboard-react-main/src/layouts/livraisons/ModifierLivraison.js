import React, { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import Grid from "@mui/material/Grid";
import Card from "@mui/material/Card";
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import MDInput from "components/MDInput";
import MDButton from "components/MDButton";
import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Footer from "examples/Footer";

import { getLivraisonById, updateLivraison } from "services/livraisonsService";

export default function ModifierLivraison() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [form, setForm] = useState(null);

  useEffect(() => {
    const item = getLivraisonById(id);
    if (!item) {
      alert("Livraison introuvable");
      navigate("/livraisons");
      return;
    }
    setForm(item);
  }, [id, navigate]);

  if (!form) return null;

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((s) => ({ ...s, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    updateLivraison(id, form);
    navigate("/livraisons");
  };

  return (
    <DashboardLayout>
      <DashboardNavbar />
      <MDBox py={3}>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <Card>
              <MDBox p={3}>
                <MDTypography variant="h5" mb={2}>
                  Modifier la livraison
                </MDTypography>

                <form onSubmit={handleSubmit}>
                  <Grid container spacing={2}>
                    <Grid item xs={12} md={3}>
                      <MDInput
                        type="date"
                        label="Date"
                        name="date"
                        value={form.date}
                        onChange={handleChange}
                        fullWidth
                      />
                    </Grid>

                    <Grid item xs={12} md={3}>
                      <MDInput
                        select
                        label="Type"
                        name="type"
                        value={form.type}
                        onChange={handleChange}
                        fullWidth
                      >
                        <option value="Aliment">Aliment</option>
                        <option value="Poussins">Poussins</option>
                        <option value="Autre">Autre</option>
                      </MDInput>
                    </Grid>

                    <Grid item xs={12} md={3}>
                      <MDInput
                        type="number"
                        label="Montant (FR)"
                        name="montant"
                        value={form.montant}
                        onChange={handleChange}
                        fullWidth
                      />
                    </Grid>

                    <Grid item xs={12} md={3}>
                      <MDInput
                        type="number"
                        label="Transport (FR)"
                        name="transport"
                        value={form.transport}
                        onChange={handleChange}
                        fullWidth
                      />
                    </Grid>

                    <Grid item xs={12} md={6}>
                      <MDInput
                        type="text"
                        label="Fournisseur"
                        name="fournisseur"
                        value={form.fournisseur}
                        onChange={handleChange}
                        fullWidth
                      />
                    </Grid>

                    <Grid item xs={12}>
                      <MDInput
                        type="text"
                        label="Notes"
                        name="notes"
                        value={form.notes}
                        onChange={handleChange}
                        fullWidth
                        multiline
                        rows={3}
                      />
                    </Grid>
                  </Grid>

                  <MDBox mt={3}>
                    <MDButton type="submit" variant="gradient" color="success">
                      Enregistrer
                    </MDButton>
                    <MDButton
                      variant="outlined"
                      color="dark"
                      onClick={() => navigate("/livraisons")}
                      style={{ marginLeft: 8 }}
                    >
                      Annuler
                    </MDButton>
                  </MDBox>
                </form>
              </MDBox>
            </Card>
          </Grid>
        </Grid>
      </MDBox>
      <Footer />
    </DashboardLayout>
  );
}
