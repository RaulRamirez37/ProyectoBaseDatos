
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from decimal import Decimal
from database import obtener_conexion

app = FastAPI(title="API TechStore")


# =========================
# MODELOS Y VALIDACIONES
# =========================

class Producto(BaseModel):
    Nombre: str = Field(min_length=1, max_length=120)
    Descripcion: str = Field(min_length=1, max_length=250)
    IdCategoria: int = Field(gt=0)
    IdMarca: int = Field(gt=0)
    PrecioVenta: Decimal = Field(ge=0)
    CostoReferencia: Decimal = Field(ge=0)


class Categoria(BaseModel):
    Nombre: str = Field(min_length=1, max_length=80)
    Descripcion: str = Field(min_length=1, max_length=200)


class Marca(BaseModel):
    Nombre: str = Field(min_length=1, max_length=80)


class Proveedor(BaseModel):
    Nombre: str = Field(min_length=1, max_length=120)
    NIT: str = Field(min_length=1, max_length=20)
    Telefono: str = Field(min_length=1, max_length=20)


class Cliente(BaseModel):
    Nombres: str = Field(min_length=1, max_length=100)
    Apellidos: str = Field(min_length=1, max_length=100)
    NIT: str = Field(min_length=1, max_length=20)
    Telefono: str = Field(min_length=1, max_length=20)


# =========================
# FUNCIONES GENERALES
# =========================

def consultar_todos(tabla, columnas):
    conexion = obtener_conexion()
    try:
        cursor = conexion.cursor()
        cursor.execute(f"SELECT {columnas} FROM {tabla}")
        nombres = [col[0] for col in cursor.description]
        return [
            dict(zip(nombres, fila))
            for fila in cursor.fetchall()
        ]
    finally:
        conexion.close()


def consultar_uno(tabla, columnas, id_columna, identificador):
    conexion = obtener_conexion()
    try:
        cursor = conexion.cursor()
        cursor.execute(
            f"SELECT {columnas} FROM {tabla} "
            f"WHERE {id_columna} = ?",
            identificador
        )

        fila = cursor.fetchone()

        if fila is None:
            raise HTTPException(
                status_code=404,
                detail="Registro no encontrado"
            )

        nombres = [col[0] for col in cursor.description]
        return dict(zip(nombres, fila))
    finally:
        conexion.close()


def insertar_registro(tabla, id_columna, campos, valores):
    conexion = obtener_conexion()
    try:
        cursor = conexion.cursor()

        cursor.execute(
            f"SELECT ISNULL(MAX({id_columna}), 0) + 1 FROM {tabla}"
        )
        nuevo_id = cursor.fetchone()[0]

        columnas = ", ".join([id_columna] + campos)
        marcadores = ", ".join(["?"] * (len(campos) + 1))

        cursor.execute(
            f"INSERT INTO {tabla} ({columnas}) "
            f"VALUES ({marcadores})",
            (nuevo_id, *valores)
        )

        conexion.commit()
        return {
            "mensaje": "Registro creado correctamente",
            id_columna: nuevo_id
        }

    except Exception as error:
        conexion.rollback()
        raise HTTPException(status_code=400, detail=str(error))
    finally:
        conexion.close()


def actualizar_registro(
    tabla, id_columna, identificador, campos, valores
):
    conexion = obtener_conexion()
    try:
        cursor = conexion.cursor()

        asignaciones = ", ".join(
            f"{campo} = ?" for campo in campos
        )

        cursor.execute(
            f"UPDATE {tabla} SET {asignaciones} "
            f"WHERE {id_columna} = ?",
            (*valores, identificador)
        )

        if cursor.rowcount == 0:
            conexion.rollback()
            raise HTTPException(
                status_code=404,
                detail="Registro no encontrado"
            )

        conexion.commit()
        return {"mensaje": "Registro actualizado correctamente"}

    except HTTPException:
        raise
    except Exception as error:
        conexion.rollback()
        raise HTTPException(status_code=400, detail=str(error))
    finally:
        conexion.close()


def eliminar_registro(tabla, id_columna, identificador):
    conexion = obtener_conexion()
    try:
        cursor = conexion.cursor()

        cursor.execute(
            f"DELETE FROM {tabla} WHERE {id_columna} = ?",
            identificador
        )

        if cursor.rowcount == 0:
            conexion.rollback()
            raise HTTPException(
                status_code=404,
                detail="Registro no encontrado"
            )

        conexion.commit()
        return {"mensaje": "Registro eliminado correctamente"}

    except HTTPException:
        raise
    except Exception as error:
        conexion.rollback()
        raise HTTPException(
            status_code=400,
            detail="No se pudo eliminar. Puede tener registros relacionados."
        )
    finally:
        conexion.close()


@app.get("/")
def inicio():
    return {"mensaje": "API TechStore funcionando"}


# =========================
# CRUD DE PRODUCTOS
# =========================

@app.get("/productos")
def listar_productos():
    return consultar_todos(
        "Productos",
        "IdProducto, Nombre, Descripcion, IdCategoria, "
        "IdMarca, PrecioVenta, CostoReferencia"
    )


@app.get("/productos/{id_producto}")
def obtener_producto(id_producto: int):
    return consultar_uno(
        "Productos",
        "IdProducto, Nombre, Descripcion, IdCategoria, "
        "IdMarca, PrecioVenta, CostoReferencia",
        "IdProducto",
        id_producto
    )


@app.post("/productos")
def crear_producto(producto: Producto):
    return insertar_registro(
        "Productos",
        "IdProducto",
        [
            "Nombre", "Descripcion", "IdCategoria",
            "IdMarca", "PrecioVenta", "CostoReferencia"
        ],
        [
            producto.Nombre, producto.Descripcion,
            producto.IdCategoria, producto.IdMarca,
            producto.PrecioVenta, producto.CostoReferencia
        ]
    )


@app.put("/productos/{id_producto}")
def actualizar_producto(id_producto: int, producto: Producto):
    return actualizar_registro(
        "Productos", "IdProducto", id_producto,
        [
            "Nombre", "Descripcion", "IdCategoria",
            "IdMarca", "PrecioVenta", "CostoReferencia"
        ],
        [
            producto.Nombre, producto.Descripcion,
            producto.IdCategoria, producto.IdMarca,
            producto.PrecioVenta, producto.CostoReferencia
        ]
    )


@app.delete("/productos/{id_producto}")
def eliminar_producto(id_producto: int):
    return eliminar_registro(
        "Productos", "IdProducto", id_producto
    )


# =========================
# CRUD DE CATEGORIAS
# =========================

@app.get("/categorias")
def listar_categorias():
    return consultar_todos(
        "Categorias", "IdCategoria, Nombre, Descripcion"
    )


@app.get("/categorias/{id_categoria}")
def obtener_categoria(id_categoria: int):
    return consultar_uno(
        "Categorias", "IdCategoria, Nombre, Descripcion",
        "IdCategoria", id_categoria
    )


@app.post("/categorias")
def crear_categoria(categoria: Categoria):
    return insertar_registro(
        "Categorias", "IdCategoria",
        ["Nombre", "Descripcion"],
        [categoria.Nombre, categoria.Descripcion]
    )


@app.put("/categorias/{id_categoria}")
def actualizar_categoria(
    id_categoria: int, categoria: Categoria
):
    return actualizar_registro(
        "Categorias", "IdCategoria", id_categoria,
        ["Nombre", "Descripcion"],
        [categoria.Nombre, categoria.Descripcion]
    )


@app.delete("/categorias/{id_categoria}")
def eliminar_categoria(id_categoria: int):
    return eliminar_registro(
        "Categorias", "IdCategoria", id_categoria
    )


# =========================
# CRUD DE MARCAS
# =========================

@app.get("/marcas")
def listar_marcas():
    return consultar_todos("Marcas", "IdMarca, Nombre")


@app.get("/marcas/{id_marca}")
def obtener_marca(id_marca: int):
    return consultar_uno(
        "Marcas", "IdMarca, Nombre", "IdMarca", id_marca
    )


@app.post("/marcas")
def crear_marca(marca: Marca):
    return insertar_registro(
        "Marcas", "IdMarca",
        ["Nombre"], [marca.Nombre]
    )


@app.put("/marcas/{id_marca}")
def actualizar_marca(id_marca: int, marca: Marca):
    return actualizar_registro(
        "Marcas", "IdMarca", id_marca,
        ["Nombre"], [marca.Nombre]
    )


@app.delete("/marcas/{id_marca}")
def eliminar_marca(id_marca: int):
    return eliminar_registro(
        "Marcas", "IdMarca", id_marca
    )


# =========================
# CRUD DE PROVEEDORES
# =========================

@app.get("/proveedores")
def listar_proveedores():
    return consultar_todos(
        "Proveedores", "IdProveedor, Nombre, NIT, Telefono"
    )


@app.get("/proveedores/{id_proveedor}")
def obtener_proveedor(id_proveedor: int):
    return consultar_uno(
        "Proveedores",
        "IdProveedor, Nombre, NIT, Telefono",
        "IdProveedor", id_proveedor
    )


@app.post("/proveedores")
def crear_proveedor(proveedor: Proveedor):
    return insertar_registro(
        "Proveedores", "IdProveedor",
        ["Nombre", "NIT", "Telefono"],
        [proveedor.Nombre, proveedor.NIT, proveedor.Telefono]
    )


@app.put("/proveedores/{id_proveedor}")
def actualizar_proveedor(
    id_proveedor: int, proveedor: Proveedor
):
    return actualizar_registro(
        "Proveedores", "IdProveedor", id_proveedor,
        ["Nombre", "NIT", "Telefono"],
        [proveedor.Nombre, proveedor.NIT, proveedor.Telefono]
    )


@app.delete("/proveedores/{id_proveedor}")
def eliminar_proveedor(id_proveedor: int):
    return eliminar_registro(
        "Proveedores", "IdProveedor", id_proveedor
    )


# =========================
# CRUD DE CLIENTES
# =========================

@app.get("/clientes")
def listar_clientes():
    return consultar_todos(
        "Clientes",
        "IdCliente, Nombres, Apellidos, NIT, Telefono"
    )


@app.get("/clientes/{id_cliente}")
def obtener_cliente(id_cliente: int):
    return consultar_uno(
        "Clientes",
        "IdCliente, Nombres, Apellidos, NIT, Telefono",
        "IdCliente", id_cliente
    )


@app.post("/clientes")
def crear_cliente(cliente: Cliente):
    return insertar_registro(
        "Clientes", "IdCliente",
        ["Nombres", "Apellidos", "NIT", "Telefono"],
        [
            cliente.Nombres, cliente.Apellidos,
            cliente.NIT, cliente.Telefono
        ]
    )


@app.put("/clientes/{id_cliente}")
def actualizar_cliente(id_cliente: int, cliente: Cliente):
    return actualizar_registro(
        "Clientes", "IdCliente", id_cliente,
        ["Nombres", "Apellidos", "NIT", "Telefono"],
        [
            cliente.Nombres, cliente.Apellidos,
            cliente.NIT, cliente.Telefono
        ]
    )


@app.delete("/clientes/{id_cliente}")
def eliminar_cliente(id_cliente: int):
    return eliminar_registro(
        "Clientes", "IdCliente", id_cliente
    )

#w========================================================================================

# =========================
# MODELOS PARA OPERACIONES
# =========================

class VentaOperacion(BaseModel):
    IdVenta: int = Field(gt=0)
    IdCliente: int = Field(gt=0)
    IdEmpleado: int = Field(gt=0)
    IdSucursal: int = Field(gt=0)
    IdDetalleVenta: int = Field(gt=0)
    IdProducto: int = Field(gt=0)
    IdAlmacen: int = Field(gt=0)
    Cantidad: int = Field(gt=0)
    PrecioUnitario: Decimal = Field(ge=0)


class CompraOperacion(BaseModel):
    IdCompra: int = Field(gt=0)
    IdProveedor: int = Field(gt=0)
    IdEmpleado: int = Field(gt=0)
    IdAlmacen: int = Field(gt=0)
    IdDetalleCompra: int = Field(gt=0)
    IdProducto: int = Field(gt=0)
    Cantidad: int = Field(gt=0)
    CostoUnitario: Decimal = Field(ge=0)


# =========================
# PROCEDIMIENTO: REGISTRAR VENTA
# =========================

@app.post("/operaciones/ventas")
def registrar_venta(venta: VentaOperacion):
    conexion = obtener_conexion()

    try:
        cursor = conexion.cursor()

        cursor.execute("""
            EXEC dbo.RegistrarVenta
                @IdVenta = ?,
                @IdCliente = ?,
                @IdEmpleado = ?,
                @IdSucursal = ?,
                @IdDetalleVenta = ?,
                @IdProducto = ?,
                @IdAlmacen = ?,
                @Cantidad = ?,
                @PrecioUnitario = ?
        """, (
            venta.IdVenta,
            venta.IdCliente,
            venta.IdEmpleado,
            venta.IdSucursal,
            venta.IdDetalleVenta,
            venta.IdProducto,
            venta.IdAlmacen,
            venta.Cantidad,
            venta.PrecioUnitario
        ))

        conexion.commit()

        return {
            "mensaje": "Venta registrada correctamente",
            "IdVenta": venta.IdVenta
        }

    except Exception as error:
        conexion.rollback()
        raise HTTPException(status_code=400, detail=str(error))

    finally:
        conexion.close()


# =========================
# PROCEDIMIENTO: REGISTRAR COMPRA
# =========================

@app.post("/operaciones/compras")
def registrar_compra(compra: CompraOperacion):
    conexion = obtener_conexion()

    try:
        cursor = conexion.cursor()

        cursor.execute("""
            EXEC dbo.RegistrarCompra
                @IdCompra = ?,
                @IdProveedor = ?,
                @IdEmpleado = ?,
                @IdAlmacen = ?,
                @IdDetalleCompra = ?,
                @IdProducto = ?,
                @Cantidad = ?,
                @CostoUnitario = ?
        """, (
            compra.IdCompra,
            compra.IdProveedor,
            compra.IdEmpleado,
            compra.IdAlmacen,
            compra.IdDetalleCompra,
            compra.IdProducto,
            compra.Cantidad,
            compra.CostoUnitario
        ))

        conexion.commit()

        return {
            "mensaje": "Compra registrada correctamente",
            "IdCompra": compra.IdCompra
        }

    except Exception as error:
        conexion.rollback()
        raise HTTPException(status_code=400, detail=str(error))

    finally:
        conexion.close()


# =========================
# REPORTE: VENTAS POR SUCURSAL
# =========================

@app.get("/reportes/ventas-sucursal")
def reporte_ventas_sucursal():
    conexion = obtener_conexion()

    try:
        cursor = conexion.cursor()

        cursor.execute("""
            SELECT
                S.Nombre AS Sucursal,
                COUNT(V.IdVenta) AS CantidadVentas,
                SUM(V.Total) AS TotalVendido
            FROM Sucursales S
            INNER JOIN Ventas V
                ON S.IdSucursal = V.IdSucursal
            GROUP BY S.IdSucursal, S.Nombre
        """)

        columnas = [col[0] for col in cursor.description]

        return [
            dict(zip(columnas, fila))
            for fila in cursor.fetchall()
        ]

    except Exception as error:
        raise HTTPException(status_code=500, detail=str(error))

    finally:
        conexion.close()


# =========================
# REPORTE: PRODUCTOS MÁS VENDIDOS
# =========================

@app.get("/reportes/productos-vendidos")
def reporte_productos_vendidos():
    conexion = obtener_conexion()

    try:
        cursor = conexion.cursor()

        cursor.execute("""
            SELECT
                P.Nombre AS Producto,
                SUM(DV.Cantidad) AS UnidadesVendidas,
                SUM(
                    DV.Cantidad * DV.PrecioUnitario - DV.Descuento
                ) AS TotalGenerado
            FROM Productos P
            INNER JOIN DetalleVentas DV
                ON P.IdProducto = DV.IdProducto
            GROUP BY P.IdProducto, P.Nombre
            ORDER BY UnidadesVendidas DESC
        """)

        columnas = [col[0] for col in cursor.description]

        return [
            dict(zip(columnas, fila))
            for fila in cursor.fetchall()
        ]

    except Exception as error:
        raise HTTPException(status_code=500, detail=str(error))

    finally:
        conexion.close()
