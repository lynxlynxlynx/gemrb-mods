# GemRB Tweaks

This mod is a collection of small GemRB tweaks and a user-friendly way to make the
gameplay richer, different or both.

Current components:
- IWD2/HOW-style detailed combat feedback for other games
- Wisdom-based experience modifier
- 10% bonus experience as per BG2, regardless of wisdom
- Maximum HP on level up for BG1
- All mage schools available to gnomes

TODO: 
- add more tweaks from http://www.gemrb.org/wiki/doku.php?id=developers:mods
- add strings and mod modal.2da for iwd1 and bg1: https://github.com/gemrb/gemrb/issues/261


## Components

### IWD2/HOW-style detailed combat feedback for other games
This adds extra strings to the games, so combat feedback can be more detailed.
Damage types are reported, plus bonus and resisted damage, just like in IWDs.

For a screenshot, check this:
http://lynxlynx.info/bugs/iwd2stylecombat2.jpg

### Wisdom-based experience modifier
This gives everyone a bonus or malus to the experience gained depending on
their wisdom. This feature was only known in PST, where it had no penalties and
mostly 2% or 3% steps of improvement. 

For example, choosing the 2% table means that a character with 5 wisdom will receive 10% less xp,
while a sage with 18 will receive 16% more.

NOTE: the displayed string for xp gained will not change, since it is party based (same for quest xp).

#### 10% bonus experience as per BG2, regardless of wisdom
Just reinstates the player-favouring cheat the original BG2 implemented. Can
be applied to any game.

### Maximum HP on level up for BG1
It was the only game without this setting or at least not nicely exposed.

### All mage schools available to gnomes
In the originals, they were restricted to illusionists.


## Installation

**As of WeiDU version 247, you can install this mod like any other.**
Make sure to run GemRB at least once on this install, so WeiDU will know
where to look for files.

Run WeiDU from the game dir:
```
   weidu gemrb-tweaks/gemrb-tweaks.tp2
```
