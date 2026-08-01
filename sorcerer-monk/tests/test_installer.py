from pathlib import Path
import re
import unittest


TP2 = (Path(__file__).resolve().parents[1] / "setup-sorcerer-monk.tp2").read_text(encoding="utf-8")


def payloads(directive, table):
    pattern = rf"{directive}\s+~{re.escape(table)}~\s+~([^~]*)~"
    return re.findall(pattern, TP2, flags=re.IGNORECASE)


class InstallerTests(unittest.TestCase):
    def test_backup_path_preserves_v19_upgrades(self):
        self.assertTrue(TP2.startswith("BACKUP ~sorcerer-monk-cleric/backup~"))
        self.assertNotIn("BACKUP ~sorcerer-monk/backup~", TP2)

    def test_split_class_metadata(self):
        class_rows = payloads("APPEND", "classes.2da")
        self.assertIn("SORCERER_MONK * 786432 0x20040000 -1 0 9", class_rows)
        self.assertIn("SORCERER_MONK 1 0 0 0 0 0 0", payloads("APPEND", "clsrcreq.2da"))
        self.assertIn("SORCERER_MONK *", payloads("APPEND", "hpclass.2da"))

    def test_native_ee_clastext_variants(self):
        self.assertIn("ACTION_IF sm_clastext_cols = 9", TP2)
        self.assertIn("ACTION_IF sm_clastext_cols = 10", TP2)
        self.assertIn(
            "SORCERER_MONK %sm_class_id% 16384 %sm_lower% %sm_desc% %sm_mixed% -1 0 %sm_brief%",
            TP2,
        )
        self.assertIn(
            "SORCERER_MONK %sm_class_id% 16384 %sm_lower% %sm_desc% %sm_mixed% -1 0 %sm_brief% -1",
            TP2,
        )

    def test_released_class_metadata(self):
        class_rows = payloads("APPEND", "classes.2da")
        self.assertIn(
            "SORCERER_MONK %sm_lower% %sm_desc% %sm_mixed% * 786432 %sm_class_id% * 0x20040000 -1 1 0 0 0 0 0 0 0 9",
            class_rows,
        )

    def test_class_registration_uses_allocated_id(self):
        self.assertIn("%sm_class_id% SORCERER_MONK", payloads("APPEND", "class.ids"))
        fist_rows = payloads("APPEND", "fistweap.2da")
        self.assertEqual(len(fist_rows), 1)
        self.assertTrue(fist_rows[0].startswith("%sm_class_id% MFIST1 MFIST1 MFIST1"))

    def test_class_id_matches_clskills_row_index(self):
        self.assertNotIn("sm_candidate_id", TP2)
        self.assertIn("OUTER_SET sm_expected_class_id = sm_clskills_id", TP2)
        self.assertIn("OUTER_SET sm_expected_class_id = sm_clskills_rows", TP2)
        self.assertIn("sm_expected_class_id > 31", TP2)
        self.assertEqual(TP2.count("sm_existing_id = sm_expected_class_id"), 2)
        self.assertIn("sm_class_id != sm_expected_class_id", TP2)
        self.assertIn("OUTER_SET sm_class_id = sm_expected_class_id", TP2)

    def test_exact_class_token_guards_do_not_match_triple_class(self):
        self.assertNotIn("UNLESS ~SORCERER_MONK~", TP2)
        guard = r"UNLESS ~\(^\|[ %TAB%]\)SORCERER_MONK\([ %TAB%]\|$\)~"
        self.assertGreaterEqual(TP2.count(guard), 20)
        token = re.compile(r"(^|[ \t])SORCERER_MONK([ \t]|$)", re.MULTILINE)
        self.assertIsNotNone(token.search("SORCERER_MONK 1 2 3"))
        self.assertIsNotNone(token.search("21 SORCERER_MONK"))
        self.assertIsNotNone(token.search("  SORCERER_MONK\t"))
        self.assertIsNone(token.search("SORCERER_MONK_CLERIC 1 2 3"))

    def test_legacy_nonproficiency_penalty_follows_monk(self):
        self.assertIn("OUTER_SPRINT sm_no_prof ~-3~", TP2)
        self.assertIn("STRING_EQUAL_CASE ~MONK~", TP2)
        self.assertIn("READ_2DA_ENTRY_FORMER ~sm_clskills~ sm_i 12 sm_no_prof", TP2)
        self.assertNotIn("OUTER_SPRINT sm_no_prof ~-4~", TP2)

    def test_sorcerer_and_monk_features_are_combined(self):
        clskills_rows = payloads("APPEND", "clskills.2da")
        self.assertEqual(len(clskills_rows), 2)
        for row in clskills_rows:
            self.assertIn("MXSPLSRC", row)
            self.assertIn("SKILLS", row)
            self.assertIn("CLABMO01", row)
        self.assertIn("$ $ SORCERER_MONK 0 0 1 1 1 0 0", payloads("APPEND_COL", "thiefscl.2da"))

    def test_combined_ability_prerequisites(self):
        self.assertIn("SORCERER_MONK 0 9 9 9 9 9", payloads("APPEND", "abclasrq.2da"))
        self.assertIn("SORCERER_MONK 0 0 0 0 0 0", payloads("APPEND", "abclsmod.2da"))

    def test_modern_monk_skill_progression(self):
        self.assertIn("SORCERER_MONK 0 10", payloads("APPEND", "thiefskl.2da"))
        self.assertNotIn("SORCERER_MONK 10 5", payloads("APPEND", "thiefskl.2da"))

    def test_legacy_monk_skill_progression(self):
        legacy_rows = payloads("APPEND_COL", "skills.2da")
        expected = "$ $ SORCERER_MONK 10 10 -1 -1 1 1 1 -1 -1"
        self.assertIn(expected, legacy_rows)
        self.assertNotIn("$ $ SORCERER_MONK 10 10 -1 -1 -1 1 1 -1 -1", legacy_rows)
        values = expected.split()[3:]
        self.assertEqual(values, ["10", "10", "-1", "-1", "1", "1", "1", "-1", "-1"])

    def test_gameplay_restrictions(self):
        self.assertIn("SORCERER_MONK 1 1 1 0 0 0 0 0 0", payloads("APPEND", "alignmnt.2da"))

    def test_proficiency_progression_uses_fastest_component(self):
        prof_rows = payloads("APPEND", "profs.2da")
        self.assertIn("SORCERER_MONK 2 4", prof_rows)
        self.assertNotIn("SORCERER_MONK 2 5", prof_rows)

    def test_xp_cap_is_inherited_from_components(self):
        self.assertNotIn("SORCERER_MONK 8000000", TP2)
        self.assertIn("OUTER_SET sm_xpcap = (0 - 2)", TP2)
        self.assertIn("STRING_EQUAL_CASE ~SORCERER~", TP2)
        self.assertIn("STRING_EQUAL_CASE ~MONK~", TP2)
        self.assertIn("sm_xpcap_value = (0 - 1)", TP2)
        self.assertIn("SET sm_xpcap = (0 - 1)", TP2)
        self.assertIn("sm_xpcap_value < sm_xpcap", TP2)
        self.assertIn("SORCERER_MONK %sm_xpcap%", payloads("APPEND", "xpcap.2da"))
        self.assertIn("ACTION_IF sm_xpcap < (0 - 1)", TP2)
        self.assertIn("FAIL @14", TP2)

    def test_starting_gold_matches_components(self):
        self.assertIn("SORCERER_MONK 4 1 1 10", payloads("APPEND", "strtgold.2da"))

    def test_bgee_starts_unarmed(self):
        self.assertIn("SORCERER_MONK", payloads("APPEND", "stweapon.2da"))

    def test_quick_weapon_slots_use_restrictive_component(self):
        self.assertIn("SORCERER_MONK 2", payloads("APPEND", "numwslot.2da"))

    def test_monk_combat_progression_is_preserved(self):
        self.assertIn("SORCERER_MONK 1 3 2", payloads("APPEND", "clswpbon.2da"))

    def test_multiclass_fist_progression_uses_conservative_average_level_mapping(self):
        fist_rows = payloads("APPEND", "fistweap.2da")
        fists = fist_rows[0].split()[1:]
        self.assertEqual(len(fists), 41)
        expected_ranges = [
            (0, 2, "MFIST1"),
            (3, 5, "MFIST2"),
            (6, 9, "MFIST3"),
            (10, 12, "MFIST4"),
            (13, 14, "MFIST5"),
            (15, 17, "MFIST6"),
            (18, 22, "MFIST7"),
            (23, 40, "MFIST8"),
        ]
        for start, end, fist in expected_ranges:
            self.assertEqual(fists[start : end + 1], [fist] * (end - start + 1))

    def test_merged_action_bar(self):
        self.assertIn("SORCERER_MONK 0 3 4 2 8 9 11 12 13", payloads("APPEND", "qslots.2da"))


if __name__ == "__main__":
    unittest.main()
