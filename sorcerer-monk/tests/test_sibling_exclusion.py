from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
SM = (ROOT / "sorcerer-monk" / "setup-sorcerer-monk.tp2").read_text(encoding="utf-8")
SMC = (ROOT / "sorcerer-monk-cleric" / "setup-sorcerer-monk-cleric.tp2").read_text(encoding="utf-8")


class SiblingExclusionTests(unittest.TestCase):
    def test_sorcerer_monk_blocks_triple_class(self):
        self.assertIn(
            "REQUIRE_PREDICATE !MOD_IS_INSTALLED ~sorcerer-monk-cleric/setup-sorcerer-monk-cleric.tp2~ 0 @16",
            SM,
        )

    def test_triple_class_blocks_sorcerer_monk(self):
        self.assertIn(
            "REQUIRE_PREDICATE !MOD_IS_INSTALLED ~sorcerer-monk/setup-sorcerer-monk.tp2~ 0 @4",
            SMC,
        )

    def test_lunumab_guards_match_exact_row_names(self):
        self.assertNotIn("UNLESS ~MULTI2SORCERER~", SM)
        self.assertNotIn("UNLESS ~MULTI2MONK~", SM)
        self.assertIn(r"UNLESS ~^[ %TAB%]*MULTI2SORCERER\([ %TAB%]\|$\)~", SM)
        self.assertIn(r"UNLESS ~^[ %TAB%]*MULTI2MONK\([ %TAB%]\|$\)~", SM)


if __name__ == "__main__":
    unittest.main()
