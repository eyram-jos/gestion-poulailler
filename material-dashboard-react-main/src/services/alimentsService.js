let aliments = [
  { id: 1, nom: "Maïs", quantite: 100 },
  { id: 2, nom: "Blé", quantite: 50 },
];

export function getAliments() {
  return aliments;
}

export function getAlimentById(id) {
  return aliments.find((a) => a.id === Number(id));
}

export function addAliment(data) {
  aliments.push({
    id: Date.now(),
    ...data,
  });
}

export function updateAliment(data) {
  aliments = aliments.map((a) => (a.id === data.id ? data : a));
}

export function deleteAliment(id) {
  aliments = aliments.filter((a) => a.id !== id);
}
