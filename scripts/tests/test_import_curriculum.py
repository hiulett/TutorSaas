"""Pruebas de la importación del currículo (CUR-03). Sin red y sin base.

    python -m unittest discover -s scripts/tests -v
"""
import json
import sys
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

import import_curriculum as ic  # noqa: E402


class TranslationStatusTest(unittest.TestCase):
    def test_marca_identical_sin_corregir(self):
        self.assertEqual(ic.translation_status("Hello!", "Hello!"), "identical")

    def test_identical_ignora_mayusculas_y_espacios_exteriores(self):
        self.assertEqual(ic.translation_status("Hello!", " hello! "), "identical")

    def test_traduccion_real_es_ok(self):
        self.assertEqual(ic.translation_status("Hello!", "¡Hola!"), "ok")

    def test_sin_traduccion_es_pending(self):
        self.assertEqual(ic.translation_status("Hello!", ""), "pending")
        self.assertEqual(ic.translation_status("Hello!", None), "pending")

    def test_una_traduccion_solo_con_espacios_es_pending(self):
        self.assertEqual(ic.translation_status("Hello!", "   "), "pending")


class ObjectiveReviewTest(unittest.TestCase):
    """CUR-05: un objetivo débil lleva motivo, y solo entonces."""

    def goal(self, text="Say hello", keywords=None, example="Hello"):
        return {
            "id": "g1",
            "text": text,
            "keywords": ["hello", "hi"] if keywords is None else keywords,
            "examplePhrase": example,
        }

    def test_objetivo_sano_no_se_marca(self):
        self.assertEqual(ic.objective_review_reasons(self.goal()), [])

    def test_una_sola_palabra_clave_se_marca(self):
        self.assertEqual(
            ic.objective_review_reasons(self.goal(keywords=["name"])),
            [ic.REVIEW_SINGLE_KEYWORD],
        )

    def test_ejemplo_igual_al_texto_se_marca(self):
        self.assertEqual(
            ic.objective_review_reasons(
                self.goal(text="Order a coffee drink", example="Order a coffee drink")
            ),
            [ic.REVIEW_EXAMPLE_EQUALS_TEXT],
        )

    def test_los_dos_motivos_a_la_vez_conservan_el_orden(self):
        self.assertEqual(
            ic.objective_review_reasons(
                self.goal(text="Order a pastry", keywords=["pastry"], example="Order a pastry")
            ),
            [ic.REVIEW_SINGLE_KEYWORD, ic.REVIEW_EXAMPLE_EQUALS_TEXT],
        )

    def test_ignora_mayusculas_y_espacios_al_comparar_el_ejemplo(self):
        self.assertEqual(
            ic.objective_review_reasons(
                self.goal(text="Say hello", example="  say HELLO ")
            ),
            [ic.REVIEW_EXAMPLE_EQUALS_TEXT],
        )

    def test_un_ejemplo_vacio_no_cuenta_como_repetido(self):
        self.assertEqual(ic.objective_review_reasons(self.goal(example="")), [])

    def test_el_motivo_guardado_es_texto_y_no_lista(self):
        plan = ic.build_plan(
            [
                {
                    "id": "a1_00",
                    "title": "t",
                    "level": "A1",
                    "category": "daily",
                    "difficulty": 1,
                    "goals": [self.goal(keywords=["name"])],
                    "phrases": [],
                }
            ]
        )
        objective = plan["lessons"][0]["objectives"][0]
        self.assertTrue(objective["needs_review"])
        self.assertEqual(objective["review_reason"], ic.REVIEW_SINGLE_KEYWORD)


class DigestTest(unittest.TestCase):
    def test_estable_ante_el_orden_de_claves(self):
        self.assertEqual(
            ic.sha256_of({"b": 1, "a": [1, 2]}),
            ic.sha256_of({"a": [1, 2], "b": 1}),
        )

    def test_detecta_cambio_de_contenido(self):
        self.assertNotEqual(ic.sha256_of({"a": "uno"}), ic.sha256_of({"a": "dos"}))


class BuildPlanTest(unittest.TestCase):
    def lesson(self, lesson_id, level="A1", goals=3, phrases=3):
        return {
            "id": lesson_id,
            "title": lesson_id,
            "description": "d",
            "level": level,
            "category": "daily",
            "interest": "daily",
            "difficulty": 1,
            "iconKey": "school",
            "mainObjective": "m",
            "scenarioContext": "s",
            "assistantRole": "Teacher",
            "userRole": "Student",
            "initialAssistantMessage": "hi",
            "goals": [
                {"id": f"g{i}", "text": f"t{i}", "keywords": ["k"], "examplePhrase": "e"}
                for i in range(1, goals + 1)
            ],
            "phrases": [
                {"id": f"p{i}", "phrase": f"ph{i}", "translation": f"tr{i}"}
                for i in range(1, phrases + 1)
            ],
        }

    def test_cuatro_unidades_por_nivel_de_cinco_lecciones(self):
        lessons = [self.lesson(f"a1_{n:02d}") for n in range(20)]
        plan = ic.build_plan(lessons)
        self.assertEqual(len(plan["units"]), 4)
        self.assertEqual([unit["order_index"] for unit in plan["units"]], [1, 2, 3, 4])
        for unit in plan["units"]:
            assigned = [row for row in plan["lessons"] if row["unit_slug"] == unit["slug"]]
            self.assertEqual(len(assigned), 5)

    def test_order_index_unico_dentro_de_la_unidad(self):
        lessons = [self.lesson(f"a1_{n:02d}") for n in range(10)]
        plan = ic.build_plan(lessons)
        first = [row["order_index"] for row in plan["lessons"] if row["unit_slug"] == "a1-u1"]
        second = [row["order_index"] for row in plan["lessons"] if row["unit_slug"] == "a1-u2"]
        self.assertEqual(first, [1, 2, 3, 4, 5])
        self.assertEqual(second, [1, 2, 3, 4, 5])

    def test_ids_del_origen_intactos(self):
        lessons = [self.lesson("a2_reporting_a_lost_wallet")]
        plan = ic.build_plan(lessons)
        self.assertEqual(plan["lessons"][0]["id"], "a2_reporting_a_lost_wallet")
        self.assertEqual(
            plan["lessons"][0]["snapshot"]["id"], "a2_reporting_a_lost_wallet"
        )

    def test_conserva_palabras_clave_del_validador(self):
        plan = ic.build_plan([self.lesson("a1_00")])
        objective = plan["lessons"][0]["objectives"][0]
        self.assertEqual(objective["code"], "g1")
        self.assertEqual(objective["evidence_examples"]["keywords"], ["k"])
        self.assertEqual(objective["evidence_examples"]["example_phrase"], "e")

    def test_frases_numeradas_desde_uno(self):
        plan = ic.build_plan([self.lesson("a1_00", phrases=4)])
        self.assertEqual(
            [phrase["order_index"] for phrase in plan["lessons"][0]["phrases"]],
            [1, 2, 3, 4],
        )

    def test_hash_cambia_si_cambia_un_objetivo(self):
        original = self.lesson("a1_00")
        changed = self.lesson("a1_00")
        changed["goals"][0]["text"] = "otro"
        self.assertNotEqual(
            ic.build_plan([original])["lessons"][0]["hash"],
            ic.build_plan([changed])["lessons"][0]["hash"],
        )

    def test_nivel_se_normaliza_al_id_de_la_tabla(self):
        plan = ic.build_plan([self.lesson("prea1_00", level="PRE-A1")])
        self.assertEqual(plan["levels"], ["pre_a1"])
        self.assertEqual(plan["units"][0]["level_id"], "pre_a1")


class ExportedCatalogTest(unittest.TestCase):
    """Contra la exportación real de CUR-02, si está generada."""

    @classmethod
    def setUpClass(cls):
        if not ic.SOURCE.exists():
            raise unittest.SkipTest(f"falta {ic.SOURCE} (ejecuta scripts/audit_lessons.py)")
        cls.plan = ic.build_plan(ic.load_source())

    def test_conteos_del_inventario(self):
        summary = ic.summarize(self.plan)
        self.assertEqual(ic.check_expected(summary), [])
        self.assertEqual(summary["lessons"], 140)
        self.assertEqual(summary["objectives"], 540)
        self.assertEqual(summary["phrases"], 539)
        self.assertEqual(summary["identical"], 481)
        self.assertEqual(summary["weak"], 519)

    def test_motivos_de_los_objetivos_debiles(self):
        from collections import Counter

        reasons = Counter(
            objective["review_reason"]
            for row in self.plan["lessons"]
            for objective in row["objectives"]
            if objective["needs_review"]
        )
        self.assertEqual(reasons[ic.REVIEW_SINGLE_KEYWORD], 39)
        self.assertEqual(reasons[ic.REVIEW_EXAMPLE_EQUALS_TEXT], 480)
        self.assertEqual(sum(reasons.values()), 519)

    def test_objetivos_sanos_no_llevan_motivo(self):
        for row in self.plan["lessons"]:
            for objective in row["objectives"]:
                if not objective["needs_review"]:
                    self.assertIsNone(objective["review_reason"])

    def test_siete_niveles_y_veintiocho_unidades(self):
        self.assertEqual(self.plan["levels"], ["a1", "a2", "b1", "b2", "c1", "c2", "pre_a1"])
        self.assertEqual(len(self.plan["units"]), 28)

    def test_cinco_lecciones_por_unidad_y_orden_sin_huecos(self):
        from collections import Counter

        per_unit = Counter(row["unit_slug"] for row in self.plan["lessons"])
        self.assertEqual(set(per_unit.values()), {5})
        for unit in self.plan["units"]:
            indexes = [
                row["order_index"]
                for row in self.plan["lessons"]
                if row["unit_slug"] == unit["slug"]
            ]
            self.assertEqual(sorted(indexes), [1, 2, 3, 4, 5])

    def test_ids_unicos_y_sin_cambios(self):
        ids = [row["id"] for row in self.plan["lessons"]]
        self.assertEqual(len(ids), len(set(ids)))
        self.assertTrue(all(row["snapshot"]["id"] == row["id"] for row in self.plan["lessons"]))

    def test_difficulty_dentro_del_check_de_la_migracion(self):
        difficulties = {row["difficulty"] for row in self.plan["lessons"]}
        self.assertTrue(difficulties <= set(range(1, 7)), difficulties)

    def test_ninguna_leccion_sin_titulo(self):
        # Regresión: `title: "I Don't Understand"` usa comillas dobles en el
        # catálogo y se exportaba como null.
        self.assertEqual([row["id"] for row in self.plan["lessons"] if not row["title"]], [])

    def test_traducciones_identicas_se_conservan_tal_cual(self):
        for row in self.plan["lessons"]:
            for phrase in row["phrases"]:
                if phrase["translation_status"] == "identical":
                    self.assertEqual(phrase["phrase"], phrase["translation"])

    def test_cada_objetivo_y_frase_cabe_en_la_clave_unica(self):
        for row in self.plan["lessons"]:
            codes = [objective["code"] for objective in row["objectives"]]
            self.assertEqual(len(codes), len(set(codes)), row["id"])
            positions = [phrase["order_index"] for phrase in row["phrases"]]
            self.assertEqual(len(positions), len(set(positions)), row["id"])

    def test_hash_estable_tras_ida_y_vuelta_por_json(self):
        # El snapshot viaja a jsonb y vuelve: el hash debe seguir igual.
        roundtrip = json.loads(json.dumps(ic.load_source(), ensure_ascii=False))
        again = ic.build_plan(roundtrip)
        self.assertEqual(
            [row["hash"] for row in again["lessons"]],
            [row["hash"] for row in self.plan["lessons"]],
        )


if __name__ == "__main__":
    unittest.main()
