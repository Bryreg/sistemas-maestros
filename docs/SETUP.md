# Setup — cómo usar sistemas-maestros en un proyecto nuevo

## Qué es este repositorio

`sistemas-maestros` **no es un proyecto ejecutable en sí mismo**. Es una plantilla de agentes y skills de Claude Code (`.claude/`) diseñada para copiarse dentro de un proyecto nuevo (o referenciarse desde él) y adaptarse a su dominio de negocio.

## Pasos para adoptar el framework en un proyecto nuevo

### 1. Adoptar el framework

```bash
scripts/adoptar.sh /ruta/a/mi-proyecto-nuevo "Nombre del proyecto"
```

Copia `.claude/`, **estampa la versión adoptada** en `.claude/FRAMEWORK`, y deja en el
proyecto un `AGENTS.md` y un `docs/ESTADO.md` para completar. Se puede copiar a mano
con `cp -r`, pero entonces no queda rastro de qué versión se copió — y sin ese rastro,
meses después nadie puede decir si el proyecto quedó atrás del framework o si se
apartó a propósito.

El script **no pisa** una adopción existente: actualizar un proyecto que ya adoptó el
framework se hace archivo por archivo, anotando la versión nueva en su
`.claude/FRAMEWORK` y en [`PROYECTOS.md`](PROYECTOS.md).

Lo que trae:
- `skills/design/` — 7 skills de diseño listos para usar tal cual.
- `skills/agentes/` — 7 agentes especializados, a adaptar al dominio.
- `workflows/orquestador-general.js` — el ciclo de fases.
- `AGENTS.md` — reglas globales, a revisar/ajustar.
- `launch.json` — config de arranque local, a ajustar a los puertos/comandos reales del proyecto.

### 2. Adaptar la spec de negocio

El Maestro Orchestrator (`maestro-fable.md`) recibe la idea del usuario en lenguaje natural y la pasa tal cual a los 5 agentes constructores en la Fase 1. No hace falta modificar el workflow para un dominio nuevo — la adaptación ocurre en cómo cada agente interpreta la spec, no en el código del orquestador.

Si el dominio tiene reglas muy específicas (ej. régimen fiscal de un país distinto a Colombia, un stack distinto a FastAPI+React), documentarlo en `.claude/AGENTS.md` del proyecto nuevo para que todos los agentes lo hereden.

### 3. Ajustar el Workflow a tu dominio

En la mayoría de los casos **no hace falta tocar** `orquestador-general.js` — el ciclo (Fase 1 paralela → Fase 2 conciliación → Fase 3 iteración) es genérico. Casos en los que sí conviene ajustarlo:

- **Agregar un sexto agente constructor** (ej. un Agente de Inventario dedicado): agregarlo al `Promise.all` de la Fase 1, agregarlo a `results`, y actualizar `.claude/skills/agentes/conciliador.md` para que también lo valide.
- **Cambiar el modelo asignado a un agente**: editar el `model` en la llamada `agent(...)` correspondiente y en el frontmatter del `.md` del agente. No hardcodear el modelo en más de un lugar.
- **Cambiar `MAX_ITERATIONS`**: ajustar la constante exportada si el dominio requiere más o menos margen de ajuste iterativo.

### 4. Cómo extender skills

Para agregar un skill de diseño nuevo (ej. un skill de "reportes PDF"):

1. Crear `mi-proyecto/.claude/skills/design/mi-skill-nuevo.md` siguiendo el formato de los 7 skills existentes (frontmatter `name`, `description`, `metadata`, luego secciones `When to Use`, referencias, scripts).
2. Si el skill necesita scripts ejecutables, documentarlos en una tabla `## Scripts` como en `design.md` o `brand.md`.
3. Referenciarlo desde `design.md` en la tabla de "Sub-skill Routing" si otros skills deben poder invocarlo.

Para agregar un agente nuevo:

1. Copiar la estructura de cualquier `.md` en `skills/agentes/` (frontmatter + Propósito + Cuándo se me invoca + Tareas + Entregables + Guardrails + Invocación).
2. Asignarle un modelo explícito y un `label` único para el workflow.
3. Decidir si participa en la Fase 1 (constructor) o es un rol de control como el Conciliador — eso determina si entra al `Promise.all` o corre después.
4. Actualizar `docs/GUIA-AGENTES.md` con la entrada del nuevo agente.

### 5. Verificación mínima antes de usar el framework en un proyecto real

- Confirmar que `.claude/AGENTS.md` refleja el stack real del proyecto (si difiere de FastAPI+React, decirlo explícitamente).
- Confirmar que `.claude/launch.json` apunta a los comandos/puertos reales de arranque local.
- Correr una iteración de prueba con una spec simple para validar que el Conciliador recibe outputs con la forma esperada de cada agente.

### 6. Anotar el proyecto en el registro

Agregar la fila en [`PROYECTOS.md`](PROYECTOS.md): repositorio, versión adoptada y
qué sobreescribió. Es lo que después permite saber qué proyectos quedaron atrás.

## Qué NO hace este framework

- No reemplaza la revisión humana final — el Legal Agent y el Contador Agent producen borradores/hallazgos, no aprobaciones legales o contables vinculantes.
- No decide arquitectura de infraestructura/deploy — eso queda fuera del alcance de los 7 agentes.
- No genera tests automáticamente salvo que se agregue explícitamente esa responsabilidad a Frontend/Backend Agent en el proyecto adoptante.
- **No aloja proyectos.** El sistema construido vive en su propio repositorio; en éste sólo viven los agentes, los skills y los patrones. Ver [`FRONTERAS.md`](FRONTERAS.md).
