import React, { useEffect, useState } from "react";
import { getMedicaments, deleteMedicament } from "../../services/medicamentsService";
import { Link } from "react-router-dom";

import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Card from "@mui/material/Card";
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import MDButton from "components/MDButton";

export default function MedicamentsPage() {
  const [medicaments, setMedicaments] = useState([]);

  useEffect(() => {
    setMedicaments(getMedicaments());
  }, []);

  const handleDelete = (id) => {
    deleteMedicament(id);
    setMedicaments(getMedicaments());
  };

  return (
    <DashboardLayout>
      <DashboardNavbar />

      <MDBox mt={4} mb={3}>
        <Card>
          <MDBox p={3}>
            <MDTypography variant="h4" fontWeight="bold">
              Liste des médicaments
            </MDTypography>

            <Link to="/medicaments/new">
              <MDButton variant="gradient" color="info" sx={{ mt: 2 }}>
                Ajouter un médicament
              </MDButton>
            </Link>

            <MDBox mt={3}>
              <table className="w-full border">
                <thead>
                  <tr>
                    <th className="border p-2">Nom</th>
                    <th className="border p-2">Prix</th>
                    <th className="border p-2">Date d’utilisation</th>
                    <th className="border p-2">Actions</th>
                  </tr>
                </thead>

                <tbody>
                  {medicaments.map((m) => (
                    <tr key={m.id}>
                      <td className="border p-2">{m.nom}</td>
                      <td className="border p-2">{m.prix} FCFA</td>
                      <td className="border p-2">{m.date}</td>
                      <td className="border p-2">
                        <Link
                          to={`/medicaments/edit/${m.id}`}
                          className="px-3 py-1 bg-yellow-500 text-white rounded mr-2"
                        >
                          Modifier
                        </Link>

                        <button
                          onClick={() => handleDelete(m.id)}
                          className="px-3 py-1 bg-red-600 text-white rounded"
                        >
                          Supprimer
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </MDBox>
          </MDBox>
        </Card>
      </MDBox>
    </DashboardLayout>
  );
}
