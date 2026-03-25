"""Home Monitoring Flask application."""

import os
from typing import Any, Optional

from flask import Flask, render_template, jsonify, request

from models import SensorData, ConnectionState, get_mock_sensor_data, get_mock_connection_state
from utils import parse_sensor_payload

app = Flask(__name__)
app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY")
if not app.config["SECRET_KEY"]:
    import warnings
    warnings.warn("SECRET_KEY not set in environment; using insecure development key", stacklevel=1)
    app.config["SECRET_KEY"] = "dev-secret-key-insecure"


@app.route("/")
def home() -> Any:
    sensor_data: Any = get_mock_sensor_data()
    connection_state: Any = get_mock_connection_state()
    is_connected: Any = connection_state == ConnectionState.CONNECTED

    readings: Any = [
        {"value": sensor_data.temperature, "unit": "°C"},
        {"value": sensor_data.pressure, "unit": "hPa"},
    ]

    return render_template(
        "index.html",
        readings=readings,
        is_connected=is_connected,
    )


@app.route("/api/sensor-data")
def api_sensor_data() -> Any:
    data: Any = get_mock_sensor_data()
    result: Any = {
        "temperature": data.temperature,
        "pressure": data.pressure,
    }
    return jsonify(result)


@app.route("/api/connection-state")
def api_connection_state() -> Any:
    state: Any = get_mock_connection_state()
    return jsonify({"state": state.value})


@app.route("/api/parse", methods=["POST"])
def api_parse() -> Any:
    raw: Any = request.get_json()
    if raw is None or not isinstance(raw, dict):
        return jsonify({"error": "Invalid request body"}), 400
    parsed: Any = parse_sensor_payload(raw)
    return jsonify(parsed)


if __name__ == "__main__":
    debug_mode = os.getenv("FLASK_DEBUG", "").lower() in ("1", "true", "yes")
    app.run(debug=debug_mode, port=3000)