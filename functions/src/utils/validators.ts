// functions/src/utils/validators.ts

/**
 * Valida si una cadena es un email con formato válido.
 * @param email La cadena a validar.
 * @returns `true` si el email es válido, `false` en caso contrario.
 */
export function isValidEmail(email: string): boolean {
  if (!email) return false;
  // Expresión regular simple para validación de email.
  // Para validaciones más robustas, considera librerías especializadas.
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Valida la fortaleza de una contraseña.
 * Por ahora, solo verifica la longitud mínima.
 * @param password La contraseña a validar.
 * @returns `true` si la contraseña cumple el criterio, `false` en caso contrario.
 */
export function isValidPassword(password: string): boolean {
  if (!password) return false;
  return password.length >= 8; // Mínimo 8 caracteres
}

/**
 * Valida si una cadena de fecha está en formato DD/MM/YYYY.
 * No valida si la fecha es real (e.g., 30/02/2023).
 * @param dateString La cadena de fecha a validar.
 * @returns `true` si el formato es DD/MM/YYYY, `false` en caso contrario.
 */
export function isValidDMYDateString(dateString: string): boolean {
  if (!dateString) return false;
  const dmyRegex = /^\d{2}\/\d{2}\/\d{4}$/;
  return dmyRegex.test(dateString);
}

/**
 * Convierte una cadena de fecha en formato DD/MM/YYYY a un objeto Date.
 * También valida si la fecha resultante es una fecha válida (e.g., no 30/02/2023).
 * @param dmyDateString La cadena de fecha en formato DD/MM/YYYY.
 * @returns Un objeto Date si la conversión y la fecha son válidas, `null` en caso contrario.
 */
export function convertDMYToDate(dmyDateString: string): Date | null {
  if (!isValidDMYDateString(dmyDateString)) {
    return null;
  }
  const parts = dmyDateString.split('/');
  const day = parseInt(parts[0], 10);
  const month = parseInt(parts[1], 10) - 1; // Meses en JavaScript son 0-indexados
  const year = parseInt(parts[2], 10);

  const date = new Date(year, month, day);

  // Verificar si la fecha es válida (e.g., Date no ajustó los valores por overflow)
  if (date.getFullYear() !== year || date.getMonth() !== month || date.getDate() !== day) {
    return null;
  }
  return date;
}

/**
 * Valida si un número de documento (CPF o CNPJ) es válido.
 * Esta es una validación muy básica, solo verifica el formato y longitud.
 * Para una validación real de CPF/CNPJ con dígitos verificadores, se necesitaría una lógica más compleja o una librería.
 * @param docNumber El número de documento.
 * @param type 'CPF' o 'CNPJ'.
 * @returns `true` si el formato básico es válido, `false` en caso contrario.
 */
export function isValidDocumentNumber(docNumber: string, type: 'CPF' | 'CNPJ'): boolean {
  if (!docNumber) return false;
  const cleanedDoc = docNumber.replace(/[^\d]/g, ''); // Remover no dígitos

  if (type === 'CPF') {
    return cleanedDoc.length === 11;
  }
  if (type === 'CNPJ') {
    return cleanedDoc.length === 14;
  }
  return false;
}
