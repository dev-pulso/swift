# Commerce — base para la aplicación iOS

Aplicación de administración comercial en Swift + SwiftUI. Nombre de producto pendiente; `Luxury` identifica la referencia visual solicitada, no limita el sistema a perfumerías.

## Estado del MVP local

Implementados en código: onboarding, creación local de tienda, navegación con cinco pestañas, dashboard y gráfica, catálogo, detalle y formulario de producto con variantes, ajustes e historial de inventario, POS con carrito/descuento/impuesto/cliente/medio de pago, historial y detalle de venta, clientes con alta, ficha e historial. Design System inspirado en Monolith Noir de Luxury, con soporte de Dynamic Type y colores adaptables. Los datos demo son explícitos; una tienda nueva empieza vacía.

Se incluye `Commerce.xcodeproj`, entry point y esquema compartido, preparados para abrir en Mac. **No se ha compilado ni validado en simulador; todavía no hay una app instalable verificada.**

El 21 de octubre de 2026 se verificó el acceso mediante Stitch MCP a [Luxury Fashion E-commerce App](https://stitch.withgoogle.com/projects/16008658520773924256). Se revisaron su Design System, HTML y capturas de dashboard, inventario, ventas y clientes. La credencial ya estaba configurada fuera del repositorio; no se copió al código.

## Revisar en el Mac

1. Copiar esta carpeta al Mac y abrir `Commerce.xcodeproj` en Xcode con soporte para iOS 17 y Swift 5.9 o posterior.
2. Seleccionar esquema `Commerce` y un simulador iPhone. Para dispositivo físico, configurar Team y un bundle identifier propio en Signing & Capabilities.
3. Ejecutar. Seleccionar «Explorar demostración» para ver datos de ejemplo o completar el onboarding para crear una tienda local vacía.
4. Para pruebas del dominio, abrir `Package.swift` y ejecutar `CommerceCoreTests`, o usar `swift test --filter CommerceCoreTests` en Terminal. El esquema de la app no incorpora los tests del paquete.
5. Probar el ciclo: crear producto → registrar compra de inventario → registrar venta → verificar dashboard, stock e historial del cliente.

El paquete presenta vistas SwiftUI únicamente en iOS; los modelos, servicios y pruebas del dominio pueden revisarse en macOS. No requiere dependencias de terceros ni credenciales de backend.

No se ejecutó compilación Swift ni pruebas XCTest en Windows. Consulta [validación](docs/VALIDATION.md) para distinguir revisión estática de ejecución pendiente.

## Documentación

- [Tareas, requerimientos pendientes y continuidad del desarrollo](docs/TAREAS.md)
- [Propuesta, pantallas, MVP y V2](docs/PRODUCT.md)
- [Arquitectura y carpetas](docs/ARCHITECTURE.md)
- [Design System de Luxury y adaptación a SwiftUI](docs/DESIGN.md)
- [Verificaciones y limitaciones](docs/VALIDATION.md)
