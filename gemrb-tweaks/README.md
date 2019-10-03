GemRB Tweaks
============

This mod is a collection of small GemRB tweaks and a user-friendly way to make the
gameplay richer, different or both.

Current components:
- IWD2/HOW-style detailed combat feedback for other games
- Wisdom-based experience modifier
- Maximum HP on level up for BG1

TODO: add more tweaks from http://www.gemrb.org/wiki/doku.php?id=developers:mods

Components
==========

1. IWD2/HOW-style detailed combat feedback for other games
This adds extra strings to the games, so combat feedback can be more detailed.
Damage types are reported, plus bonus and resisted damage, just like in IWDs.

For a screenshot, check this:
http://lynxlynx.info/bugs/iwd2stylecombat2.jpg

2. Wisdom-based experience modifier
This gives everyone a bonus or malus to the experience gained depending on
their wisdom. This feature was only known in PST, where it had no penalties and
mostly 2% or 3% steps of improvement. 

For example, choosing the 2% table means that a character with 5 wisdom will receive 10% less xp,
while a sage with 18 will receive 16% more.

NOTE: the displayed string for xp gained will not change, since it is party based (same for quest xp).

3. Maximum HP on level up for BG1
It was the only game without this setting or at least not nicely exposed.

Installation
============

**As of WeiDU version newer than 246, you can install this mod like any other.**
Make sure to run GemRB at least once on this install, so WeiDU will know
where to look for files.

Otherwise, check where you installed GemRB (data) and mark it down.

Run WeiDU as (substituting with the real path; USE THE CORRECT dir for your GAME):

   weidu --search /path/to/gemrbs/datadir/unhardcoded/bg2/ gemrb-tweaks/gemrb-tweaks.tp2
