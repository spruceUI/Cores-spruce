#!/usr/bin/env python3
"""Check one standalone build against its recipe and lay out what spruce ships.

Usage: check.py <recipes.json> <recipe> <output dir> <card dir>

<output dir> is what the recipe's script wrote: dist/ and elf.tsv. The checks are cores-experimental's
(corebuild/standalone.py). Every mapped output must exist, and every library a built ELF needs must be on the device
or shipped by the build, and must not be forbidden. The files are also compared with the sha256 that spruce ships;
that comparison is reported, not required. The mapped files are copied to <card dir> at their card paths.
"""
import hashlib
import json
import os
import shutil
import sys
from pathlib import Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    recipes, name, out, card = json.loads(Path(sys.argv[1]).read_text()), sys.argv[2], Path(sys.argv[3]), Path(sys.argv[4])
    spec = recipes[name]
    dist = out / "dist"
    problems = []

    elf = {}
    for line in (out / "elf.tsv").read_text().splitlines() if (out / "elf.tsv").exists() else []:
        file, kind, value = line.split("\t")
        entry = elf.setdefault(file, {"soname": None, "needed": []})
        if kind == "soname":
            entry["soname"] = value
        else:
            entry["needed"].append(value)
    files = {p.relative_to(dist).as_posix() for p in dist.rglob("*") if p.is_file()} if dist.is_dir() else set()
    provided = set(spec["device_libs"]) | {Path(f).name for f in files}
    provided |= {e["soname"] for e in elf.values() if e["soname"]} | {Path(f).name for f in elf}
    for file, entry in sorted(elf.items()):
        for lib in entry["needed"]:
            if lib in spec["forbidden_libs"]:
                problems.append(f"{file} needs {lib}, which is forbidden")
            elif lib not in provided:
                problems.append(f"{file} needs {lib}, which is neither on the device nor shipped")

    # A card-map key ending in "/" maps a folder; a file's own key wins over its folder's.
    for key, target in spec["spruce"].items():
        source = dist / key.rstrip("/")
        if key.endswith("/"):
            if not source.is_dir():
                problems.append(f"{key} was not produced")
                continue
            shutil.copytree(source, card / target.rstrip("/"), dirs_exist_ok=True)
        elif source.is_file():
            (card / target).parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, card / target)
        else:
            problems.append(f"{key} was not produced")

    report = [f"## {name}"]
    for path, want in sorted(spec["shipped"].items()):
        got = sha256(dist / path) if (dist / path).is_file() else None
        state = "missing" if got is None else "match" if got == want else "differs"
        report.append(f"- `{path}`: {state} with what spruce ships" + ("" if state == "match" else f" ({(got or '-')[:16]})"))
        if state != "match":
            print(f"::warning::{name}: {path} {state} with what spruce ships")
    for problem in problems:
        report.append(f"- problem: {problem}")
        print(f"::error::{name}: {problem}")
    print("\n".join(report))
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as summary:
            summary.write("\n".join(report) + "\n")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
