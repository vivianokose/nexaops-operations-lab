# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-07-23

### Added
- `user-service`: Java service built with Maven, producing a versioned JAR artifact.
  Adds, finds, and counts user accounts. Covered by four JUnit tests.
- `notification-service`: Node service built with npm, packaged as a versioned .tgz.
  Sends simulated email and SMS notifications. Covered by five tests using Node's
  built-in test runner.
- CycloneDX SBOMs generated with Syft for both artifacts.
- Vulnerability scanning with Grype against both SBOMs. No findings.
- SHA-256 checksum published alongside the JAR, with tamper detection verified.
