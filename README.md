# sistemas-maestros

Framework de agentes de Claude Code para construir sistemas de software completos (frontend + backend + analytics) de forma coordinada, con revisión contable y legal integrada desde el diseño.

En vez de que una sola sesión de IA construya todo secuencialmente, este framework lanza **5 agentes especializados en paralelo** sobre la misma spec (Frontend, Backend, Contador, Legal, Analytics), un **Conciliador** que valida que sus outputs sean coherentes entre sí, y un **Maestro Orquestador** que decide si el sistema está listo o si hace falta otra iteración.

## Qué incluye

```
sistemas-maestros/
├── .claude/
│   ├── skills/
│   │   ├── design/    → 7 skills de diseño reutilizables (banner, brand, design system, slides, UI styling, UI/UX intelligence)
│   │   └── agentes/   → 7 agentes especializados (Frontend, Backend, Contador, Legal, Analytics, Conciliador, Maestro)
│   ├── workflows/
│   │   └── orquestador-general.js  → ciclo de fases: Disparo → Conciliación → Iteración
│   ├── AGENTS.md      → reglas globales para todos los agentes
│   └── launch.json    → config de arranque local (plantilla)
├── docs/
│   ├── ARQUITECTURA.md   → visión general, abstracciones, diagrama de agentes
│   ├── FRONTERAS.md      → qué entra a este repo y qué va en el del proyecto
│   ├── PROYECTOS.md      → registro: qué proyectos hay y en qué versión están
│   ├── PATRONES.md       → patrones reutilizables y guardrails
│   ├── SETUP.md          → cómo adoptar el framework en un proyecto nuevo
│   └── GUIA-AGENTES.md   → qué hace cada agente, cómo se invoca, qué produce
├── scripts/
│   └── adoptar.sh        → adopción reproducible, estampa la versión adoptada
├── CLAUDE.md             → punto de entrada y orden de lectura
├── VERSION
└── CHANGELOG.md
```

## Este repo no aloja proyectos

Un sistema construido con este framework vive en **su propio repositorio**, con su
propia copia de `.claude/`. Acá no entra código de producto, ni specs de negocio, ni
datos, ni el estado de ningún proyecto: la regla completa está en
[`docs/FRONTERAS.md`](docs/FRONTERAS.md) y el registro de proyectos en
[`docs/PROYECTOS.md`](docs/PROYECTOS.md).

## Cómo empezar

1. Lee `CLAUDE.md` — el punto de entrada y el orden de lectura.
2. Lee `docs/ARQUITECTURA.md` para entender el modelo de 7 agentes y el ciclo de fases.
3. Lee `docs/FRONTERAS.md` para saber qué entra a este repo y qué va en el del proyecto.
4. Adoptá el framework en tu proyecto nuevo:

   ```bash
   scripts/adoptar.sh /ruta/al/proyecto-nuevo "Nombre del proyecto"
   ```

   Ver `docs/SETUP.md` para qué hay que completar después.
5. Lee `docs/GUIA-AGENTES.md` para el detalle de qué produce cada agente y con qué modelo corre.
6. Invoca al Maestro Orquestador (`.claude/skills/agentes/maestro-fable.md`) con la idea del sistema que querés construir.

## Principio central

**Ningún agente constructor se autodeclara terminado.** El único criterio de "listo" es el veredicto del Conciliador (`coherente: true`), y ningún conflicto bloqueante puede quedar silenciado en la entrega final.

Ver `docs/` para el detalle completo.
