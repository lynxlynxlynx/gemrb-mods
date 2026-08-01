from pathlib import Path
import shutil
import sys
import tempfile

from weidu_smoke import build_fixture, count_token, run_weidu, write_2da


CLASS_HEADERS_COMBINED = [
    "NAME_REF", "DESC_REF", "CAP_REF", "SAVE", "MULTI", "ID", "HP",
    "USABILITY", "MC_WAS_ID", "HUMAN", "ELF", "HALF_ELF", "DWARF",
    "HALFLING", "GNOME", "HALFORC", "STREXTRA", "CONBONLVL",
]

CLASS_NAMES = [
    "UNUSED", "MAGE", "FIGHTER", "CLERIC", "THIEF", "BARD", "PALADIN",
    "FIGHTER_MAGE", "FIGHTER_CLERIC", "FIGHTER_THIEF", "FIGHTER_MAGE_THIEF",
    "DRUID", "RANGER", "MAGE_THIEF", "CLERIC_MAGE", "CLERIC_THIEF",
    "FIGHTER_DRUID", "FIGHTER_MAGE_CLERIC", "CLERIC_RANGER", "SORCERER", "MONK",
    "SHAMAN",
]


def write_clskills(path, modern):
    headers = [
        "DRUIDSPELL", "CLERICSPELL", "MAGESPELL", "STARTXP", "BARDSKILL",
        "THIEFSKILL", "LAYHANDS", "TURNLEVEL", "BOOKTYPE", "HATERACE",
        "ABILITIES", "NO_PROF", "STARTXP2", "RANGERSKILL", "SAVEBONUS", "SPONCAST",
    ]
    rows = []
    for name in CLASS_NAMES:
        values = ["*", "*", "*", 89000, "*", "*", "*", 0, 0, "*", "*", -3, 2500000, "*", 0, "*"]
        if name == "UNUSED":
            values[3] = "*"
            values[11] = "*"
            values[12] = "*"
        elif name == "SORCERER":
            values[2] = "MXSPLSRC"
            values[8] = 2
            values[11] = -4
        elif name == "MONK":
            values[5] = "SKILLS"
            values[10] = "CLABMO01"
            values[11] = -3
        if modern:
            values = values[:11] + values[12:]
        rows.append((name, values))
    if modern:
        headers = headers[:11] + headers[12:]
    write_2da(path, headers, rows)


def write_legacy_skills(override):
    for name in ("thiefscl.2da", "thiefskl.2da"):
        path = override / name
        if path.exists():
            path.unlink()
    write_2da(
        override / "skills.2da",
        ["MONK"],
        [
            ("FIRST_LEVEL", [10]),
            ("RATE", [10]),
            ("PICK_POCKETS", [-1]),
            ("OPEN_LOCKS", [-1]),
            ("FIND_TRAPS", [1]),
            ("MOVE_SILENTLY", [1]),
            ("HIDE_IN_SHADOWS", [1]),
            ("DETECT_ILLUSION", [-1]),
            ("SET_TRAPS", [-1]),
        ],
        default="-1",
    )


def make_released_ee_layout(game):
    build_fixture(game)
    override = game / "override"
    write_2da(
        override / "classes.2da",
        CLASS_HEADERS_COMBINED,
        [
            ("SORCERER", [45849, 45866, 45856, "SAVEWIZ", 0, 19, "HPWIZ", "0x40000", -1, 1, 1, 1, 0, 0, 0, 0, 0, 10]),
            ("MONK", [45851, 45867, 45858, "SAVEMONK", 0, 20, "HPMONK", "0x20000000", -1, 1, 0, 0, 0, 0, 0, 0, 0, 9]),
            ("SHAMAN", [103056, 103057, 103058, "SAVEPRS", 0, 21, "HPPRS", "0x40000000", -1, 1, 1, 1, 1, 1, 1, 1, 1, 9]),
        ],
    )
    write_clskills(override / "clskills.2da", modern=False)
    write_2da(
        override / "hpclass.2da",
        ["HP"],
        [("SORCERER", ["HPWIZ"]), ("MONK", ["HPMONK"]), ("SHAMAN", ["HPPRS"])],
    )
    write_legacy_skills(override)
    (override / "class.ids").write_text("19 SORCERER\n20 MONK\n21 SHAMAN\n", encoding="utf-8")


def make_current_split_layout(game):
    build_fixture(game)
    override = game / "override"
    write_2da(
        override / "classes.2da",
        ["SAVE", "MULTI", "USABILITY", "MC_WAS_ID", "STREXTRA", "CONBONLVL"],
        [
            ("SORCERER", ["SAVEWIZ", 0, "0x40000", -1, 0, 10]),
            ("MONK", ["SAVEMONK", 0, "0x20000000", -1, 0, 9]),
            ("SHAMAN", ["SAVEPRS", 0, "0x40000000", -1, 1, 9]),
        ],
    )
    write_clskills(override / "clskills.2da", modern=True)
    write_2da(
        override / "clastext.2da",
        ["CLASSID", "KITID", "LOWER", "DESCSTR", "MIXED"],
        [
            ("SORCERER", [19, "*", 45849, 45866, 45856]),
            ("MONK", [20, "*", 45851, 45867, 45858]),
            ("SHAMAN", [21, 16384, 103056, 103057, 103058]),
        ],
    )
    write_2da(
        override / "clsrcreq.2da",
        ["HUMAN", "ELF", "HALF_ELF", "DWARF", "HALFLING", "GNOME", "HALFORC"],
        [
            ("SORCERER", [1, 1, 1, 0, 0, 0, 0]),
            ("MONK", [1, 0, 0, 0, 0, 0, 0]),
            ("SHAMAN", [1, 1, 1, 1, 1, 1, 1]),
        ],
    )
    write_2da(
        override / "hpclass.2da",
        ["HP"],
        [("SORCERER", ["HPWIZ"]), ("MONK", ["HPMONK"]), ("SHAMAN", ["HPPRS"])],
    )
    (override / "class.ids").write_text("19 SORCERER\n20 MONK\n21 SHAMAN\n", encoding="utf-8")


def row(path, name):
    for line in path.read_text(encoding="utf-8").splitlines():
        cells = line.split()
        if cells and cells[0] == name:
            return cells
    raise AssertionError(f"missing {name} in {path}")


def verify_released_ee(game):
    override = game / "override"
    class_row = row(override / "classes.2da", "SORCERER_MONK")
    assert len(class_row) == 19, class_row
    assert class_row[6] == "22", class_row
    assert count_token(override / "hpclass.2da", "SORCERER_MONK") == 0
    assert "22 SORCERER_MONK" in (override / "class.ids").read_text(encoding="utf-8")
    assert count_token(override / "clskills.2da", "SORCERER_MONK") == 1
    assert count_token(override / "skills.2da", "SORCERER_MONK") == 1


def verify_current_split(game):
    override = game / "override"
    class_row = row(override / "classes.2da", "SORCERER_MONK")
    assert len(class_row) == 7, class_row
    assert class_row[2] == "786432", class_row
    assert row(override / "clastext.2da", "SORCERER_MONK")[1] == "22"
    assert count_token(override / "hpclass.2da", "SORCERER_MONK") == 1
    assert count_token(override / "clsrcreq.2da", "SORCERER_MONK") == 1
    assert "22 SORCERER_MONK" in (override / "class.ids").read_text(encoding="utf-8")
    assert count_token(override / "clskills.2da", "SORCERER_MONK") == 1
    assert count_token(override / "thiefscl.2da", "SORCERER_MONK") == 1


def exercise(weidu, builder, verifier, label):
    with tempfile.TemporaryDirectory(prefix=f"sorcerer-monk-{label}-") as tmp:
        game = Path(tmp)
        builder(game)
        originals = {p.name: p.read_bytes() for p in (game / "override").iterdir() if p.is_file()}

        run_weidu(weidu, game, "--force-install-list", "0")
        verifier(game)
        run_weidu(weidu, game, "--reinstall")
        verifier(game)
        run_weidu(weidu, game, "--force-uninstall", "0")

        for name, original in originals.items():
            assert (game / "override" / name).read_bytes() == original, f"{label}: {name}"
        print(f"{label}: OK", flush=True)


def main():
    weidu = shutil.which(sys.argv[1] if len(sys.argv) > 1 else "weidu")
    if not weidu:
        raise SystemExit("WeiDU executable not found")

    exercise(weidu, make_released_ee_layout, verify_released_ee, "released-ee-combined-with-hpclass")
    exercise(weidu, make_current_split_layout, verify_current_split, "current-split")


if __name__ == "__main__":
    main()
