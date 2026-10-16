---
name: verify
description: Definition of Done — corre los tests de la spec, recorre cada criterio de aceptación contra los tests que lo citan y, si todo está ✅, cierra la spec en su forma mínima
argument-hint: "[NNN-slug]"
---

Estás en la fase **Verify** del flujo SDD (ver `specs/README.md`) — la que cierra la feature. Para: $ARGUMENTS

1. Delegá al agente **`validator`** la recolección de evidencia: que corra `{{SPEC_TEST_COMMAND}}` (los tests de la spec), busque por cada criterio de aceptación de `specs/NNN-slug/spec.md` el test que lo **cita** con el ancla `Spec`/`AC` (`CONSTITUTION.md §5`) y devuelva una tabla AC × evidencia × veredicto sugerido. Si la feature expone una superficie ejecutable que se pueda ejercitar de afuera (API, CLI, librería con harness), los criterios `requires-live` los valida **después** el agente **`e2e-tester`** (OPCIONAL).
2. Marcá cada criterio ✅ (cumplido y verificado) o ❌ (con evidencia de por qué falla) en `spec.md`. No asumas: comprobá. **Si al verificarlo un criterio de aceptación resulta ambiguo** (no queda claro qué evidencia cuenta como cumplido o qué escenario validar), **no asumas el veredicto: corré el protocolo `clarify`** (skill `clarify`) y preguntame qué evidencia cuenta / qué escenario validar, con un default sugerido + la opción "que decida la IA". Mientras una ambigüedad de un criterio quede sin resolver (`[VERIFICAR]`), ese criterio no se tilda ✅.
3. Si hay algún ❌ → la feature NO está done; listá qué falta y volvé a implementación. Un criterio **sin test que lo cite** es ❌ aunque el código parezca cumplirlo: antes de escribir un test, buscá el que ya existe y anclalo; uno nuevo se escribe desde el código, no desde el papel (`.claude/skills/spec-sanitize/anclar.md`).
4. Si **todos** ✅:
   - `spec.md` → `status: done` y los criterios tildados. Si la feature tiene `contract.md`, pasalo a `shipped` con su §8 en una línea (`Tests: {{SPEC_TEST_COMMAND}} en verde.`).
   - **Compactá la spec a la forma mínima** con la skill **`spec-sanitize`** (`NNN --cierre`): borra `plan.md`/`tasks.md` y el andamio de la spec, reescribe las decisiones como reglas, poda lo que ya dicen el código y los tests y conserva los rótulos que cita el código (`CONSTITUTION.md §6`). Su reporte va en el de `/verify`; lo que siga abierto, a una línea del backlog del `INDEX.md`.
   - Actualizá la fila del `INDEX.md` y corré **`/validate-specs`**: tiene que dar 0 errores.
5. **Gate de doc-sync (OPCIONAL):** si tu proyecto mantiene documentación/artefactos derivados de la interfaz (ej. doc de API publicada, snapshot de schema), regenerala y confirmá que quedó sincronizada; si no aplica, dejalo explícito como N/A.
6. **Al shipear un `contract.md` (OPCIONAL — multi-repo):** si la feature shipea/cambia una interfaz que otros repos consumen, corré el checklist **"al shipear un contrato"** de `specs/README.md` (avisar a `consumers:`, actualizar INDEX, registrar el cambio en el outbox del consumidor).

Nunca declares "done" sin que cada criterio tenga un test que lo cite en verde.
