# Scanner P&O

Scanner P&O es la APK de descubrimiento y evaluación de oportunidades comerciales de Wealth OS.

## Flujo

1. Detectar tiendas con demanda alta y visibilidad relativamente baja.
2. Identificar los productos que explican la oportunidad.
3. Ejecutar scanners de tendencia, social, ventas, anuncios, IA, reviews, competencia, proveedores, landed cost, CAC, rentabilidad y riesgo.
4. Mejorar producto/oferta usando reviews y evidencia.
5. Buscar benchmarks líderes por IA, anuncios, social, oferta, landing, SEO, autoridad y precio/valor.
6. Enviar el expediente completo a Team Alpha y Team Beta para análisis independiente.
7. JEFF sintetiza los mejores puntos de ambos equipos.
8. Solo el Usuario puede aprobar ejecución real.

## Arquitectura

- Flutter APK: interfaz, pipeline, resultados y Opportunity Cards.
- Backend seguro: Python/FastAPI.
- API keys: solo en backend mediante variables de entorno.
- Evidence ledger: cada score conserva fuente, fecha, tipo de evidencia y confianza.
- Modo demo: permite usar la APK sin backend mientras se conectan fuentes reales.

## Principios

- Demanda no equivale a rentabilidad.
- Viralidad no equivale a demanda pagadora.
- Estimación no equivale a hecho.
- API visibility no equivale necesariamente a la experiencia exacta del consumidor.
- Ningún scanner ejecuta compras, pagos, contratos ni acciones irreversibles.
- Datos faltantes se muestran como DATO FALTANTE.

## Build Android

El workflow de GitHub Actions genera un APK release y lo publica como artifact llamado Scanner-P-O-APK.

## Estado

V1 Foundation: interfaz completa, pipeline, catálogo de scanners, Opportunity Cards, modo demo, conexión backend y contrato de backend.
