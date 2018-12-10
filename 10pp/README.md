Maximum party size extender
===========================
This Weidu/perl mod will extend scripts and dialogs to also refer to player objects
beyond player 6. It can start anywhere, BUT IS ONLY USABLE with GemRB, since the
other engines do not support more objects.

PERL IS REQUIRED and not bundled at this point. If you're on windows, look at
https://www.perl.org/get.html (ActiveState or Strawberry)

Works on GemRB **v0.8.3** or newer.

Check the screenshots folder for some action shots. Or this brief video of a certain boss fight:
https://youtu.be/0W0w_i6vNjs

Forum discussion thread:
http://gibberlings3.net/forums/index.php?showtopic=27138

Caveats:
- scripting wise, up to 10 member parties are supported (Player10/Player10Fill objects)
  - easily extended, if there's enough interest
- there are no numerical keyboard shortcuts for the new portraits
  - but you can reverse the portrait order with ctrl-e
  - other hotkeys or right-clicking on the portraits still works though
- inventory and other views are more constrained, so we scale down the portraits to fit
- max party size is set through your gemrb.cfg (MaxPartySize)
  - this means you can also put a lower than 6 hard limit on party size


Compatibility
-------------
Every mod should work, but since the core of the mod is a dumb robot, there
are bound to be Exceptions (see section below).

Mods confirmed not to cause problems:
* bg2
  * NPC: Haldamir, Tashia, Saradas2, Kivan, Sarah, Auren Aseph, Angelo, Fade
  * Misc: Dungeon be gone, Alternatives, Divine Remix, Item upgrade
* Salk's gameover mod will fail, but test44 shows how to edit the file
  * you can get most of the work by just changing one value: http://www.gemrb.org/wiki/doku.php?id=developers:mods

Testing with other mods and/or finding appropriate overrides is very welcome!

GemRB currently does no GUI extending for PST and IWD2 due to the way their windows are set up. You won't be able to see new portraits, but party joining and all the rest will work. Use ctrl-e to temporary reverse the party order if you want to click on portraits (eg. in shops).

The party window in iwd still has only 6 slots, so you'd need to use a hack:
- create all the characters, but export the ones above 6
- start the game, ctrl+space to open the console
- cc("filename") (for each .cre exported earlier)
- ctrl+q to have them join your party


Installation
------------
This mod should be installed after all other script&dialog altering/adding mods!
For bg2, the G3 Fixpack is required (Core fixes): www.gibberlings3.net/bg2fixpack/

Since it also extends embedded dialog scripts, it is best to just install it last.

The conversion process can take several minutes depending on the size of your install!
Please be patient and DO NOT INTERRUPT execution lest you want to start from zero.
There is only one query and then you can go plant some coffee.

Clone the gemrb-mods repository to you computer and copy 10pp to the game dir.

Run WeiDU in the game directory, eg.:

    WeiDU 10pp/setup-10pp.tp2

If it breaks, remove the backup directory and add the offending file to the
exception list in extend.pl. Rerun.

If you are a modder, you can check the files in the diffs/ directory, which
will contain all the differences for the changed files.

Exceptions
----------
Some funky scripts are not handled. Presently this includes fguard.baf from
bg2 (extra globals setting), but that file is not that important, so we don't
ship manual overrides either.

Some difficulty scripts that check for party size are not scalable. Eg. the
final hell fight does not spawn any extra demons for larger parties.

Similar caveats hold for dialogs, just more often. From vanilla bg2, this
includes the drow pit fights and challenging for the druid grove. If there
are any problems with mod added stuff, let me know.

For mod authors
---------------
Check out this WeiDU extension functions to see how you can make your mod work
flawlessly with any party size:
http://gibberlings3.net/forums/index.php?showtopic=27535

Development
-----------
If you'll be extending the extender logic, use test-suite.pl and write tests
under tests/* liberally. All other paths lead to madness and peril.

To add tests, just add a file and then make a copy with the desired changes,
naming it file_expected. Dialog tests need a D after their id.

Example invocations:
  * ./test-suite.pl       # runs all tests, prints diffs for failures
  * ./test-suite.pl -q    # runs all tests without printing diffs for failures
  * ./test-suite.pl "someglob"   # runs specified tests

cdiff.pl is a perl version of diff used by wrapper.pl for portability. The
wrapper is the main entry point for external use. The parameters are input baf,
max party size and an optional output baf. Without it just the diff will be
generated for changed files. Example:

    ./wrapper.pl rerak06.baf 8

... would extend rerak06.baf for up to 8 PCs, save the diff under
diffs/rerak06.baf.diff and delete the temporary file.
NOTE: do not use the same input and output file!

Special thanks
--------------
Perl diff implementation is from Algorithm::Diff:
http://search.cpan.org/~tyemq/Algorithm-Diff-1.1903/lib/Algorithm/Diff.pm

CrevsDaak for motivation and weidu stuff.

Uninstallation
--------------
Rerun weidu and choose uninstall.
