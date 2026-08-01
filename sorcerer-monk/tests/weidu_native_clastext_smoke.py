from pathlib import Path
import shutil
import sys

from weidu_layout_smoke import exercise, make_current_split_layout, row, verify_current_split
from weidu_smoke import write_2da


def write_native_clastext(game, fallen_notice):
    override = game / "override"
    headers = [
        "CLASSID", "KITID", "LOWER", "DESCSTR", "MIXED", "BIOGRAPHY", "FALLEN", "BRIEFDESC",
    ]
    rows = [
        ("SORCERER", [19, 16384, 24224, 24233, 24227, -1, 0, 32300]),
        ("MONK", [20, 16384, 24225, 24234, 24228, -1, 0, 32299]),
        ("SHAMAN", [21, 16384, 32441, 32341, 32342, -1, 0, 32344]),
    ]
    if fallen_notice:
        headers.append("FALLEN_NOTICE")
        rows = [(name, [*values, -1]) for name, values in rows]
    write_2da(override / "clastext.2da", headers, rows, default="-1")


def make_native_ee9_layout(game):
    make_current_split_layout(game)
    write_native_clastext(game, fallen_notice=False)


def make_native_ee10_layout(game):
    make_current_split_layout(game)
    write_native_clastext(game, fallen_notice=True)


def verify_native(game, expected_columns):
    verify_current_split(game)
    class_text = row(game / "override" / "clastext.2da", "SORCERER_MONK")
    assert len(class_text) == expected_columns, class_text
    assert class_text[1] == "22", class_text
    assert class_text[2] == "16384", class_text


def main():
    weidu = shutil.which(sys.argv[1] if len(sys.argv) > 1 else "weidu")
    if not weidu:
        raise SystemExit("WeiDU executable not found")

    exercise(weidu, make_native_ee9_layout, lambda game: verify_native(game, 9), "native-ee9-clastext")
    exercise(weidu, make_native_ee10_layout, lambda game: verify_native(game, 10), "native-ee10-clastext")


if __name__ == "__main__":
    main()
