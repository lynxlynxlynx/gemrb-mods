# Maximum party size extender

This WeiDU and Perl mod extends Infinity Engine scripts and dialogs so they can address party members beyond `Player6`.

It is usable only with GemRB. The original Infinity Engine executables do not support parties larger than six members.

## Requirements

- A current GemRB build
- Perl available through the `perl` command
- WeiDU 252 or newer
- For classic BG2 or ToB: the G3 BG2 Fixpack Core Fixes component

On Windows, Strawberry Perl is the simplest supported option. Perl is not bundled with the mod.

GemRB accepts `MaxPartySize` values from 1 through 10. Values from 1 through 6 require only a GemRB configuration change. Values from 7 through 10 also require this mod to convert game scripts and dialogs.

## Installation

Install this component after every other mod that adds or changes scripts or dialogs. Embedded dialog scripts are converted as well, so installing 10pp last is important.

1. Copy the `10pp` directory into the game directory.
2. Run WeiDU from the game directory:

   ```text
   weidu 10pp/setup-10pp.tp2
   ```

3. Enter the desired maximum party size.
4. Set the same value in the GemRB configuration:

   ```text
   MaxPartySize = 8
   ```

The conversion can take several minutes on a large installation. Do not interrupt WeiDU while it is processing resources.

Generated unified diffs are written to the game directory's `diffs` folder. They identify every script and dialog change and should be included when reporting conversion problems.

## Caveats

- Script objects are supported through `Player10` and `Player10Fill`.
- The extra portraits have no numerical keyboard shortcuts.
- `Ctrl+E` reverses portrait order and can make otherwise hidden party members accessible.
- Some game GUIs still expose only six visible portrait slots.
- Inventory and other portrait-heavy views have less available space with large parties.
- Difficulty scripts based on a fixed six-person party are not automatically rebalanced.
- Some unusual scripts and dialogs cannot be transformed safely and are intentionally skipped.

Known skipped resources include the Faldorn pit-fight teleporter scripts and `fguard` variants. Salk's game-over mod also needs a manual compatibility adjustment; `tests/test44` documents the expected transformation.

## Compatibility

The converter handles ordinary mod-added scripts and dialogs, but it is heuristic rather than a full IEScript semantic analyser. Test the resulting installation before committing to a long playthrough.

Historically tested BG2 NPC mods include Haldamir, Tashia, Saradas2, Kivan, Sarah, Auren Aseph, Angelo, and Fade. Historically tested miscellaneous mods include Dungeon Be Gone, Alternatives, Divine Remix, and Item Upgrade.

Discussion and compatibility reports:

- https://www.gibberlings3.net/forums/topic/27138-heard-you-like-parties/
- https://www.gibberlings3.net/forums/topic/27535-making-mods-10-party-members-aware-draft/

## Wrapper usage

`wrapper.pl` is the supported command-line entry point for converting one decompiled script or dialog:

```text
perl 10pp/wrapper.pl INPUT_FILE PARTY_SIZE [OUTPUT_FILE]
```

Example:

```text
perl 10pp/wrapper.pl rerak06.baf 8
```

Without an output path, the converted temporary file is removed after a unified diff is generated. Input and output paths must be different.

## Development

Run the complete regression suite from any directory:

```text
perl 10pp/test-suite.pl
```

Quiet mode suppresses failure diffs:

```text
perl 10pp/test-suite.pl -q
```

Specific tests or globs can be supplied:

```text
perl 10pp/test-suite.pl test02 test4*
```

Every test input has a matching `_expected` file. Dialog tests use a `D` suffix. For transformed cases, the runner compares exact content after normalizing line endings. Known exception cases are reported as skipped. The runner exits nonzero when any executed comparison fails.

`cdiff.pl` and the bundled `Algorithm::Diff` module provide portable unified diffs.

## Uninstallation

Rerun WeiDU and uninstall the component. Do not continue using saves with more than six party members through the original Infinity Engine executable.

## Media

- Screenshots are available in `10pp/screenshots`.
- Example boss fight: https://youtu.be/0W0w_i6vNjs
