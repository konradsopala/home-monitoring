const path = require("node:path");

const express = require("express");

const {
  ConnectionState,
  getMockConnectionState,
  getMockSensorData,
} = require("./models");
const { parseSensorPayload } = require("./utils");

function createApp() {
  const app = express();

  app.set("view engine", "ejs");
  app.set("views", path.join(__dirname, "..", "views"));

  app.use(express.json());
  app.use(express.static(path.join(__dirname, "..", "public")));

  app.get("/", (_req, res) => {
    const sensorData = getMockSensorData();
    const connectionState = getMockConnectionState();
    const isConnected = connectionState === ConnectionState.CONNECTED;

    const readings = [
      { value: sensorData.temperature, unit: "°C" },
      { value: sensorData.pressure, unit: "hPa" },
    ];

    res.render("index", {
      readings,
      isConnected,
    });
  });

  app.get("/api/sensor-data", (_req, res) => {
    const data = getMockSensorData();
    res.json({
      temperature: data.temperature,
      pressure: data.pressure,
    });
  });

  app.get("/api/connection-state", (_req, res) => {
    const state = getMockConnectionState();
    res.json({ state });
  });

  app.post("/api/parse", (req, res) => {
    const raw = req.body;

    if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
      return res.status(400).json({ error: "Invalid request body" });
    }

    return res.json(parseSensorPayload(raw));
  });

  app.use((error, _req, res, next) => {
    if (error instanceof SyntaxError && "body" in error) {
      return res.status(400).json({ error: "Invalid request body" });
    }

    return next(error);
  });

  return app;
}

module.exports = {
  createApp,
};
