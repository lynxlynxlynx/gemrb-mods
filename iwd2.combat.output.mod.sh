#!/bin/bash
#
# This mod adds IWD2/HoW-like combat output with detailed type and resistance info
# http://www.gemrb.org/wiki/doku.php?id=mods:iwd2style_combatoutput
#
# Run it as: bash iwd2.combat.output.mod.sh /path/to/gemrb/unhardcoded/bg2 (or other GameType)
#
GOVERRIDEPATH="${1:-$HOME/dev/gemrb/gemrb/gemrb/unhardcoded/bg2}"

echo "Press Ctrl-C if you're not in the top game dir. You have 1 seconds."
sleep 1
if ! ls -1 | grep -qi dialog.tlk; then
  echo "Ehh, I told you to go to the game dir!"
  exit 123
fi

# a dump of how/iwd2 combat related strings
strid=( DAMAGE_IMMUNITY DAMAGE_STR1 DAMAGE_STR2 DAMAGE_STR3 DMG_POISON \
  DMG_MAGIC DMG_MISSILE DMG_SLASHING DMG_PIERCING DMG_CRUSHING DMG_FIRE \
  DMG_ELECTRIC DMG_COLD DMG_ACID )
strref=()
str=()
str[0]="<DAMAGEE> was immune to my <TYPE> damage"
str[1]="Takes <AMOUNT> <TYPE> damage from <DAMAGER>"
str[2]="Takes <AMOUNT> <TYPE> damage from <DAMAGER> (<RESISTED> damage resisted)"
str[3]="Takes <AMOUNT> <TYPE> damage from <DAMAGER> (<RESISTED> damage bonus)"
str[4]="poison"
str[5]="magic"
str[6]="missile"
str[7]="slashing"
str[8]="piercing"
str[9]="crushing"
str[10]="fire"
str[11]="electric"
str[12]="cold"
str[13]="acid"

dialog=$(find -mindepth 1 -maxdepth 1 -iname dialog.tlk)

echo Backing up current $dialog to $dialog.gemrb.backup
cp "$dialog"  "$dialog.gemrb.backup"
echo

# now we can insert them into dialog.tlk
# since we need the resulting strrefs, we can't just add and forget
for i in $(seq ${#str[@]}); do
  WeiDU --strapp "${str[$i]}" --tlkout "$dialog" || exit 1
  strref[$i]=$(WeiDU --strfind "${str[$i]}" | grep  "~${str[$i]}~" |
                 sed -n '/String/ { s,String #\([[:digit:]]*\) .*$,\1,p; q }')
done

# now modify gemrb's string override with the new strrefs
cp "$GOVERRIDEPATH"/strings.2da override/
for i in $(seq ${#strid[@]}); do
  sed -i "s/^${strid[$i]} .*$/${strid[$i]} ${strref[$i]}/" override/strings.2da || exit 2
done
