#!/usr/local/ActivePerl-5.20/bin/perl5.20.1
# change that when i'm done

use strict;
use warnings;

# reads passed BAF and extends it to request max party count if needed
sub extend {
    my $input_handle = shift;
    my $output_handle = shift;
    my $party_num = shift;

    my $input_baf = do { local $/; <$input_handle> };
    my @baf_blocks = split(m{\n\n}x, $input_baf) or die;

    # shortcircuit scripts that won't need changing
    # IOW those that have no mentions of Player6
    if ((grep /Player6/, @baf_blocks) == 0) {
        return 0;
    }

    # overview:
    # 1. read each block into its:
    #   * trigger list
    #   * response block1 ... blockN
    # 2. check which class of a problem the block represents
    # 3. fix it
    #
    # We're writing to the output handle as we go, so we don't need to reread
    # the original
    foreach (@baf_blocks) { # might need to change if other method is used.
	# it would be ideal to drop this on a LINE
	# loop, not block loop.
#	if ($_ =~ m/^.*NumInParty\(\d\)$/) {
#	    my $NumInParty_orig = $1;
	    # calculate $NumInParty_change according to $party_num
	    # and $NumInParty_orig, not sure, need lynx's opinion.
#	    if ($1 <= 6) {
#		my $NumInParty_change = $1 * 666;
#	    }
#	}
#	if ($_ =~ m/[ ][ ]OR\(\d\)\n/)
# # 	if ($_ =~ m/([ ][ ][ ][ ](.*)Player4(.*)\n)/) {
# # 	    # might need less robust check for the ones that aren't together
# # 	    # or random ordering support too, sigh, that'll get long.
# # 	    if ($_ =~ m/($1[ ][ ][ ][ ](.*)Player5(.*)\n)/) {
# # 		if ($_ =~ m/($1[ ][ ][ ][ ](.*)Player6(.*)\n)/) {
# # 		    for (my $i =7; $i<$party_num; $i++) {
# # 			s/$1/$2Player$i$3/ # dunno if I should do this with flag g or no
# # 		    }
# # 		}
# # 	    }
# # 	} # if player4

	
    }
    return 1;
}

#exit 0;
1
