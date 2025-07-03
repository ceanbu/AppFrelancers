// functions/src/models/employer.model.ts
import * as admin from 'firebase-admin'; // Necesario para FieldValue y Timestamp
import { Address, ContactInfo, Timestampable } from './shared.model';

/**
 * Tipos de documentos aceptados para el representante del Employer.
 * Podría expandirse si se aceptan otros tipos de documentos para la empresa misma.
 */
export type RepresentativeDocumentType = 'CPF'; // Por ahora, asumimos CPF para el representante

/**
 * Información del representante legal o de contacto principal de la empresa.
 */
export interface RepresentativeInfo extends ContactInfo {
  fullName: string;
  documentType: RepresentativeDocumentType;
  documentNumber_encrypted: string; // Documento encriptado/hasheado
  documentNumber?: string; // Se recibe en claro, se procesa y no se guarda
  dateOfBirth: string;      // Formato YYYY-MM-DD (almacenado) o DD/MM/YYYY (API)
  // position?: string; // Cargo del representante en la empresa (opcional)
}

/**
 * Modelo de datos para un Employer (Empleador/Empresa) almacenado en Firestore.
 */
export interface Employer extends Timestampable {
  userId: string;                   // UID de Firebase Auth (asociado al email de login de la empresa)
  email: string;                    // Email de login de la empresa
  businessName: string;             // Razón Social o Nombre Fantasía
  businessTypeId: string;           // ID o descripción del tipo de negocio (e.g., "Tecnologia", "Restaurante")
                                    // Podría ser un ID que refiera a otra colección si los tipos son manejados dinámicamente
  // businessDocumentType?: 'CNPJ'; // Si la empresa tiene su propio documento
  // businessDocumentNumber_encrypted?: string;

  representativeInfo: RepresentativeInfo; // Información del contacto/representante
  businessAddress: Address;

  website?: string;                 // Sitio web de la empresa (opcional)
  companyLogoUrl?: string;          // URL del logo de la empresa (opcional)
  aboutCompany?: string;            // Descripción de la empresa (opcional)

  credits: number;                  // Créditos para interactuar en la plataforma (e.g., postear trabajos)
  profileCompleted: boolean;        // Indica si el perfil básico de la empresa está completo

  // Otros campos relevantes
  // activeJobPostings?: number;
  // totalHires?: number;
  // industry?: string;
}

/**
 * Datos esperados del API para crear un Employer.
 */
export interface EmployerApiCreateData {
  email: string;
  password?: string; // Para Auth, no se guarda en Firestore
  businessName: string;
  businessTypeId: string;

  // Para el representante, se espera dateOfBirth en DD/MM/YYYY y documentNumber en claro
  representativeInfo: Omit<RepresentativeInfo, 'documentNumber_encrypted' | 'dateOfBirth'> & { dateOfBirth: string; documentNumber: string; };

  businessAddress: Address;
  website?: string;
  aboutCompany?: string;
  credits?: number;
  profileCompleted?: boolean;
}
