import PropTypes from "prop-types";
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import MDButton from "components/MDButton";

export default function RequirePremium({ isPremium, children }) {
  if (!isPremium) {
    return (
      <MDBox textAlign="center" p={4}>
        <MDTypography variant="h5" color="error" mb={2}>
          Fonctionnalité Premium
        </MDTypography>

        <MDTypography mb={3}>Cette section est réservée aux comptes Premium.</MDTypography>

        <MDButton color="info">Passer au Premium</MDButton>
      </MDBox>
    );
  }

  return children;
}

RequirePremium.propTypes = {
  isPremium: PropTypes.bool.isRequired,
  children: PropTypes.node.isRequired,
};
