# Guía de Agentes — sistemas-maestros

Referencia rápida del **catálogo de roles** del framework. Para el detalle completo de
cada uno (tareas, entregables, guardrails), ver el `.md` correspondiente en
`.claude/skills/agentes/`.

> **Esto es un catálogo, no el equipo.** El Maestro define en la fase de Planificación
> qué agentes lanzar para cada problema: reutiliza los que calzan, los adapta, descarta
> los que no aportan y **crea roles nuevos** si hace falta un especialista que el
> catálogo no tiene. Una fase de tres pantallas no convoca al Contador; ninguna fase
> convoca a los ocho porque sí. La columna «Cuándo entra» describe el uso típico, no
> una obligación.

| Agente | Archivo | Modelo | Label | Cuándo entra |
|--------|---------|--------|-------|--------------|
| Frontend Agent | `agente-frontend.md` | `claude-sonnet-5` | `builder:frontend` | Construcción, si hay interfaz |
| Backend Agent | `agente-backend.md` | `claude-sonnet-5` | `builder:backend` | Construcción, si hay API o modelo de datos |
| Accounting Agent | `agente-contador.md` | `claude-opus-5` | `builder:accounting` | Construcción, si hay plata de por medio |
| Legal Agent | `agente-legal.md` | `claude-opus-5` | `builder:legal` | Construcción, si hay PII o compliance |
| Analytics Agent | `agente-analytics.md` | `claude-haiku-4-5-20251001` | `builder:analytics` | Construcción, si hay métricas o reportes |
| Analista de Datos | `agente-datos.md` | `claude-sonnet-5` | `analyst:data` | Pase de refinamiento sobre un panel ya construido, o builder de presentación en una fase analítica |
| Conciliador Agent | `conciliador.md` | `claude-haiku-4-5-20251001` | `reconciliation` | Conciliación — **siempre**, no es opcional |
| Maestro Orchestrator (Fable) | `maestro-fable.md` | `claude-fable-5-1` | `maestro` | Planificación y Entrega — orquesta todo el ciclo |

## Qué hace cada agente

### Frontend Agent
Construye componentes React + TypeScript con `shadcn/ui` + Tailwind a partir de specs funcionales. Consume el contrato de API que publica Backend Agent; nunca inventa endpoints. Responsable de responsive, dark mode y accesibilidad WCAG 2.1 AA.

### Backend Agent
Define modelos SQLAlchemy y endpoints FastAPI a partir de specs de negocio. Responsable de autenticación JWT, validación con Pydantic, manejo de errores consistente y defensa de concurrencia (índices únicos o 409).

### Accounting Agent
Audita que el modelo de datos soporte asientos contables trazables, valida P&L y reconciliaciones, y señala requisitos de cumplimiento fiscal cuando la spec los declara. No construye código — especifica requisitos que Backend Agent debe cumplir.

### Legal Agent
Revisa qué datos sensibles (PII, precios) expone el sistema, valida que el esquema de roles/permisos siga menor privilegio, y sugiere puntos para T&C/política de privacidad. Nunca redacta documentos legales vinculantes por sí solo.

### Analytics Agent
Diseña queries de análisis, specs de dashboards y definiciones formales de KPI a partir del modelo de datos real de Backend Agent. Recomienda tipo de visualización (Chart.js/Recharts) por tipo de métrica.

### Analista de Datos
No inventa métricas ni toca fórmulas: hace que los números CUENTEN algo. Audita qué pregunta de negocio responde cada elemento de un panel, qué forma le corresponde a cada métrica y qué jerarquía visual tiene la pantalla. Su caso típico es de refinamiento: el builder de frontend hizo funcionar el dashboard, él lo hace legible en cinco segundos.

### Conciliador Agent
No construye nada — lee los outputs de los agentes del equipo en la misma iteración, **los cruza contra el código real** (`git diff`, no contra lo que cada agente dice haber hecho) y detecta conflictos: endpoints que Frontend pide y Backend no expone, reglas contables que Backend ignoró, datos que Frontend expone y Legal no aprobó, dashboards que dependen de campos inexistentes. Produce `{ conflicts[], coherente }`.

### Maestro Orchestrator (Fable)
Punto de entrada del framework. Recibe el pedido del usuario, **arma el equipo**, lee el veredicto del Conciliador, decide si itera (con ajustes dirigidos SÓLO a los agentes en conflicto, no relanzando a todos) o entrega el resultado. Mantiene el historial de iteraciones y reporta explícitamente los conflictos que quedaron abiertos.

## Cómo son invocados

Todos los agentes se invocan vía `agent(prompt, { model, label, phase, schema })` dentro de `.claude/workflows/orquestador-general.js`. El Maestro también: **su primera llamada es la que devuelve el equipo**, y el workflow lanza lo que esa llamada trajo. Por eso agregar un rol al catálogo no obliga a tocar el workflow.

```js
// Planificación — el Maestro DEVUELVE el equipo; no está escrito en el workflow
const plan = await agent(promptDePlanificación, {
  label: 'maestro:planificación', phase: 'Planificación', schema: EQUIPO_SCHEMA,
})
const TEAM = {}
for (const a of plan.equipo) TEAM[a.id] = a

// Construcción — se lanza EL EQUIPO QUE VINO, con el modelo que el Maestro le asignó
const results = await parallel(ids.map(id => () =>
  agent(misionCompleta(TEAM[id], ajustesPorAgente?.[id], iter), {
    label: id, phase: fase, model: TEAM[id].modelo, schema: BUILDER_SCHEMA,
  })
))

// Conciliación — siempre
veredicto = await agent(promptDeConciliación, { label: 'reconciliation', ... })
```

Y se dispara desde afuera con el pedido en lenguaje natural:

```js
Workflow({
  scriptPath: '.claude/workflows/orquestador-general.js',   // o systems-master/... si es submodule
  args: {
    pedido: 'Agregar facturación electrónica a la caja',
    outputs: 'features/facturacion/outputs',
    spec:    'features/facturacion/spec.md',
    contexto: ['docs/ESTADO.md', 'AGENTS.md'],
  },
})
```

## Qué produce cada uno

| Agente | Entregable principal |
|--------|----------------------|
| Frontend | Componentes `.tsx`, lista de endpoints consumidos, gaps detectados |
| Backend | Modelos SQLAlchemy, contrato OpenAPI, notas de reglas implementadas |
| Contador | Validaciones/hallazgos de riesgo contable, spec de reportes financieros |
| Legal | Inventario de datos sensibles, hallazgos de exposición, borrador de puntos para T&C |
| Analytics | Specs de queries, specs de dashboards, definiciones de KPI |
| Datos | Panel auditado: qué pregunta responde cada elemento, qué forma le toca a cada métrica |
| Conciliador | `{ conflicts[], coherente }` |
| Maestro | Resultado final del sistema + historial de iteraciones |

## Ver también

- `docs/ARQUITECTURA.md` — diagrama completo y abstracciones del framework.
- `docs/PATRONES.md` — patrones reutilizables y guardrails transversales.
- `.claude/AGENTS.md` — reglas globales que todos los agentes heredan.
