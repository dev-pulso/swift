# Design System — Luxury / Monolith Noir

## Evidencia disponible

Referencia verificada el 21 de octubre de 2026: proyecto Stitch `16008658520773924256`, **Luxury Fashion E-commerce App**, Design System **Monolith Noir**. Se resolvió el acceso y se inspeccionaron metadatos, HTML y capturas de Panel de Control Principal (`477f93ab…`), Gestión de Inventario (`10c2bd4f…`), Registro de Ventas (`50bb85e0…`) y Gestión de Clientes (`fe9b443b…`).

La referencia contiene pantallas desktop rotuladas RENTALCORE, con contenido de comercio y alquiler. Se adopta su lenguaje visual, sin trasladar su terminología ni sus funciones de alquiler al producto minorista.

## Análisis visual de Luxury

Paleta de alto contraste: negro #000000, superficies blancas, canvas #F9F9F9, texto secundario #666666 y bordes #E5E5E5. Inter en pesos 400–700, titulares densos, cifras dominantes y labels en mayúsculas con tracking amplio. Ritmo de 4 px, gutters de 24 y márgenes móviles de 16 en los tokens fuente.

Cards delimitadas con borde fino; esquinas rectas y sin sombras. Los bloques negros destacan información y acciones. Tablas con separadores horizontales, buscadores discretos y formularios rectangulares. El dashboard combina cuatro métricas, gráfica de barras y transacciones recientes. Ventas presenta catálogo fotográfico y resumen del carrito; clientes usa avatares, estados y panel lateral. Las fotos se usan como contenido del catálogo, no como decoración de métricas. Iconos Material Symbols lineales en la referencia; se adaptan a SF Symbols en iOS.

Hay pequeñas discrepancias entre el Design System (radios cero) y HTML generado (algún avatar redondo y radios utilitarios). Se conserva la geometría recta de las superficies principales y se prioriza accesibilidad y comportamiento nativo.

## Adaptación implementada en SwiftUI

Las siguientes reglas adaptan la referencia al iPhone:

- Tokens semánticos `canvas`, `surface`, `ink`, `muted`, `border` y `danger` en LuxuryTheme. Valores claros extraídos de Luxury; valores oscuros propuestos para iOS, pendientes de QA visual.
- SF Pro mediante estilos de texto del sistema para Dynamic Type. Cifras financieras con dígitos monoespaciados; tipografía alternativa únicamente si la referencia lo justifica y su licencia permite distribuirla.
- Espaciado base 4/8/12/16/24/32; margen de 20 puntos, cards con 20–24 puntos interiores, bordes de 1 punto, sin radios ni sombras. Se reduce el padding desktop de 32 para aprovechar el ancho del iPhone.
- SF Symbols coherentes. Objetivos táctiles mínimos de 44 puntos; texto y símbolo para estados, no solo color. Contrast ratio mínimo 4.5:1 para texto normal.
- TabView nativa con cinco secciones; sheet para formularios; respeto de safe areas, VoiceOver, Reduce Motion y tamaños grandes de texto.
- Dashboard con importe dominante, métricas secundarias y alertas accionables. Gráfica de siete días con descripción accesible y valores consultables.
- Fotografías de producto mediante URL opcional, caché futura y placeholder local. Sin recursos remotos obligatorios en demos ni marcas inventadas como activos oficiales.

## Componentes

Implementados: LuxuryButton (primary/secondary/loading), LuxuryCard, LuxuryTextField con label, LuxurySearchBar, LuxuryMetricCard, LuxuryBadge, LuxurySectionHeader, LuxuryAvatar, LuxuryEmptyState y LuxuryError. ProductRow, ProductImage y SaleRow son componentes de feature. Los formularios usan sheet nativa; las confirmaciones de venta tienen pantalla persistente. Toast y wrapper de sheet se posponen hasta que exista un caso real que necesite abstracción.

Evitar dos componentes equivalentes para StatCard y MetricCard. Usar un único MetricCard con variantes. Mantener errores persistentes junto al campo; toast solo para confirmaciones que no exijan acción.

## Estados y auditoría visual pendiente

Todas las listas: loading, empty con siguiente paso, contenido y error con reintento. Distinguir «no hay productos» de «sin resultados para esta búsqueda». Preservar formulario al fallar un guardado. Deshabilitar confirmaciones mientras se procesa una operación.

Se revisaron dashboard, tablas, panel de cliente, formulario POS y campos de búsqueda antes de implementar. Queda validar 375/390/430 puntos, Dynamic Type, modo oscuro y VoiceOver en Xcode. No se añadieron animaciones personalizadas, para mantener la UI compatible con Reduce Motion.

Se consultó la guía ui-ux-pro-max para accesibilidad y SwiftUI. Su script `scripts/search.py` no está presente en la instalación disponible; no se generó una paleta automática.
