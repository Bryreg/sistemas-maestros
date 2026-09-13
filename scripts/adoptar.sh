#!/usr/bin/env bash
#
# Adoptar sistemas-maestros en un proyecto nuevo.
#
#   scripts/adoptar.sh /ruta/al/proyecto "Nombre del proyecto"
#   scripts/adoptar.sh --verificar        # prueba la adopción en un temporal y limpia
#
# Por qué existe, si `cp -r .claude/ mi-proyecto/` hace casi lo mismo: el `cp` no
# deja rastro de QUÉ VERSIÓN se copió. Sin ese rastro, seis meses después nadie
# puede decir si un proyecto quedó atrás del framework o si se apartó a propósito
# —y esa duda es la que termina con alguien copiando archivos sueltos de un
# proyecto a otro «para emparejar», que es como se mezclan dos sistemas.
#
# Este script copia, estampa la versión, y deja el proyecto con los dos archivos
# que tiene que completar: su AGENTS.md (lo que se aparta de las reglas globales)
# y su docs/ESTADO.md (el documento vivo). Ninguno de los dos se inventa solo.

set -euo pipefail

raiz="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(cat "$raiz/VERSION")"

uso() {
  sed -n '3,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-1}"
}

verificar() {
  # La adopción se prueba de verdad: se adopta a un temporal, se comprueba lo que
  # tiene que haber quedado, y se borra. Un script de andamiaje que nunca se corrió
  # es un script roto que todavía no se sabe.
  # `tmp` a propósito NO es local: la trampa de limpieza corre al salir del
  # script, no de la función, y con `set -u` una variable local ya fuera de
  # alcance ahí aborta con «unbound variable» justo después de haber pasado.
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  "$0" "$tmp/proyecto-de-prueba" "Proyecto de prueba" >/dev/null

  local faltan=0
  for archivo in .claude/AGENTS.md .claude/FRAMEWORK .claude/workflows/orquestador-general.js \
                 .claude/skills/agentes/maestro-fable.md AGENTS.md docs/ESTADO.md; do
    if [[ ! -f "$tmp/proyecto-de-prueba/$archivo" ]]; then
      echo "FALTA: $archivo" >&2; faltan=1
    fi
  done
  grep -q "$version" "$tmp/proyecto-de-prueba/.claude/FRAMEWORK" \
    || { echo "FALTA: la versión no quedó estampada" >&2; faltan=1; }
  grep -q "Proyecto de prueba" "$tmp/proyecto-de-prueba/AGENTS.md" \
    || { echo "FALTA: el nombre del proyecto no llegó al AGENTS.md" >&2; faltan=1; }

  if [[ $faltan -eq 0 ]]; then
    echo "adoptar.sh: la adopción deja el proyecto completo (framework $version)"
  else
    exit 1
  fi
}

[[ "${1:-}" == "--verificar" ]] && { verificar; exit 0; }
[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && uso 0
[[ $# -lt 2 ]] && uso

destino="$1"
nombre="$2"

if [[ -e "$destino/.claude" ]]; then
  echo "«$destino» ya tiene un .claude/. No se pisa: si querés actualizar el" >&2
  echo "framework de un proyecto que ya lo adoptó, hacelo archivo por archivo y" >&2
  echo "anotá la versión nueva en su .claude/FRAMEWORK y en docs/PROYECTOS.md." >&2
  exit 1
fi

mkdir -p "$destino/docs"
cp -R "$raiz/.claude" "$destino/.claude"

cat > "$destino/.claude/FRAMEWORK" <<EOF
sistemas-maestros $version
adoptado: $(date +%Y-%m-%d)

Este proyecto adoptó el framework en esta versión. Si el repo del framework está
más adelante, este proyecto está ATRÁS — lo cual está bien mientras sea una
decisión y no un olvido. Al actualizar, cambiar esta versión y la fila de este
proyecto en docs/PROYECTOS.md del framework.
EOF

cat > "$destino/AGENTS.md" <<EOF
# AGENTS.md — $nombre

Hereda todas las reglas globales de \`.claude/AGENTS.md\` (framework
sistemas-maestros $version). **Acá va únicamente lo que este proyecto hace
DISTINTO**, y cada excepción con su por qué: una regla global que se aparta en
silencio es una regla que no existe.

## Dominio

_(Qué hace este sistema, en tres líneas. Quién lo usa y para qué.)_

## Lo que se aparta de las reglas globales

| Regla global | Qué hace este proyecto | Por qué |
|---|---|---|
| _(ninguna todavía)_ | | |

Candidatas habituales: stack distinto del default (FastAPI + React), régimen fiscal
de un país que no sea Colombia, un idioma de UI distinto del español, un agente
agregado o desactivado.

## Verificación mínima

_(Los comandos que tienen que pasar antes de dar algo por hecho. Concretos: el
typecheck, la suite, el arranque. Sin esto, «listo» no significa nada.)_
EOF

cat > "$destino/docs/ESTADO.md" <<EOF
# $nombre — estado del proyecto

Documento de referencia para retomar el trabajo sin reconstruir el contexto.
Última actualización: $(date +%Y-%m-%d) (adopción del framework sistemas-maestros $version).

**Este documento es VIVO.** Si un cambio altera una regla o un flujo descrito acá,
se actualiza en el MISMO PR que el cambio. Un estado desactualizado miente con más
autoridad que no tener estado.

---

## Cómo corre

_(Comandos reales de arranque local, puertos, variables de entorno necesarias.)_

## Reglas duras

_(Las decisiones que no se renegocian y por qué. Las que si alguien las toca sin
saber, rompe algo que no se ve en pantalla.)_

## Qué está hecho

_(Por área. Con el porqué de cada decisión grande, no sólo el qué.)_

## Dónde retomar

_(Los hilos abiertos, en orden, con lo que YA se averiguó de cada uno para que
nadie lo vuelva a averiguar.)_
EOF

echo "Framework $version adoptado en «$destino» ($nombre)."
echo
echo "Falta, y no lo puede hacer el script:"
echo "  1. Completar $destino/AGENTS.md — qué hace distinto este proyecto."
echo "  2. Completar $destino/docs/ESTADO.md — arranque y reglas duras."
echo "  3. Ajustar $destino/.claude/launch.json a los comandos y puertos reales."
echo "  4. Anotar el proyecto en docs/PROYECTOS.md del framework."
