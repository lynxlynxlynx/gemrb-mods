What does this mod do?
======================

This mods adds a new multiclass choice, sorcerer/monk. Currently dualclassing is **not** possible (see notes in the tp2 file).

Mage race and item restrictions, monk avatar, combined starting gear in tob, no detecting traps (custom actionbar).

![screenshot](http://lynxlynx.info/bugs/sorcerer_monk.jpg)

[Screenshot of the game area with the merged action bar](http://lynxlynx.info/bugs/sorcerer_monk2.jpg)

Only the english strings are currently supported, but that's easily changed - just provide me a standard TRA file.

Installation
------------
Check where you installed GemRB (data) and mark it down.

Run WeiDU as (substituting with the real path; USE THE CORRECT dir for your GAME):

   weidu --search /path/to/gemrbs/datadir/unhardcoded/bg2/  --search /path/to/gemrbs/datadir/unhardcoded/shared/ sorcerer-monk/setup-sorcerer-monk.tp2

Alternatively, manually copy these files from unhardcoded/bg2:
  - avprefc.2da
  - classes.2da
  - clskills.2da
  - fistweap.2da
  - qslots.2da
  - skills.2da
... to the "override" dir in the game dir and run WeiDU in the game directory, eg.:

    WeiDU setup-sorcerer-monk.tp2

TODO: in the end, package weidu, so setup-sorcerer-monk.exe can be used

Uninstallation
--------------
Rerun weidu and choose uninstall.

