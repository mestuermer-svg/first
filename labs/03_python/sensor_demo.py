"""
Lern- & Testmodul (Rubrik 03: Python Coding)
Demonstriert saubere Type Hints (für Pylance), Dataclasses und Fehlerbehandlung.
Ausführen mit: uv run python labs/03_python/sensor_demo.py
"""

from dataclasses import dataclass


@dataclass(frozen=True)
class Messwert:
    sensor_id: str
    wert: float
    einheit: str = "°C"
    gueltig: bool = True


def berechne_mittelwert(messungen: list[Messwert]) -> float | None:
    """Berechnet das arithmetische Mittel aller gültigen Messwerte."""
    aktive_werte = [m.wert for m in messungen if m.gueltig]
    if not aktive_werte:
        return None
    return round(sum(aktive_werte) / len(aktive_werte), 2)


if __name__ == "__main__":
    test_daten = [
        Messwert("T_VORLAUF", 42.5),
        Messwert("T_RUECKLAUF", 37.5),
        Messwert("T_DEFEKT", 999.9, gueltig=False),
    ]
    ergebnis = berechne_mittelwert(test_daten)
    print(f"Gültiger Mittelwert: {ergebnis} °C")
