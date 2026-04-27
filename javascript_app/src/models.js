const ConnectionState = Object.freeze({
  DISCONNECTED: "disconnected",
  SEARCHING: "searching",
  CONNECTING: "connecting",
  CONNECTED: "connected",
  ERROR: "error",
});

function createSensorData({
  temperature = null,
  pressure = null,
  humidity = null,
  batteryLevel = null,
} = {}) {
  return {
    temperature,
    pressure,
    humidity,
    batteryLevel,
  };
}

function getMockSensorData() {
  return createSensorData({
    temperature: 22,
    pressure: 1013,
  });
}

function getMockConnectionState() {
  return ConnectionState.CONNECTED;
}

module.exports = {
  ConnectionState,
  createSensorData,
  getMockSensorData,
  getMockConnectionState,
};
