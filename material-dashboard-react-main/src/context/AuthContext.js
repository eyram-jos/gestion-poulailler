import { createContext, useContext, useState } from "react";
import PropTypes from "prop-types";

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);

  const login = ({ email }) => {
    // SIMULATION (plus tard backend)
    if (email === "admin@poulailler.com") {
      setUser({ role: "admin", plan: "premium", name: "Admin" });
    } else if (email === "maman@poulailler.com") {
      setUser({ role: "owner", plan: "premium", name: "Maman" });
    } else {
      setUser({ role: "client", plan: "free", name: "Client" });
    }
  };

  const logout = () => setUser(null);

  return <AuthContext.Provider value={{ user, login, logout }}>{children}</AuthContext.Provider>;
};

AuthProvider.propTypes = {
  children: PropTypes.node.isRequired,
};

export const useAuth = () => {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth doit être utilisé dans AuthProvider");
  return ctx;
};
