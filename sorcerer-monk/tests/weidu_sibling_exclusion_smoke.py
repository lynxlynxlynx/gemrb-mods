from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from weidu_smoke import ROOT, build_fixture, run_weidu, write_2da


SMC = ROOT / "sorcerer-monk-cleric"


def snapshot(override):
    return {p.name: p.read_bytes() for p in override.iterdir() if p.is_file()}


def assert_snapshot(override, expected, label):
    actual = snapshot(override)
    assert actual.keys() == expected.keys(), f"{label}: file set changed"
    for name, original in expected.items():
        assert actual[name] == original, f"{label}: {name} changed"


def prepare_both(game):
    build_fixture(game)
    shutil.copytree(SMC, game / "sorcerer-monk-cleric")
    override = game / "override"
    write_2da(
        override / "25stweap.2da",
        ["MAGE"],
        [(f"SLOT{i}", ["*"]) for i in range(20)],
    )
    write_2da(override / "luabbr.2da", ["ABBREV"], [("SORCERER", ["SOR"]), ("MONK", ["MON"])])
    write_2da(
        override / "lunumab.2da",
        ["FIRST_LEVEL", "RATE", "MAX_LEVEL", "NUM_ALLOWED"],
        [("SORCERER", [14, 1, 99, 1]), ("MONK", [14, 1, 99, 1]), ("CLERIC", [14, 1, 99, 1])],
    )


def use_legacy_smc_weapprof(override):
    write_2da(
        override / "weapprof.2da",
        ["MAGE"],
        [(f"PROF{i:02d}", [1]) for i in range(51)],
        default="0",
    )


def run_component(weidu, game, tp2, *args, check=True):
    command = [
        weidu,
        tp2,
        "--game", str(game),
        "--language", "0",
        "--noautoupdate",
        *args,
    ]
    print("+", " ".join(command), flush=True)
    result = subprocess.run(
        command,
        cwd=game,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if check and result.returncode:
        print(result.stdout, flush=True)
        raise subprocess.CalledProcessError(result.returncode, command, output=result.stdout)
    return result


def assert_blocked(result, expected_message):
    output = result.stdout.casefold()
    print(result.stdout, flush=True)
    assert expected_message.casefold() in output, output


def exercise_sm_then_smc(weidu):
    with tempfile.TemporaryDirectory(prefix="sorcerer-monk-sibling-sm-first-") as tmp:
        game = Path(tmp)
        prepare_both(game)
        override = game / "override"
        originals = snapshot(override)

        run_weidu(weidu, game, "--force-install-list", "0")
        installed = snapshot(override)
        blocked = run_component(
            weidu,
            game,
            "sorcerer-monk-cleric/setup-sorcerer-monk-cleric.tp2",
            "--force-install-list", "0",
            check=False,
        )
        assert_blocked(blocked, "cannot be installed while Sorcerer/Monk is installed")
        assert_snapshot(override, installed, "SM -> blocked SMC")
        log = (game / "WeiDU.log").read_text(encoding="utf-8").lower()
        assert "setup-sorcerer-monk.tp2" in log
        assert "setup-sorcerer-monk-cleric.tp2" not in log

        run_weidu(weidu, game, "--force-uninstall", "0")
        assert_snapshot(override, originals, "SM uninstall after blocked SMC")
        print("SM -> blocked SMC -> uninstall SM: OK", flush=True)


def exercise_smc_then_sm(weidu):
    with tempfile.TemporaryDirectory(prefix="sorcerer-monk-sibling-smc-first-") as tmp:
        game = Path(tmp)
        prepare_both(game)
        override = game / "override"
        use_legacy_smc_weapprof(override)
        originals = snapshot(override)

        run_component(
            weidu,
            game,
            "sorcerer-monk-cleric/setup-sorcerer-monk-cleric.tp2",
            "--force-install-list", "0",
        )
        installed = snapshot(override)
        blocked = run_component(
            weidu,
            game,
            "sorcerer-monk/setup-sorcerer-monk.tp2",
            "--force-install-list", "0",
            check=False,
        )
        assert_blocked(blocked, "cannot be installed while Sorcerer/Monk/Cleric is installed")
        assert_snapshot(override, installed, "SMC -> blocked SM")
        log = (game / "WeiDU.log").read_text(encoding="utf-8").lower()
        assert "setup-sorcerer-monk-cleric.tp2" in log
        assert "setup-sorcerer-monk.tp2" not in log

        run_component(
            weidu,
            game,
            "sorcerer-monk-cleric/setup-sorcerer-monk-cleric.tp2",
            "--force-uninstall", "0",
        )
        assert_snapshot(override, originals, "SMC uninstall after blocked SM")
        print("SMC -> blocked SM -> uninstall SMC: OK", flush=True)


def main():
    weidu = shutil.which(sys.argv[1] if len(sys.argv) > 1 else "weidu")
    if not weidu:
        raise SystemExit("WeiDU executable not found")

    exercise_sm_then_smc(weidu)
    exercise_smc_then_sm(weidu)


if __name__ == "__main__":
    main()
