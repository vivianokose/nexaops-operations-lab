# Start from a small official Python image (the "base" the box is built on)
FROM python:3.12-slim

# A label describing who made this
LABEL maintainer="Vivian Okose"
LABEL description="NexaOps Report Service, containerised"

# Work inside /app in the box
WORKDIR /app

# Copy the built wheel into the box
COPY dist/*.whl /tmp/

# Install the wheel, so the package is available inside the box
RUN pip install --no-cache-dir /tmp/*.whl

# Run as a non-root user inside the container (least privilege, same idea as the nexus user)
RUN useradd -r -u 1001 appuser
USER appuser

# When the box runs, print a report using the package we built
CMD ["python", "-c", "from report_service.report import generate_uptime_report, summarize; r = generate_uptime_report(); print('NexaOps Report Service v' + r['version']); print(summarize(r))"]
