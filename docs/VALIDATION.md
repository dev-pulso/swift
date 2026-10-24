# Validación de la primera entrega

## Ejecutado aquí

Revisión estática de dependencias, aislamiento de actor, límites entre capas, validación de scope, conservación de recibos y orden de commit. Comprobación local de estructura y archivos por herramienta Python; esto **no compila Swift**.

No hay resultados de compilación, XCTest ni simulador. Se inspeccionaron capturas y HTML de referencia en Stitch; no se han renderizado las pantallas SwiftUI. Swift/Xcode no están disponibles aquí ni son requisitos para continuar escribiendo código en Windows.

## Pruebas preparadas, pendientes de ejecutar en Mac

`CommerceRepositoryTests` incluye diez pruebas: checkout con descuento de stock y reintento idempotente, rollback del carrito por stock insuficiente, rechazo de sucursal ajena, tienda nueva vacía, SKU duplicado, persistencia JSON, serie del dashboard, descuento/impuesto Decimal, rollback por fallo de escritura y cliente de otra tienda.

## Verificar en Xcode

1. Resolver el paquete, compilar CommerceCore y CommercePresentation y ejecutar XCTest. Revisar advertencias de concurrencia con las opciones del compilador elegido.
2. Ejecutar las pruebas preparadas de persistencia fallida e impuestos. Añadir cobertura adicional de límites monetarios, desbordamiento de cantidades, archivos corruptos y múltiples checkouts concurrentes.
3. Confirmar distribución de fechas, zona horaria y comienzo de semana del comercio. Calendar es inyectable; la UI debe seleccionar una configuración coherente por tienda.
4. Al añadir SwiftUI, verificar navegación completa, cancelación y reintentos, refresco después de vender/ajustar, listas vacías, Dynamic Type y VoiceOver.
5. Verificar el adaptador persistente en Application Support y errores de escritura en dispositivo. No usar el repositorio demo para datos comerciales reales.

## Limitaciones explícitas

El código incluye pantallas y target Xcode, todavía sin compilar. Sin cuenta real, procesamiento de pagos, seguridad de servidor, CRUD completo de clientes, borrado/duplicación de producto ni imágenes empaquetadas. El alta de clientes sí está implementada. Los roles son preparatorios. La tasa de impuesto es manual en el modelo; el alta inicial usa cero y aún no ofrece edición de impuestos. Solo COP/USD y dos decimales contables. No hay descuentos promocionales ni cálculo de beneficio neto. Las imágenes demo usan placeholders locales para no depender de red.
