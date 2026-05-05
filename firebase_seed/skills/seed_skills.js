const admin = require('firebase-admin');

const serviceAccount = require('./workflex-app-9d2cc-firebase-adminsdk-fbsvc-cf50107655.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function seedSkills() {
  const skillsData = require('./skills_data.json');
  
  for (const skill of skillsData.skills) {
    const docRef = db.collection('skills').doc();
    await docRef.set({
      name: skill.name,
      category: skill.category,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log(`Habilidad agregada: ${skill.name}`);
  }
  
  console.log('Todas las habilidades se han cargado exitosamente');
}

seedSkills().catch(console.error);