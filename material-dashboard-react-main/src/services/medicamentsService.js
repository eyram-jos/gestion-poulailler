export function getMedicaments() {
  return JSON.parse(localStorage.getItem("medicaments")) || [];
}

export function addMedicament(medicament) {
  const medicaments = getMedicaments();
  medicament.id = Date.now();
  medicaments.push(medicament);
  localStorage.setItem("medicaments", JSON.stringify(medicaments));
}

export function deleteMedicament(id) {
  const medicaments = getMedicaments().filter((m) => m.id !== id);
  localStorage.setItem("medicaments", JSON.stringify(medicaments));
}

export function getMedicamentById(id) {
  return getMedicaments().find((m) => m.id === Number(id));
}

export function updateMedicament(id, updated) {
  const medicaments = getMedicaments().map((m) => (m.id === Number(id) ? { ...m, ...updated } : m));
  localStorage.setItem("medicaments", JSON.stringify(medicaments));
}
