const test = require("node:test");
const assert = require("node:assert/strict");

const request = require("supertest");

const { createApp } = require("../src/app");
const {
  celsiusToFahrenheit,
  formatReading,
  hpaToInhg,
  parseSensorPayload,
  validateBeaconId,
} = require("../src/utils");

test("GET /api/sensor-data returns the mock sensor payload", async () => {
  const response = await request(createApp()).get("/api/sensor-data");

  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.body, {
    temperature: 22,
    pressure: 1013,
  });
});

test("GET /api/connection-state returns the connected state", async () => {
  const response = await request(createApp()).get("/api/connection-state");

  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.body, { state: "connected" });
});

test("POST /api/parse validates the request body", async () => {
  const response = await request(createApp())
    .post("/api/parse")
    .set("Content-Type", "application/json")
    .send("not-an-object");

  assert.equal(response.statusCode, 400);
  assert.deepEqual(response.body, { error: "Invalid request body" });
});

test("POST /api/parse remaps the sensor payload fields", async () => {
  const response = await request(createApp()).post("/api/parse").send({
    temp: 20.5,
    pres: 1008,
  });

  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.body, {
    temperature: 20.5,
    pressure: 1008,
  });
});

test("GET / renders the dashboard labels", async () => {
  const response = await request(createApp()).get("/");

  assert.equal(response.statusCode, 200);
  assert.match(response.text, /22 °C/);
  assert.match(response.text, /1013 hPa/);
});

test("utility helpers preserve the Python app behavior", () => {
  assert.equal(formatReading(22, "°C"), "22 °C");
  assert.equal(formatReading(null, "hPa"), "-- hPa");
  assert.deepEqual(parseSensorPayload({ temp: 19, pres: 1000 }), {
    temperature: 19,
    pressure: 1000,
  });
  assert.equal(validateBeaconId("beacon-123"), true);
  assert.equal(validateBeaconId(""), false);
  assert.equal(celsiusToFahrenheit(0), 32);
  assert.equal(hpaToInhg(1013), 29.913890000000002);
});
