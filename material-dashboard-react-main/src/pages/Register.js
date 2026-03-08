import { useState } from "react";
import { createUserWithEmailAndPassword } from "firebase/auth";
import { auth } from "../firebase";

function Register() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");

  const handleRegister = async (e) => {
    e.preventDefault();

    try {
      await createUserWithEmailAndPassword(auth, email, password);
      setMessage("Compte créé avec succès ✅");
    } catch (error) {
      setMessage(error.message);
    }
  };

  return (
    <div style={{ padding: 40 }}>
      <h2>Créer un compte</h2>

      <form onSubmit={handleRegister}>
        <input
          type="email"
          placeholder="Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
        />
        <br />
        <br />

        <input
          type="password"
          placeholder="Mot de passe"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />
        <br />
        <br />

        <button type="submit">S inscrire</button>
      </form>

      <p>{message}</p>
    </div>
  );
}

export default Register;
