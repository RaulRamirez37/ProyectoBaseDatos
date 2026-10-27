from database import obtener_conexion

try:
    conexion = obtener_conexion()
    cursor = conexion.cursor()

    cursor.execute("SELECT DB_NAME()")
    print("Conectado a la base de datos:", cursor.fetchone()[0])

    conexion.close()

except Exception as error:
    print("Error de conexión:", error)