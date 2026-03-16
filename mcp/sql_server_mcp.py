#!/usr/bin/env python3
"""
DWH MCP Server — gives Claude direct read-only SQL query access.

Supports SQL Server (pyodbc) and PostgreSQL (psycopg2) based on DB_DRIVER env var.

Environment variables:
  DB_DRIVER   - "sqlserver" or "postgresql" (default: sqlserver)
  DB_HOST     - Database host
  DB_PORT     - Database port
  DB_NAME     - Database name
  DB_USER     - Database user
  DB_PASSWORD - Database password (optional)

Install:
  uv pip install mcp pyodbc  # for SQL Server
  uv pip install mcp psycopg2-binary  # for PostgreSQL
"""

import json
import logging
import os
from pathlib import Path
import sys

logging.basicConfig(level=logging.INFO, stream=sys.stderr)
logger = logging.getLogger("dwh-mcp")

# ---------------------------------------------------------------------------
# Load credentials from ~/.claude/.env (not tracked by git)
# Falls back to environment variables set in settings.json
# ---------------------------------------------------------------------------

ENV_FILE = Path.home() / ".claude" / ".env"
if ENV_FILE.exists():
    for line in ENV_FILE.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, _, value = line.partition("=")
            os.environ.setdefault(key.strip(), value.strip())

DB_DRIVER = os.getenv("DB_DRIVER", "postgresql")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "9700")
DB_NAME = os.getenv("DB_NAME", "datax")
DB_USER = os.getenv("DB_USER", "")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
ROW_LIMIT = int(os.getenv("DB_ROW_LIMIT", "1000"))


def get_connection():
    """Create a database connection based on DB_DRIVER."""
    if DB_DRIVER == "postgresql":
        import psycopg2

        return psycopg2.connect(
            host=DB_HOST,
            port=int(DB_PORT),
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD or None,
        )
    else:
        import pyodbc

        conn_str = (
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"SERVER={DB_HOST},{DB_PORT};"
            f"DATABASE={DB_NAME};"
            f"UID={DB_USER};"
            f"PWD={DB_PASSWORD};"
            f"TrustServerCertificate=yes;"
        )
        return pyodbc.connect(conn_str)


def run_query(sql: str, params: tuple = (), limit: int = ROW_LIMIT) -> list[dict]:
    """Execute a read-only query and return results as list of dicts."""
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        columns = [desc[0] for desc in cur.description] if cur.description else []
        rows = cur.fetchmany(limit)
        return [dict(zip(columns, row)) for row in rows]
    finally:
        conn.close()


# ---------------------------------------------------------------------------
# MCP Server
# ---------------------------------------------------------------------------

from mcp.server.fastmcp import FastMCP

server = FastMCP("dwh", instructions="Read-only SQL access to the data warehouse.")


@server.tool()
def query(sql: str, limit: int = ROW_LIMIT) -> str:
    """Execute a read-only SQL query. Returns JSON array of row objects.

    Parameters
    ----------
    sql : str
        The SQL query to execute. Must be a SELECT statement.
    limit : int
        Maximum rows to return (default 1000).
    """
    sql_upper = sql.strip().upper()
    if not sql_upper.startswith("SELECT") and not sql_upper.startswith("WITH"):
        return json.dumps({"error": "Only SELECT/WITH queries are allowed (read-only)."})

    try:
        rows = run_query(sql, limit)
        return json.dumps(rows, default=str, indent=2)
    except Exception as e:
        return json.dumps({"error": str(e)})


@server.tool()
def list_tables(schema: str = "dbo") -> str:
    """List all tables in a schema.

    Parameters
    ----------
    schema : str
        Schema name (default: dbo for SQL Server, public for PostgreSQL).
    """
    if DB_DRIVER == "postgresql":
        sql = """
            SELECT table_name, table_type
            FROM information_schema.tables
            WHERE table_schema = %s
            ORDER BY table_name
        """
    else:
        sql = """
            SELECT TABLE_NAME, TABLE_TYPE
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA = ?
            ORDER BY TABLE_NAME
        """
    try:
        rows = run_query(sql, (schema,), limit=500)
        return json.dumps(rows, default=str, indent=2)
    except Exception as e:
        return json.dumps({"error": str(e)})


@server.tool()
def describe_table(table: str, schema: str = "dbo") -> str:
    """Describe columns of a table.

    Parameters
    ----------
    table : str
        Table name.
    schema : str
        Schema name (default: dbo for SQL Server, public for PostgreSQL).
    """
    if DB_DRIVER == "postgresql":
        sql = """
            SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s
            ORDER BY ORDINAL_POSITION
        """
    else:
        sql = """
            SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?
            ORDER BY ORDINAL_POSITION
        """
    try:
        rows = run_query(sql, (schema, table), limit=500)
        return json.dumps(rows, default=str, indent=2)
    except Exception as e:
        return json.dumps({"error": str(e)})


if __name__ == "__main__":
    server.run(transport="stdio")
