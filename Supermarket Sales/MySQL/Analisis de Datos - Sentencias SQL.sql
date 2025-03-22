-- 	REALIZAR COPIA DE LA TABLA
CREATE TABLE supermarket_sales_copy AS SELECT * FROM supermarket_sales;

-- CAMBIAR NOMBRES DE LOS CAMPOS PARA QUE NO HAYA ESPACIOS EN BLANCO
ALTER TABLE `supermarket`.`supermarket_sales` 
CHANGE COLUMN `Invoice ID` `Invoice_ID` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Customer type` `Customer_type` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Product line` `Product_line` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Unit price` `Unit_price` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `Tax 5%` `Tax_5%` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `gross margin percentage` `gross_margin_percentage` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `gross income` `gross_income` DOUBLE NULL DEFAULT NULL ;

-- ANALISIS DE LA TABLA SUPERMARKET_SALES
SELECT * FROM supermarket_sales;

-- VENTAS GENERADAS EN EL SUPERMERCADO
SELECT 
	ROUND(SUM(Total), 2) AS ventas_generadas 
FROM 
	supermarket_sales;
    
-- GANANCIAS GENERADAS EN EL SUPERMERCADO
SELECT 
	ROUND(SUM(gross_income), 2) AS ganancias_generadas
FROM
	supermarket_sales;

-- CATEGORIAS DE PRODUCTOS CON MAYORES VENTAS EN TERMINOS DE INGRESOS
SELECT 
	Product_line AS linea_producto, 
	ROUND(SUM(total), 2) AS ingresos 
FROM 
	supermarket_sales 
GROUP BY 
	linea_producto
ORDER BY 
	ingresos 
DESC;

-- CATEGORIAS MÁS DEMANDADAS EN TERMINOS DE TRANSACCIONES/CANTIDADES VENDIDAS
SELECT 
	Product_line AS linea_producto,
    SUM(Quantity) AS demanda
FROM
	supermarket_sales
GROUP BY 
	linea_producto
ORDER BY
	demanda
DESC;

-- CIUDADES CON MAYORES INGRESOS
SELECT 
	City, 
    ROUND(SUM(total), 2) AS ingresos_totales 
FROM 
	supermarket_sales 
GROUP BY 
	City 
ORDER BY 
	ingresos_totales 
DESC;

-- DIA DE LA SEMANA CON MAYOR VOLUMEN DE VENTAS POR SUCURSAL
-- EN ESTA CONSULTA SE UTILIZA UNA CTE PARA EXTRAER ALGUNOS DATOS Y CALCULAR LA SUMA DE VENTAS POR DIA Y SUCURSAL
-- LUEGO, EN LA CONSULTA PRINCIPAL, SE FILTRAN SOLO LOS DATOS QUE CONTENGAN LAS VENTAS MAS ALTAS POR SUCURSAL
WITH ventas_por_dia AS (
	SELECT 
		Branch AS sucursal,
		City AS ciudad,
		DAYNAME(STR_TO_DATE(Date, '%m/%d/%Y')) AS dia_de_la_semana, 
		ROUND(SUM(total), 2) AS volumen_ventas 
	FROM 
		supermarket_sales
	GROUP BY
		sucursal,
		dia_de_la_semana
)

SELECT 
	* 
FROM 
	ventas_por_dia 
WHERE 
	volumen_ventas 
IN (
	SELECT 
		MAX(volumen_ventas) 
	FROM 
		ventas_por_dia 
	GROUP BY 
		sucursal
);

-- CANTIDAD DE PERSONAS POR GENERO Y CIUDAD
SELECT 
	City AS ciudad,
    Gender AS genero,
    COUNT(*) AS personas
FROM 	
	supermarket_sales
GROUP BY 
	ciudad,
    genero
ORDER BY
	ciudad;

-- GENERO QUE MAS INGRESOS DA
SELECT
	Gender AS genero,
    ROUND(SUM(total), 2) AS ingresos_generados
FROM
	supermarket_sales
GROUP BY 
	Genero;
    
-- DIFERENCIA DE GANACIAS POR TIPO DE CLIENTE "Member" y "Normal"
-- EN ESTA CONSULTA SE UTILIZA UNA CTE PARA CALCULAR LAS GANANCIAS REVISANDO PRIMERO A QUE TIPO DE CLIENTE PERTENECE
-- LUEGO, EN LA CONSULTA PRINCIPAL, SE REALIZA LA RESTA DE LAS GANANCIAS CALCULADAS
WITH suma_clientes AS (
	SELECT
		ROUND(SUM(CASE WHEN Customer_type = "Member" THEN gross_income ELSE 0 END),2) AS suma_member,
		ROUND(SUM(CASE WHEN Customer_type = "Normal" THEN gross_income ELSE 0 END),2) AS suma_normal
	FROM
		supermarket_sales
)

SELECT
	*,
    (suma_member - suma_normal) AS diferencia
FROM
	suma_clientes;

-- METODOS DE PAGO MÁS UTILIZADOS
SELECT
	Payment AS metodo_pago,
    COUNT(*) AS total
FROM
	supermarket_sales
GROUP BY
	Payment
ORDER BY 
	total
DESC;

-- TICKET PROMEDIO DE LOS CLIENTES (CUANTO DINERO GASTAN EN PROMEDIO, INDEPENDIENTEMENTE DEL TIPO DE CLIENTE)
SELECT
	ROUND(AVG(total), 2) AS ticket_promedio
FROM
	supermarket_sales;
    
-- TICKET PROMEDIO POR TIPO DE CLIENTE
SELECT
	Customer_type AS tipo_cliente,
    ROUND(AVG(total), 2) AS ticket_promedio
FROM 
	supermarket_sales
GROUP BY
	tipo_cliente;
    
-- NUMERO DE TRANSACCIONES
SELECT
	COUNT(*) AS transacciones
FROM 
	supermarket_sales;

-- HORA PICO GENERAL CON BASE A TRANSACCIONES
SELECT
	HOUR(CAST(Time AS TIME)) AS hora,
    COUNT(*) AS transacciones
FROM
	supermarket_sales
GROUP BY 
	hora
ORDER BY	
	transacciones 
DESC;

-- HORA PICO CON BASE A INGRESOS
SELECT
	HOUR(CAST(Time AS TIME)) AS hora,
    ROUND(SUM(total), 2) AS ingresos
FROM
	supermarket_sales
GROUP BY 
	hora
ORDER BY	
	ingresos 
DESC;

-- CALIFICACION PROMEDIO POR LINEA DE PRODUCTO
SELECT 
	Product_line AS linea_producto,
    ROUND(AVG(Rating), 2) AS promedio
FROM
	supermarket_sales
GROUP BY
	Product_line
ORDER BY
	promedio
DESC;

-- VENTAS GENERALES POR MES
SELECT
	CASE
		WHEN MONTH(STR_TO_DATE(Date, '%m/%d/%Y')) = 1 THEN "Enero"
        WHEN MONTH(STR_TO_DATE(Date, '%m/%d/%Y')) = 2 THEN "Febrero"
        ELSE "Marzo"
        END	AS mes,
	ROUND(SUM(total), 2) AS total_vendido
FROM
	supermarket_sales
GROUP BY 
	mes
ORDER BY
	mes;

