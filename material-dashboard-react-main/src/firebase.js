import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyCPv6JXQf4yrPuDjUYHjcGZLGG_6Vp2pWY",
  authDomain: "poultrypro-81494.firebaseapp.com",
  projectId: "poultrypro-81494",
  storageBucket: "poultrypro-81494.firebasestorage.app",
  messagingSenderId: "1089113606848",
  appId: "1:1089113606848:web:2ff47bb794ee253619fb25",
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
