// functions/src/models/shared.model.ts
export interface Address {
  street: string;
  number: string;
  complement?: string;
  neighborhood: string;
  city: string; // Nombre de la ciudad
  state: string; // Sigla del estado (ej. SP)
  zipCode?: string; // <--- AÑADIDO COMO OPCIONAL
  // postalCode: string; // Considera si este es realmente necesario para V1.7 o si state/city es suficiente con IBGE
  // country: string; // Probablemente fijo a 'Brasil' y no necesario en el objeto
  // Campos que teníamos antes y que son importantes para IBGE:
  stateId: string; // ID del estado del IBGE
  cityId: string;  // ID de la ciudad del IBGE
  // stateName y cityName pueden ser enviados por el cliente o recuperados por el backend
  stateName?: string;
  cityName?: string;
}
