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
my $temp_result = $ARGV[2];
my $preserve = 1;
if (not $temp_result) {
	$temp_result = 'jkgbnmbnmhjh23gas_-_-_-_dabbnm45_67rd___-fmdsfghhg_87bhg6';
	$preserve = 0;
}

my $rc = extend($file, $temp_result, $party_size);
if ($rc > 0) {
	use Cwd 'abs_path';
	my $run_dir = abs_path();
	mkdir "$run_dir/diffs";
	chdir $dirname;
	my $basename = basename($file);
	system("perl cdiff.pl -u $run_dir/$file $run_dir/$temp_result > $run_dir/diffs/$basename.diff") or die;
	chdir $run_dir;
}
if (not $preserve) {
	unlink $temp_result or warn "Could not unlink temporary file: $!";
}

exit 0;
