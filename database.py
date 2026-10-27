import pyodbc

def obtener_conexion():
    conexion = pyodbc.connect(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=localhost;"
        "DATABASE=TechStore;"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )
    return conexion