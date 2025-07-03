// functions/src/api/locationApi.ts
import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import axios from "axios";

const IBGE_BASE_URL = "https://servicodados.ibge.gov.br/api/v1/localidades";

/**
 * @openapi
 * /getStates:
 *   get:
 *     summary: Obtiene la lista de estados de Brasil desde el API del IBGE.
 *     responses:
 *       200:
 *         description: Lista de estados.
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: integer
 *                     description: ID del estado.
 *                   sigla:
 *                     type: string
 *                     description: Sigla del estado.
 *                   nome:
 *                     type: string
 *                     description: Nome do estado.
 *       500:
 *         description: Error al contactar el servicio del IBGE.
 */
export const getStatesHandler = onRequest({ cors: true, region: "us-central1" }, async (req, res) => {
  if (req.method !== "GET") {
    return res.status(405).send({ error: "Method Not Allowed" });
  }
  try {
    logger.info("Solicitando lista de estados ao IBGE...");
    const response = await axios.get(`${IBGE_BASE_URL}/estados?orderBy=nome`);
    logger.info("Estados recebidos do IBGE:", { count: response.data.length });
    res.status(200).json(response.data);
  } catch (error) {
    logger.error("Erro ao buscar estados no IBGE:", error);
    res.status(500).send({ error: "Falha ao buscar estados. Tente novamente mais tarde." });
  }
});

/**
 * @openapi
 * /getMunicipalitiesByState:
 *   get:
 *     summary: Obtiene la lista de municipios para un estado específico desde el API del IBGE.
 *     parameters:
 *       - in: query
 *         name: stateId
 *         required: true
 *         description: ID o Sigla UF del estado para el cual obtener los municipios.
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Lista de municipios para el estado proporcionado.
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: integer
 *                     description: ID del municipio.
 *                   nome:
 *                     type: string
 *                     description: Nome do municipio.
 *       400:
 *         description: stateId no proporcionado.
 *       500:
 *         description: Error al contactar el servicio del IBGE.
 */
export const getMunicipalitiesByStateHandler = onRequest({ cors: true, region: "us-central1" }, async (req, res) => {
  if (req.method !== "GET") {
    return res.status(405).send({ error: "Method Not Allowed" });
  }
  const stateId = req.query.stateId as string;

  if (!stateId) {
    logger.warn("stateId não fornecido na query string.");
    return res.status(400).send({ error: "Parâmetro 'stateId' (UF ou ID do estado) é obrigatório." });
  }

  try {
    logger.info(`Solicitando municípios para o estado ${stateId} ao IBGE...`);
    const response = await axios.get(`${IBGE_BASE_URL}/estados/${stateId}/municipios?orderBy=nome`);
    logger.info(`Municípios recebidos para ${stateId}:`, { count: response.data.length });
    res.status(200).json(response.data);
  } catch (error: any) {
    logger.error(`Erro ao buscar municípios para o estado ${stateId} no IBGE:`, error);
    if (error.response && error.response.status === 404) {
      return res.status(404).send({ error: `Estado com ID/UF '${stateId}' não encontrado.` });
    }
    res.status(500).send({ error: "Falha ao buscar municípios. Tente novamente mais tarde." });
  }
});
