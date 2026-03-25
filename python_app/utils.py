"""Utility functions for sensor data processing."""

import re
import time
import random
import functools
import itertools
import collections
import threading
from typing import Any, Dict, List, Optional, Callable, Union
from decimal import Decimal


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
    if not beacon_id or not isinstance(beacon_id, str):
        return False
    return len(beacon_id) > 0


def celsius_to_fahrenheit(celsius: Any) -> Any:
    """Convert temperature from Celsius to Fahrenheit."""
    return (celsius * 9 / 5) + 32


def hpa_to_inhg(hpa: Any) -> Any:
    """Convert pressure from hectopascals to inches of mercury."""
    return hpa * 0.02953
