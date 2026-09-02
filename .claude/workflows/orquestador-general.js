/**
 * Orquestador General — sistemas-maestros
 *
 * Coordina 5 agentes constructores (Frontend, Backend, Contador, Legal, Analytics)
 * en paralelo, seguidos de un Conciliador que valida coherencia entre sus outputs.
 * El Maestro (Fable) decide si itera o entrega según el veredicto del Conciliador.
 *
 * Ver:
 *   .claude/skills/agentes/agente-frontend.md
 *   .claude/skills/agentes/agente-backend.md
 *   .claude/skills/agentes/agente-contador.md
 *   .claude/skills/agentes/agente-legal.md
 *   .claude/skills/agentes/agente-analytics.md
 *   .claude/skills/agentes/conciliador.md
 *   .claude/skills/agentes/maestro-fable.md
 */

export const meta = {
  name: 'orquestador-sistema-maestro',
  description: 'Orquestación multi-agente para construcción de sistemas complejos',
  phases: [
    { title: 'Disparo', detail: 'Lanzar los 5 agentes especializados en paralelo (Frontend, Backend, Contador, Legal, Analytics)' },
    { title: 'Conciliación', detail: 'Validar coherencia entre outputs y resolver conflictos' },
    { title: 'Iteración', detail: 'Si falta algo, ajustar prompts específicos y relanzar la Fase 1' }
  ]
}

const MAX_ITERATIONS = 3

/**
 * Ajusta los prompts de los agentes involucrados en conflictos bloqueantes,
 * inyectando el contexto del conflicto detectado por el Conciliador.
 *
 * @param {object} basePrompts - prompts base por agente para esta spec
 * @param {Array<{id:string, origen:string, destino:string, descripcion:string, severidad:string}>} conflicts
 * @returns {object} prompts ajustados por agente
 */
function ajustarPromptsPorConflictos(basePrompts, conflicts) {
  const ajustados = { ...basePrompts }
  const bloqueantes = conflicts.filter((c) => c.severidad === 'bloqueante')

  for (const conflicto of bloqueantes) {
    // El agente "destino" es quien debe resolver el gap detectado.
    const agente = conflicto.destino
    if (!ajustados[agente]) continue

    ajustados[agente] += `\n\nCORRECCIÓN REQUERIDA (conflicto ${conflicto.id}): ${conflicto.descripcion}. Ajustá tu output en esta iteración para resolverlo.`
  }

  return ajustados
}

/**
 * Punto de entrada del Maestro Orquestador.
 * @param {string} specDelUsuario - idea/spec en lenguaje natural
 */
async function main(specDelUsuario) {
  const spec = specDelUsuario

  const results = {
    frontend: null,
    backend: null,
    accounting: null,
    legal: null,
    analytics: null,
    conflicts: [],
    historial: []
  }

  let prompts = {
    frontend: `Construir frontend según spec:\n${spec}`,
    backend: `Construir backend según spec:\n${spec}`,
    accounting: `Validar contabilidad según spec:\n${spec}`,
    legal: `Validar compliance según spec:\n${spec}`,
    analytics: `Diseñar analytics según spec:\n${spec}`
  }

  let iteration = 0

  while (iteration < MAX_ITERATIONS) {
    iteration++
    console.log(`\n=== ITERACIÓN ${iteration} ===\n`)

    // Fase 1: Disparo paralelo de los 5 agentes constructores
    const [frontend, backend, accounting, legal, analytics] = await Promise.all([
      agent(prompts.frontend, { model: 'claude-sonnet-5', label: 'builder:frontend' }),
      agent(prompts.backend, { model: 'claude-sonnet-5', label: 'builder:backend' }),
      agent(prompts.accounting, { model: 'claude-opus-5', label: 'builder:accounting' }),
      agent(prompts.legal, { model: 'claude-opus-5', label: 'builder:legal' }),
      agent(prompts.analytics, { model: 'claude-haiku-4-5-20251001', label: 'builder:analytics' })
    ])

    results.frontend = frontend
    results.backend = backend
    results.accounting = accounting
    results.legal = legal
    results.analytics = analytics

    // Fase 2: Conciliación
    const conciliationPrompt = [
      'Revisar coherencia entre todos los outputs de esta iteración.',
      `Frontend: ${JSON.stringify(frontend)}`,
      `Backend: ${JSON.stringify(backend)}`,
      `Contador: ${JSON.stringify(accounting)}`,
      `Legal: ${JSON.stringify(legal)}`,
      `Analytics: ${JSON.stringify(analytics)}`
    ].join('\n\n')

    const conciliation = await agent(conciliationPrompt, {
      model: 'claude-haiku-4-5-20251001',
      label: 'reconciliation'
    })

    results.conflicts = conciliation.conflicts ?? []

    results.historial.push({
      iteration,
      conflicts: results.conflicts,
      coherente: conciliation.coherente ?? results.conflicts.length === 0
    })

    const bloqueantes = results.conflicts.filter((c) => c.severidad === 'bloqueante')

    if (bloqueantes.length === 0) {
      console.log('Todo coherente. Sistema listo.')
      break
    }

    console.log(`${bloqueantes.length} conflicto(s) bloqueante(s). Reiterando...`)

    // Fase 3: Iteración — el Maestro ajusta prompts según conflictos detectados
    prompts = ajustarPromptsPorConflictos(prompts, results.conflicts)

    if (iteration === MAX_ITERATIONS) {
      console.log(`Se alcanzó MAX_ITERATIONS (${MAX_ITERATIONS}) con conflictos sin resolver. Reportando al usuario.`)
    }
  }

  return results
}

export { main, ajustarPromptsPorConflictos, MAX_ITERATIONS }
