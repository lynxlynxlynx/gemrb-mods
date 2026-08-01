# Sorcerer/Monk multiclass for GemRB

This mod adds a true Sorcerer/Monk multiclass to Infinity Engine games running through GemRB.

Install it before creating the character and do not uninstall it while a save still contains Sorcerer/Monk characters.

## Supported games

- Tutu and Tutu_TotSC
- Baldur's Gate: Enhanced Edition
- Classic Adventures
- Baldur's Gate II: Shadows of Amn
- Throne of Bhaal
- BGT
- Baldur's Gate II: Enhanced Edition
- EET

Original BG1 and TotSC are not included because they do not provide the Sorcerer and Monk base classes. All supported games must be launched through GemRB.

## Installation

1. Run GemRB once against the target game installation.
2. Copy the `sorcerer-monk` directory into the game directory.
3. Run:

```text
weidu sorcerer-monk/setup-sorcerer-monk.tp2
```

Use WeiDU 247 or newer.

Sorcerer/Monk and the legacy Sorcerer/Monk/Cleric mod are intentionally mutually exclusive. Uninstall one before installing the other.

## Version 2.0 corrections

- Retains the historical `sorcerer-monk-cleric/backup` location so existing 1.9 installations can still be reinstalled or uninstalled safely by WeiDU.
- Prevents simultaneous installation with Sorcerer/Monk/Cleric because both legacy packages share the same WeiDU backup namespace and the older triple-class installer hardcodes a class ID that can collide on EE layouts.
- Derives the Sorcerer/Monk class ID from its `CLSKILLS.2DA` row instead of hardcoding class ID 21.
- Rejects conflicting class-table layouts and class IDs above 31, matching GemRB's runtime row-index and class-mask constraints.
- Supports the combined class table used by released GemRB versions and the split class tables used by development builds.
- Handles normalized GemRB plus older nine-column and newer ten-column native Enhanced Edition `CLASSTEXT.2DA` layouts when the split tables are present.
- Handles the released and development `CLSKILLS.2DA` layouts and inherits campaign-specific starting experience from the Sorcerer row.
- Uses the more restrictive Sorcerer/Monk experience cap from the active game's `XPCAP.2DA` instead of forcing the BG2/ToB 8,000,000 cap on every supported campaign.
- Preserves the conventional `XPCAP=-1` uncapped configuration used by XP-cap remover mods: two uncapped components stay uncapped, while a finite component cap remains the restrictive result.
- Adds the standard combined ability prerequisites: DEX 9, CON 9, INT 9, WIS 9 and CHA 9; STR remains unrestricted.
- Adds a matching zero `ABCLSMOD.2DA` row so GemRB's ability-requirement and modifier tables remain aligned.
- Uses multiclass save and hit-point handling instead of priest saves and full Monk hit points.
- Restricts the class to humans, matching the intersection of Sorcerer and Monk race rules.
- Combines Mage/Sorcerer and Monk item-usability restrictions.
- Adds the allocated class identifier to `CLASS.IDS`.
- Avoids modifying ToB starting-equipment and HLA tables in games where those tables are absent.
- Supports both the older `SKILLS.2DA` layout and the newer `THIEFSCL.2DA`/`THIEFSKL.2DA` pair.
- Matches Monk skill-point progression in both skill-table layouts: legacy `10/10` and current split `0/10`.
- Uses the fastest component proficiency rate, giving the multiclass one proficiency point every four Monk levels.
- Uses the Monk non-proficiency penalty on legacy GemRB tables.
- Adds the component-compatible starting-gold row.
- Restricts quick-weapon slots to two, matching the more restrictive Sorcerer component.
- Preserves Monk fist APR progression and combat proficiency behavior through `CLSWPBON.2DA` where available.
- Keeps BGEE character generation unarmed rather than falling back to the default quarterstaff.
- Adjusts the custom `FISTWEAP.2DA` row for GemRB's rounded multiclass-level lookup so fist tiers are not granted before the Monk component earns them and high-tier fists remain reachable when the campaign cap permits them.
- Uses exact class-token guards so `SORCERER_MONK_CLERIC` rows and columns do not suppress Sorcerer/Monk installation.
- Uses exact row-name guards for the `MULTI2SORCERER` and `MULTI2MONK` HLA metadata.

## Gameplay model

- Sorcerer spontaneous arcane spell progression
- Monk fists and class abilities
- Lawful alignments only
- Human only
- Minimum DEX 9, CON 9, INT 9, WIS 9 and CHA 9
- Combined Sorcerer/Mage and Monk equipment restrictions
- No dual-classing
- Custom merged action bar

## Compatibility notes

The installer has two documented class-table branches: the combined format used by released GemRB versions and the split format used by development builds. Split `CLASSTEXT.2DA` is accepted in GemRB's normalized six-column form and in native EE nine- or ten-column forms.

GemRB uses class IDs as indices into several class tables and tracks class categories with 32-bit masks. For that reason, custom-class table order is significant: the Sorcerer/Monk ID must equal its `CLSKILLS.2DA` row index and must remain below 32. The installer fails instead of creating a character whose class metadata would be interpreted incorrectly at runtime.

GemRB currently selects `FISTWEAP.2DA` by the rounded average multiclass level, not by the Monk component level. An exact Monk fist transition at every XP boundary therefore cannot be represented by a single custom table row. Version 2.0 uses a conservative mapping: some fist transitions can occur slightly later than on a single-class Monk, but none occur before the Monk component reaches the corresponding tier. Lower-cap campaigns naturally stop at lower fist tiers; BG2/ToB progression can still reach the final tier.

The apparently misplaced backup directory is intentional in version 2.0. Version 1.9 stored its uninstall data under `sorcerer-monk-cleric/backup`; changing the `BACKUP` directive after users have already installed 1.9 would prevent WeiDU from finding those restoration files during an upgrade. A future backup-path migration requires an explicit transition strategy rather than a direct path rename.

Sorcerer/Monk and Sorcerer/Monk/Cleric cannot be installed together. They historically use the same WeiDU backup directory and component number, so simultaneous installation would make uninstall restoration order-dependent. The old triple-class installer also hardcodes class ID 22, which can collide with Sorcerer/Monk on EE layouts with Shaman present. Both installers now reject the second installation before modifying game files.

Install custom-class mods before starting a new game. Existing saves created without the class tables are not guaranteed to remain compatible after installing or uninstalling the mod.
