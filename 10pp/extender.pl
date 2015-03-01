#!/usr/local/ActivePerl-5.20/bin/perl5.20.1
# change that when i'm done

use strict;
use warnings;

# reads passed BAF and extends it to request max party count if needed
sub extend {
    my $input_handle = shift;
    my $output_file = shift;
    my $party_num = shift;

    open(my $output_handle, "+>", $output_file);
    my $input_baf = do { local $/; <$input_handle> };
    my @baf_blocks = split(m{\n\n}x, $input_baf) or die;

    # shortcircuit scripts that won't need changing
    # IOW those that have no mentions of Player6
    if ((grep /Player6/, @baf_blocks) == 0) {
        close($output_handle);
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
    foreach my $block (@baf_blocks) {
        # nothing to do? Just write it out
        if ($block !~ /Player6/) {
            say $output_handle $block . "\n";
            next;
        }

        # now we know there is a mention of Player6, so let's dig deeper
        my $trigger_mention = 0;
        my $response_mention = 0;
        # safely strip out the contents
        my ($trigger_half) = ($block =~ /^IF\n((?:(?!^IF).)*)THEN$/ms);
        my ($response_half) = ($block =~ /^THEN\n((?:(?!^THEN).)*)END$/ms);

        # where are the uses?
        $trigger_mention++ if ($trigger_half =~ /Player6/);
        $response_mention++ if ($response_half =~ /Player6/);
        if ($trigger_mention == $response_mention && $trigger_mention == 0) {
            print $trigger_half . "||||\n" . $response_half . "\n\n";
            print "FATAL PARSING ERROR: player mention mismatch! Dumped problematic block above.";
            exit;
        }

        my @trigger_list = split /\n/, $trigger_half;
#         my @response_blocks = split /RESPONSE/, $response_half;

        # figure out what toplevel strategy to take
        if ($trigger_mention == $response_mention) {
            # both triggers and response blocks need to be changed
            # TODO: test5, test8-10
        } elsif ($trigger_mention == 1) {
            # likely only triggers need to be changed
            # if (everyone) is mentioned append trigger (test2)
            # TODO: else copy the whole block (TODO: test missing!)
            if ($trigger_half =~ /Player5/) {
                # NOTE: for now assuming this is enough and that scripts work either on the whole party or individuals
                $trigger_half = fixTriggersOnly($trigger_half, $party_num, @trigger_list);
            } else {

            }
        } else {
            # likely only response blocks need to be changed
            # TODO: if (everyone) is mentioned append action(s) (tests: 4, 6, 7)
            # TODO: else copy the whole block (test3)
        }

        # TODO: don't forget to re-add IF/THEN/END and any other omissions!
        say $output_handle "IF\n" . $trigger_half . "THEN\n" . $response_half . "END\n";

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
    close($output_handle);
    return 1;
}

# NOTE: for now we don't care about ordering (567 vs 765)
sub fixTriggersOnly {
    my $trigger_half = shift;
    my $party_num = shift;
    my @trigger_list = @_;

    # we have a party, just add extra triggers by copying Player6 lines
    my $new_trigger_half = "";
    my $in_or = 0;
    for my $line (@trigger_list) {
        if ($line =~ /^  Or\(/) {
            $in_or = 1;
            $new_trigger_half .= $line . "\n";
            next;
        } elsif ($line =~ /^\s\s\S/) {
            # OR causes extra indent (python style)
            $in_or = 0;
        }
        if ($line =~ /Player6/) {
            # adjust Or() if needed
            if ($in_or) {
                # FIXME: UGLY, perhaps just split on OR(.) and work on that?
                my $cur_pos = index $new_trigger_half, my $grr = $line =~ s/Player6/Player5/r;
                my $or_pos = rindex $new_trigger_half, " Or(", $cur_pos;
#               print $new_trigger_half, "|\n" , $line, "\n";
#               print ((substr $new_trigger_half, $or_pos, 6), "||", $cur_pos, "||", $or_pos, "||\n");
                # we have to set the new count carefully in case there are other actions inside the Or: just add to existing
                my $new_count = (substr $new_trigger_half, $or_pos+4, 1) + ($party_num - 6);
                substr $new_trigger_half, $or_pos, 6, " Or($new_count)";
                #$in_or = 0; # one fix per Or block is only enough if there is only one Player6-using trigger ...
            }
            # add new triggers
            my $prevPC = "Player6";
            for (my $i = 7; $i <= $party_num; $i++) {
                my $nextPC = "Player" . $i;
                $line = $line =~ s/^(\s*)(.*)($prevPC)(.*)$/$1$2$3$4\n$1$2$nextPC$4/mr;
                $prevPC = $nextPC;
            }
        }
        $new_trigger_half .= $line . "\n";
    }
    return $new_trigger_half;
}
#exit 0;
1
