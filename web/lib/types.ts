export type ConnectionState =
  | "disconnected"
  | "searching"
  | "connecting"
  | "connected"
  | "error";

export interface SensorData {
  temperature: number | null;
  pressure: number | null;
}
