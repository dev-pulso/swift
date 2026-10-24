# Tareas y requerimientos de Commerce

Última actualización: **21 de octubre de 2026**.

Este documento es el registro de continuidad del desarrollo. Reúne los pendientes del documento original, las mejoras identificadas y las funciones futuras. Tener una pantalla escrita no significa que el módulo esté completo ni validado.

## Cómo utilizar este documento

- `[ ]` indica trabajo pendiente. `[x]` indica código o documentación existente; la validación en ejecución se registra por separado.
- **P0 — Validación:** necesario para confirmar que la base funciona en Mac. No bloquea continuar escribiendo código en Windows.
- **P1 — Completar MVP:** cerrar los flujos y mejorar la experiencia antes de ampliar módulos.
- **P2 — V2:** operación avanzada, backend y colaboración.
- **P3 — Futuro:** distribución comercial, SaaS y canales públicos.
- Mantener los identificadores de tareas para poder referenciarlas en conversaciones y entregas.
- Al terminar una tarea, actualizar aquí su estado, archivos relevantes, comprobaciones realizadas y limitaciones. No marcar pruebas o compilaciones como aprobadas si no se ejecutaron.

Referencias: [producto y mapa de pantallas](PRODUCT.md), [arquitectura](ARCHITECTURE.md), [Design System](DESIGN.md), [validación](VALIDATION.md) y [guía para abrir el proyecto](../README.md).

## Punto de partida confirmado

La siguiente base está escrita y revisada estáticamente; **todavía no está compilada ni probada en simulador**:

- [x] Consultar Luxury mediante Stitch MCP y analizar dashboard, inventario, ventas y clientes.
- [x] Documentar la adaptación de Monolith Noir a SwiftUI: monocromía, bordes finos, superficies rectas y sin sombras.
- [x] Crear paquete modular `CommerceCore` / `CommercePresentation`, target iOS y esquema compartido en `Commerce.xcodeproj`.
- [x] Crear modelos de negocio, sucursal, contexto de tienda, productos, variantes, clientes, ventas y movimientos; roles como preparación futura.
- [x] Implementar repositorio local mediante actor y persistencia JSON atómica; inyección de dependencias sin backend en las vistas.
- [x] Implementar navegación Inicio / Ventas / Productos / Clientes / Más, onboarding de cuatro páginas y creación local de tienda.
- [x] Implementar dashboard con ventas de hoy/semana/mes, pedidos, ticket promedio, margen bruto, clientes nuevos, gráfica de siete días, alertas, últimas ventas y productos más vendidos.
- [x] Implementar listado, búsqueda, detalle, creación y edición de productos; estados activo/inactivo/archivado y variantes básicas.
- [x] Implementar existencias por variante/sucursal, ajustes con motivo e historial de movimientos.
- [x] Implementar POS con cantidades, descuento fijo, impuesto desde el modelo, cliente opcional, medios de pago y registro de venta con actualización transaccional de stock.
- [x] Implementar alta, búsqueda, ficha e historial de compras de clientes.
- [x] Crear mocks con fechas relativas; separar demo en memoria de negocios reales locales que empiezan vacíos.
- [x] Preparar diez pruebas XCTest del dominio y una comprobación de estructura con Python.

### Límites que deben permanecer visibles

- No hay cuenta real, sesión autenticada, backend ni sincronización.
- Registrar tarjeta, Nequi u otro medio **solo guarda el medio informado**; no procesa ni verifica un pago.
- La ganancia mostrada es margen bruto estimado, no beneficio neto.
- El impuesto existe en el modelo, pero el alta inicial usa cero y todavía no hay editor de impuestos.
- Solo COP y USD; los importes usan Decimal con dos decimales contables.
- Stock, ventas y métricas operativas se consultan por sucursal. No presentar cifras de una sucursal como consolidadas de toda una cadena.
- La referencia visual ya es accesible. No quedan permisos de Stitch pendientes como bloqueo del diseño.

## Próxima secuencia de desarrollo

1. **NEG-01 a NEG-04:** completar configuración editable, país, impuestos y logo.
2. **VAR-01 a VAR-04:** reemplazar las opciones escritas manualmente por un editor visual de variantes.
3. **PRO-01 y DEM-01:** agregar imágenes y enriquecer las demostraciones para diferentes comercios.
4. **PRO-02 a PRO-05 y CLI-01 a CLI-03:** completar los campos y acciones del catálogo y CRM básico.
5. **DAS-01 a DAS-04 e INV-01 a INV-03:** hacer el dashboard y el inventario más accionables.
6. **UX-01 a UX-06:** revisar todos los estados y pulir los flujos.
7. Ejecutar **VAL-01 a VAL-07** en cuanto se disponga del Mac; corregir los fallos encontrados antes de considerar cerrado el MVP.

**Siguiente tarea recomendada: NEG-01.** El próximo desarrollo puede comenzar por configuración de tienda sin esperar Swift o Xcode en este equipo.

## P1 — Completar el MVP

### Negocio, onboarding y personalización

- [ ] **NEG-01 — Editar configuración:** permitir cambiar nombre, tipo, ciudad, dirección, teléfono y email después del alta; persistir y refrescar las vistas. Actualmente Más muestra información, pero no la edita.
- [ ] **NEG-02 — País seleccionable:** agregar país en el alta y configuración; no fijar Colombia para todos los negocios. Conservar COP/USD como alcance inicial explícito.
- [ ] **NEG-03 — Impuestos configurables:** agregar editor de tasa y explicación de cómo se aplica; validar rango y mostrar desglose en POS. Conservar los importes históricos al cambiar la configuración. Es configuración manual, sin automatización tributaria.
- [ ] **NEG-04 — Logo:** seleccionar, reemplazar y quitar logo; guardar el recurso localmente y mostrarlo donde aporte contexto.
- [ ] **NEG-05 — Marca y contacto público:** configurar color principal, Instagram, WhatsApp y sitio web; conservar contraste y consistencia del Design System.
- [ ] **NEG-06 — Adaptación por comercio:** sugerir categorías y nombres de atributos según ropa, zapatos, perfumes, maquillaje, accesorios, joyería, bolsos, deportes, electrónica, regalos, artesanías u otro. Todas las sugerencias deben ser editables.
- [ ] **NEG-07 — Revisar onboarding:** comprobar las cuatro páginas, cancelación y reanudación del alta, recuperación de errores y diferenciación clara entre demo y uso local. Mantener la creación de cuenta real pendiente de AUT-01.

### Variantes

- [ ] **VAR-01 — Editor visual:** reemplazar `Color=Negro; Talla=M` por campos de nombre de atributo y valores; permitir agregar, editar y quitar atributos/valores del borrador sin exigir sintaxis técnica.
- [ ] **VAR-02 — Combinaciones:** generar combinaciones únicas y previsualizar cuántas variantes se crearán. Evitar duplicados y advertir antes de generar cantidades poco manejables.
- [ ] **VAR-03 — Edición individual:** gestionar SKU, código de barras, precio, costo, imagen y stock mínimo por combinación. Las existencias se modifican con movimientos de inventario.
- [ ] **VAR-04 — Cambios seguros:** permitir retirar variantes nuevas del borrador y definir desactivación de variantes existentes sin perder stock, movimientos ni ventas históricas.

Criterio de aceptación: representar ropa con color/talla, zapatos con talla/color, perfumes con contenido y maquillaje con tono/presentación usando el mismo modelo.

### Productos, categorías e imágenes

- [ ] **PRO-01 — Imágenes:** seleccionar fotos, mostrarlas en listado/detalle/POS, cambiar su orden y eliminarlas; admitir imagen por variante. Crear un servicio de imágenes intercambiable, con almacenamiento local inicial, estados de carga/error y caché apropiada.
- [ ] **PRO-02 — Campos pendientes:** permitir editar código de barras y etiquetas; preparar asociación de proveedor sin exigir implementar su módulo completo ahora. Conservar descripción, marca, categoría, costo, margen y estados existentes.
- [ ] **PRO-03 — Duplicar producto:** generar nuevos IDs y SKU pendientes o únicos; no copiar existencias, movimientos ni ventas del original.
- [ ] **PRO-04 — Eliminar producto:** definir cuándo se admite eliminación y cuándo debe ofrecerse archivo; confirmar la acción y preservar referencias históricas y existencias relevantes.
- [ ] **PRO-05 — Archivo y filtros:** filtrar por estado/categoría, consultar y restaurar archivados; diferenciar catálogo vacío de búsqueda sin resultados.
- [ ] **PRO-06 — Categorías personalizadas:** crear, renombrar y gestionar categorías por tienda; definir qué sucede con sus productos al eliminar una categoría. Actualmente la categoría es un texto libre.

### Dashboard e inteligencia local inicial

- [ ] **DAS-01 — Comparaciones:** calcular variaciones reales frente a ayer y al período anterior; resolver correctamente períodos sin ventas y bases de comparación en cero. No mostrar porcentajes decorativos.
- [ ] **DAS-02 — Stock visible:** mostrar nombres, variantes, cantidades y acceso al ajuste de productos con poco stock o agotados; actualmente existe un resumen con enlace a inventario.
- [ ] **DAS-03 — Recomendaciones accionables:** crear reglas locales para alertas de stock y tendencias; ofrecer una acción relacionada y no mostrar conclusiones sin datos suficientes.
- [ ] **DAS-04 — Períodos y ranking:** aclarar el período de cada métrica y del ranking; revisar agrupación por identificador de producto para no mezclar productos diferentes con el mismo nombre. Usar zona horaria y calendario coherentes con el negocio.
- [ ] **DAS-05 — Cumpleaños:** después de CLI-02, identificar cumpleaños próximos y preparar el acceso a futuras promociones.

### Inventario

- [ ] **INV-01 — Historial navegable:** filtrar movimientos por producto, variante, fecha y motivo; consultar el historial completo, no solo los últimos treinta movimientos.
- [ ] **INV-02 — Ajustes claros:** mejorar selección de ingreso/salida o ajuste de saldo, previsualizar saldo resultante y exigir motivo; conservar tipos venta, compra, ajuste, devolución, dañado y corrección manual.
- [ ] **INV-03 — Alertas y vacíos:** diferenciar agotado de stock bajo, dar un estado claro cuando un filtro no tiene coincidencias y enlazar alertas al producto correspondiente.

### Ventas / POS

- [ ] **VEN-01 — Carrito:** permitir quitar una línea y vaciar el carrito con interacción explícita; mejorar resumen de cantidades y subtotales. Mantener validación de disponibilidad al confirmar.
- [ ] **VEN-02 — Descuentos básicos:** agregar porcentaje además del monto fijo, validar límites y mostrar descuento aplicado. Los cupones y reglas promocionales pertenecen a DES-01/CUP-01.
- [ ] **VEN-03 — Cliente durante la venta:** facilitar búsqueda y alta de cliente desde POS sin perder el carrito.
- [ ] **VEN-04 — Historial:** buscar y filtrar por fecha, cliente y método de pago; mejorar detalle con cliente y vendedor legibles. El vendedor local actual no es una identidad autenticada.
- [ ] **VEN-05 — Errores y reintentos:** preservar el carrito al fallar, ofrecer recuperación frente a cambios de precio/stock y evitar ventas duplicadas. Revisar el ID de reintento cuando cambien los datos de la operación.
- [ ] **VEN-06 — Reglas de importes:** documentar y verificar redondeo, orden descuento/impuesto y precio con/sin impuesto; mostrar moneda de forma inequívoca.

Criterio de aceptación: completar una venta con efectivo, tarjeta, transferencia, Nequi, Daviplata u otro medio; actualizar stock, movimiento, historial del cliente y dashboard después de un único guardado correcto.

### Clientes / CRM básico

- [ ] **CLI-01 — Editar perfil:** modificar nombre, teléfono, email, dirección y notas sin alterar su historial de compras.
- [ ] **CLI-02 — Cumpleaños:** agregar fecha de cumpleaños en alta/edición, permitir quitarla y preparar su consulta para alertas.
- [ ] **CLI-03 — Etiquetas:** crear y editar etiquetas por cliente, incluida VIP; no limitar la interfaz a etiquetas presentes en los mocks.
- [ ] **CLI-04 — Métricas y búsqueda:** revisar total gastado, número de compras, última compra y fecha de alta; ampliar búsqueda por teléfono y aclarar el alcance por sucursal de los importes.

### Design System, estados y experiencia

- [ ] **UX-01 — Auditoría de estados:** comprobar loading, empty, success y error/reintento en cada pantalla; distinguir falta de datos de ausencia de coincidencias.
- [ ] **UX-02 — Formularios:** mostrar errores cerca del campo, preservar entradas ante fallos y revisar teclado, foco y cierre del teclado; impedir guardados duplicados y pérdida accidental de cambios.
- [ ] **UX-03 — Consistencia Luxury:** revisar tipografía, jerarquías, bordes, espaciado y botones frente a Stitch. Mantener adaptación nativa, sin copiar la navegación desktop ni contenido de alquiler.
- [ ] **UX-04 — Accesibilidad:** verificar VoiceOver, Dynamic Type, objetivos táctiles, contraste, modo oscuro, Reduce Motion y alternativas accesibles de gráficas.
- [ ] **UX-05 — Navegación y refresco:** comprobar regreso desde detalles, presentación/cierre de sheets, conservación de contexto y actualización de todas las pestañas tras una mutación.
- [ ] **UX-06 — Componentes:** extraer filas de producto/cliente y formularios repetidos cuando lo justifique el uso; evaluar toast y bottom sheet propios solo si la sheet y las confirmaciones nativas no resuelven el caso.

### Datos de demostración

- [ ] **DEM-01 — Demo visual:** empaquetar fotografías adecuadas y datos de ejemplo para distintas categorías; no depender únicamente de placeholders o perfumería.
- [ ] **DEM-02 — Escenarios:** incluir producto sin variantes visibles, varias opciones, stock normal/bajo/agotado, archivados, clientes nuevos/VIP/inactivos y ventas con diferentes métodos y descuentos.
- [ ] **DEM-03 — Coherencia:** mantener existencias e historial conciliados, fechas relativas y separación estricta de demo/datos del usuario; revisar también los estados vacíos de una tienda nueva.

## P0 — Validación en Mac y preparación técnica

- [ ] **VAL-01 — Compilación real:** abrir `Commerce.xcodeproj`, resolver el paquete, compilar y corregir diagnósticos; revisar SwiftUI, aislamiento de actor y concurrencia con el compilador elegido.
- [ ] **VAL-02 — XCTest:** ejecutar las diez pruebas preparadas desde el paquete; registrar resultado real y corregir fallos.
- [ ] **VAL-03 — Ciclo completo:** probar onboarding → tienda → producto con variantes → ingreso de stock → cliente → venta → stock/dashboard/historial.
- [ ] **VAL-04 — Persistencia:** cerrar y reabrir la app, comprobar conservación de datos, recuperación de errores y separación de demo; probar falta de acceso/escritura y archivo corrupto.
- [ ] **VAL-05 — QA visual:** revisar iPhone de 375/390/430 puntos, teclado, safe areas, texto grande, claro/oscuro y VoiceOver. Las capturas de Stitch no sustituyen este paso.
- [ ] **VAL-06 — Cobertura de dominio:** ampliar pruebas de concurrencia de checkouts, cantidades extremas, redondeo, descuentos inválidos, identificación de variantes y aislamiento entre tiendas/sucursales.
- [ ] **VAL-07 — Proyecto iOS:** verificar esquema compartido y referencias del paquete, configurar firma para dispositivo, bundle identifier propio, icono, launch screen y textos de permisos cuando se agregue acceso a fotos/cámara.
- [ ] **TEC-01 — Versionado local:** versionar el archivo persistido y diseñar migraciones antes de publicar cambios de esquema; no sobrescribir silenciosamente datos corruptos.
- [ ] **TEC-02 — Protección y recuperación:** definir protección de datos del dispositivo, exportación/copia de seguridad y restauración antes de uso comercial con información real.
- [ ] **TEC-03 — Límites de JSON:** evaluar almacenamiento local más adecuado cuando aumente el historial; conservar atomicidad y un único repositorio por archivo mientras se use JSON.
- [ ] **TEC-04 — Mantenimiento:** revisar ViewModels que se solapan, lógica repetida, nombres, strings de presentación y organización; actualizar arquitectura/documentación conforme cambie la implementación.

## P2 — V2: operación avanzada y backend

### Cuenta, servicios remotos y acceso

- [ ] **AUT-01 — Cuenta real:** definir proveedor e implementar registro, inicio/cierre de sesión, recuperación y sesión persistente mediante un contrato de autenticación. No simular una cuenta real con credenciales guardadas en JSON.
- [ ] **AUT-02 — Backend:** elegir Supabase, Firebase o API propia e implementar adaptadores de repositorio; migrar/importar datos locales y definir sincronización, modo sin conexión, conflictos y reintentos.
- [ ] **AUT-03 — Seguridad de acceso:** validar pertenencia y permisos en servidor por usuario/negocio/sucursal; no confiar únicamente en IDs enviados por el cliente.
- [ ] **AUT-04 — Servicios externos:** preparar adaptadores para almacenamiento de imágenes como Cloudinary y procesamiento de pagos como Stripe cuando se implementen; mantener las Views independientes de sus SDK.

### Descuentos, cupones y ofertas

- [ ] **DES-01 — Descuentos:** porcentaje y monto fijo con reglas por producto, categoría o cliente VIP; fecha de inicio/finalización y estado.
- [ ] **DES-02 — Comprar X obtener Y:** definir unidades elegibles, combinaciones, límites y compatibilidad con otros descuentos; ejemplos como compra 2 y lleva 3.
- [ ] **CUP-01 — Cupones:** crear códigos, porcentaje/monto, compra mínima, expiración y máximo de usos; validar y contar usos de forma consistente al confirmar ventas.
- [ ] **OFE-01 — Ofertas visuales:** gestionar nombre, banner, productos incluidos, vigencia y estado; ejemplo de promoción por categoría durante un fin de semana.

### Proveedores y compras

- [ ] **PRV-01 — Proveedores:** gestionar empresa, contacto, teléfono, email y productos asociados.
- [ ] **OC-01 — Órdenes de compra:** registrar proveedor, productos, cantidades y costos; gestionar estado de recepción y actualizar inventario al recibir sin duplicar ingresos por reintentos.

### Caja, gastos y rentabilidad

- [ ] **CAJ-01 — Caja:** apertura/cierre, base inicial, entradas/salidas, ventas del turno y efectivo esperado; distinguir efectivo de otros medios de pago.
- [ ] **GAS-01 — Gastos:** registrar y categorizar arriendo, transporte, empaques, publicidad, nómina, servicios, compras y otras salidas.
- [ ] **REN-01 — Rentabilidad:** incorporar gastos al resultado; definir período y evitar contar compras de inventario dos veces como costo y gasto. Diferenciar margen bruto de beneficio neto.

### Analítica e inteligencia de negocio

- [ ] **ANA-01 — Estadísticas:** ventas por día/semana/mes, productos y categorías más vendidos, horas de mayor venta, medios de pago, ticket promedio, recurrencia de clientes y margen.
- [ ] **INT-01 — Reglas locales avanzadas:** estimar días de inventario, patrones por día de semana, clientes que no compran hace cierto tiempo y cambios frente al período anterior; exponer fundamento y acción útil.
- [ ] **INT-02 — IA futura:** evaluar recomendaciones mediante IA después de contar con datos suficientes y controles de acceso; no es requisito del MVP.

### Clientes, tiendas, sucursales y equipo

- [ ] **SEG-01 — Segmentación:** definir y filtrar clientes nuevos, frecuentes, mejores, inactivos y VIP; documentar umbrales y preparar selección para campañas.
- [ ] **MTI-01 — Multi-tienda:** asociar negocios a una cuenta, crear/seleccionar negocio y cambiar contexto sin mezclar productos, inventario, ventas, clientes, configuración ni métricas.
- [ ] **SUC-01 — Sucursales:** gestionar ubicaciones físicas/online, elegir sucursal y consultar stock separado; definir transferencias y reportes consolidados como ampliaciones explícitas.
- [ ] **EMP-01 — Empleados y roles:** invitar/gestionar usuarios e implementar Owner, Manager, Seller e Inventory Manager; establecer matriz de permisos y enforcement remoto.
- [ ] **EMP-02 — Permisos personalizados:** agregar permisos configurables después de validar los roles iniciales.

### Notificaciones y captura

- [ ] **NOT-01 — Notificaciones:** stock bajo/agotado, nueva venta, meta alcanzada, cumpleaños próximo y oferta por finalizar; definir preferencias, permisos y deduplicación.
- [ ] **ESC-01 — Escáner:** leer código de barras con cámara, solicitar permiso cuando se necesite y resolver códigos desconocidos o duplicados; conservar búsqueda manual.

## P3 — Evolución comercial

- [ ] **WEB-01 — Tienda pública:** catálogo por negocio, productos, carrito, compra/pedido y URL propia; aislar datos privados del panel de gestión.
- [ ] **WEB-02 — Enlaces de producto:** compartir nombre, precio e imagen con enlace directo de producto/compra por WhatsApp u otros canales.
- [ ] **WEB-03 — Catálogo para WhatsApp:** generar un catálogo visual de productos para compartir.
- [ ] **FAC-01 — Documentos comerciales:** recibos, facturas internas, exportación PDF e impresión; distinguirlos de facturación electrónica.
- [ ] **SAA-01 — Planes y límites:** modelar FREE (una tienda, productos limitados, funciones básicas), PRO (productos ilimitados, estadísticas, clientes, descuentos, proveedores) y BUSINESS (varias tiendas, empleados, roles, sucursales y estadísticas avanzadas).
- [ ] **SAA-02 — Suscripciones:** implementar pagos y derechos de acceso por plan después de definir el modelo comercial; evitar condiciones de plan dispersas en las vistas.
- [ ] **PUB-01 — Preparación comercial:** nombre definitivo, identidad, iconos/recursos, privacidad, distribución beta y preparación de publicación después de validar el producto.

**Fuera de alcance actual:** facturación electrónica. El documento original pide no implementarla todavía; su eventual incorporación requiere una decisión de alcance independiente.

## Decisiones que hay que conservar

- Swift + SwiftUI, MVVM, NavigationStack y async/await; interfaces/protocolos para servicios, repositorios donde aporten e inyección sencilla.
- Negocio generalista, con variantes flexibles; Luxury es la referencia visual, no una restricción a moda o perfumería.
- No escribir toda la aplicación en un archivo ni añadir módulos vacíos para aparentar funcionalidad.
- Conservar stock en una única fuente de verdad y registrar sus movimientos.
- Mantener importes Decimal y recibos con snapshots históricos de precios y costos.
- Mantener atomicidad de venta/stock/movimientos, idempotencia y aislamiento por tienda/sucursal al conectar un backend.
- Revisar la referencia de Stitch pertinente antes de implementar o rediseñar cada funcionalidad.
- No detener desarrollo por ausencia de Swift/Xcode en Windows; indicar qué se revisó estáticamente y qué falta ejecutar en Mac.
- No guardar API keys, contraseñas ni otras credenciales en código, documentación, mocks o recursos del proyecto.

## Criterio de cierre del MVP

Cerrar las tareas P1 acordadas o documentar expresamente cualquier cambio de alcance; ejecutar las validaciones P0; demostrar el ciclo comercial completo con persistencia correcta; revisar calidad visual y accesibilidad; mantener actualizados README, arquitectura y limitaciones. No considerar terminado el MVP solo por existir las pantallas.

## Registro de continuidad

| Fecha | Trabajo y resultado | Próximo paso |
| --- | --- | --- |
| 2026-10-21 | Base local y pantallas escritas; referencia Luxury revisada; diez XCTest preparados. Comprobación de estructura aprobada; compilación, pruebas y simulador pendientes. | Completar configuración de tienda (NEG-01). |
| 2026-10-21 | Creado este registro de tareas con faltantes del MVP, V2, futuro y criterios de validación. | Actualizar tareas y evidencia al terminar cada entrega. |

Para retomar: leer este documento y las decisiones de arquitectura, elegir el siguiente identificador pendiente y comprobar su implementación actual antes de modificarla. Registrar aquí lo que se terminó y lo que queda; actualizar la secuencia recomendada si cambia la prioridad.
