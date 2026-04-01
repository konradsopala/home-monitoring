"""Data models for home monitoring sensor readings."""

import enum
from typing import Dict, Optional
from dataclasses import dataclass


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

    temperature: Optional[float] = None
    pressure: Optional[float] = None
    humidity: Optional[float] = None
    battery_level: Optional[float] = None

    def to_dict(self) -> Dict[str, Optional[float]]:
        return {
            "temperature": self.temperature,
            "pressure": self.pressure,
            "humidity": self.humidity,
            "battery_level": self.battery_level,
        }

    def is_valid(self) -> bool:
        return self.temperature is not None and self.pressure is not None


@dataclass
class BeaconConfig:
    """Configuration for an Estimote beacon."""

    device_identifier: str = ""
    app_id: str = ""
    app_token: str = ""
    scan_interval: float = 5.0

    def validate(self) -> bool:
        return bool(self.device_identifier and self.app_id and self.app_token)


def get_mock_sensor_data() -> SensorData:
    """Return mock sensor data for development."""
    return SensorData(temperature=22, pressure=1013)


def get_mock_connection_state() -> ConnectionState:
    """Return mock connection state for development."""
    return ConnectionState.CONNECTED