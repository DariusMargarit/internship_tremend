FROM python:3.9-slim

WORKDIR /app

COPY calculator.py requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt
RUN pip install Flask

EXPOSE 8080

CMD ["gunicorn", "-b", "0.0.0.0:8080", "calculator:app"]
