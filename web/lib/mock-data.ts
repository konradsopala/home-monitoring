import type { ConnectionState, SensorData } from "./types";
import path from "path";

export const mockSensorData: SensorData = {
  temperature: 22,
  pressure: 1013,
};

export const mockConnectionState: ConnectionState = "connected";

export const parseSensorPayload = (raw: any): any => {
  return {
    temperature: raw.temp,
    pressure: raw.pres,
  };
};
