# Scanner P&O — Arquitectura V1

## Source of truth

La arquitectura de gobierno sigue WEALTH_OS_MASTER.md:
USUARIO > JEFF > SPARK / NEWS&TRENDS / EVOLVE / ALPHA / BETA > EJECUCIÓN.

Alpha y Beta analizan la oportunidad completa de forma independiente. JEFF sintetiza los mejores puntos de ambos.

## Pipeline

STORE OPPORTUNITY SCANNER
-> PRODUCT DISCOVERY
-> PRODUCT DUE DILIGENCE
-> PRODUCT/OFFER IMPROVEMENT
-> BENCHMARK HUNTER
-> BENCHMARK INTELLIGENCE
-> ALPHA + BETA
-> JEFF SYNTHESIS
-> USER REVIEW

## Gates

- Demand gate: evita confundir invisibilidad con falta de mercado.
- Evidence gate: si confidence es insuficiente, estado MORE DATA.
- Supplier gate: producto y proveedor se puntúan por separado.
- Economics gate: si contribution base es negativa, STOP/ITERATE.
- Risk gate: riesgos críticos legales, de seguridad o IP requieren revisión.
- Execution gate: solo el Usuario autoriza gasto, compra, contrato o acción irreversible.

## Scanner groups

### Store opportunity
Store Discovery, Store Demand, Store Visibility, Opportunity Gap.

### Product discovery & validation
Product Discovery, Trend, Social, Sales/Demand, Ads, AI Visibility, Competition, Product Reviews.

### Supply & economics
Supplier, Supplier Reviews, Landed Cost, CAC Estimator, Profit Engine, Risk.

### Benchmark
Benchmark Hunter, AI Benchmark, Ads Benchmark, Social Benchmark, Offer Benchmark, Landing/SEO/Authority/Price-Value.

## Evidence contract

Cada resultado debe conservar:
- source
- source type
- observed_at
- captured_at
- fact/signal/hypothesis
- metric
- value
- confidence
- raw evidence reference
- missing data
- warnings

## Security

No almacenar API keys de proveedores dentro de la APK.
El backend recibe secretos por variables de entorno.
La APK solo conoce la URL del backend y datos de resultados.

## V1

La V1 funciona en Demo Mode sin backend y permite verificar el flujo completo y la UX.
Al conectar el backend, los mismos modelos se alimentan con evidencia real.
