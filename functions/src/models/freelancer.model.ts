// functions/src/models/freelancer.model.ts
import { Timestamp } from 'firebase-admin/firestore'; // Para createdAt/updatedAt
import { Address } from './shared.model';

// Tipos específicos para Freelancer que habíamos discutido
export type FreelancerDocumentType = 'CPF' | 'RG' | 'RNM' | 'CRNM';

export interface ProfileCompletionSteps {
  personalInfo: boolean;
  availability: boolean;
  skills: boolean;
  experience: boolean;
}

export interface AvailabilitySlot {
  dayOfWeek: 'Segunda' | 'Terça' | 'Quarta' | 'Quinta' | 'Sexta' | 'Sábado' | 'Domingo';
  startTime: string; // Formato HH:MM
  endTime: string;   // Formato HH:MM
}

export interface Skill { // Asumiendo que tienes un skill.model.ts o lo defines aquí
  name: string;
  level: 'Básico' | 'Intermediário' | 'Avançado' | 'Especialista';
}

export interface WorkExperienceEntry {
  type: 'Experiência Profissional' | 'Educação';
  title: string;
  institution: string;
  startDate: string; // YYYY-MM o YYYY-MM-DD
  endDate?: string;
  isCurrent?: boolean;
  description?: string;
}

// Interfaz principal para Freelancer en Firestore
export interface Freelancer {
  userId: string;
  email: string;
  fullName: string;
  documentType: FreelancerDocumentType;
  documentNumber_encrypted: string; // Hasheado/Encriptado
  dateOfBirth: string; // Formato YYYY-MM-DD
  phone: string;
  address: Address;

  aboutMe?: string;
  profilePictureUrl?: string;

  profileCompletedSteps: ProfileCompletionSteps;

  initialAvailability?: AvailabilitySlot[];
  skills?: Skill[]; // Podría referenciar a una interfaz Skill más detallada
  workExperience?: WorkExperienceEntry[];

  createdAt: Timestamp;
  updatedAt: Timestamp;
}

// Datos esperados de la API para crear un Freelancer
export interface FreelancerApiCreateData {
  email: string;
  password: string; // Para Auth, no se guarda en Firestore
  fullName: string;
  documentType: FreelancerDocumentType;
  documentNumber: string; // En claro desde la API
  dateOfBirth: string;    // Formato DD/MM/YYYY desde la API
  phone: string;
  address: Address;
  aboutMe?: string;
  // Los siguientes son opcionales en la creación inicial
  initialAvailability?: AvailabilitySlot[];
  skills?: Skill[];
  workExperience?: WorkExperienceEntry[];
}
