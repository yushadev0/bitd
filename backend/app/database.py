from sqlalchemy import create_engine, func
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from app.config import get_settings

settings = get_settings()

engine = create_engine(settings.database_url, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def random_order():
    """ORDER BY expression for a random row — RANDOM() on Postgres, NEWID() on SQL Server."""
    return func.newid() if engine.dialect.name == "mssql" else func.random()
