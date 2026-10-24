"""Repository hygiene only. This does not parse, type-check or compile Swift."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
core = root / "Sources/CommerceCore"
presentation = root / "Sources/CommercePresentation"
tests = root / "Tests/CommerceCoreTests"
errors = []
for directory in (core, presentation, tests):
    if not directory.is_dir():
        errors.append(f"Missing package target: {directory.relative_to(root)}")

symbols = {}
files = sorted(root.glob("Sources/**/*.swift")) + sorted(root.glob("Tests/**/*.swift")) + sorted(root.glob("App/**/*.swift"))
for path in files:
    source = path.read_text(encoding="utf-8")
    if "<<<<<<<" in source or ">>>>>>>" in source:
        errors.append(f"Merge marker: {path.relative_to(root)}")
    if "@MainActor\n@MainActor" in source:
        errors.append(f"Duplicate actor attribute: {path.relative_to(root)}")
    if "import SwiftUI" in source and path.is_relative_to(presentation) and not source.startswith("#if os(iOS)"):
        errors.append(f"iOS view missing platform guard: {path.relative_to(root)}")
    if path.is_relative_to(core) and re.search(r"^import (SwiftUI|Combine)$", source, re.M):
        errors.append(f"UI dependency in domain: {path.relative_to(root)}")
    for name in re.findall(r"^(?:public )?(?:final )?(?:struct|enum|actor|class|protocol) (\w+)", source, re.M):
        if name in symbols:
            errors.append(f"Duplicate top-level name: {name}")
        symbols[name] = path

for doc in root.glob("**/*.md"):
    for target in re.findall(r"\]\(([^)]+)\)", doc.read_text(encoding="utf-8")):
        if "://" not in target and not (doc.parent / target.split("#")[0]).exists():
            errors.append(f"Broken document link: {doc.relative_to(root)} -> {target}")

project_file = root / "Commerce.xcodeproj/project.pbxproj"
if project_file.exists():
    project = project_file.read_text(encoding="utf-8")
    declarations = re.findall(r"^\s*([A-F0-9]{24}) = \{", project, re.M)
    references = set(re.findall(r"\b[A-F0-9]{24}\b", project))
    if len(declarations) != len(set(declarations)):
        errors.append("Duplicate Xcode project object ID")
    for missing in references - set(declarations):
        errors.append(f"Unresolved Xcode project reference: {missing}")
    if not (root / "App/CommerceApp.swift").exists():
        errors.append("Missing app entry point")
    ET.parse(root / "Commerce.xcodeproj/xcshareddata/xcschemes/Commerce.xcscheme")

if errors:
    raise SystemExit("\n".join(errors))
print(f"Structure OK: {len(files)} Swift source/test files; {len(symbols)} unique top-level declarations.")
print("Domain has no SwiftUI/Combine imports. Local documentation links resolve.")
print("Xcode object references resolve; shared scheme XML is well formed. This is not xcodebuild validation.")
print("Swift compilation and XCTest execution remain pending on Mac.")
