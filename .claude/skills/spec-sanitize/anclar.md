<!-- Cargado bajo demanda por spec-sanitize (--anclar) y por /verify ante un AC sin anclar. -->

# Anclar: primero buscar, después escribir

Cuando llegás acá ya entendiste las reglas de negocio de la spec, y **ese entendimiento no se vuelve a pagar tan barato**: cargar y comprender la spec es lo caro; anclar es el costo marginal. Pero en este orden, porque el orden es casi todo el valor.

## 1. Buscá el test que YA existe

Casi siempre existe. Un criterio "sin test" suele estar **testeado pero sin citar**: el test se escribió antes de que existiera el ancla, o con otro nombre. Buscá por **conducta**, no por el número de spec (buscando el número no vas a encontrar nada, que es justo por lo que figura sin anclar):

```bash
# la clase/módulo bajo prueba y el nombre de la regla
grep -rln "<ModuloDeLaFeature>" <carpeta de tests>
grep -rn "<NombreDelMetodo>\|<NombreDeLaRegla>" <carpeta de tests>
```

## 2. Si existe → anclalo. Cero código nuevo.

Es el caso mayoritario y el más barato: se le agrega el ancla `Spec`/`AC` con la forma de `AGENTS.md > Testing` (`CONSTITUTION.md §5`) y nada más.

```
[EJEMPLO — reemplazar por la forma de tu stack]
[Trait("Spec", "012")] [Trait("AC", "AC3")]          # xUnit
@pytest.mark.spec("012") @pytest.mark.ac("AC3")       # pytest
```

**Un test que ya pasa no se reescribe** para que "quede lindo": se le agrega el ancla y nada más.

## 3. Si NO existe → escribilo desde el CÓDIGO, nunca desde el papel

Acá está el riesgo real. Un test derivado de la spec **certifica lo que la spec cree**, no lo que el sistema hace. Si el papel dice una cosa y el código hace otra, hay dos salidas y una es venenosa: la buena es que el test falle y aparezca la divergencia; la mala es "ajustar" el test al código y bendecir el drift con un check verde.

1. Leé **la implementación** de la regla antes de escribir la aserción.
2. Si el código **coincide** con el AC → escribí el test contra el código, con el ancla del punto 2.
3. Si el código **contradice** el AC → **no escribas el test.** Reportá la divergencia: es un bug o un AC stale, y cuál de los dos es **decisión humana**.
4. Si el AC no es testeable a nivel unitario (solo se confirma en vivo) → marcalo para `e2e-tester` y seguí. **No lo simules.**

> **El test tiene que fallar si rompés la conducta.** Si la aserción pasa con el método vaciado, no ancla nada: es un "no es nulo" disfrazado, escrito para satisfacer el gate. Eso es peor que no tener test, porque miente en verde.

Valen los estándares del repo tal cual (`CLAUDE.md > Testing Standards`): categoría obligatoria, las matrices de escenarios donde apliquen, y diagnosticar antes de arreglar un rojo.

## Por qué es opt-in

El resto de la skill toca solo `specs/` (y algún comentario); ahí está su garantía de no trabar a nadie. Anclar escribe en los tests, que pueden estar en movimiento:

```bash
git log --since="14 days ago" --oneline -- <carpeta de tests> | wc -l
```

Si la carpeta de tests está en movimiento, anclá en un commit aparte del de la compactación.
