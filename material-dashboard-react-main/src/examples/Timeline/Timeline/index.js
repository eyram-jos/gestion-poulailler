// prop-types is a library for typechecking of props
import PropTypes from "prop-types";

// @mui material components
import Card from "@mui/material/Card";

// Material Dashboard 2 React components
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";

// Material Dashboard 2 React components
import { useMaterialUIController } from "context";

// 🚨 CORRECTION : Importe l'exportation par défaut
import TimelineContext from "examples/Timeline/context";

function Timeline({ title, dark, children }) {
  const [controller] = useMaterialUIController();
  const { darkMode } = controller;

  return (
    // 🚨 CORRECTION : Utilise le Provider via l'objet par défaut
    <TimelineContext.TimelineProvider value={dark}>
      <Card>
        <MDBox
          bgColor={dark ? "dark" : "white"}
          variant="gradient"
          borderRadius="xl"
          sx={{ background: ({ palette: { background } }) => darkMode && background.card }}
        >
          <MDBox pt={3} px={3}>
            <MDTypography variant="h6" fontWeight="medium" color={dark ? "white" : "dark"}>
              {title}
            </MDTypography>
          </MDBox>
          <MDBox p={2}>{children}</MDBox>
        </MDBox>
      </Card>
    </TimelineContext.TimelineProvider>
  );
}

// Setting default values for the props of Timeline
Timeline.defaultProps = {
  dark: false,
};

// Typechecking props for the Timeline
Timeline.propTypes = {
  title: PropTypes.string.isRequired,
  dark: PropTypes.bool,
  children: PropTypes.node.isRequired,
};

export default Timeline;
