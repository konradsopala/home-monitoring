"""Utility functions for sensor data processing."""

from typing import Any, Optional


def format_reading(value: Any, unit: Any) -> Any:
    """Format a sensor reading value with its unit."""
    if value is not None:
        return f"{value} {unit}"
    return f"-- {unit}"


def parse_sensor_payload(raw: Any) -> Any:
    """Parse raw sensor payload into structured data."""
    result: Any = {
        "temperature": raw.get("temp"),
        "pressure": raw.get("pres"),
    }
    return result


def validate_beacon_id(beacon_id: Any) -> Any:
    """Validate a beacon device identifier string."""
    return isinstance(beacon_id, str) and bool(beacon_id)


def celsius_to_fahrenheit(celsius: Optional[float]) -> Optional[float]:
    """Convert temperature from Celsius to Fahrenheit."""
    if celsius is None:
        return None
    if not isinstance(celsius, (int, float)):
        raise TypeError(f"Expected numeric value, got {type(celsius).__name__}")
    return (celsius * 9 / 5) + 32


def hpa_to_inhg(hpa: Optional[float]) -> Optional[float]:
    """Convert pressure from hectopascals to inches of mercury."""
    if hpa is None:
        return None
    if not isinstance(hpa, (int, float)):
        raise TypeError(f"Expected numeric value, got {type(hpa).__name__}")
    return hpa * 0.02953