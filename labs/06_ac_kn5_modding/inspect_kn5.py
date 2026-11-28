#!/usr/bin/env python3
"""
Binärer Inspektor und Integritätsprüfer für Assetto Corsa .kn5-Modelldateien.

Verwendet ausschließlich die Python-Standardbibliothek (Python 3.12+).
Inspiziert Header, Texturen, Materialien (inkl. Shader und Parameter) sowie
Fahrzeugordner auf vollständige .kn5- und UI-Dateien.
"""

from __future__ import annotations

import argparse
import json
import struct
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import BinaryIO

KN5_MAGIC = b"sc6969"


class Kn5FormatError(ValueError):
    """Wird ausgelöst, wenn eine Datei kein gültiges KN5-Format besitzt."""


@dataclass
class TextureInfo:
    name: str
    active: bool
    size_bytes: int


@dataclass
class MaterialInfo:
    name: str
    shader: str
    blend_mode: int
    alpha_tested: bool
    depth_mode: int | None
    property_count: int
    texture_mappings: dict[str, str] = field(default_factory=dict)


@dataclass
class Kn5Inspection:
    path: str
    file_size_bytes: int
    version: int
    extra_header: int | None
    texture_count: int
    total_texture_bytes: int
    textures: list[TextureInfo]
    material_count: int
    materials: list[MaterialInfo]
    partial_parse_warning: str | None = None


def _read_exact(stream: BinaryIO, size: int) -> bytes:
    data = stream.read(size)
    if len(data) != size:
        raise Kn5FormatError(
            f"Unerwartetes Dateiende: erwartet {size} Bytes, gelesen {len(data)} Bytes"
        )
    return data


def _read_int32(stream: BinaryIO) -> int:
    return struct.unpack("<i", _read_exact(stream, 4))[0]


def _read_uint8(stream: BinaryIO) -> int:
    return struct.unpack("<B", _read_exact(stream, 1))[0]


def _read_string(stream: BinaryIO) -> str:
    length = _read_int32(stream)
    if length < 0 or length > 10_000_000:
        raise Kn5FormatError(f"Ungültige String-Länge im KN5-Stream: {length}")
    raw = _read_exact(stream, length)
    return raw.decode("utf-8", errors="replace")


def inspect_kn5_file(file_path: Path) -> Kn5Inspection:
    """Liest Header, Texturen und Materialien einer .kn5-Datei aus."""
    if not file_path.is_file():
        raise FileNotFoundError(f"Datei nicht gefunden: {file_path}")

    file_size = file_path.stat().st_size
    if file_size < 14:
        raise Kn5FormatError(f"Datei zu klein für KN5-Header ({file_size} Bytes): {file_path}")

    textures: list[TextureInfo] = []
    materials: list[MaterialInfo] = []
    partial_warning: str | None = None
    extra_header: int | None = None
    tex_count = 0
    mat_count = 0

    with file_path.open("rb") as fh:
        magic = _read_exact(fh, 6)
        if magic != KN5_MAGIC:
            raise Kn5FormatError(
                f"Ungültige Magic-Bytes {magic!r} (erwartet {KN5_MAGIC!r}) in {file_path}"
            )

        version = _read_int32(fh)
        if version > 5:
            extra_header = _read_int32(fh)

        tex_count = _read_int32(fh)
        if tex_count < 0 or tex_count > 100_000:
            raise Kn5FormatError(f"Unplausible Texturanzahl: {tex_count}")

        for _ in range(tex_count):
            active = _read_int32(fh) != 0
            tex_name = _read_string(fh)
            tex_len = _read_int32(fh)
            if tex_len < 0:
                raise Kn5FormatError(f"Negative Texturlänge ({tex_len}) bei {tex_name}")
            fh.seek(tex_len, 1)
            textures.append(
                TextureInfo(name=tex_name, active=active, size_bytes=tex_len)
            )

        try:
            mat_count = _read_int32(fh)
            if mat_count < 0 or mat_count > 100_000:
                raise Kn5FormatError(f"Unplausible Materialanzahl: {mat_count}")

            for _ in range(mat_count):
                mat_name = _read_string(fh)
                shader_name = _read_string(fh)
                blend_mode = _read_uint8(fh)
                alpha_tested = _read_uint8(fh) != 0
                depth_mode: int | None = None
                if version >= 5:
                    depth_mode = _read_int32(fh)

                prop_count = _read_int32(fh)
                if prop_count < 0 or prop_count > 10_000:
                    raise Kn5FormatError(
                        f"Unplausible Property-Anzahl ({prop_count}) bei Material {mat_name}"
                    )
                for _ in range(prop_count):
                    _ = _read_string(fh)
                    # valueA (1 float) + valueB (2 floats) + valueC (3 floats) + valueD (4 floats) = 40 Bytes
                    _ = _read_exact(fh, 40)

                tex_map_count = _read_int32(fh)
                if tex_map_count < 0 or tex_map_count > 1_000:
                    raise Kn5FormatError(
                        f"Unplausible Texture-Mapping-Anzahl ({tex_map_count}) bei Material {mat_name}"
                    )
                tex_mappings: dict[str, str] = {}
                for _ in range(tex_map_count):
                    sampler_name = _read_string(fh)
                    _slot = _read_int32(fh)
                    mapped_tex = _read_string(fh)
                    tex_mappings[sampler_name] = mapped_tex

                materials.append(
                    MaterialInfo(
                        name=mat_name,
                        shader=shader_name,
                        blend_mode=blend_mode,
                        alpha_tested=alpha_tested,
                        depth_mode=depth_mode,
                        property_count=prop_count,
                        texture_mappings=tex_mappings,
                    )
                )
        except (Kn5FormatError, struct.error, OSError) as exc:
            partial_warning = (
                f"Material-Sektion nur teilweise geparst ({len(materials)}/{mat_count}): {exc}"
            )

    total_tex_bytes = sum(t.size_bytes for t in textures)
    return Kn5Inspection(
        path=str(file_path),
        file_size_bytes=file_size,
        version=version,
        extra_header=extra_header,
        texture_count=tex_count,
        total_texture_bytes=total_tex_bytes,
        textures=textures,
        material_count=mat_count,
        materials=materials,
        partial_parse_warning=partial_warning,
    )


def check_car_directory(car_dir: Path) -> dict:
    """Prüft einen AC-Fahrzeugordner auf KN5-Integrität, Collider und UI-Metadaten."""
    if not car_dir.is_dir():
        return {
            "car_dir": str(car_dir),
            "healthy": False,
            "errors": [f"Fahrzeugordner existiert nicht: {car_dir}"],
            "kn5_files": [],
        }

    errors: list[str] = []
    warnings: list[str] = []
    kn5_entries: list[dict] = []

    kn5_paths = sorted(car_dir.glob("*.kn5"))
    if not kn5_paths:
        errors.append("Keine einzige .kn5-Datei im Fahrzeugordner gefunden.")

    has_collider = (car_dir / "collider.kn5").is_file()
    if not has_collider:
        errors.append("Pflichtdatei collider.kn5 fehlt.")

    model_kn5 = [p for p in kn5_paths if p.name.lower() != "collider.kn5"]
    if not model_kn5:
        errors.append("Kein Fahrzeugmodell (.kn5 außer collider.kn5) vorhanden.")

    for kn5_path in kn5_paths:
        size_bytes = kn5_path.stat().st_size
        entry: dict = {
            "name": kn5_path.name,
            "size_bytes": size_bytes,
            "size_mb": round(size_bytes / (1024 * 1024), 2),
            "valid_magic": False,
            "version": None,
            "textures": None,
            "materials": None,
        }
        try:
            with kn5_path.open("rb") as fh:
                magic = fh.read(6)
                ver_bytes = fh.read(4)
                if magic == KN5_MAGIC and len(ver_bytes) == 4:
                    entry["valid_magic"] = True
                    entry["version"] = struct.unpack("<i", ver_bytes)[0]
                else:
                    errors.append(f"Ungültiger KN5-Header in {kn5_path.name}")
            if kn5_path.name.lower() != "collider.kn5" and size_bytes < 10_000:
                warnings.append(
                    f"Sehr kleine Modell-KN5 ({size_bytes} Bytes): {kn5_path.name}"
                )
        except OSError as exc:
            errors.append(f"Lesefehler bei {kn5_path.name}: {exc}")
        kn5_entries.append(entry)

    ui_car_path = car_dir / "ui" / "ui_car.json"
    ui_car_name: str | None = None
    if not ui_car_path.is_file():
        errors.append("Metadaten-Datei ui/ui_car.json fehlt.")
    else:
        try:
            ui_raw = ui_car_path.read_text(encoding="utf-8-sig", errors="replace")
            ui_json = json.loads(ui_raw)
            ui_car_name = ui_json.get("name")
        except json.JSONDecodeError as exc:
            errors.append(f"ui/ui_car.json ist ungültiges JSON: {exc}")

    ext_cfg = car_dir / "extension" / "ext_config.ini"
    return {
        "car_dir": str(car_dir),
        "car_id": car_dir.name,
        "ui_car_name": ui_car_name,
        "has_ext_config": ext_cfg.is_file(),
        "kn5_count": len(kn5_entries),
        "kn5_files": kn5_entries,
        "errors": errors,
        "warnings": warnings,
        "healthy": len(errors) == 0,
    }


def _print_inspection(report: Kn5Inspection, top_n: int) -> None:
    tex_mb = report.total_texture_bytes / (1024 * 1024)
    file_mb = report.file_size_bytes / (1024 * 1024)
    print(f"KN5-Analyse: {report.path}")
    print(
        f"  Dateigröße : {report.file_size_bytes:,} Bytes ({file_mb:.2f} MB)"
    )
    print(
        f"  KN5-Version: {report.version}"
        + (f" (extra={report.extra_header})" if report.extra_header is not None else "")
    )
    print(f"  Texturen   : {report.texture_count} (Payload: {tex_mb:.2f} MB)")
    print(f"  Materialien: {report.material_count}")
    if report.partial_parse_warning:
        print(f"  WARNUNG    : {report.partial_parse_warning}")

    print(f"\nTop {min(top_n, len(report.textures))} größte Texturen:")
    for tex in sorted(report.textures, key=lambda t: t.size_bytes, reverse=True)[:top_n]:
        kb = tex.size_bytes / 1024
        print(f"  - {tex.name:<40} {kb:8.1f} KB  (active={tex.active})")

    shader_counts: dict[str, int] = {}
    for mat in report.materials:
        shader_counts[mat.shader] = shader_counts.get(mat.shader, 0) + 1
    if shader_counts:
        print("\nVerwendete Shader:")
        for shader, count in sorted(shader_counts.items(), key=lambda kv: (-kv[1], kv[0])):
            print(f"  - {shader:<32} {count:3d}x")

    print(f"\nErste {min(top_n, len(report.materials))} Materialien:")
    for mat in report.materials[:top_n]:
        tx = ", ".join(f"{k}={v}" for k, v in mat.texture_mappings.items())
        print(
            f"  - {mat.name:<28} shader={mat.shader} blend={mat.blend_mode} "
            f"alpha={mat.alpha_tested} [{tx}]"
        )


def _print_car_check(result: dict) -> None:
    status = "HEALTHY" if result["healthy"] else "DEFECT"
    print(f"Car-Check [{status}]: {result['car_id']} ({result['car_dir']})")
    if result.get("ui_car_name"):
        print(f"  UI-Name    : {result['ui_car_name']}")
    print(f"  ext_config : {'vorhanden' if result.get('has_ext_config') else 'nicht vorhanden'}")
    print(f"  KN5-Dateien: {result['kn5_count']}")
    for kf in result["kn5_files"]:
        print(
            f"    * {kf['name']:<32} {kf['size_bytes']:>11,} Bytes "
            f"({kf['size_mb']:>6.2f} MB) v={kf['version']} magic={kf['valid_magic']}"
        )
    for warn in result.get("warnings", []):
        print(f"  WARNUNG: {warn}")
    for err in result.get("errors", []):
        print(f"  FEHLER : {err}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Inspiziert Assetto Corsa .kn5-Dateien und prüft Fahrzeugordner auf Vollständigkeit."
    )
    target = parser.add_mutually_exclusive_group(required=True)
    target.add_argument("--file", type=Path, help="Pfad zu einer einzelnen .kn5-Datei")
    target.add_argument(
        "--check-car-dir",
        type=Path,
        help="Pfad zu einem Fahrzeugordner (z. B. .../content/cars/gp_2025_rb21)",
    )
    parser.add_argument(
        "--top",
        type=int,
        default=10,
        help="Anzahl der größten Texturen/Materialien in der Textausgabe (Standard: 10)",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Ergebnis als JSON auf stdout ausgeben",
    )
    args = parser.parse_args(argv)

    if args.file:
        try:
            inspection = inspect_kn5_file(args.file)
        except (FileNotFoundError, Kn5FormatError, OSError) as exc:
            if args.json:
                print(json.dumps({"healthy": False, "error": str(exc)}, indent=2))
            else:
                print(f"FEHLER: {exc}", file=sys.stderr)
            return 1

        if args.json:
            print(json.dumps(asdict(inspection), indent=2, ensure_ascii=False))
        else:
            _print_inspection(inspection, args.top)
        return 0

    result = check_car_directory(args.check_car_dir)
    if args.json:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        _print_car_check(result)
    return 0 if result["healthy"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
