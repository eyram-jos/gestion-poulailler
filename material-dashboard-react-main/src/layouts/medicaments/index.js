import { useState } from "react";
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

function Medicaments() {
  const { vagueActive, ajouterMedicament } = usePoulailler();

  const [form, setForm] = useState({
    nom: "",
    type: "",
    dateAdministration: "",
    joursRappel: 0,
  });

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

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const calculerDateRappel = (date, jours) => {
    const d = new Date(date);
    d.setDate(d.getDate() + Number(jours));
    return d.toISOString().split("T")[0];
  };

  const enregistrerMedicament = () => {
    if (!form.nom || !form.dateAdministration) {
      alert("Champs obligatoires manquants");
      return;
    }

    const rappel =
      form.joursRappel > 0 ? calculerDateRappel(form.dateAdministration, form.joursRappel) : null;

    ajouterMedicament({
      id: Date.now(),
      nom: form.nom,
      type: form.type,
      dateAdministration: form.dateAdministration,
      joursRappel: Number(form.joursRappel),
      dateRappel: rappel,
    });

    setForm({
      nom: "",
      type: "",
      dateAdministration: "",
      joursRappel: 0,
    });
  };

  return (
    <DashboardLayout>
      <DashboardNavbar />
      <MDBox py={3}>
        <Grid container spacing={3}>
          {/* FORMULAIRE */}
          <Grid item xs={12} md={5}>
            <Card>
              <MDBox p={3}>
                <MDTypography variant="h5">Nouveau médicament / vaccin</MDTypography>

                <MDBox mt={2}>
                  <MDInput
                    label="Nom du médicament"
                    name="nom"
                    value={form.nom}
                    onChange={handleChange}
                    fullWidth
                  />
                </MDBox>

                <MDBox mt={2}>
                  <MDInput
                    label="Type (vaccin, antibiotique, vitamine...)"
                    name="type"
                    value={form.type}
                    onChange={handleChange}
                    fullWidth
                  />
                </MDBox>

                <MDBox mt={2}>
                  <MDInput
                    type="date"
                    label="Date d'administration"
                    name="dateAdministration"
                    value={form.dateAdministration}
                    onChange={handleChange}
                    fullWidth
                    InputLabelProps={{ shrink: true }}
                  />
                </MDBox>

                <MDBox mt={2}>
                  <MDInput
                    type="number"
                    label="Rappel après (jours)"
                    name="joursRappel"
                    value={form.joursRappel}
                    onChange={handleChange}
                    fullWidth
                  />
                </MDBox>

                <MDBox mt={3}>
                  <MDButton color="info" onClick={enregistrerMedicament}>
                    Enregistrer
                  </MDButton>
                </MDBox>
              </MDBox>
            </Card>
          </Grid>

          {/* HISTORIQUE + RAPPELS */}
          <Grid item xs={12} md={7}>
            <Card>
              <MDBox p={3}>
                <MDTypography variant="h5">Historique & rappels</MDTypography>

                {vagueActive.medicaments.length === 0 && (
                  <MDTypography>Aucun médicament enregistré</MDTypography>
                )}

                {vagueActive.medicaments.map((m, i) => {
                  const aujourdHui = new Date().toISOString().split("T")[0];
                  const rappelProche = m.dateRappel && m.dateRappel <= aujourdHui;

                  return (
                    <MDBox
                      key={i}
                      mt={2}
                      p={2}
                      borderRadius="lg"
                      bgcolor={rappelProche ? "#fdecea" : "#f5f5f5"}
                    >
                      <MDTypography fontWeight="bold">{m.nom}</MDTypography>

                      <MDTypography variant="button">
                        {m.type} — Administré le {m.dateAdministration}
                      </MDTypography>

                      {m.dateRappel && (
                        <MDTypography mt={1} color={rappelProche ? "error" : "info"}>
                          Rappel prévu : {m.dateRappel}
                        </MDTypography>
                      )}
                    </MDBox>
                  );
                })}
              </MDBox>
            </Card>
          </Grid>
        </Grid>
      </MDBox>
      <Footer />
    </DashboardLayout>
  );
}

export default Medicaments;
