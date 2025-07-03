// functions/src/api/services/employer.service.ts
import * as admin from 'firebase-admin';
import { Employer, EmployerApiCreateData, RepresentativeInfo } from '../../models/employer.model';

// Renombrado de registerEmployerHandler a registerEmployerService
export const registerEmployerService = async (
  userRecord: admin.auth.UserRecord,
  data: EmployerApiCreateData,
  encryptedRepDocNumber: string,
  repBirthDateISO: string // Fecha de nacimiento del representante en YYYY-MM-DD
): Promise<void> => {

  // Construir representativeInfo asegurando que el documentNumber original no se guarde
  const representativeInfoToStore: RepresentativeInfo = {
    ...data.representativeInfo,
    documentNumber_encrypted: encryptedRepDocNumber,
    dateOfBirth: repBirthDateISO, // Guardar como YYYY-MM-DD
    documentNumber: undefined, // Eliminar explícitamente el campo original
  };

  const employerData: Omit<Employer, 'createdAt'|'updatedAt'|'representativeInfo'> & {
    representativeInfo: RepresentativeInfo;
    createdAt: admin.firestore.FieldValue;
    updatedAt: admin.firestore.FieldValue;
  } = {
    userId: userRecord.uid,
    email: data.email,
    businessName: data.businessName,
    businessTypeId: data.businessTypeId,
    representativeInfo: representativeInfoToStore,
    businessAddress: data.businessAddress,
    credits: data.credits ?? 0,
    profileCompleted: data.profileCompleted ?? false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };

  await admin.firestore().collection('employers').doc(userRecord.uid).set(employerData);
};
