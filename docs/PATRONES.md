# Patrones — sistemas-maestros

Patrones reutilizables extraídos de los **proyectos de referencia** (café-sistema,
retail-espacios) que cualquier sistema nuevo construido con este framework debería
considerar.

Los patrones están escritos **sin el dominio del que salieron**: «entidad que se
alquila por período», no «góndola». Esa traducción es el requisito para que un patrón
entre acá — ver [`FRONTERAS.md`](FRONTERAS.md). La mención al proyecto de origen se
conserva a propósito: saber de dónde vino un patrón es lo que permite juzgarlo cuando
el caso original ya se olvidó.

## Patrones de dominio

### Spine / eje operativo

Cuando el sistema tiene un ciclo operativo diario claro (ej. `DiaOperativo` en café-sistema: apertura de turno → operación → cierre), modelarlo como una entidad "spine" explícita de la que cuelgan las demás operaciones, en vez de derivar el "día operativo" implícitamente de timestamps. Facilita reportes, cortes de caja y auditoría.

**Guardrail**: no permitir operaciones (ventas, movimientos de caja) fuera de un spine abierto — el Backend Agent debe modelar esto como una restricción de estado, no como una validación opcional en el frontend.

### Producto sombra

Cuando existen combos o agrupaciones de precio fijo sobre productos individuales, modelarlos como un "producto sombra" que referencia a sus componentes, en vez de duplicar lógica de precio. El Analytics Agent debe tratar las líneas de combo por separado de las líneas de producto individual al calcular métricas, para no inflar ni desinflar el conteo real de unidades vendidas.

### Atribución sin FK dura

Cuando un dato de atribución (ej. quién atendió una venta) debe capturarse en un contexto de dispositivo/kiosco compartido sin login individual, preferir campos planos denormalizados (`barista_id` + `barista_nombre`) en vez de una FK estricta, cuando el caso de uso tolera esa relajación. El Contador/Legal Agent debe validar explícitamente si el dominio tolera esta relajación o si requiere integridad referencial estricta.

### Cascada FIFO de excedentes

Cuando un exceso de caja/inventario de un período debe absorberse hacia períodos anteriores, aplicar la cascada en orden FIFO explícito (más antiguo primero) y dejar registro de cada paso de la cascada. Nunca aplicar el excedente de forma implícita o en un solo movimiento agregado — el Contador Agent es responsable de exigir esta trazabilidad.

### Umbrales configurables, nunca en cero por defecto

Motores de alerta/reposición (stock mínimo/crítico, etc.) deben forzar la configuración explícita de umbrales antes de considerarse "activos". Un umbral en `0` por defecto deja el motor inerte sin que nadie lo note. El Backend Agent debe validar esto en el modelo (constraint o valor por defecto que fuerce configuración) y el Analytics Agent debe reportarlo si detecta umbrales en cero en producción.

## Patrones de proceso (multi-agente)

### Conciliación como gate, no como sugerencia

El Conciliador Agent no es opcional ni informativo: su veredicto (`coherente: true/false`) es el único criterio que el Maestro usa para decidir si el sistema está listo. Ningún agente constructor puede autodeclararse "terminado" sin pasar por esta validación cruzada.

### Ajuste de prompt dirigido, no relanzamiento ciego

Cuando el Conciliador detecta un conflicto bloqueante, el Maestro ajusta el prompt únicamente del agente `destino` del conflicto (ver `ajustarPromptsPorConflictos` en `orquestador-general.js`), no relanza a todos los agentes con el mismo prompt genérico. Esto evita que agentes que ya estaban correctos introduzcan nuevas inconsistencias.

### Límite de iteraciones con escalamiento explícito

`MAX_ITERATIONS` (default 3) evita loops infinitos de ajuste. Si se agota sin resolver todos los conflictos bloqueantes, el Maestro debe reportarlo explícitamente al usuario — nunca entregar un sistema con conflictos bloqueantes silenciados.

### Cada costura entre territorios tiene dueño del test de punta a punta

Cuando el Maestro reparte territorios disjuntos, los hooks cruzados (un dominio llama
una función del otro) quedan con dueño en cada extremo pero sin dueño del test que
los recorre enteros. Cada agente prueba su extremo llamando la función directo, y el
hook puede no correr jamás por HTTP sin que ningún test lo note. Regla: el contrato
interno que el Maestro deja para el equipo nombra, por cada hook cruzado, quién
escribe el test de punta a punta; y ofrece una fixture común de «una sesión por
request» para tests de carrera con hilos, porque una sesión compartida entre hilos
muere antes de llegar al índice único. Origen: restaurante-sistema, pedido 1a
(defectos D-1 y D-2 de la entrega, hallados por el Maestro en la verificación final).

### La suite completa es un recurso compartido

Los agentes corren en paralelo sobre el MISMO árbol de trabajo. Si cada uno decide que "verificar" es "correr toda la suite", N suites simultáneas compiten por CPU y se pisan los archivos temporales (bases SQLite de prueba que el teardown de una borra a la otra); un `npm run build` a mitad de una corrida borra `dist/` y produce errores falsos. La regla, inyectada en cada misión por `REGLA_VERIFICACION` en `orquestador-general.js`: cada builder y auditor corre SOLO los tests de su territorio más el typecheck, con `TMPDIR` propio; la suite completa y el build los corre UNA sola vez, en serie, el paso de verificación final, con el árbol quieto y sin procesos huérfanos.

## Guardrails generales (qué evitar)

- **No mezclar registro y caja real** sin dos capas explícitas (ver `DualModel` en `ARQUITECTURA.md`).
- **No exponer PII o datos financieros sensibles** a roles que no los necesitan — siempre pasa por Legal Agent.
- **No borrar físicamente registros financieros** — usar soft-delete con historial de auditoría.
- **No hardcodear reglas fiscales** sin que la spec las declare explícitamente para la región correspondiente.
- **No usar Zustand (o cualquier estado global)** si no hay sincronización real entre componentes — preferir estado local.
- **No inventar endpoints** en el frontend que el backend no expone — todo contrato de API nace en Backend Agent.
- **No aceptar coherencia parcial** — un conflicto bloqueante detiene la entrega, no se negocia por conveniencia de plazo.

## Ejemplos de instanciación

### Ejemplo: sistema de reservas para un consultorio

- **Spine**: `JornadaConsultorio` (apertura → turnos atendidos → cierre).
- **DualModel**: registro de cita vs. pago efectivamente recibido (puede haber citas sin pago inmediato).
- **Contador Agent**: valida que cada pago quede trazado a una cita y que no se pueda "borrar" una cita pagada sin dejar rastro.
- **Legal Agent**: valida que el historial clínico (si existe) no se exponga en el mismo endpoint que la agenda pública.
- **Analytics Agent**: KPI de tasa de ausentismo, ingresos por profesional, ocupación por franja horaria.

### Ejemplo: sistema de gestión de inventario para una tienda pequeña

- **Spine**: `CicloDeCompra` (orden de compra → recepción → disponible en venta).
- **Producto sombra**: combos de productos con precio fijo (ej. "kit de bienvenida").
- **Umbrales configurables**: stock mínimo/crítico por SKU, nunca en cero por defecto.
- **Contador Agent**: valida costo promedio ponderado vs. costo de última compra según lo que la spec declare.
