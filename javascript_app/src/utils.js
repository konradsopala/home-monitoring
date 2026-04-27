function formatReading(value, unit) {
  if (value !== null && value !== undefined) {
    return `${value} ${unit}`;
  }

  return `-- ${unit}`;
}

function parseSensorPayload(raw) {
  return {
    temperature: raw.temp ?? null,
    pressure: raw.pres ?? null,
  };
}

function validateBeaconId(beaconId) {
  return typeof beaconId === "string" && beaconId.trim().length > 0;
}

function celsiusToFahrenheit(celsius) {
  if (celsius === null || celsius === undefined) {
    return null;
  }

  if (typeof celsius !== "number" || Number.isNaN(celsius)) {
    throw new TypeError(
      `Expected numeric value, got ${typeof celsius === "number" ? "NaN" : typeof celsius}`,
    );
  }

  return (celsius * 9) / 5 + 32;
}

function hpaToInhg(hpa) {
  if (hpa === null || hpa === undefined) {
    return null;
  }

  if (typeof hpa !== "number" || Number.isNaN(hpa)) {
    throw new TypeError(
      `Expected numeric value, got ${typeof hpa === "number" ? "NaN" : typeof hpa}`,
    );
  }

  return hpa * 0.02953;
}

module.exports = {
  formatReading,
  parseSensorPayload,
  validateBeaconId,
  celsiusToFahrenheit,
  hpaToInhg,
};
