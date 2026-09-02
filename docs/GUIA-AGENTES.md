# Guía de Agentes — sistemas-maestros

Referencia rápida de los 7 agentes del framework. Para el detalle completo de cada uno (tareas, entregables, guardrails), ver el `.md` correspondiente en `.claude/skills/agentes/`.

| Agente | Archivo | Modelo | Label | Fase |
|--------|---------|--------|-------|------|
| Frontend Agent | `agente-frontend.md` | `claude-sonnet-5` | `builder:frontend` | 1 (paralelo) |
| Backend Agent | `agente-backend.md` | `claude-sonnet-5` | `builder:backend` | 1 (paralelo) |
| Accounting Agent | `agente-contador.md` | `claude-opus-5` | `builder:accounting` | 1 (paralelo) |
| Legal Agent | `agente-legal.md` | `claude-opus-5` | `builder:legal` | 1 (paralelo) |
| Analytics Agent | `agente-analytics.md` | `claude-haiku-4-5-20251001` | `builder:analytics` | 1 (paralelo) |
| Conciliador Agent | `conciliador.md` | `claude-haiku-4-5-20251001` | `reconciliation` | 2 (después de Fase 1) |
| Maestro Orchestrator (Fable) | `maestro-fable.md` | `claude-fable-5-1` | `maestro` | orquesta todo el ciclo |

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

### Conciliador Agent
No construye nada — lee los outputs de los 5 agentes anteriores en la misma iteración y detecta conflictos: endpoints que Frontend pide y Backend no expone, reglas contables que Backend ignoró, datos que Frontend expone y Legal no aprobó, dashboards que dependen de campos inexistentes. Produce `{ conflicts[], coherente }`.

### Maestro Orchestrator (Fable)
Punto de entrada del framework. Recibe la idea del usuario, dispara el workflow, lee el veredicto del Conciliador, decide si itera (ajustando prompts dirigidos a los agentes en conflicto) o entrega el resultado final. Mantiene historial de iteraciones.

## Cómo son invocados

Todos los agentes constructores y el Conciliador se invocan vía la función `agent(prompt, { model, label })` dentro de `.claude/workflows/orquestador-general.js`. El Maestro es quien orquesta esas llamadas — no se invoca a sí mismo dentro del workflow, es el que ejecuta `main(spec)`.

```js
// Fase 1 — paralelo
const [frontend, backend, accounting, legal, analytics] = await Promise.all([
  agent(prompts.frontend, { model: 'claude-sonnet-5', label: 'builder:frontend' }),
  agent(prompts.backend, { model: 'claude-sonnet-5', label: 'builder:backend' }),
  agent(prompts.accounting, { model: 'claude-opus-5', label: 'builder:accounting' }),
  agent(prompts.legal, { model: 'claude-opus-5', label: 'builder:legal' }),
  agent(prompts.analytics, { model: 'claude-haiku-4-5-20251001', label: 'builder:analytics' })
])

// Fase 2 — conciliación
const conciliation = await agent(conciliationPrompt, {
  model: 'claude-haiku-4-5-20251001',
  label: 'reconciliation'
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
| Conciliador | `{ conflicts[], coherente }` |
| Maestro | Resultado final del sistema + historial de iteraciones |

## Ver también

- `docs/ARQUITECTURA.md` — diagrama completo y abstracciones del framework.
- `docs/PATRONES.md` — patrones reutilizables y guardrails transversales.
- `.claude/AGENTS.md` — reglas globales que todos los agentes heredan.
