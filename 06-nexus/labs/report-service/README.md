# nexaops-report-service

A small Python package that generates uptime reports for NexaOps services.

Built and published to an internal Sonatype Nexus registry as part of a
DevOps learning module on artifact repository management.

## Install

```bash
pip install nexaops-report-service
```

(from the NexaOps internal registry)

## Usage

```python
from report_service.report import generate_uptime_report, summarize

report = generate_uptime_report()
print(summarize(report))
```
