# Fronteras — qué es framework y qué es proyecto

Este repositorio es una **plantilla**. Los sistemas que se construyen con ella son
**otros repositorios**. Este documento existe porque esa separación no se sostiene
sola: se rompe de a un archivo por vez, siempre con una buena razón en el momento.

## La regla

> **Si sirve para UN solo proyecto, no va acá. Si sirve para el próximo proyecto
> que todavía no existe, va acá.**

## Qué entra

- Agentes (`.claude/skills/agentes/`) y skills (`.claude/skills/design/`).
- El workflow orquestador (`.claude/workflows/`).
- Reglas globales (`.claude/AGENTS.md`): las que todo proyecto hereda.
- Patrones **generalizados** (`docs/PATRONES.md`): el patrón, no el caso.
- Documentación del framework y del proceso.

## Qué NO entra, nunca

| No entra | Dónde va |
|---|---|
| Código de producto (frontend, backend, migraciones) | El repo del proyecto |
| La spec de negocio de un cliente | El repo del proyecto |
| El `ESTADO.md` de un proyecto | El repo del proyecto |
| Datos, planos, catálogos, exports, capturas | El repo del proyecto |
| Credenciales, tokens, `.env`, claves de API | En ningún repo — variables de entorno |
| Reglas fiscales o legales de un país concreto | El `AGENTS.md` del proyecto |
| Un ajuste "sólo para este cliente" | El `AGENTS.md` del proyecto |

## La prueba de olfato

Antes de agregar un archivo, preguntate:

1. **¿Tiene adentro el nombre de un cliente, un producto o un dominio?** Si sí,
   o se generaliza o no entra. «Góndola» no entra; «entidad que se alquila por
   período» sí.
2. **¿El próximo proyecto lo usaría sin editarlo?** Si hay que editarlo para cada
   proyecto, es plantilla del proyecto, no del framework.
3. **¿Se rompe si el stack cambia?** El stack por defecto (FastAPI + React) es una
   **elección revisable**, no una ley. Lo que dependa de él va marcado como default,
   nunca como requisito.

## Cuando algo bueno nace adentro de un proyecto

Pasa seguido, y es la forma sana de alimentar el framework. El camino es **promover,
no copiar**:

1. **Se prueba en el proyecto primero.** Un patrón que se usó una sola vez todavía
   no es un patrón: es una decisión.
2. **Se generaliza al subirlo.** Se le quitan los nombres del dominio, se lo escribe
   como regla y se le explica el POR QUÉ — que es lo que sobrevive cuando el caso
   original se olvida.
3. **Se anota de dónde salió.** La procedencia se conserva (`origin:` en el
   frontmatter de los skills, la mención en `PATRONES.md`): saber de qué proyecto
   vino un patrón es lo que permite juzgarlo después.
4. **Sube la versión del framework** y se anota en `CHANGELOG.md`.

Lo que **no** es promover: copiar el archivo tal cual con el nombre del cliente
adentro y dejar que el próximo proyecto lo borre.

## Los proyectos de referencia no son el framework

`café-sistema` y `retail-espacios` aparecen citados en `ARQUITECTURA.md` y
`PATRONES.md` como **fuentes** de los patrones: son de dónde salió el aprendizaje,
no una dependencia. Ninguno de los dos adoptó este framework — son anteriores.
Borrar esas menciones perdería la única pista de por qué cada patrón está escrito
así; tratarlas como defaults sería el error opuesto.

## Ramas

Una rama de este repo trata sobre **el framework**. Si el nombre de una rama
menciona un proyecto, algo se mezcló: o el trabajo va en el repo del proyecto, o
la rama está mal nombrada. Ver `docs/PROYECTOS.md` para el estado de cada uno.
