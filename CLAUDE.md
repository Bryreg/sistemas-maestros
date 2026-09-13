# sistemas-maestros

Framework de agentes de Claude Code para construir sistemas de software completos
de forma coordinada. **No es un producto: es la plantilla con la que se construyen
productos.**

## Lo primero, porque es lo que más fácil se rompe

**Acá no entra ningún proyecto.** Ni su código, ni su spec de negocio, ni su
`ESTADO.md`, ni sus datos, ni sus capturas. Un proyecto construido con este
framework vive en **su propio repositorio**, con su propia copia de `.claude/`.

La regla completa —qué entra, qué no, y qué hacer cuando algo bueno nace adentro
de un proyecto— está en **[`docs/FRONTERAS.md`](docs/FRONTERAS.md)**. Leela antes
de agregar un archivo que no sea un agente, un skill o un patrón.

Qué proyectos existen y en qué versión del framework están:
**[`docs/PROYECTOS.md`](docs/PROYECTOS.md)**.

## Orden de lectura

1. [`README.md`](README.md) — qué es y qué incluye.
2. [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md) — los 7 agentes y el ciclo de fases.
3. [`docs/FRONTERAS.md`](docs/FRONTERAS.md) — el límite entre framework y proyecto.
4. [`docs/SETUP.md`](docs/SETUP.md) — cómo adoptarlo en un proyecto nuevo.
5. [`docs/GUIA-AGENTES.md`](docs/GUIA-AGENTES.md) — qué produce cada agente.
6. [`.claude/AGENTS.md`](.claude/AGENTS.md) — las reglas duras que ningún agente puede saltarse.
7. [`docs/PATRONES.md`](docs/PATRONES.md) — patrones reutilizables y guardrails.

## Adoptar el framework en un proyecto nuevo

```bash
scripts/adoptar.sh /ruta/al/proyecto-nuevo "Nombre del proyecto"
```

Copia `.claude/`, estampa la versión adoptada en `.claude/FRAMEWORK`, y deja en el
proyecto un `AGENTS.md` y un `docs/ESTADO.md` para completar. **Copiar a mano con
`cp -r` funciona pero no deja rastro de qué versión se adoptó**, y ese rastro es lo
que después permite saber si un proyecto quedó atrás.

Después de adoptar, anotá el proyecto en [`docs/PROYECTOS.md`](docs/PROYECTOS.md).

## Versión

La versión vive en [`VERSION`](VERSION) y los cambios en
[`CHANGELOG.md`](CHANGELOG.md). Todo cambio a `.claude/` o al workflow sube la
versión: un proyecto adoptante tiene que poder decir contra qué versión está.

## Verificación mínima

```bash
node --check .claude/workflows/orquestador-general.js
scripts/adoptar.sh --verificar
```
