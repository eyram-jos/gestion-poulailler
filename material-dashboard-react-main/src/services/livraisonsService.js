// C:\Users\user\OneDrive\Bureau\PROJET POULAILLER\material-dashboard-react-main\src\services\livraisonsService.js

// src/services/livraisonsService.js
const STORAGE_KEY = "poulailler_livraisons_v1";

function _readAll() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch (e) {
    console.error("Error reading livraisons from localStorage", e);
    return [];
  }
}

function _writeAll(list) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(list));
  } catch (e) {
    console.error("Error writing livraisons to localStorage", e);
  }
}

export function getLivraisons() {
  return _readAll();
}

export function getLivraisonById(id) {
  const list = _readAll();
  return list.find((l) => l.id === id);
}

export function addLivraison(payload) {
  const list = _readAll();
  const newItem = {
    id: Date.now().toString(),
    date: payload.date || new Date().toISOString().split("T")[0],
    type: payload.type || "Aliment",
    montant: Number(payload.montant) || 0,
    transport: Number(payload.transport) || 0,
    fournisseur: payload.fournisseur || "",
    notes: payload.notes || "",
  };
  list.push(newItem);
  _writeAll(list);
  return newItem;
}

export function updateLivraison(id, payload) {
  const list = _readAll();
  const idx = list.findIndex((l) => l.id === id);
  if (idx === -1) return null;
  list[idx] = { ...list[idx], ...payload };
  _writeAll(list);
  return list[idx];
}

export function deleteLivraison(id) {
  const list = _readAll();
  const newList = list.filter((l) => l.id !== id);
  _writeAll(newList);
  return true;
}
