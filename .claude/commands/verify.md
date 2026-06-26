---
name: verify
description: Definition of Done — recorre cada criterio de aceptación contra el código y el comportamiento real
argument-hint: "[NNN-slug]"
---

Estás en la fase **Verify** del flujo SDD (ver `specs/README.md`) — la que cierra la feature. Para: $ARGUMENTS

1. Delegá al agente **`validator`** la recolección de evidencia: que recorra **cada criterio de aceptación** de `specs/NNN-slug/spec.md` contra el código (`archivo:línea`) y, si aplica, contra los tests del repo (`{{TEST_COMMAND}}`). Si la feature expone una superficie ejecutable que se pueda ejercitar de afuera (API, CLI, librería con harness), puede invocar el agente **`e2e-tester`** (OPCIONAL) para correrla de verdad. Que devuelva una tabla AC × evidencia × veredicto sugerido.
2. Marcá cada criterio ✅ (cumplido y verificado) o ❌ (con evidencia de por qué falla) en `spec.md`. No asumas: comprobá. **Si al verificarlo un criterio de aceptación resulta ambiguo** (no queda claro qué evidencia cuenta como cumplido o qué escenario validar), **no asumas el veredicto: corré el protocolo `clarify`** (skill `clarify`) y preguntame qué evidencia cuenta / qué escenario validar, con un default sugerido + la opción "que decida la IA". Mientras una ambigüedad de un criterio quede sin resolver (`[VERIFICAR]`), ese criterio no se tilda ✅.
3. Si hay algún ❌ → la feature NO está done; listá qué falta y volvé a implementación.
4. Si **todos** ✅ → poné `status: done` en la `spec.md` y actualizá el `INDEX.md`. Si la feature tiene `contract.md`, pasalo a `shipped` y completá su sección de evidencia.
5. **Gate de doc-sync (OPCIONAL):** si tu proyecto mantiene documentación/artefactos derivados de la interfaz (ej. doc de API publicada, snapshot de schema), regenerala y confirmá que quedó sincronizada; si no aplica, dejalo explícito como N/A.
6. **Al shipear un `contract.md` (OPCIONAL — multi-repo):** si la feature shipea/cambia una interfaz que otros repos consumen, corré el checklist **"al shipear un contrato"** de `specs/README.md` (avisar a `consumers:`, actualizar INDEX, registrar el cambio en el outbox del consumidor).

Nunca declares "done" sin haber tildado cada criterio de aceptación con evidencia.
