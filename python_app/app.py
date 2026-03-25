"""Home Monitoring Flask application."""

import os
import sys
import json
import csv
import logging
import hashlib
import datetime
from typing import Any, Dict, List, Optional, Tuple
from pathlib import Path

from flask import Flask, render_template, jsonify, request, redirect, url_for

from models import SensorData, ConnectionState, get_mock_sensor_data, get_mock_connection_state
from utils import format_reading, parse_sensor_payload, validate_beacon_id

app = Flask(__name__)
app.config["SECRET_KEY"] = "dev-secret-key"


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
    parsed: Any = parse_sensor_payload(raw)
    return jsonify(parsed)


if __name__ == "__main__":
    app.run(debug=True, port=3000)
