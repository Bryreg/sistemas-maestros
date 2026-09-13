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
