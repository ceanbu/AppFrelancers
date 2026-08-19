// seed_skills.js
// Carga habilidades nuevas en la coleccion 'skills' de Firestore.
// Uso: node seed_skills.js
// Requiere: npm install firebase-admin
// Requiere: serviceAccountKey.json en la misma carpeta (ver instrucciones)

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Editar esta lista para agregar mas skills en el futuro.
const newSkills = [
  { name: 'Camarera de pisos / Limpieza de habitaciones', category: 'hospedaje' },
  { name: 'Lavanderia', category: 'hospedaje' },
  { name: 'Mantenimiento general', category: 'mantenimiento' },
  { name: 'Servicios generales', category: 'general' },
];

async function seedSkills() {
  console.log(`Cargando ${newSkills.length} habilidades nuevas...`);

  // Chequea duplicados por nombre antes de insertar
  const existingSnapshot = await db.collection('skills').get();
  const existingNames = new Set(
    existingSnapshot.docs.map((doc) => (doc.data().name || '').trim().toLowerCase())
  );

  let created = 0;
  let skipped = 0;

  for (const skill of newSkills) {
    const key = skill.name.trim().toLowerCase();
    if (existingNames.has(key)) {
      console.log(`- Omitida (ya existe): ${skill.name}`);
      skipped++;
      continue;
    }
    await db.collection('skills').add({
      name: skill.name,
      category: skill.category,
    });
    console.log(`+ Creada: ${skill.name} (${skill.category})`);
    created++;
  }

  console.log(`\nListo. Creadas: ${created}, omitidas por duplicado: ${skipped}`);
  process.exit(0);
}

seedSkills().catch((err) => {
  console.error('Error al cargar skills:', err);
  process.exit(1);
});
