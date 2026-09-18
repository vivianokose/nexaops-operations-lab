FROM python:3.11-slim
RUN useradd -r -u 1001 clearops
WORKDIR /app
COPY app.py .
RUN chown clearops /app/app.py
USER clearops
EXPOSE 8080
CMD ["python3", "app.py"]
