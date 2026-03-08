// src/layouts/livraisons/index.js
import React, { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import Grid from "@mui/material/Grid";
import Card from "@mui/material/Card";
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import MDButton from "components/MDButton";
import DataTable from "examples/Tables/DataTable";
import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Footer from "examples/Footer";

import { getLivraisons, deleteLivraison } from "services/livraisonsService";

export default function LivraisonsList() {
  const [livraisons, setLivraisons] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    setLivraisons(getLivraisons());
  }, []);

  const handleDelete = (id) => {
    if (!window.confirm("Supprimer cette livraison ?")) return;
    deleteLivraison(id);
    setLivraisons(getLivraisons());
  };

  const tableData = {
    columns: [
      { Header: "Date", accessor: "date", width: "15%" },
      { Header: "Type", accessor: "type", width: "18%" },
      { Header: "Montant (FR)", accessor: "montant", align: "right" },
      { Header: "Transport (FR)", accessor: "transport", align: "right" },
      { Header: "Fournisseur", accessor: "fournisseur", width: "20%" },
      { Header: "Actions", accessor: "actions", width: "20%" },
    ],
    rows: livraisons.map((l) => ({
      ...l,
      montant: Number(l.montant).toLocaleString("fr-FR"),
      transport: Number(l.transport).toLocaleString("fr-FR"),
      actions: (
        <div>
          <MDButton
            size="small"
            variant="contained"
            color="info"
            onClick={() => navigate(`/livraisons/edit/${l.id}`)}
            style={{ marginRight: 8 }}
          >
            Modifier
          </MDButton>
          <MDButton
            size="small"
            variant="contained"
            color="error"
            onClick={() => handleDelete(l.id)}
          >
            Supprimer
          </MDButton>
        </div>
      ),
    })),
  };

  return (
    <DashboardLayout>
      <DashboardNavbar />
      <MDBox py={3}>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <Card>
              <MDBox display="flex" justifyContent="space-between" alignItems="center" p={3}>
                <MDTypography variant="h6">Livraisons</MDTypography>
                <Link to="/livraisons/new" style={{ textDecoration: "none" }}>
                  <MDButton variant="gradient" color="success">
                    Ajouter une livraison
                  </MDButton>
                </Link>
              </MDBox>

              <MDBox p={3}>
                <DataTable
                  table={tableData}
                  canSearch
                  entriesPerPage={false}
                  isSorted={false}
                  showTotalEntries={false}
                />
              </MDBox>
            </Card>
          </Grid>
        </Grid>
      </MDBox>
      <Footer />
    </DashboardLayout>
  );
}
