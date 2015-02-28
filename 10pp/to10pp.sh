#!/bin/bash
top=${1:-$(dirname "$0")}
game=${2:-bg2}
pctotal=${3:-7}
base="$top/scripts/$game"
orig_base="$top/../../gemrb"
orig="$orig_base/scripts/$game"
triggerids="$top/trigger-$game.ids"
simple_sed="$top/simple-sed-ok-$game"

# TODO: repeat for dialog scripts
# TODO: repeat for PlayerXFill
# TODO: use freshly unweidued scripts and recompile+save the changed ones at the end
# TODO: add other game's trigger.ids (or bother with weidu due to tobex and co)
# TODO: fix all the other FIXME / TODO entries

cleanup() {
  echo cleaning up
  rm "$top/advanced-sed-extras" "$top/untouched-todo"
  rm -r "$base"
  cp -r "$orig" "$base"
  exit 13
}
trap cleanup SIGINT
player6files=$(grep -rl Player6 "$orig" | sed "s,$orig_base/,,")
triggers=$(cut -s -d" " -f2 "$triggerids" | cut -d"(" -f1)

for (( pcnum=7; pcnum <= pctotal; pcnum++ )); do # MAIN LOOP
  echo -e "Adding Player$pcnum\n"
  pre1pcnum=$((pcnum-1))
  pre2pcnum=$((pcnum-2))
  pre3pcnum=$((pcnum-3))

  #sed -i 's,^\(\s\s*\S*\)Player6\(.*\)$,&\n\1Player'$i'\2,' "$base"/*

  # 456
  sed -i "/Player$pre2pcnum/ { N; s,^\(\s\s*\S*\)Player$pre2pcnum.*\n\1Player$pre1pcnum\(.*\)$,&\n\1Player$pcnum\2,; }" "$base"/*

  # 654
  # dplayer3 and any similar, where the ordering is reversed
  sed -i "/Player$pre1pcnum/ { N; s,^\(\s\s*\S*\)Player$pre1pcnum.*\n\1Player$pre2pcnum\(.*\)$,\1Player$pcnum\2\n&,; }" "$base"/*

  # find files the smarter regex found that the dumber would not
  recheck=$({ diff -rq "$orig" "$base" | awk '{print $4}'; 
	while read i; do echo "$base"/$i; done < "$top"/$simple_sed | tr ' ' '\n' | sed p;
  } | sort | uniq -u)
  echo "$recheck" > "$top/advanced-sed-extras"

  # find the files that the dumb regex would change, but the smart one didn't
  recheck=$({ diff -rq "$orig" "$base" | awk '{print $4}' | sed p; 
	while read i; do echo "$base"/$i; done < "$top"/$simple_sed | tr ' ' '\n';
  } | sort | uniq -u)
  echo Rechecking some nonstandard scripts:
  echo "$recheck"
  echo
  for i in $recheck; do
	# catch (x5, y5, x6, y6)-like patterns
	sed -i "s,^\(\s\s*\S*\)Player$pre1pcnum\(.*\)$,&\n\1Player$pcnum\2," $i
	#diff -us $orig/${i##*/} $i
	# WARNING: cut232f.baf is one of them and appears buggy before our change
	# WARNING: cut44aa.baf is ok, but similar cases could cause problems due to delays!
  done

  # START DEALING WITH STANDALONE TRIGGERS
  # find all the files that mention player6 but we haven't touched yet
  if ((pcnum == 7)); then # only need to do it once
	recheck=$({ diff -rq "$orig" "$base" | awk '{print $2}' | sed -e "s,$orig_base/,," -e p;
	  echo "$player6files";
	} | sort | uniq -u)
	echo -n Finding untouched scripts needing changes...
	echo "$recheck" > "$top"/untouched-todo
	# also work on advanced-sed-extras, since they require the same fixes
	sed "s,$top/,," "$top"/advanced-sed-extras >> "$top"/untouched-todo
	echo " done"
	echo

	# in case it turns out better to do check progressively, fix the paths read from the todo to point to the modified files
	actAndTrigMentions=$(grep -w -h Player$pre1pcnum $(cat "$top"/untouched-todo) | tr -d ' !' | sed -e 's,~[^~]*~,,' -e 's,"[^"]*",,g' -e 's,\[[^]]*\],,g' | cut -d"(" -f1 | sort | uniq)
	# 1. check all the trigger mentions
	echo Handling trigger mentions
	usedRest=$(echo -e "$actAndTrigMentions\n$triggers\n$triggers" | sort | uniq -u)
	usedTriggers=$(echo -e "$actAndTrigMentions\n$usedRest\n$usedRest" | sort | uniq -u)
	echo $usedTriggers
	echo
  fi

  # block copying goodness
  # construct a wordlist of possible matches
  # we need to fix everything at once, while not modifying previous mentions that
  #  need to stay and ensuring we copy each relevant block only once
  #   some are taken care of by only using one indentation level - all the OR blocks are skipped; not anymore, since it is multiline
  trigPat=$(sed 's,^,\\(,; s, ,\\|,g; s,$,\\),' <<<$usedTriggers)
  restPat=$(sed 's,^,\\(,; s, ,\\|,g; s,$,\\),' <<<$usedRest)
  #echo $restPat
  # override with a combined pattern:
  trigPat=$(sed 's,^,\\(,; s, ,\\|,g; s,..$,\\),' <(tr '\n' ' ' <<< "$usedTriggers $usedRest"))
  echo $trigPat
 
  [[ -s "$top"/untouched-todo ]] &&
  while read u; do
  #   for t in $usedTriggers; do
  #     grep "^  \!\?$t.*(\(.*,\)\?,*\s*Player$pre1pcnum" "$u"
  #   done
	[[ -z $u ]] && continue

	sed -n -i "/^\s*\S.*$/ { H; }; /^\s*$/ { x; p; s/\(  \!\?$trigPat(\([^\n]*,\)\?,*\s*Player\)$pre1pcnum\([^\n]*\)/\1${pcnum}\4/gp; }; $ { g; p }" "$top/$u"
	sed -i 1d "$top/$u"
	# WARNING: not robust/bullet-proof - cases like what the dumb sed handled get mangled

	# refix advanced sed fixes we just mangled (eg. IsOverMe in OR blocks)
	# use 4 lines for better robustness, patterns 4577 and 7754
  # HAND FIXME: we break fguard.baf borinall.baf - no action copying; deck622.baf which uses extra vars
	sed -i "/Player$pre3pcnum/ { N; N; N; s,^\(\s\s*\S*\)\(Player$pre3pcnum.*\n\1Player$pre2pcnum.*\n\1Player\)$pcnum\(.*\n\1Player$pcnum.*\)$,\1\2$pre1pcnum\3,; }" "$top/$u" 
	sed -i "/Player$pcnum/ { N; N; N; s,^\(\s\s*\S*\)\(Player$pcnum.*\n\1Player\)$pcnum\(\n\1Player$pre2pcnum.*\n\1Player$pre3pcnum.*\)$,\1\2$pre1pcnum\3,; }" "$top/$u"

	# remove needless duplicate blocks (our fault)
	awk -f "$top"/block-dedup.awk "$top/$u" > "$top"/tmptmp.1
	mv "$top"/tmptmp.1 "$top/$u"

  done < "$top"/untouched-todo # | cut -d"(" -f1 | sort | uniq

  # FIXME: fix the count for just expanded OR blocks - OR(6) -> OR(7)
  # we do that by counting indented lines, since weidu nicely separates them for us
  diff -rq "$orig" "$base" | awk '{print $4}' |
  while read script; do
	echo -n "$script "
  done
echo
  # FIXME: change all  NumInParty(6) and similar (LT,GT) [just use GT>5]

  echo "*****************************************************"
done # END MAIN LOOP




while read i; do
  j=${i##*/}
  diff -u "$orig/$j" "$base/$j"
done < "$top"/untouched-todo | less


cleanup

: <<"AOK"
simple-sed-ok was generated by running:
  sed -i 's,^\(\s\s*\S*\)Player6\(.*\)$,&\n\1Player'$pcnum'\2,' "$base"/*
and then *manually* weeding out the bad results. Filenames use glob patterns!
diff -ru scripts/bg1/ 10pp/scripts/bg1 |less
AOK
