# Arquitectura — sistemas-maestros

## Visión general

`sistemas-maestros` es un framework de agentes de Claude Code para construir sistemas de software completos (frontend + backend + reportes) de forma coordinada, con revisión contable y legal integrada desde el diseño, no como parche posterior.

El framework no construye un sistema específico: define un **equipo reutilizable de agentes** (skills) y un **workflow orquestador** que cualquier proyecto nuevo puede copiar y adaptar a su dominio.

La idea central: en vez de que una sola sesión de IA construya frontend, backend, contabilidad y analytics de forma secuencial y sin chequeo cruzado, un **equipo armado para ESE problema** trabaja en paralelo sobre territorios disjuntos, y el Conciliador valida que sus outputs sean coherentes entre sí —contra el código real, no contra lo que cada agente dice haber hecho— antes de considerar el trabajo terminado. El Maestro (Fable) orquesta el ciclo y decide cuándo iterar.

**El equipo lo define el Maestro, no una plantilla.** En la fase de Planificación lee el pedido, explora el repo y arma un equipo de entre 2 y 6 agentes: el catálogo de `.claude/skills/agentes/` es material de consulta —se reutiliza, se adapta, se descarta y se inventan roles nuevos según el problema—. Un pedido de tres pantallas y un endpoint no necesita al Contador ni al Legal; uno de facturación electrónica necesita a los dos y quizá a un especialista que todavía no existe.

## Abstracciones

El framework se apoya en cinco abstracciones que se repiten en los **proyectos de referencia** (café-sistema, retail-espacios) y que cualquier sistema nuevo puede instanciar. Esos dos proyectos son de dónde SALIERON las abstracciones, no una dependencia: ninguno adoptó este framework, son anteriores. Ver [`PROYECTOS.md`](PROYECTOS.md).

### StateMachine

Todo proceso de negocio con estados válidos y transiciones controladas (ej. una venta: abierta → pagada → cerrada; un turno de caja: cerrado → abierto → cerrado) se modela como una máquina de estados explícita, no como flags booleanos sueltos. Evita estados imposibles y facilita auditoría.

### DualModel

Cuando un sistema necesita representar tanto "lo que se registró" como "lo que realmente ocurrió en la caja/banco" (ej. consignaciones: contado vs. crédito/bancos), se modelan como dos capas separadas y explícitas, nunca mezcladas en una sola tabla. El Accounting Agent es responsable de detectar cuándo un dominio necesita este patrón.

### CollectiveResponsibility

Ningún agente constructor (Frontend, Backend, Contador, Legal, Analytics) es responsable de validar coherencia con los demás — esa responsabilidad es exclusiva del Conciliador. Esto evita que cada agente intente "adivinar" lo que hacen los otros y previene deriva de contrato.

### EventualConsistency

Los agentes constructores trabajan en paralelo sin comunicarse entre sí durante la fase de Construcción. La coherencia no es instantánea — se logra al final de cada iteración vía el Conciliador. El Maestro tolera hasta `MAX_ITERATIONS` (3) rondas de inconsistencia temporal antes de escalar al usuario.

Trabajar en paralelo sobre el MISMO árbol impone su propia regla: cada agente verifica **sólo su territorio**, y la suite completa la corre una sola vez, en serie, el paso de verificación final. Ver `.claude/AGENTS.md § Verificación` — nació de cuatro suites simultáneas que se borraban las bases de prueba entre sí.

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
| Diseño | Los 7 skills de `.claude/skills/` — cada uno en su carpeta, con sus datos y scripts (tokens, banners, slides, UI/UX intelligence) |

Este stack es el **default** del framework, heredado de café-sistema y retail-espacios. Es una elección revisable, no un requisito: un proyecto nuevo puede reemplazarlo (ver [`SETUP.md`](SETUP.md)), pero debe declarar el reemplazo explícitamente en el `AGENTS.md` de ese proyecto — nunca en el de este repo, que es de todos los proyectos a la vez.

## Diagrama de agentes

```
                         ┌─────────────────────────┐
                         │  Maestro Orchestrator    │
                         │  (Fable)                 │
                         │  .claude/skills/agentes/ │
                         │  maestro-fable.md        │
                         └────────────┬─────────────┘
                          │ PLANIFICACIÓN: lee el pedido y el repo,
                          │ elige del catálogo, adapta o inventa roles
                          ▼
              ┌───────────────────────────────────┐
              │  EQUIPO AD-HOC — de 2 a 6 agentes │
              │  territorios disjuntos            │
              └───────────────┬───────────────────┘
                              │ CONSTRUCCIÓN (paralelo)
        ┌──────────────┬──────┴──────┬──────────────┐
        ▼              ▼             ▼              ▼
  ┌──────────┐   ┌──────────┐  ┌──────────┐   ┌──────────┐
  │ del      │   │ del      │  │ adaptado │   │  NUEVO   │
  │ catálogo │   │ catálogo │  │          │   │ (inventado
  └────┬─────┘   └────┬─────┘  └────┬─────┘   └────┬─────┘  para el caso)
       └──────────────┴─────────────┴──────────────┘
                              │ CONCILIACIÓN
                              ▼
                 ┌─────────────────────────┐
                 │   Conciliador Agent      │
                 │  cruza outputs contra    │
                 │  el código real (git     │
                 │  diff) → conflicts[]     │
                 └────────────┬─────────────┘
                              │ ITERACIÓN (sólo los agentes
                              ▼  con conflictos bloqueantes)
                 Maestro ajusta misiones dirigidas
                 y relanza — hasta MAX_ITERATIONS (3)
                              │
                              ▼ ENTREGA
                 Síntesis: equipo elegido, historial,
                 conflictos que quedaron abiertos

              El catálogo de .claude/skills/agentes/ alimenta
              la planificación; NO es el equipo.
```

## Ver también

- `docs/PATRONES.md` — patrones reutilizables y guardrails.
- `docs/SETUP.md` — cómo instanciar este framework en un proyecto nuevo.
- `docs/GUIA-AGENTES.md` — detalle de cada agente.
- `.claude/workflows/orquestador-general.js` — implementación del ciclo de fases.
