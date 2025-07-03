// functions/src/api/services/freelancer.service.ts
import * as admin from 'firebase-admin';
import { Freelancer, FreelancerApiCreateData } from '../../models/freelancer.model';

// Renombrado de registerFreelancerHandler a registerFreelancerService
export const registerFreelancerService = async (
  userRecord: admin.auth.UserRecord,
  data: FreelancerApiCreateData,
  encryptedDocNumber: string,
  birthDateISO: string
): Promise<void> => {
  const freelancerData: Omit<Freelancer, 'createdAt'|'updatedAt'> & {
    createdAt: admin.firestore.FieldValue;
    updatedAt: admin.firestore.FieldValue;
  } = {
    userId: userRecord.uid,
    email: data.email,
    fullName: data.fullName,
    documentType: data.documentType,
    documentNumber_encrypted: encryptedDocNumber,
    dateOfBirth: birthDateISO, // Almacenar como YYYY-MM-DD
    phone: data.phone,
    address: data.address,
    aboutMe: data.aboutMe || '',
    profileCompletedSteps: {
      personalInfo: true,
      availability: false,
      skills: false,
      experience: false
    },
    initialAvailability: data.initialAvailability || [],
    skills: data.skills || [],
    workExperience: data.workExperience || [],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };

  await admin.firestore().collection('freelancers').doc(userRecord.uid).set(freelancerData);
};
