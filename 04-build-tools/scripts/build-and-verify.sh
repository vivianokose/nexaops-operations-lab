#!/usr/bin/env bash
#
# Builds the user-service, then produces everything needed to trust the artifact:
#   1. the JAR        (what is it)
#   2. an SBOM        (what is inside it)
#   3. a Grype scan   (is it safe)
#   4. a SHA-256 sum  (is it unchanged)
#
# Usage: ./build-and-verify.sh

set -euo pipefail

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../labs/user-service" && pwd)"
cd "${SERVICE_DIR}"

VERSION="1.0.0"
ARTIFACT="target/user-service-${VERSION}.jar"
SBOM="sbom/user-service-${VERSION}-sbom.json"

echo ">> Step 1 of 4: building the artifact"
mvn -B clean package

echo ""
echo ">> Step 2 of 4: generating the SBOM"
mkdir -p sbom
syft "${ARTIFACT}" -o cyclonedx-json > "${SBOM}"
echo "   wrote ${SBOM}"

echo ""
echo ">> Step 3 of 4: scanning for known vulnerabilities"
grype "sbom:${SBOM}"

echo ""
echo ">> Step 4 of 4: producing the checksum"
sha256sum "${ARTIFACT}" > "${ARTIFACT}.sha256"
sha256sum -c "${ARTIFACT}.sha256"

echo ""
echo ">> Done. Artifact is built, listed, scanned, and sealed."
ls -lh "${ARTIFACT}" "${SBOM}" "${ARTIFACT}.sha256"
