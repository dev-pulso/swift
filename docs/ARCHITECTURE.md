# Arquitectura inicial

## Capas

`SwiftUI View → @MainActor ViewModel → CommerceRepository → LocalCommerceRepository actor → JSON`

Las Views no conocen rutas de archivo ni SDK de backend. AppDependencies construye los servicios; no es un singleton. CommerceCore no importa SwiftUI ni Combine. CommercePresentation usa ObservableObject para las primeras pantallas. Una futura implementación remota sustituye el repositorio inyectado.

El repositorio agrupa inicialmente el agregado comercial porque una venta necesita confirmar stock, líneas y movimiento en la misma transacción. Separar servicios que escriban cada entidad de manera independiente rompería esa garantía. Dividir protocolos por feature cuando los consumidores reales lo requieran.

## Modelos principales

| Modelo | Responsabilidad |
| --- | --- |
| Business, BusinessKind | Configuración comercial, moneda, contacto y tasa manual |
| Branch, StoreScope | Separación de tienda/sucursal explícita en las operaciones |
| Membership, MemberRole | Base de roles futura; sin autenticación ni enforcement de permisos |
| Product, ProductVariant, VariantOption | Catálogo, SKU, opciones arbitrarias, precio y costo |
| StockLevel | Cantidad de una variante en una sucursal |
| InventoryMovement | Delta, saldo resultante, motivo, fecha y referencia a venta |
| Customer | Perfil y etiquetas; compras y gasto derivados de las ventas |
| CheckoutRequest, CartItem | Intención de venta e ID de reintento |
| Sale, SaleLine | Recibo inmutable con snapshot de precio, costo y descripción |
| DashboardSummary, DailyRevenue | Métricas calculadas, sin números decorativos hardcodeados |

## Invariantes

- Toda consulta comercial exige tienda y sucursal válidas.
- El catálogo es de tienda; stock y ventas son de sucursal. Clientes son de tienda.
- Incluso un producto simple tiene una variante; no existe stock duplicado en Product.
- SKU único por tienda, ignorando mayúsculas y espacios externos. IDs de variante globalmente únicos.
- No se eliminan variantes ya guardadas; archivar el producto conserva historial.
- Stock no negativo y cantidades enteras positivas al vender. Carrito vacío inválido.
- Checkout agrupa líneas repetidas y valida precio/estado desde el catálogo, nunca desde la pantalla.
- La operación local hace copia, valida todas las líneas, escribe de forma atómica y publica el estado solo si el guardado termina.
- Un mismo checkout ID devuelve su venta previa en el mismo scope; el llamador debe conservar el ID durante reintentos. Cambiar el carrito exige ID nuevo.
- Importes Decimal con dos decimales; descuento fijo limitado al subtotal; impuesto posterior al descuento. No convertir dinero a Double para cálculos.

## Carpetas actuales y próximas

```text
Package.swift
Sources/
  CommerceCore/
    Models/           Business, Product, Inventory, Customer, Sale
    Repositories/     Protocolos, snapshot y actor local
    Services/         DashboardCalculator
    Mocks/            DemoData
    Utilities/        Money
  CommercePresentation/
    App/              AppDependencies
    Core/             LoadState
    Features/
      Home/           DashboardViewModel
      Products/       ProductsViewModel
Tests/CommerceCoreTests/
docs/
```

Agregados después de analizar Luxury: `CommercePresentation/DesignSystem`, `Features/Onboarding`, `StoreSetup`, `Inventory`, `Sales` y `Customers`. `AppSession` abre el repositorio local o una demo efímera; `StoreViewModel` comparte un snapshot de lectura y refresca las pestañas después de mutaciones. Los editores y checkout tienen ViewModels propios. `App/CommerceApp.swift` es el entry point del target en `Commerce.xcodeproj`. La consulta de configuración está dentro de Más; la edición avanzada queda pendiente.

## Persistencia y evolución

JSON local es adecuado para el prototipo, no para un historial comercial grande o varios procesos escribiendo al mismo archivo. El actor serializa un único repositorio por archivo; AppDependencies debe compartirse durante toda la sesión. Añadir versionado/migraciones antes de distribuir actualizaciones con cambios de esquema. Si un archivo está corrupto se propaga el error y se preserva el archivo.

Los mocks son opt-in y solo usan direcciones example.com. No se guardan secretos. Antes de producción: autenticación, autorización remota por tenant, protección de datos del dispositivo, backups, migraciones y transacciones del servidor. En Supabase/Firebase/API, la seguridad no puede depender de StoreScope enviado por el cliente.
