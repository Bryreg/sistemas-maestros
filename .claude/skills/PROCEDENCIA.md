# De dónde salió cada skill

Un skill copiado sin rastro es un skill que nadie sabe actualizar. Acá queda
qué es de este framework y qué vino de afuera, con su origen y su versión.

## Propios

`agentes` — del framework. Los roles del equipo y qué produce cada uno.

## De terceros

### `brag` — `latent-spaces/brag`

- **Upstream**: <https://github.com/latent-spaces/brag> (MIT, licencia en
  `brag/LICENSE-UPSTREAM`).
- **Versión adoptada**: `0.3.0`, commit `57ce4c9`.
- **Qué hace**: convierte el proyecto en un video corto de lanzamiento, con
  música y copy para compartir. Lee el código directo: no necesita una URL
  viva ni capturas.
- **Cómo actualizar**: `npx skills add https://github.com/latent-spaces/brag
  --skill brag`, o copiar `skills/brag/` del repositorio upstream sobre
  `.claude/skills/brag/`.

Su paso 3 no lo resuelve sola: delega la composición y el render a las skills
de dominio de Hyperframes, que están abajo. **Desde 2.5.0 vienen incluidas**;
en 2.4.0 no venían y el skill se registraba pero no producía video.

**Pesa 17 MB**, casi todo pistas de música en `assets/music/`. Es el skill más
pesado del framework por un margen grande, y viaja a cada proyecto que adopte.
Si eso molesta, la salida es adoptarlo por proyecto en vez de por framework.

### Hyperframes — `heygen-com/hyperframes`

El motor que `brag` usa para componer y renderizar. Son dos cosas separadas y
conviene no confundirlas:

- **El CLI** (`npx hyperframes`, paquete npm `hyperframes`, Apache-2.0) **no
  se guarda acá**: se baja solo al invocarlo. Verificado con 0.8.59.
- **Las skills de dominio** sí se guardan, porque son las que el agente lee
  para saber escribir una composición.

De las 21 que publica el upstream se adoptaron **siete**: las cinco que
`brag` nombra —`hyperframes-core`, `-animation`, `-creative`, `-keyframes`,
`-cli`— más `media-use` y `hyperframes-registry`, que son las únicas dos que
esas cinco citan y que sin ellas quedarían colgadas (`media-use` resuelve
música y SFX; `hyperframes-registry` es el catálogo de ~400 bloques y efectos
ya hechos). Son 326 archivos y 5,2 MB, contra 19 MB de las 21.

**Las catorce que faltan se dejaron afuera a propósito**, no por peso: entre
ellas están los orquestadores `hyperframes` y `product-launch-video`, y el
`SKILL.md` de `brag` dice literalmente que no hay que entrar en la entrevista
de intención del primero ni rutear al workflow genérico del segundo. Tenerlas
instaladas es invitar al agente a tomar el camino que `brag` prohíbe.

- **Versión adoptada**: skills del commit `6f6d242` del upstream, alineadas
  con el CLI `0.8.59`. Licencia en `LICENSE-UPSTREAM-hyperframes`.
- **Cómo actualizar**: `npx hyperframes skills update` **no sirve para esto**
  — instala en `~/.claude/skills/` y en `~/.agents/skills/`, o sea global y
  fuera del repo, y en un contenedor efímero eso se pierde. Para actualizar
  acá hay que volver a copiar las siete carpetas desde el upstream y subir la
  versión del framework. Lo que sí sirve es `npx hyperframes skills check`,
  que dice si lo instalado quedó atrás.

#### El motor necesita tres cosas del sistema que no viajan en el repo

Y las tres fallan de una forma que no se parece a su causa. Para eso está
`scripts/preparar-video.sh`, que las deja listas y es idempotente:

```bash
scripts/preparar-video.sh              # prepara y verifica
scripts/preparar-video.sh --verificar  # sólo informa
```

1. **Un ffmpeg completo.** No alcanza con que `ffmpeg` exista. El que trae
   Playwright en `/opt/pw-browsers/` está compilado con `--disable-everything`:
   encodea webm/VP8, no tiene H.264 ni `ffprobe`, y el render muere al final,
   después de gastar todos los frames. El script pregunta por `libx264`, no
   por el nombre del binario.
2. **Un navegador que arranque.** El que se baja puppeteer existe y aun así no
   arranca acá (`SIGTERM, ETIMEDOUT`). Hay que apuntarle a uno que sí con
   `HYPERFRAMES_BROWSER_PATH`. El script lo prueba arrancándolo, que es la
   única forma de saberlo.
3. **La CA del proxy en el almacén del navegador.** Chrome **no lee el almacén
   del sistema**: lee su propia base NSS en `~/.pki/nssdb`. Que la CA esté en
   `/etc/ssl/certs` no dice nada. Sin esto el navegador no baja GSAP del CDN y
   `hyperframes check` falla con `ERR_CERT_AUTHORITY_INVALID`, que parece un
   problema de la composición y no lo es.

#### Verificado de punta a punta, no sólo instalado

Con el entorno preparado, en este mismo contenedor:

- `npx hyperframes doctor` — todo lo obligatorio en verde.
- `npx hyperframes check` sobre una composición con animación — **`Check
  passed`**, que es exactamente la única compuerta que `brag` pone antes de
  renderizar.
- `npx hyperframes render` — MP4 de 15,0 s, 1920×1080, H.264 + AAC, 11 MB, en
  53 s. Se extrajeron frames y tienen imagen real.

Lo que quedó en rojo es opcional y sólo importa para usos que `brag` no
necesita: `whisper-cpp` (transcripción), Kokoro (sólo con `--voice`), MusicGen
(sólo como música de reemplazo, y `brag` trae la suya) y Docker (backend de
render alternativo).

### Las siete de diseño — `nextlevelbuilder/ui-ux-pro-max-skill`

`banner-design`, `brand`, `design`, `design-system`, `slides`, `ui-styling`,
`ui-ux-pro-max`.

- **Upstream**: <https://github.com/nextlevelbuilder/ui-ux-pro-max-skill>
  (MIT, © Next Level Builder).
- **Cómo actualizar**: `npm install -g ui-ux-pro-max-cli` y después
  `uipro init --ai claude --force` en la raíz del proyecto. El instalador
  escribe **sólo** `.claude/skills/` y no toca nada más — verificado
  corriéndolo en un directorio vacío antes de usarlo.
- **Divergencia local deliberada**: en `ui-ux-pro-max`, la sección «When to
  Apply» está traducida al inglés y upstream sigue en chino. Un
  `uipro init --force` la pisa.
- **Lo que el CLI no trae**: `ui-styling/canvas-fonts/` (82 archivos, 5,6 MB
  de TTF para el render por canvas). No se usan; si alguna vez hacen falta,
  salen del repositorio upstream.

Que los archivos estén no alcanza. El chequeo real es que la skill produzca:

```bash
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<producto>" --design-system
```

Tiene que devolver patrón, estilo, el set completo de tokens de color, el par
tipográfico con su URL de Google Fonts, efectos, lista de «avoid» y checklist
de pre-entrega.

#### Tres cosas que se aprendieron usándolas, y que cuestan rondas enteras

**1. La base está indexada en inglés, y una consulta en español falla en
silencio.** No devuelve «menos resultados»: detecta mal el dominio, busca en
el CSV equivocado y devuelve `Found: 0 results`. Quien no lo sabe cree que la
herramienta no tiene nada para su producto, vuelve a sus propios gustos, y no
se entera. **Consultá siempre en inglés**, aunque todo lo demás del proyecto
esté en español.

**2. La consulta es la palanca, no un detalle.** El mismo producto devuelve
sistemas de diseño completamente distintos según cómo se lo describa, y todas
las descripciones son ciertas: `restaurant food ordering` devuelve un estilo
vibrante en fondo claro con Playfair Display, y `cash control blind
reconciliation audit` devuelve OLED oscuro con Fira Code. El método que
funciona es correr **tres a seis descripciones distintas, comparar, y recién
ahí elegir** — dejando anotado cuál se eligió y por qué.

**3. El catálogo se contradice, y hay que leerlo entero.** `products.csv`
recomienda estilos que la columna **«Do Not Use For»** de `styles.csv` veta
para ese mismo caso. No es un error a corregir: es información. **Siempre leer
«Do Not Use For» de los estilos que la herramienta recomienda**, porque es
donde dice en qué caso su propia recomendación no sirve.

El registro de la verificación archivo por archivo contra el CLI 2.15.0 —con
los ejemplos concretos de cada una de las tres— está en
`restaurante-sistema/.claude/skills/PROCEDENCIA.md`, que es donde se hizo.
