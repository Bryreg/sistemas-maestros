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

## 2.4.0 — 2026-09-21

### Agregado

- **`brag`**, de `latent-spaces/brag` 0.3.0 (MIT, commit `57ce4c9`). Convierte
  el proyecto en un video corto de lanzamiento, con música y copy para
  compartir; lee el código directo, sin necesitar una URL viva ni capturas.
  Su procedencia y su camino de actualización quedan en
  `.claude/skills/PROCEDENCIA.md`, que se estrena con este cambio.

  Dos cosas que hay que saber antes de usarla, y que están escritas al lado
  del skill para que nadie las descubra a mitad de camino:

  - **No viene con sus dependencias.** Su paso 3 lee las skills de dominio de
    Hyperframes (`hyperframes-core`, `-animation`, `-creative`, `-keyframes`,
    `-cli`), que no están ni acá ni en su upstream. Sin ellas no produce
    video.
  - **Pesa 17 MB**, casi todo pistas de música. Es el skill más pesado del
    framework por un margen grande, y viaja a cada proyecto que adopte. Si
    eso molesta, la salida es adoptarlo por proyecto y no por framework.

- **`.claude/skills/PROCEDENCIA.md`**, que dice de dónde salió cada skill, en
  qué versión está y cómo se actualiza. Un skill copiado sin rastro es un
  skill que nadie sabe actualizar.

  Además de `brag`, recoge lo que se aprendió usando las 7 de diseño y que
  hasta ahora vivía sólo en `restaurante-sistema`: que **el catálogo está
  indexado en inglés y una consulta en español falla en silencio**, que la
  redacción de la consulta cambia por completo el sistema que devuelve, y que
  hay que leer la columna «Do Not Use For» de los estilos que la propia
  herramienta recomienda. Eso es conocimiento del framework, no de un
  restaurante, y estaba del lado equivocado de la frontera
  (`docs/FRONTERAS.md`).

## 2.3.0 — 2026-09-20

**MENOR**: los 7 skills de diseño estaban **invisibles y vacíos**. Se restauran
completos. Un proyecto en 2.2.0 sigue funcionando igual; para adoptar esto hay
que borrar `mi-proyecto/.claude/skills/design/` y copiar en su lugar las siete
carpetas nuevas de `.claude/skills/`.

Qué pasó. Cuando los skills se adoptaron desde `retail-espacios` se copió sólo
el `SKILL.md` de cada uno, renombrado a `design/<nombre>.md`. De **172 archivos
quedaron 7**; de **4,7 MB quedaron 116 KB**. Y como Claude Code descubre un
skill por `skills/<nombre>/SKILL.md`, aplanarlos a un `.md` suelto dentro de
`design/` hizo que **ninguno se registrara como skill**: no aparecían en la
lista de skills disponibles de ninguna sesión, en ningún proyecto adoptante.
Servían sólo si alguien pasaba la ruta del archivo a mano, como documento.

Lo que faltaba no era relleno. `ui-ux-pro-max` sola perdió `styles.csv` (88
estilos, cada uno con paleta primaria y secundaria, efectos, para qué sirve,
**para qué no**, soporte de modo oscuro, accesibilidad y rendimiento),
`ui-reasoning.csv` (192 perfiles de producto con patrón recomendado, humor de
color, humor tipográfico, reglas de decisión y antipatrones), más
`colors.csv`, `typography.csv`, `google-fonts.csv`, `charts.csv`,
`motion.csv`, `ux-guidelines.csv`, los datos por stack y el `search.py` que los
consulta.

Cómo se notó. Cinco directores de diseño independientes, trabajando sobre el
mismo encargo en `restaurante-sistema`, entregaron **la misma dirección**:
misma tipografía, misma paleta, misma metáfora. Sin catálogo que consultar,
cinco instancias del mismo modelo improvisan desde los mismos priores y
convergen. Con los datos restaurados, una consulta por «restaurant food
ordering» devuelve recomendaciones que ninguna de las cinco había considerado.

Qué se conservó de 2.2.0: el `SKILL.md` de cada skill es el markdown que el
framework ya había curado (con la metadata `origin:` y las secciones que
estaban en chino ya traducidas), no el original de `retail-espacios`.

## 2.2.0 — 2026-09-20

**MENOR**: corrección de una falla sistemática del ciclo de conciliación. Un
proyecto en 2.1.0 sigue funcionando igual; si adopta esto, copia
`orquestador-general.js` y `.claude/skills/agentes/conciliador.md`, y anota la
versión en su `.claude/FRAMEWORK`.

- **El Conciliador verificaba contra el diff en vez de contra el árbol de
  trabajo.** En este framework **los agentes nunca commitean** —commitea el
  orquestador humano después de revisar—, así que en el momento en que corre el
  Conciliador el trabajo del equipo está sin commitear, y un dominio nuevo está
  además **sin trackear**: `git status` muestra la carpeta y no los archivos de
  adentro, y `git diff` no lo muestra en absoluto. El resultado era que el
  Conciliador declaraba «no está commiteado» como conflicto **bloqueante** sobre
  archivos que existían y estaban completos.

  Nació en **restaurante-sistema**, pedido 2c: `coherente: false` con tres
  bloqueantes que decían exactamente eso, con los ocho archivos presentes. El
  Maestro repitió el error al repartir los ajustes, porque el prompt le pedía no
  cuestionar el veredicto del Conciliador. Una ronda entera de iteraciones
  gastada en arreglar algo que no estaba roto.

  Tres cambios, que van juntos:
  - `ARBOL_ES_LA_VERDAD` en el orquestador reemplaza al `DIFF_HINT` anterior, que
    además afirmaba lo contrario de lo que pasa («el trabajo YA ESTÁ
    COMMITEADO»). `args.base` sigue siendo útil, pero como complemento.
  - Guardrail nuevo en `conciliador.md`: «no está commiteado» **nunca** es un
    conflicto; es el estado esperado de todo el trabajo del equipo.
  - El prompt de ajustes del Maestro gana **una sola excepción** a «no
    modifiques el veredicto del Conciliador»: todo conflicto que afirme que algo
    falta se verifica abriendo el archivo antes de mandar a nadie a rehacerlo.

## 2.1.0 — 2026-09-14

**MENOR**: capacidad nueva compatible en el orquestador. Un proyecto en 2.0.0 sigue
funcionando igual; si adopta esto, tiene que copiar `orquestador-general.js` y anotar
la versión en su `.claude/FRAMEWORK`.

- **`args.base` en el orquestador**: el commit base del pedido. El orquestador humano
  commitea snapshots mientras el equipo trabaja (para no perder horas de agentes si
  el contenedor muere); sin este parámetro, el Conciliador y la entrega del Maestro
  miran `git diff` contra un árbol ya commiteado, lo ven vacío y marcan como
  conflicto todo lo que los agentes declaran. Con `base`, comparan contra ese commit
  y contra `git status`. Nació en **restaurante-sistema**, pedido 1a: el primer run
  se conciliaba contra tres snapshots ya pusheados. Opcional; sin `base` el
  comportamiento es el de 2.0.0.
- Lección registrada en `docs/PATRONES.md`: en un equipo paralelo, cada hook cruzado
  entre dos territorios necesita un dueño del test de punta a punta. La entrega del
  pedido 1a de restaurante-sistema encontró dos defectos exactamente en las costuras
  que ningún agente probaba entero (un hook buscado en el módulo equivocado; un test
  de carrera sobre una fixture compartida entre hilos).

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
