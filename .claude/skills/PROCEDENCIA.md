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

**Dependencia que NO viene incluida y sin la cual no produce video**: su paso 3
lee las skills de dominio de Hyperframes (`hyperframes-core`,
`hyperframes-animation`, `hyperframes-creative`, `hyperframes-keyframes`,
`hyperframes-cli`). No están en este repositorio ni en el upstream de `brag`:
hay que instalarlas aparte antes de usarla.

**Pesa 17 MB**, casi todo pistas de música en `assets/music/`. Es el skill más
pesado del framework por un margen grande, y viaja a cada proyecto que adopte.
Si eso molesta, la salida es adoptarlo por proyecto en vez de por framework.

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
