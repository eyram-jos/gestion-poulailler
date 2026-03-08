import React from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import App from "App";

import { MaterialUIControllerProvider } from "context";
import { PoulaillerProvider } from "context/PoulaillerContext";

const container = document.getElementById("app");
const root = createRoot(container);

root.render(
  <BrowserRouter>
    <MaterialUIControllerProvider>
      <PoulaillerProvider>
        <App />
      </PoulaillerProvider>
    </MaterialUIControllerProvider>
  </BrowserRouter>
);
