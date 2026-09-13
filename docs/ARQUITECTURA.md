# Arquitectura — sistemas-maestros

## Visión general

`sistemas-maestros` es un framework de agentes de Claude Code para construir sistemas de software completos (frontend + backend + reportes) de forma coordinada, con revisión contable y legal integrada desde el diseño, no como parche posterior.

El framework no construye un sistema específico: define un **equipo reutilizable de agentes** (skills) y un **workflow orquestador** que cualquier proyecto nuevo puede copiar y adaptar a su dominio.

La idea central: en vez de que una sola sesión de IA construya frontend, backend, contabilidad y analytics de forma secuencial y sin chequeo cruzado, se lanzan 5 agentes especializados en paralelo sobre la misma spec, y un sexto agente (Conciliador) valida que sus outputs sean coherentes entre sí antes de considerar el trabajo terminado. Un séptimo agente (Maestro/Fable) orquesta el ciclo completo y decide cuándo iterar.

## Abstracciones

El framework se apoya en cinco abstracciones que se repiten en los **proyectos de referencia** (café-sistema, retail-espacios) y que cualquier sistema nuevo puede instanciar. Esos dos proyectos son de dónde SALIERON las abstracciones, no una dependencia: ninguno adoptó este framework, son anteriores. Ver [`PROYECTOS.md`](PROYECTOS.md).

### StateMachine

Todo proceso de negocio con estados válidos y transiciones controladas (ej. una venta: abierta → pagada → cerrada; un turno de caja: cerrado → abierto → cerrado) se modela como una máquina de estados explícita, no como flags booleanos sueltos. Evita estados imposibles y facilita auditoría.

### DualModel

Cuando un sistema necesita representar tanto "lo que se registró" como "lo que realmente ocurrió en la caja/banco" (ej. consignaciones: contado vs. crédito/bancos), se modelan como dos capas separadas y explícitas, nunca mezcladas en una sola tabla. El Accounting Agent es responsable de detectar cuándo un dominio necesita este patrón.

### CollectiveResponsibility

Ningún agente constructor (Frontend, Backend, Contador, Legal, Analytics) es responsable de validar coherencia con los demás — esa responsabilidad es exclusiva del Conciliador. Esto evita que cada agente intente "adivinar" lo que hacen los otros y previene deriva de contrato.

### EventualConsistency

Los agentes constructores trabajan en paralelo sobre la misma spec sin comunicarse entre sí durante la Fase 1. La coherencia no es instantánea — se logra al final de cada iteración vía el Conciliador. El Maestro tolera hasta `MAX_ITERATIONS` rondas de inconsistencia temporal antes de escalar al usuario.

### I18nCode

Código, specs técnicas y artefactos (OpenSpec, tareas, tests) siempre en inglés, independientemente del idioma de la conversación con el usuario. La UI final y los comentarios de cara al usuario siguen el idioma del contexto del proyecto (español, en los proyectos de referencia del usuario).

## Stack base

| Capa | Tecnología |
|------|-----------|
| Frontend | React + TypeScript + shadcn/ui + Tailwind CSS |
| Backend | FastAPI + SQLAlchemy + Pydantic |
| Autenticación | JWT |
| Estado cliente | Zustand (solo si hay sincronización real) |
| Visualización | Chart.js / Recharts |
| Diseño | Skills de `.claude/skills/design/` (tokens, banners, slides, UI/UX intelligence) |

Este stack es el **default** del framework, heredado de café-sistema y retail-espacios. Es una elección revisable, no un requisito: un proyecto nuevo puede reemplazarlo (ver [`SETUP.md`](SETUP.md)), pero debe declarar el reemplazo explícitamente en el `AGENTS.md` de ese proyecto — nunca en el de este repo, que es de todos los proyectos a la vez.

## Diagrama de agentes

```
                         ┌─────────────────────────┐
                         │  Maestro Orchestrator    │
                         │  (Fable)                 │
                         │  .claude/skills/agentes/ │
                         │  maestro-fable.md        │
                         └────────────┬─────────────┘
                                      │ dispara Fase 1 (paralelo)
        ┌──────────────┬─────────────┼─────────────┬──────────────┐
        ▼              ▼             ▼             ▼              ▼
  ┌──────────┐   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
  │ Frontend │   │ Backend  │  │ Contador │  │  Legal   │  │Analytics │
  │  Agent   │   │  Agent   │  │  Agent   │  │  Agent   │  │  Agent   │
  │  sonnet  │   │  sonnet  │  │  opus    │  │  opus    │  │  haiku   │
  └────┬─────┘   └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘
       └──────────────┴─────────────┴─────────────┴──────────────┘
                                      │ Fase 2
                                      ▼
                         ┌─────────────────────────┐
                         │   Conciliador Agent      │
                         │        (haiku)           │
                         │  detecta conflicts[]      │
                         └────────────┬─────────────┘
                                      │ Fase 3 (si hay bloqueantes)
                                      ▼
                         Maestro ajusta prompts →
                         relanza Fase 1 (hasta MAX_ITERATIONS)
```

## Ver también

- `docs/PATRONES.md` — patrones reutilizables y guardrails.
- `docs/SETUP.md` — cómo instanciar este framework en un proyecto nuevo.
- `docs/GUIA-AGENTES.md` — detalle de cada agente.
- `.claude/workflows/orquestador-general.js` — implementación del ciclo de fases.
