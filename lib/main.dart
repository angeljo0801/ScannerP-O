import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const ScannerPOApp());
}

class ScannerPOApp extends StatelessWidget {
  const ScannerPOApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF7C4DFF);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scanner P&O',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF090D18),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Color(0xFF121827),
          margin: EdgeInsets.zero,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF0E1421),
          indicatorColor: Color(0xFF34255E),
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  bool demoMode = true;
  String backendUrl = 'https://your-backend.example.com';
  bool checkingBackend = false;
  String backendStatus = 'No comprobado';

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomeScreen(onOpenPipeline: () => setState(() => index = 1)),
      const PipelineScreen(),
      const ScannersScreen(),
      const OpportunitiesScreen(),
      SettingsScreen(
        demoMode: demoMode,
        backendUrl: backendUrl,
        backendStatus: backendStatus,
        checkingBackend: checkingBackend,
        onDemoModeChanged: (value) => setState(() => demoMode = value),
        onBackendUrlChanged: (value) => backendUrl = value,
        onCheckBackend: _checkBackend,
      ),
    ];
  }

  void _rebuildSettingsPage() {
    pages[4] = SettingsScreen(
      demoMode: demoMode,
      backendUrl: backendUrl,
      backendStatus: backendStatus,
      checkingBackend: checkingBackend,
      onDemoModeChanged: (value) {
        setState(() {
          demoMode = value;
          _rebuildSettingsPage();
        });
      },
      onBackendUrlChanged: (value) => backendUrl = value,
      onCheckBackend: _checkBackend,
    );
  }

  Future<void> _checkBackend() async {
    setState(() {
      checkingBackend = true;
      backendStatus = 'Comprobando...';
      _rebuildSettingsPage();
    });

    final status = await BackendProbe.check(backendUrl);

    if (!mounted) return;
    setState(() {
      checkingBackend = false;
      backendStatus = status;
      _rebuildSettingsPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    _rebuildSettingsPage();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF00BCD4)],
                ),
              ),
              child: const Icon(Icons.radar, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Scanner P&O',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Chip(
              avatar: Icon(
                demoMode ? Icons.science_outlined : Icons.cloud_outlined,
                size: 16,
              ),
              label: Text(demoMode ? 'DEMO' : 'LIVE'),
            ),
          ),
        ],
      ),
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree_outlined),
            selectedIcon: Icon(Icons.account_tree),
            label: 'Flujo',
          ),
          NavigationDestination(
            icon: Icon(Icons.radar_outlined),
            selectedIcon: Icon(Icons.radar),
            label: 'Scanners',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: 'Oportunidades',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

class BackendProbe {
  static Future<String> check(String baseUrl) async {
    if (baseUrl.trim().isEmpty) return 'DATO FALTANTE: URL del backend';
    HttpClient? client;
    try {
      final uri = Uri.parse(baseUrl.replaceAll(RegExp(r'/$'), '') + '/health');
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      final body = await utf8.decodeStream(response);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['ok'] == true) {
          return 'Conectado · backend saludable';
        }
        return 'Conectado · respuesta inesperada';
      }
      return 'Error HTTP ' + response.statusCode.toString();
    } catch (error) {
      return 'Sin conexión: ' + error.runtimeType.toString();
    } finally {
      client?.close(force: true);
    }
  }
}

enum ScannerState { ready, planned, blocked, running }

class ScannerModule {
  final String name;
  final String group;
  final String purpose;
  final String input;
  final String output;
  final String gate;
  final ScannerState state;

  const ScannerModule({
    required this.name,
    required this.group,
    required this.purpose,
    required this.input,
    required this.output,
    required this.gate,
    this.state = ScannerState.ready,
  });
}

class Opportunity {
  final String id;
  final String title;
  final String origin;
  final int opportunity;
  final int confidence;
  final int demand;
  final int visibilityGap;
  final int supplier;
  final int economics;
  final int risk;
  final String state;
  final List<String> missing;
  final String alpha;
  final String beta;
  final String jeff;

  const Opportunity({
    required this.id,
    required this.title,
    required this.origin,
    required this.opportunity,
    required this.confidence,
    required this.demand,
    required this.visibilityGap,
    required this.supplier,
    required this.economics,
    required this.risk,
    required this.state,
    required this.missing,
    required this.alpha,
    required this.beta,
    required this.jeff,
  });
}

class DemoData {
  static const scanners = <ScannerModule>[
    ScannerModule(
      name: 'Store Discovery',
      group: '1 · Tienda',
      purpose: 'Encuentra tiendas activas que merecen análisis.',
      input: 'Categoría, mercado, fuentes públicas y comercio.',
      output: 'Lista de tiendas + evidencia de actividad.',
      gate: 'ACTIVE BUSINESS CHECK',
    ),
    ScannerModule(
      name: 'Store Demand',
      group: '1 · Tienda',
      purpose: 'Mide señales de demanda antes de interpretar baja visibilidad.',
      input: 'Búsquedas, reviews, marketplaces, ads y señales sociales.',
      output: 'Demand Score 0–100 + confidence.',
      gate: 'Demanda mínima configurable.',
    ),
    ScannerModule(
      name: 'Store Visibility',
      group: '1 · Tienda',
      purpose: 'Compara visibilidad en IA, búsqueda, social y autoridad.',
      input: 'Marca, dominio, prompts y competidores.',
      output: 'Visibility Score + Share of Voice.',
      gate: 'No confundir una sola ausencia con invisibilidad.',
    ),
    ScannerModule(
      name: 'Opportunity Gap',
      group: '1 · Tienda',
      purpose: 'Detecta demanda fuerte con visibilidad relativamente baja.',
      input: 'Demand Score + Visibility Score.',
      output: 'Store Opportunity Gap.',
      gate: 'Demanda alta + gap suficiente.',
    ),
    ScannerModule(
      name: 'Product Discovery',
      group: '2 · Producto',
      purpose: 'Identifica qué productos explican la oportunidad de la tienda.',
      input: 'Catálogo, precios, señales de producto.',
      output: 'Top productos candidatos.',
      gate: 'Solo los mejores pasan al due diligence profundo.',
    ),
    ScannerModule(
      name: 'Trend Scanner',
      group: '2 · Producto',
      purpose: 'Mide crecimiento, aceleración y estacionalidad.',
      input: 'Series de búsqueda y keywords.',
      output: 'Trend Score + trayectoria.',
      gate: 'Tendencia no equivale a rentabilidad.',
    ),
    ScannerModule(
      name: 'Social Scanner',
      group: '2 · Producto',
      purpose: 'Mide momentum sostenible en redes.',
      input: 'TikTok, YouTube, Instagram, Reddit y menciones.',
      output: 'Social Momentum + viralidad vs persistencia.',
      gate: 'Viralidad aislada es solo señal.',
    ),
    ScannerModule(
      name: 'Sales / Demand',
      group: '2 · Producto',
      purpose: 'Busca evidencia más cercana a ventas reales.',
      input: 'Rank, reviews, stock, precio y marketplaces.',
      output: 'Demand Evidence Score.',
      gate: 'Cruzar con al menos otra señal.',
    ),
    ScannerModule(
      name: 'Ad Scanner',
      group: '2 · Producto',
      purpose: 'Analiza persistencia, creativos, hooks y ofertas publicitarias.',
      input: 'Bibliotecas de anuncios y creativos.',
      output: 'Ad Validation Score.',
      gate: 'Anuncio activo no equivale a ROAS positivo.',
    ),
    ScannerModule(
      name: 'AI Visibility',
      group: '2 · Producto',
      purpose: 'Mide menciones, recomendaciones, posiciones y citas.',
      input: 'Prompts de intención de compra en varios motores.',
      output: 'Mention, Top-3, Citation y Share of Voice.',
      gate: 'API Scan y Consumer Check se guardan separados.',
    ),
    ScannerModule(
      name: 'Competition',
      group: '2 · Producto',
      purpose: 'Mide saturación y estructura competitiva.',
      input: 'Competidores, precios, posicionamiento y canales.',
      output: 'Competition Score + mapa de rivales.',
      gate: 'Competencia alta no es rechazo automático.',
    ),
    ScannerModule(
      name: 'Product Reviews',
      group: '2 · Producto',
      purpose: 'Convierte reviews en requisitos de mejora.',
      input: 'Reviews del producto y equivalentes.',
      output: 'Feature Love, Complaint y Defect signals.',
      gate: 'Reviews reducen incertidumbre, no reemplazan toda prueba física.',
    ),
    ScannerModule(
      name: 'Supplier Scanner',
      group: '3 · Proveedor/Economics',
      purpose: 'Compara precio, MOQ, historial, certificaciones y capacidades.',
      input: 'Proveedores candidatos.',
      output: 'Supplier Confidence.',
      gate: 'Producto y proveedor se puntúan por separado.',
    ),
    ScannerModule(
      name: 'Supplier Reviews',
      group: '3 · Proveedor/Economics',
      purpose: 'Analiza calidad, retrasos, defectos y comunicación.',
      input: 'Reviews e historial observable del proveedor.',
      output: 'Supplier Review Score + red flags.',
      gate: 'Red flags críticos bloquean el proveedor.',
    ),
    ScannerModule(
      name: 'Landed Cost',
      group: '3 · Proveedor/Economics',
      purpose: 'Estima coste real puesto en destino.',
      input: 'Producto, freight, duty, packaging, inbound e inspección.',
      output: 'Low / Base / High landed cost.',
      gate: 'HTS ambiguo = REVIEW REQUIRED.',
    ),
    ScannerModule(
      name: 'CAC Estimator',
      group: '3 · Proveedor/Economics',
      purpose: 'Estima adquisición antes de tener campañas propias.',
      input: 'CPC/CPM, CTR, CVR, benchmarks y categoría.',
      output: 'CAC Optimistic / Base / Conservative.',
      gate: 'Se etiqueta siempre como estimación.',
    ),
    ScannerModule(
      name: 'Profit Engine',
      group: '3 · Proveedor/Economics',
      purpose: 'Calcula contribution margin y break-even CAC/ROAS.',
      input: 'Precio, costes variables, devoluciones y CAC.',
      output: 'Unit economics y escenarios.',
      gate: 'Base contribution negativa = STOP/ITERATE.',
    ),
    ScannerModule(
      name: 'Risk Scanner',
      group: '3 · Proveedor/Economics',
      purpose: 'Detecta IP, seguridad, regulación, dependencia y downside.',
      input: 'Producto, proveedor, mercado y modelo.',
      output: 'Risk Score + riesgos críticos.',
      gate: 'Riesgo crítico requiere revisión.',
    ),
    ScannerModule(
      name: 'Benchmark Hunter',
      group: '4 · Benchmark',
      purpose: 'Busca quién hace mejor cada parte de la comercialización.',
      input: 'Producto final + categoría + intención.',
      output: 'Líderes por IA, ads, social, oferta, landing, SEO y valor.',
      gate: 'Benchmark significa aprender, no copiar identidad.',
    ),
    ScannerModule(
      name: 'Benchmark Intelligence',
      group: '4 · Benchmark',
      purpose: 'Extrae patrones ganadores y gaps que siguen abiertos.',
      input: 'Benchmarks por función.',
      output: 'Challenger Blueprint.',
      gate: 'Patrones verificables, no clonación de activos protegidos.',
    ),
    ScannerModule(
      name: 'Alpha Analysis',
      group: '5 · Wealth OS',
      purpose: 'Team Alpha analiza la oportunidad completa de forma independiente.',
      input: 'Expediente completo.',
      output: 'Análisis Alpha.',
      gate: 'No aprueba ejecución.',
    ),
    ScannerModule(
      name: 'Beta Analysis',
      group: '5 · Wealth OS',
      purpose: 'Team Beta analiza la misma oportunidad completa independientemente.',
      input: 'Expediente completo.',
      output: 'Análisis Beta.',
      gate: 'No aprueba ejecución.',
    ),
    ScannerModule(
      name: 'JEFF Synthesis',
      group: '5 · Wealth OS',
      purpose: 'Combina los mejores puntos de Alpha y Beta con evidencia.',
      input: 'Alpha + Beta + expediente.',
      output: 'JEFF Decision Memo.',
      gate: 'Solo PRESENTAR / DEVOLVER / RECHAZAR.',
    ),
    ScannerModule(
      name: 'User Review',
      group: '5 · Wealth OS',
      purpose: 'Reserva la autoridad final al Usuario.',
      input: 'JEFF Decision Memo.',
      output: 'APPROVED / REJECTED / ITERATE.',
      gate: 'Sin aprobación no hay ejecución.',
    ),
  ];

  static const opportunities = <Opportunity>[
    Opportunity(
      id: 'DEMO-001',
      title: 'Bluetooth sleep mask challenger',
      origin: 'Store gap → product discovery',
      opportunity: 87,
      confidence: 81,
      demand: 84,
      visibilityGap: 79,
      supplier: 89,
      economics: 78,
      risk: 61,
      state: 'ANALYZING',
      missing: [
        'Live multi-engine consumer check',
        'Final landed-cost quote',
        'Real CAC test',
      ],
      alpha:
          'La oportunidad parece asimétrica si el landed base se mantiene dentro del rango esperado. El CAC real sigue siendo el dato que más puede invalidar el caso.',
      beta:
          'El producto permite una oferta enfocada en side sleepers, bundles y posicionamiento por intención. Si funciona, puede expandirse a una línea de sleep accessories.',
      jeff:
          'Conservar el upside identificado por Beta y los gates de capital de Alpha. Siguiente paso: confirmar proveedores y benchmarks antes de presentar experimento al Usuario.',
    ),
    Opportunity(
      id: 'DEMO-002',
      title: 'Pet enrichment bundle',
      origin: 'High demand / low visibility store',
      opportunity: 82,
      confidence: 75,
      demand: 88,
      visibilityGap: 83,
      supplier: 91,
      economics: 66,
      risk: 48,
      state: 'MORE_DATA',
      missing: [
        'Bundle landed cost',
        'Category CAC range',
        'Benchmark offer scan',
      ],
      alpha:
          'Producto simple y reversible, pero muy comoditizado. Sin diferenciación suficiente el margen podría desaparecer en adquisición.',
      beta:
          'El bundle y el contenido de enrichment pueden elevar AOV y reducir comparación directa por precio.',
      jeff:
          'Mantener en watchlist hasta cerrar CAC y benchmark offer. No ejecutar aún.',
    ),
    Opportunity(
      id: 'DEMO-003',
      title: 'Driver essentials kit',
      origin: 'Store execution gap',
      opportunity: 80,
      confidence: 72,
      demand: 77,
      visibilityGap: 74,
      supplier: 86,
      economics: 79,
      risk: 44,
      state: 'BENCHMARKING',
      missing: [
        'Bundle fitment assumptions',
        'Ad persistence sample',
      ],
      alpha:
          'La ventaja depende de mantener devoluciones y compatibilidad bajo control. El producto individual es demasiado competitivo.',
      beta:
          'El kit permite elevar AOV y crear una marca de organización del vehículo en lugar de competir por un solo accesorio.',
      jeff:
          'Profundizar en benchmark de oferta y compatibilidad antes de cualquier experimento.',
    ),
  ];
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenPipeline;

  const HomeScreen({super.key, required this.onOpenPipeline});

  @override
  Widget build(BuildContext context) {
    final top = DemoData.opportunities.first;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Opportunity Intelligence',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Detectar → validar → mejorar → aprender de benchmarks → Alpha/Beta → JEFF → Usuario',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = width > 700 ? (width - 24) / 3 : width;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: const SummaryCard(
                    label: 'Scanners',
                    value: '24',
                    sub: '5 grupos',
                    icon: Icons.radar,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: const SummaryCard(
                    label: 'Oportunidades',
                    value: '3',
                    sub: 'demo foundation',
                    icon: Icons.lightbulb,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: const SummaryCard(
                    label: 'Ejecución',
                    value: '0',
                    sub: 'requiere aprobación',
                    icon: Icons.verified_user_outlined,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        SectionHeader(
          title: 'Mejor oportunidad demo',
          trailing: TextButton.icon(
            onPressed: onOpenPipeline,
            icon: const Icon(Icons.account_tree_outlined),
            label: const Text('Ver flujo'),
          ),
        ),
        const SizedBox(height: 10),
        OpportunityCard(opportunity: top),
        const SizedBox(height: 18),
        const SectionHeader(title: 'Reglas no negociables'),
        const SizedBox(height: 10),
        const GuardrailCard(
          icon: Icons.fact_check_outlined,
          title: 'Evidencia auditable',
          body:
              'Cada score debe conservar fuente, fecha, tipo de evidencia, confianza, warnings y DATO FALTANTE.',
        ),
        const SizedBox(height: 10),
        const GuardrailCard(
          icon: Icons.balance_outlined,
          title: 'Alpha y Beta independientes',
          body:
              'Ambos analizan el expediente completo. JEFF combina los mejores puntos sin inventar consenso.',
        ),
        const SizedBox(height: 10),
        const GuardrailCard(
          icon: Icons.lock_outline,
          title: 'Usuario = autoridad final',
          body:
              'La APK no compra, paga, contrata ni ejecuta acciones irreversibles automáticamente.',
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          sub,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuardrailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const GuardrailCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(body),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class PipelineScreen extends StatelessWidget {
  const PipelineScreen({super.key});

  static const steps = [
    (
      '1',
      'Store Opportunity Scanner',
      'Primero busca tiendas con demanda fuerte y visibilidad relativamente baja.',
      Icons.storefront_outlined
    ),
    (
      '2',
      'Product Discovery',
      'Dentro de esas tiendas identifica qué productos explican la oportunidad.',
      Icons.inventory_2_outlined
    ),
    (
      '3',
      'Multi-Scanner Due Diligence',
      'Trend, social, sales, ads, IA, competencia, reviews, proveedores, landed, CAC, profit y risk.',
      Icons.radar_outlined
    ),
    (
      '4',
      'Product / Offer Improvement',
      'Usa reviews y evidencia para mejorar especificaciones, bundle, precio y propuesta.',
      Icons.auto_fix_high_outlined
    ),
    (
      '5',
      'Benchmark Hunter',
      'Busca los mejores por IA, anuncios, social, oferta, landing, SEO, autoridad y valor.',
      Icons.emoji_events_outlined
    ),
    (
      '6',
      'Alpha + Beta',
      'Los dos equipos analizan independientemente la oportunidad completa.',
      Icons.groups_2_outlined
    ),
    (
      '7',
      'JEFF Synthesis',
      'JEFF conserva los mejores puntos de ambos análisis y crea el Decision Memo.',
      Icons.hub_outlined
    ),
    (
      '8',
      'User Review',
      'Tú decides. Sin aprobación expresa no existe ejecución.',
      Icons.verified_user_outlined
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Flujo definitivo',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Diseñado para invalidar barato, aprender de ganadores y preservar la autoridad del Usuario.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
        const SizedBox(height: 18),
        ...steps.map(
          (step) => PipelineStep(
            number: step.$1,
            title: step.$2,
            body: step.$3,
            icon: step.$4,
            last: step.$1 == '8',
          ),
        ),
      ],
    );
  }
}

class PipelineStep extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final IconData icon;
  final bool last;

  const PipelineStep({
    super.key,
    required this.number,
    required this.title,
    required this.body,
    required this.icon,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              body,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.68),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannersScreen extends StatefulWidget {
  const ScannersScreen({super.key});

  @override
  State<ScannersScreen> createState() => _ScannersScreenState();
}

class _ScannersScreenState extends State<ScannersScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = DemoData.scanners
        .where(
          (scanner) =>
              scanner.name.toLowerCase().contains(query.toLowerCase()) ||
              scanner.group.toLowerCase().contains(query.toLowerCase()) ||
              scanner.purpose.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    final groups = <String, List<ScannerModule>>{};
    for (final scanner in filtered) {
      groups.putIfAbsent(scanner.group, () => []).add(scanner);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Scanners',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Buscar scanner…',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 18),
        ...groups.entries.expand(
          (entry) => [
            SectionHeader(title: entry.key),
            const SizedBox(height: 9),
            ...entry.value.map(
              (scanner) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: ScannerTile(scanner: scanner),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }
}

class ScannerTile extends StatelessWidget {
  final ScannerModule scanner;

  const ScannerTile({super.key, required this.scanner});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF1C2640),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.radar),
        ),
        title: Text(
          scanner.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          scanner.purpose,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xFF111827),
          builder: (context) => ScannerDetailSheet(scanner: scanner),
        ),
      ),
    );
  }
}

class ScannerDetailSheet extends StatelessWidget {
  final ScannerModule scanner;

  const ScannerDetailSheet({super.key, required this.scanner});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                scanner.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(scanner.purpose),
              const SizedBox(height: 20),
              DetailBlock(label: 'Entrada', value: scanner.input),
              DetailBlock(label: 'Salida', value: scanner.output),
              DetailBlock(label: 'Gate', value: scanner.gate),
              const DetailBlock(
                label: 'V1',
                value:
                    'Contrato y UI listos. Live adapters se conectan desde backend; la APK nunca guarda secretos de proveedores.',
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: const Text('Entendido'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailBlock extends StatelessWidget {
  final String label;
  final String value;

  const DetailBlock({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(value),
        ],
      ),
    );
  }
}

class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Opportunity Cards',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Demo data. LIVE results will preserve evidence and confidence separately.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
        const SizedBox(height: 16),
        ...DemoData.opportunities.map(
          (opportunity) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OpportunityCard(opportunity: opportunity),
          ),
        ),
      ],
    );
  }
}

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;

  const OpportunityCard({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OpportunityDetailScreen(opportunity: opportunity),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      opportunity.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  ScoreBadge(value: opportunity.opportunity),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                opportunity.id + ' · ' + opportunity.state,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MetricChip(label: 'Conf.', value: opportunity.confidence),
                  MetricChip(label: 'Demand', value: opportunity.demand),
                  MetricChip(label: 'Vis. gap', value: opportunity.visibilityGap),
                  MetricChip(label: 'Supplier', value: opportunity.supplier),
                  MetricChip(label: 'Economics', value: opportunity.economics),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.arrow_forward, size: 17),
                  const SizedBox(width: 5),
                  Text(
                    'Abrir expediente',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScoreBadge extends StatelessWidget {
  final int value;

  const ScoreBadge({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
      ),
      child: Text(
        value.toString(),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class MetricChip extends StatelessWidget {
  final String label;
  final int value;

  const MetricChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label + ' ' + value.toString()),
      visualDensity: VisualDensity.compact,
    );
  }
}

class OpportunityDetailScreen extends StatelessWidget {
  final Opportunity opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Opportunity', opportunity.opportunity),
      ('Confidence', opportunity.confidence),
      ('Demand', opportunity.demand),
      ('Visibility gap', opportunity.visibilityGap),
      ('Supplier', opportunity.supplier),
      ('Economics', opportunity.economics),
      ('Risk', opportunity.risk),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(opportunity.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            opportunity.title,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(opportunity.origin),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: metrics
                    .map(
                      (metric) => Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: ScoreRow(label: metric.$1, value: metric.$2),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'DATO FALTANTE'),
          const SizedBox(height: 8),
          ...opportunity.missing.map(
            (item) => Card(
              child: ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(item),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Análisis independientes'),
          const SizedBox(height: 8),
          TeamMemoCard(
            team: 'TEAM ALPHA',
            body: opportunity.alpha,
            icon: Icons.shield_outlined,
          ),
          const SizedBox(height: 10),
          TeamMemoCard(
            team: 'TEAM BETA',
            body: opportunity.beta,
            icon: Icons.rocket_launch_outlined,
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'JEFF synthesis'),
          const SizedBox(height: 8),
          TeamMemoCard(
            team: 'JEFF',
            body: opportunity.jeff,
            icon: Icons.hub_outlined,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text(
                'USER REVIEW REQUIRED',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                'Ningún gasto, compra, contrato o ejecución es autorizado por esta pantalla.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreRow extends StatelessWidget {
  final String label;
  final int value;

  const ScoreRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 115, child: Text(label)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: value / 100,
              backgroundColor: Colors.white10,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 34,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class TeamMemoCard extends StatelessWidget {
  final String team;
  final String body;
  final IconData icon;

  const TeamMemoCard({
    super.key,
    required this.team,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final bool demoMode;
  final String backendUrl;
  final String backendStatus;
  final bool checkingBackend;
  final ValueChanged<bool> onDemoModeChanged;
  final ValueChanged<String> onBackendUrlChanged;
  final VoidCallback onCheckBackend;

  const SettingsScreen({
    super.key,
    required this.demoMode,
    required this.backendUrl,
    required this.backendStatus,
    required this.checkingBackend,
    required this.onDemoModeChanged,
    required this.onBackendUrlChanged,
    required this.onCheckBackend,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.backendUrl);
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backendUrl != widget.backendUrl &&
        controller.text != widget.backendUrl) {
      controller.text = widget.backendUrl;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Ajustes',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        Card(
          child: SwitchListTile(
            value: widget.demoMode,
            onChanged: widget.onDemoModeChanged,
            title: const Text(
              'Demo Mode',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'Usa datos demostrativos mientras el backend y las fuentes reales se conectan.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Backend seguro',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Las API keys permanecen en el servidor. La APK solo necesita la URL HTTPS.',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  onChanged: widget.onBackendUrlChanged,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Backend URL',
                    border: OutlineInputBorder(),
                    hintText: 'https://scanner.example.com',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed:
                      widget.checkingBackend ? null : widget.onCheckBackend,
                  icon: widget.checkingBackend
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering),
                  label: const Text('Probar conexión'),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.backendStatus,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.account_balance_wallet_outlined),
            title: Text(
              'Capital máximo del experimento',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'DATO FALTANTE · No se inventa hasta que el Usuario lo defina.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.security_outlined),
            title: Text(
              'Execution Guard',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'Bloquea compras, pagos, deuda, contratos y acciones irreversibles sin aprobación explícita.',
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'V1 Foundation · scanner_po 0.1.0',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.42),
          ),
        ),
      ],
    );
  }
}
