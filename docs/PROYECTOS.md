# Proyectos

Qué sistemas existen, en qué versión del framework están y qué sobreescribieron.

Este registro existe para responder tres preguntas que si no hay que reconstruir a
mano: **¿qué proyectos hay?**, **¿cuál quedó atrás respecto del framework?** y
**¿qué se apartó de las reglas globales y por qué?**

Se actualiza al adoptar el framework en un proyecto nuevo y cada vez que un
proyecto sube de versión.

## Construidos con el framework

| Proyecto | Repositorio | Versión adoptada | Qué sobreescribió | Estado |
|---|---|---|---|---|
| Restaurante Sistema | `Bryreg/restaurante-sistema` | 2.0.0 | Régimen fiscal colombiano (INC 8 %, propina Ley 1935, documento equivalente electrónico); PIN personal sobre dispositivo compartido con sesión en cookie `httpOnly`; **no adopta** «atribución sin FK dura» (usa FK real + nombre congelado); base fija de caja; producto para varios restaurantes con organización → sede y funciones habilitables por flag; roles supervisor y responsable de caja. Detalle en su `AGENTS.md`. | en construcción |

Cómo se llena cada columna:

- **Versión adoptada**: la que quedó en `.claude/FRAMEWORK` del proyecto. Si no
  coincide con `VERSION` de este repo, el proyecto está atrás — lo cual está bien
  mientras sea una decisión y no un olvido.
- **Qué sobreescribió**: stack distinto, régimen fiscal de otro país, un agente
  agregado o desactivado. Tiene que estar declarado en el `AGENTS.md` del proyecto;
  acá va el resumen de una línea.
- **Estado**: en construcción / en producción / detenido.

## Proyectos de referencia (anteriores al framework)

No adoptaron `sistemas-maestros`: son **de dónde salieron sus patrones**. Se listan
para que quede claro que citarlos es procedencia, no dependencia.

| Proyecto | Repositorio | Qué aportó |
|---|---|---|
| café-sistema | — | El spine operativo (`DiaOperativo`), el producto sombra, la cascada FIFO de excedentes, la atribución sin FK dura |
| retail-espacios (RECABRA) | `Bryreg/retail-espacios` | Los 7 skills de diseño (ver `origin:` en cada frontmatter), el modelo dual registro/caja, y el método de trabajo: documento vivo de estado, guardas que ejecutan la cuenta en vez de mirar nombres, y no modelar de memoria |

### Nota sobre `retail-espacios`

En ese repo quedó abierta la rama `claude/sistemas-maestros-retail-mzb1om` con el
PR [#37](https://github.com/Bryreg/retail-espacios/pull/37). Es **trabajo de retail
bajo un nombre de rama de este framework**, y su base (`c4dc404`) no comparte
historia con el `main` de retail. Es exactamente el tipo de mezcla que
`docs/FRONTERAS.md` busca evitar: si se retoma, va como rama de retail con nombre
de retail, no bajo este nombre.
