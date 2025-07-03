/**
 * Configuración principal de Cloud Functions
 * Importa y exporta todas las funciones de tu backend
 */

import * as admin from "firebase-admin";
import { setGlobalOptions } from "firebase-functions/v2";

// Inicialización de Firebase Admin SDK
// Asegúrate de que initializeApp() se llame solo una vez
if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Configuración global de las funciones
setGlobalOptions({
  region: "us-central1", // Define la región para todas las funciones v2
  maxInstances: 10
});

// Importación y exportación de las funciones de la API

// Freelancer API
export { freelancerHttpController as registerFreelancer } from "./api/http/freelancer.http";

// Employer API
export { employerHttpController as registerEmployer } from "./api/http/employer.http";

// Location API
// Necesitaremos crear/restaurar este archivo: ./api/locationApi.ts
export {
  getStatesHandler as getStates,
  getMunicipalitiesByStateHandler as getMunicipalitiesByState
} from "./api/locationApi";

/**
 * Notas importantes:
 * 1. Este archivo sirve como punto de entrada principal para todas tus Functions.
 * 2. Las funciones HTTP (onRequest) se importan desde los archivos en './api/http/'.
 * 3. La lógica de negocio (interacción con Firestore, etc.) está en './api/services/'.
 * 4. Los modelos de datos están en './models/'.
 * 5. Las utilidades (validadores, etc.) están en './utils/'.
 * 6. Para llamar a estas funciones localmente (después de 'npm run serve' o 'firebase emulators:start'):
 *    - Freelancer: POST http://localhost:5001/<project-id>/us-central1/registerFreelancer
 *    - Employer:   POST http://localhost:5001/<project-id>/us-central1/registerEmployer
 *    - States:     GET http://localhost:5001/<project-id>/us-central1/getStates
 *    - Munics:     GET http://localhost:5001/<project-id>/us-central1/getMunicipalitiesByState?stateId=SP
 * 7. Revisa que las rutas de importación en todos los archivos sean correctas después de la reorganización.
 */
