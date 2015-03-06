#!/usr/bin/env perl
use strict;
use warnings;

# FIXME: check what weidu uses; for the miscompiled cases the comments may be useful
# but that also means that strrefs could bring in wierd chars
use open qw< :encoding(UTF-8) >;

use File::Basename;
my $dirname = dirname(__FILE__);
require "$dirname/extender.pl" or die "Could not load extender functions: $!";

my $file = $ARGV[0];
my $party_size = $ARGV[1];
my $temp_result = 'jkgbnmbnmhjh23gas_-_-_-_dabbnm45_67rd___-fmdsfghhg_87bhg6';

my $rc = extend($file, $temp_result, $party_size);
if ($rc > 0) {
	system("diff -u " . $file . " " . $temp_result . " > diffs/$file.diff") or die;
}
unlink $temp_result or warn "Could not unlink temporary file: $!";

exit 0;
