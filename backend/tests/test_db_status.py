"""
Pruebas para comprobar la conexión con SQL Server y la existencia de la base 'buyer'.
"""


def test_sql_server_connected_and_buyer_db_exists(client):
    """
    2. SQL Server está conectado.
    3. La base buyer existe y contiene las 22 tablas requeridas.
    """
    response = client.get("/api/db/status")
    assert response.status_code == 200
    assert response.content_type == "application/json"

    data = response.get_json()
    assert data is not None
    assert data.get("status") == "connected"
    assert data.get("database") == "buyer"
    assert data.get("dbo_tables_count") == 22
    assert data.get("schema_valid") is True
    assert "server_edition" in data
    assert "server_utc_time" in data
