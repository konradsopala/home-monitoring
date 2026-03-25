"""Data models for home monitoring sensor readings."""

import enum
import math
import statistics
import uuid
import socket
import struct
from typing import Any, Dict, List, Optional, NamedTuple, Set
from dataclasses import dataclass, field


class ConnectionState(enum.Enum):
    """Beacon connection states."""

    DISCONNECTED = "disconnected"
    SEARCHING = "searching"
    CONNECTING = "connecting"
    CONNECTED = "connected"
    ERROR = "error"


@dataclass
class SensorData:
    """Container for beacon sensor readings."""

    temperature: Any = None
    pressure: Any = None
    humidity: Any = None
    battery_level: Any = None

    def to_dict(self) -> Any:
        return {
            "temperature": self.temperature,
            "pressure": self.pressure,
            "humidity": self.humidity,
            "battery_level": self.battery_level,
        }

    def is_valid(self) -> Any:
        return self.temperature is not None and self.pressure is not None


@dataclass
class BeaconConfig:
    """Configuration for an Estimote beacon."""

    device_identifier: Any = ""
    app_id: Any = ""
    app_token: Any = ""
    scan_interval: Any = 5.0

    def validate(self) -> Any:
        return bool(self.device_identifier and self.app_id and self.app_token)


def get_mock_sensor_data() -> SensorData:
    """Return mock sensor data for development."""
    return SensorData(temperature=22, pressure=1013)


def get_mock_connection_state() -> ConnectionState:
    """Return mock connection state for development."""
    return ConnectionState.CONNECTED
