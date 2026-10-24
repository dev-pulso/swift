# Propuesta de producto

## Decisiones iniciales

Aplicación nativa para operar un negocio desde el iPhone. iOS 17 como base inicial; SwiftUI, NavigationStack, MVVM y async/await. Idioma español, COP y USD inicialmente. Los tipos de comercio sugieren categorías y opciones; nunca cambian la estructura del producto.

Primero validar el ciclo completo **crear tienda → producto → entrada de stock → venta → consulta de resultados**. Diseñar únicamente dashboards sin completar ese ciclo produciría un prototipo difícil de validar comercialmente.

## Mapa de pantallas propuesto

```text
Onboarding (4 páginas)
 ├─ Explorar demostración → negocio de ejemplo en memoria
 └─ Configurar mi negocio → formulario → tienda vacía
Shell principal
 ├─ Inicio → resumen → alertas → inventario / últimas ventas
 ├─ Ventas → historial → detalle
 │           └─ Nueva venta → búsqueda → variante → carrito
 │               → cliente opcional → descuento → pago → confirmación
 ├─ Productos → búsqueda → detalle → editar / archivar
 │               └─ Crear → opciones y variantes → guardar
 ├─ Clientes → búsqueda → ficha → historial de compras
 └─ Más → Inventario → filtro → ajuste con motivo → movimientos
          └─ Configuración de tienda
```

Cada pestaña tendrá su NavigationStack. Los formularios se presentan en sheet con cancelación explícita; las vistas de detalle permanecen en el stack. La selección de tienda tendrá un contexto explícito y recreará los ViewModels para no mezclar datos. El selector multi-tienda visible queda para V2.

## MVP visual y funcional local

| Área | Alcance inicial |
| --- | --- |
| Entrada | Onboarding, modo demo y configuración local de tienda |
| Inicio | Hoy, semana, mes, pedidos, ticket, margen bruto, stock bajo, agotados, serie de 7 días, últimas ventas |
| Productos | Listar, buscar por nombre/SKU, detalle, crear, editar, archivar, estado y variantes |
| Inventario | Existencias por variante, entradas/salidas, motivo e historial |
| Ventas | Carrito, selección de variante, cantidades, descuento fijo, impuesto configurado, cliente y método de pago |
| Clientes | Lista, alta local, ficha e historial calculado desde ventas |
| Configuración | Alta con nombre, tipo, moneda, ciudad y contacto; consulta en Más; una sucursal principal |

Las opciones de pago registran el medio informado por el comerciante; no procesan pagos. El impuesto es una tasa manual de demostración, sin reglas tributarias ni facturación electrónica. La ganancia es **margen bruto estimado**, no rentabilidad neta.

## V2 y siguientes

Autenticación real, sincronización/backend, CRM editable y segmentación, promociones, cupones, comprar X obtener Y, proveedores, órdenes de compra, gastos, caja, estadísticas avanzadas, empleados y permisos efectivos, selector multi-tienda, inventario multi-sucursal visible, notificaciones y código de barras.

V3 potencial: SaaS y suscripciones, catálogo público, enlaces de compra, WhatsApp, recibos/PDF e integraciones de pagos. Facturación electrónica fuera del alcance actual.

## Cuenta y confianza del usuario

No simular creación de una cuenta real ni guardar contraseñas en JSON. Mientras no exista un proveedor de identidad, el flujo debe decir «Configurar en este dispositivo» y «Explorar demostración». Una futura AuthService gestionará sesión y membresías; ningún rol local constituye autorización de servidor.
