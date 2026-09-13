# Cambios de sistemas-maestros

Todo cambio a `.claude/` o al workflow sube la versión: un proyecto adoptante tiene
que poder decir contra qué versión está parado.

Versionado: `MAYOR.MENOR.PARCHE`.

- **MAYOR** — un proyecto adoptante tiene que hacer trabajo para actualizarse: se
  agrega o se saca un agente, cambia la forma de los outputs que consume el
  Conciliador, cambia un contrato del workflow.
- **MENOR** — capacidad nueva compatible: un skill nuevo, una regla global nueva,
  un patrón nuevo.
- **PARCHE** — redacción, correcciones, documentación.

## 2.0.0 — 2026-09-13

**MAYOR**: cambia el contrato del workflow y entra un rol nuevo al catálogo. Un
proyecto que adoptó 1.0.0 sigue funcionando con su copia, pero para actualizarse
tiene que cambiar cómo dispara el orquestador.

- **El equipo dejó de ser fijo.** Se agrega una fase de **Planificación**: el Maestro
  lee el pedido y el repo y define qué agentes lanzar —entre 2 y 6—, repartiendo
  territorios disjuntos. La librería de `.claude/skills/agentes/` pasa a ser un
  **catálogo, no un mandato**: se reutiliza, se adapta, se descarta, y se crean roles
  nuevos cuando el problema pide un especialista que no existe. Antes, los cinco
  constructores estaban escritos adentro de un `Promise.all`.
- **El orquestador se dispara con un pedido**, no con una spec pasada a mano:
  `args.pedido`, más `outputs`, `spec` y `contexto` opcionales. El framework puede
  vivir como submodule (`systems-master/`) o ser el repo raíz; los agentes resuelven
  cuál con `ls`.
- **El Conciliador cruza contra el código real** (`git diff`), no contra lo que cada
  agente dice haber hecho.
- **Agente nuevo: Analista de Datos** (`agente-datos.md`). No inventa métricas ni toca
  fórmulas: hace que un panel se entienda en cinco segundos.
- **Regla de verificación nueva** en `.claude/AGENTS.md`: la suite completa es un
  recurso compartido. Cada agente corre sólo los tests de su territorio; la suite
  entera y el build los corre una sola vez, en serie, el paso final. Salió de un caso
  real: cuatro suites en paralelo sobre el mismo árbol, más de 40 minutos sin
  terminar, y el teardown de una borrando las bases SQLite de otra.
- La documentación queda alineada con todo lo anterior: `ARQUITECTURA.md` (diagrama
  del equipo ad-hoc), `GUIA-AGENTES.md` (el catálogo, con el rol nuevo),
  `SETUP.md` (agregar un rol ya no obliga a tocar el workflow) y los `.md` de los
  agentes, que decían «en paralelo con Frontend, Backend, Contador y Legal» — una
  lista fija que ya no aplica.

## 1.0.0 — 2026-09-13

Primera versión numerada. No cambia el comportamiento: le pone versión y estructura
a lo que ya existía, para que los proyectos que vienen no se mezclen entre sí ni con
el framework.

- `docs/FRONTERAS.md`: qué entra a este repo y qué no, y cómo se promueve al
  framework algo que nació adentro de un proyecto.
- `docs/PROYECTOS.md`: registro de proyectos, versión adoptada y qué sobreescribió
  cada uno. Separa los proyectos construidos con el framework de los **de
  referencia**, que son anteriores y sólo aportaron patrones.
- `CLAUDE.md`: punto de entrada, con el orden de lectura y la frontera arriba de todo.
- `scripts/adoptar.sh`: adopción reproducible que estampa la versión en
  `.claude/FRAMEWORK` del proyecto. Antes era un `cp -r` que no dejaba rastro de qué
  versión se había copiado.
- `VERSION` y este `CHANGELOG.md`.
