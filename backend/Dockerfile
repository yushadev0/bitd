FROM python:3.12-slim-bookworm

WORKDIR /app

# ODBC Driver 18 for SQL Server — needed for the mssql+pyodbc production DB path.
# (Local dev uses postgresql+psycopg, which needs no system driver.)
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl gnupg2 unixodbc-dev gcc g++ \
    && curl -sSL -O https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
