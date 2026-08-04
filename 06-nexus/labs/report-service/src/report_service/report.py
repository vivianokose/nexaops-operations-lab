"""Report generation for NexaOps services."""

from datetime import datetime, timezone


def generate_uptime_report():
    """Return a simple uptime report for the core NexaOps services.

    In a real service this would query live health checks. Here it returns
    a fixed snapshot, enough to prove the package works once installed.
    """
    return {
        "version": "1.0.0",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "services": ["API Gateway", "Auth Service", "Database"],
        "status": "all operational",
    }


def summarize(report):
    """Turn a report dict into a one-line human summary."""
    count = len(report["services"])
    return f"{count} services checked, status: {report['status']}"


if __name__ == "__main__":
    r = generate_uptime_report()
    print("NexaOps Report Service v" + r["version"])
    print(summarize(r))
