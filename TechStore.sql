CREATE DATABASE TechStore;
USE TechStore;

CREATE TABLE Categorias (
    IdCategoria INT PRIMARY KEY,
    Nombre VARCHAR(80),
    Descripcion VARCHAR(200)
);

CREATE TABLE Marcas (
    IdMarca INT PRIMARY KEY,
    Nombre VARCHAR(80)
);

CREATE TABLE Productos (
    IdProducto INT PRIMARY KEY,
    Nombre VARCHAR(120),
    Descripcion VARCHAR(250),
    IdCategoria INT,
    IdMarca INT,
    PrecioVenta DECIMAL(10,2),
    CostoReferencia DECIMAL(10,2),

    CONSTRAINT FK_Productos_Categorias
        FOREIGN KEY (IdCategoria)
        REFERENCES Categorias(IdCategoria),

    CONSTRAINT FK_Productos_Marcas
        FOREIGN KEY (IdMarca)
        REFERENCES Marcas(IdMarca)
);

CREATE TABLE Proveedores (
    IdProveedor INT PRIMARY KEY,
    Nombre VARCHAR(120),
    NIT VARCHAR(20),
    Telefono VARCHAR(20)
);

CREATE TABLE Clientes (
    IdCliente INT PRIMARY KEY,
    Nombres VARCHAR(100),
    Apellidos VARCHAR(100),
    NIT VARCHAR(20),
    Telefono VARCHAR(20)
);

CREATE TABLE Sucursales (
    IdSucursal INT PRIMARY KEY,
    Nombre VARCHAR(100),
    Direccion VARCHAR(200),
    Telefono VARCHAR(20)
);

CREATE TABLE Empleados (
    IdEmpleado INT PRIMARY KEY,
    Nombres VARCHAR(100),
    Apellidos VARCHAR(100),
    Telefono VARCHAR(20),
    IdSucursal INT,

    CONSTRAINT FK_Empleados_Sucursales
        FOREIGN KEY (IdSucursal)
        REFERENCES Sucursales(IdSucursal)
);

CREATE TABLE Roles (
    IdRol INT PRIMARY KEY,
    Nombre VARCHAR(50),
    Descripcion VARCHAR(200)
);

CREATE TABLE Usuarios (
    IdUsuario INT PRIMARY KEY,
    IdEmpleado INT UNIQUE,
    IdRol INT,
    NombreUsuario VARCHAR(50),
    HashContrasena VARCHAR(255),

    CONSTRAINT FK_Usuarios_Empleados
        FOREIGN KEY (IdEmpleado)
        REFERENCES Empleados(IdEmpleado),

    CONSTRAINT FK_Usuarios_Roles
        FOREIGN KEY (IdRol)
        REFERENCES Roles(IdRol)
);

CREATE TABLE Almacenes (
    IdAlmacen INT PRIMARY KEY,
    IdSucursal INT,
    Nombre VARCHAR(100),
    Ubicacion VARCHAR(150),

    CONSTRAINT FK_Almacenes_Sucursales
        FOREIGN KEY (IdSucursal)
        REFERENCES Sucursales(IdSucursal)
);

CREATE TABLE Inventario (
    IdInventario INT PRIMARY KEY,
    IdAlmacen INT,
    IdProducto INT,
    Existencia INT,
    StockMinimo INT,

    CONSTRAINT FK_Inventario_Almacenes
        FOREIGN KEY (IdAlmacen)
        REFERENCES Almacenes(IdAlmacen),

    CONSTRAINT FK_Inventario_Productos
        FOREIGN KEY (IdProducto)
        REFERENCES Productos(IdProducto),

    CONSTRAINT UQ_Inventario_Almacen_Producto
        UNIQUE (IdAlmacen, IdProducto)
);

CREATE TABLE MovimientosInventario (
    IdMovimiento INT PRIMARY KEY,
    IdInventario INT,
    TipoMovimiento VARCHAR(20),
    Cantidad INT,
    Fecha DATETIME2,
    Observacion VARCHAR(250),

    CONSTRAINT FK_Movimientos_Inventario
        FOREIGN KEY (IdInventario)
        REFERENCES Inventario(IdInventario)
);

CREATE TABLE Compras (
    IdCompra INT PRIMARY KEY,
    IdProveedor INT,
    IdEmpleado INT,
    IdAlmacen INT,
    Fecha DATETIME2,
    Estado VARCHAR(20),
    Total DECIMAL(12,2),

    CONSTRAINT FK_Compras_Proveedores
        FOREIGN KEY (IdProveedor)
        REFERENCES Proveedores(IdProveedor),

    CONSTRAINT FK_Compras_Empleados
        FOREIGN KEY (IdEmpleado)
        REFERENCES Empleados(IdEmpleado),

    CONSTRAINT FK_Compras_Almacenes
        FOREIGN KEY (IdAlmacen)
        REFERENCES Almacenes(IdAlmacen)
);

CREATE TABLE DetalleCompras (
    IdDetalleCompra INT PRIMARY KEY,
    IdCompra INT,
    IdProducto INT,
    Cantidad INT,
    CostoUnitario DECIMAL(10,2),

    CONSTRAINT FK_DetalleCompras_Compras
        FOREIGN KEY (IdCompra)
        REFERENCES Compras(IdCompra),

    CONSTRAINT FK_DetalleCompras_Productos
        FOREIGN KEY (IdProducto)
        REFERENCES Productos(IdProducto),

    CONSTRAINT UQ_DetalleCompras_Compra_Producto
        UNIQUE (IdCompra, IdProducto)
);

CREATE TABLE Ventas (
    IdVenta INT PRIMARY KEY,
    IdCliente INT,
    IdEmpleado INT,
    IdSucursal INT,
    Fecha DATETIME2,
    Estado VARCHAR(20),
    Total DECIMAL(12,2),

    CONSTRAINT FK_Ventas_Clientes
        FOREIGN KEY (IdCliente)
        REFERENCES Clientes(IdCliente),

    CONSTRAINT FK_Ventas_Empleados
        FOREIGN KEY (IdEmpleado)
        REFERENCES Empleados(IdEmpleado),

    CONSTRAINT FK_Ventas_Sucursales
        FOREIGN KEY (IdSucursal)
        REFERENCES Sucursales(IdSucursal)
);

CREATE TABLE DetalleVentas (
    IdDetalleVenta INT PRIMARY KEY,
    IdVenta INT,
    IdProducto INT,
    Cantidad INT,
    PrecioUnitario DECIMAL(10,2),
    Descuento DECIMAL(10,2),

    CONSTRAINT FK_DetalleVentas_Ventas
        FOREIGN KEY (IdVenta)
        REFERENCES Ventas(IdVenta),

    CONSTRAINT FK_DetalleVentas_Productos
        FOREIGN KEY (IdProducto)
        REFERENCES Productos(IdProducto),

    CONSTRAINT UQ_DetalleVentas_Venta_Producto
        UNIQUE (IdVenta, IdProducto)
);

CREATE TABLE MetodosPago (
    IdMetodoPago INT PRIMARY KEY,
    Nombre VARCHAR(50)
);

CREATE TABLE Pagos (
    IdPago INT PRIMARY KEY,
    IdVenta INT,
    IdMetodoPago INT,
    Fecha DATETIME2,
    Monto DECIMAL(12,2),
    Referencia VARCHAR(100),

    CONSTRAINT FK_Pagos_Ventas
        FOREIGN KEY (IdVenta)
        REFERENCES Ventas(IdVenta),

    CONSTRAINT FK_Pagos_MetodosPago
        FOREIGN KEY (IdMetodoPago)
        REFERENCES MetodosPago(IdMetodoPago)
);

CREATE TABLE Facturas (
    IdFactura INT PRIMARY KEY,
    IdVenta INT UNIQUE,
    NumeroFactura VARCHAR(50),
    FechaEmision DATETIME2,
    NITReceptor VARCHAR(20),
    NombreReceptor VARCHAR(150),

    CONSTRAINT FK_Facturas_Ventas
        FOREIGN KEY (IdVenta)
        REFERENCES Ventas(IdVenta),

    CONSTRAINT UQ_Facturas_Numero
        UNIQUE (NumeroFactura)
);

CREATE TABLE Devoluciones (
    IdDevolucion INT PRIMARY KEY,
    IdDetalleVenta INT,
    IdEmpleado INT,
    Fecha DATETIME2,
    Cantidad INT,
    Motivo VARCHAR(250),
    Estado VARCHAR(20),

    CONSTRAINT FK_Devoluciones_DetalleVentas
        FOREIGN KEY (IdDetalleVenta)
        REFERENCES DetalleVentas(IdDetalleVenta),

    CONSTRAINT FK_Devoluciones_Empleados
        FOREIGN KEY (IdEmpleado)
        REFERENCES Empleados(IdEmpleado)
);



INSERT INTO Categorias (IdCategoria, Nombre, Descripcion)
VALUES
(1, 'Computadoras', 'Computadoras y laptops'),
(2, 'Perifericos', 'Teclados, mouse y accesorios'),
(3, 'Componentes', 'Componentes para computadoras');

INSERT INTO Marcas (IdMarca, Nombre)
VALUES
(1, 'HP'),
(2, 'Logitech'),
(3, 'Kingston');

INSERT INTO Proveedores (IdProveedor, Nombre, NIT, Telefono)
VALUES
(1, 'Distribuidora Tech', '1234567-8', '5555-1000'),
(2, 'Importadora Digital', '2345678-9', '5555-2000');

INSERT INTO Clientes (IdCliente, Nombres, Apellidos, NIT, Telefono)
VALUES
(1, 'Carlos', 'Perez', 'CF', '5555-3000'),
(2, 'Maria', 'Lopez', '1234567-1', '5555-4000');

INSERT INTO Sucursales (IdSucursal, Nombre, Direccion, Telefono)
VALUES
(1, 'Sucursal Central', 'Retalhuleu, Guatemala', '5555-5000'),
(2, 'Sucursal Norte', 'Quetzaltenango, Guatemala', '5555-6000');

INSERT INTO Roles (IdRol, Nombre, Descripcion)
VALUES
(1, 'Administrador', 'Acceso completo al sistema'),
(2, 'Vendedor', 'Registro de ventas');


--xd

INSERT INTO Productos
(IdProducto, Nombre, Descripcion, IdCategoria, IdMarca, PrecioVenta, CostoReferencia)
VALUES
(1, 'Laptop HP', 'Laptop para uso personal', 1, 1, 4500.00, 3500.00),
(2, 'Teclado Logitech', 'Teclado USB', 2, 2, 180.00, 100.00),
(3, 'Memoria Kingston', 'Memoria RAM de 8 GB', 3, 3, 250.00, 160.00),
(4, 'Mouse Logitech', 'Mouse USB', 2, 2, 100.00, 60.00),
(5, 'Laptop HP Gamer', 'Laptop para videojuegos', 1, 1, 6500.00, 5200.00);

INSERT INTO Empleados
(IdEmpleado, Nombres, Apellidos, Telefono, IdSucursal)
VALUES
(1, 'Yeltsin', 'Sanchez', '5555-7000', 1),
(2, 'Geovany', 'Guzman', '5555-8000', 2);

INSERT INTO Usuarios
(IdUsuario, IdEmpleado, IdRol, NombreUsuario, HashContrasena)
VALUES
(1, 1, 1, 'admin', 'hash_demo_admin'),
(2, 2, 2, 'vendedor', 'hash_demo_vendedor');

INSERT INTO Almacenes
(IdAlmacen, IdSucursal, Nombre, Ubicacion)
VALUES
(1, 1, 'Almacen Central', 'Bodega principal'),
(2, 2, 'Almacen Norte', 'Bodega secundaria');



INSERT INTO Inventario
(IdInventario, IdAlmacen, IdProducto, Existencia, StockMinimo)
VALUES
(1, 1, 1, 10, 2),
(2, 1, 2, 25, 5),
(3, 1, 3, 15, 3),
(4, 2, 4, 30, 5),
(5, 2, 5, 8, 2);

INSERT INTO MovimientosInventario
(IdMovimiento, IdInventario, TipoMovimiento, Cantidad, Fecha, Observacion)
VALUES
(1, 1, 'Entrada', 10, GETDATE(), 'Ingreso inicial de laptops'),
(2, 2, 'Entrada', 25, GETDATE(), 'Ingreso inicial de teclados'),
(3, 3, 'Entrada', 15, GETDATE(), 'Ingreso inicial de memorias RAM'),
(4, 4, 'Entrada', 30, GETDATE(), 'Ingreso inicial de mouse'),
(5, 5, 'Entrada', 8, GETDATE(), 'Ingreso inicial de laptops gamer');

INSERT INTO Compras
(IdCompra, IdProveedor, IdEmpleado, IdAlmacen, Fecha, Estado, Total)
VALUES
(1, 1, 1, 1, GETDATE(), 'Completada', 3660.00),
(2, 2, 2, 2, GETDATE(), 'Completada', 5360.00);

INSERT INTO DetalleCompras
(IdDetalleCompra, IdCompra, IdProducto, Cantidad, CostoUnitario)
VALUES
(1, 1, 1, 1, 3500.00),
(2, 1, 2, 1, 100.00),
(3, 1, 3, 1, 160.00),
(4, 2, 4, 1, 60.00),
(5, 2, 5, 1, 5200.00);



INSERT INTO Ventas
(IdVenta, IdCliente, IdEmpleado, IdSucursal, Fecha, Estado, Total)
VALUES
(1, 1, 2, 1, GETDATE(), 'Completada', 4680.00),
(2, 2, 1, 2, GETDATE(), 'Completada', 350.00);

INSERT INTO DetalleVentas
(IdDetalleVenta, IdVenta, IdProducto, Cantidad, PrecioUnitario, Descuento)
VALUES
(1, 1, 1, 1, 4500.00, 0.00),
(2, 1, 2, 1, 180.00, 0.00),
(3, 2, 3, 1, 250.00, 0.00),
(4, 2, 4, 1, 100.00, 0.00);



INSERT INTO MetodosPago (IdMetodoPago, Nombre)
VALUES
(1, 'Efectivo'),
(2, 'Tarjeta'),
(3, 'Transferencia');

INSERT INTO Pagos
(IdPago, IdVenta, IdMetodoPago, Fecha, Monto, Referencia)
VALUES
(1, 1, 1, GETDATE(), 4680.00, 'PAGO-001'),
(2, 2, 2, GETDATE(), 350.00, 'PAGO-002');

INSERT INTO Facturas
(IdFactura, IdVenta, NumeroFactura, FechaEmision, NITReceptor, NombreReceptor)
VALUES
(1, 1, 'FAC-001', GETDATE(), 'CF', 'Carlos Perez'),
(2, 2, 'FAC-002', GETDATE(), '1234567-1', 'Maria Lopez');

INSERT INTO Devoluciones
(IdDevolucion, IdDetalleVenta, IdEmpleado, Fecha, Cantidad, Motivo, Estado)
VALUES
(1, 4, 1, GETDATE(), 1, 'Producto defectuoso', 'Pendiente');




--Registrar una venta

GO

CREATE PROCEDURE RegistrarVenta
    @IdVenta INT,
    @IdCliente INT,
    @IdEmpleado INT,
    @IdSucursal INT,
    @IdDetalleVenta INT,
    @IdProducto INT,
    @IdAlmacen INT,
    @Cantidad INT,
    @PrecioUnitario DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Cantidad <= 0
            THROW 50001, 'La cantidad debe ser mayor que cero.', 1;

        IF @PrecioUnitario < 0
            THROW 50002, 'El precio no puede ser negativo.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM Inventario
            WHERE IdProducto = @IdProducto
              AND IdAlmacen = @IdAlmacen
              AND Existencia >= @Cantidad
        )
            THROW 50003, 'No hay suficiente inventario.', 1;

        INSERT INTO Ventas
        (IdVenta, IdCliente, IdEmpleado, IdSucursal, Fecha, Estado, Total)
        VALUES
        (@IdVenta, @IdCliente, @IdEmpleado, @IdSucursal,
         GETDATE(), 'Completada', @Cantidad * @PrecioUnitario);

        INSERT INTO DetalleVentas
        (IdDetalleVenta, IdVenta, IdProducto, Cantidad, PrecioUnitario, Descuento)
        VALUES
        (@IdDetalleVenta, @IdVenta, @IdProducto, @Cantidad,
         @PrecioUnitario, 0);

        UPDATE Inventario
        SET Existencia = Existencia - @Cantidad
        WHERE IdProducto = @IdProducto
          AND IdAlmacen = @IdAlmacen;

        INSERT INTO MovimientosInventario
        (IdMovimiento, IdInventario, TipoMovimiento, Cantidad, Fecha, Observacion)
        SELECT
            (SELECT ISNULL(MAX(IdMovimiento), 0) + 1
             FROM MovimientosInventario),
            IdInventario,
            'Salida',
            @Cantidad,
            GETDATE(),
            'Salida por venta'
        FROM Inventario
        WHERE IdProducto = @IdProducto
          AND IdAlmacen = @IdAlmacen;

        COMMIT TRANSACTION;
        PRINT 'Venta registrada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO




--Registrar una compra

GO
CREATE PROCEDURE RegistrarCompra
    @IdCompra INT,
    @IdProveedor INT,
    @IdEmpleado INT,
    @IdAlmacen INT,
    @IdDetalleCompra INT,
    @IdProducto INT,
    @Cantidad INT,
    @CostoUnitario DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Cantidad <= 0
            THROW 50011, 'La cantidad debe ser mayor que cero.', 1;

        IF @CostoUnitario < 0
            THROW 50012, 'El costo no puede ser negativo.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM Inventario
            WHERE IdProducto = @IdProducto
              AND IdAlmacen = @IdAlmacen
        )
            THROW 50013, 'El producto no existe en ese inventario.', 1;

        INSERT INTO Compras
        (IdCompra, IdProveedor, IdEmpleado, IdAlmacen, Fecha, Estado, Total)
        VALUES
        (@IdCompra, @IdProveedor, @IdEmpleado, @IdAlmacen,
         GETDATE(), 'Completada', @Cantidad * @CostoUnitario);

        INSERT INTO DetalleCompras
        (IdDetalleCompra, IdCompra, IdProducto, Cantidad, CostoUnitario)
        VALUES
        (@IdDetalleCompra, @IdCompra, @IdProducto,
         @Cantidad, @CostoUnitario);

        UPDATE Inventario
        SET Existencia = Existencia + @Cantidad
        WHERE IdProducto = @IdProducto
          AND IdAlmacen = @IdAlmacen;

        INSERT INTO MovimientosInventario
        (IdMovimiento, IdInventario, TipoMovimiento, Cantidad, Fecha, Observacion)
        SELECT
            (SELECT ISNULL(MAX(IdMovimiento), 0) + 1
             FROM MovimientosInventario),
            IdInventario,
            'Entrada',
            @Cantidad,
            GETDATE(),
            'Entrada por compra'
        FROM Inventario
        WHERE IdProducto = @IdProducto
          AND IdAlmacen = @IdAlmacen;

        COMMIT TRANSACTION;
        PRINT 'Compra registrada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO


--Ventas totales
SELECT
    S.Nombre AS Sucursal,
    COUNT(V.IdVenta) AS CantidadVentas,
    SUM(V.Total) AS TotalVendido
FROM Sucursales S
INNER JOIN Ventas V
    ON S.IdSucursal = V.IdSucursal
GROUP BY S.IdSucursal, S.Nombre;

--Productos mas vendidos
SELECT
    P.Nombre AS Producto,
    SUM(DV.Cantidad) AS UnidadesVendidas,
    SUM(DV.Cantidad * DV.PrecioUnitario - DV.Descuento) AS TotalGenerado
FROM Productos P
INNER JOIN DetalleVentas DV
    ON P.IdProducto = DV.IdProducto
GROUP BY P.IdProducto, P.Nombre
ORDER BY UnidadesVendidas DESC;





USE TechStore;

SELECT * FROM Ventas;
SELECT * FROM DetalleVentas;
SELECT * FROM Compras;
SELECT * FROM DetalleCompras;
SELECT * FROM Inventario;
SELECT * FROM MovimientosInventario;