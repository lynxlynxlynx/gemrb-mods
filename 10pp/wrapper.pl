#!/usr/bin/env perl
use strict;
use warnings;

# FIXME: check what weidu uses; for the miscompiled cases the comments may be useful
# but that also means that strrefs could bring in wierd chars
use open qw< :encoding(UTF-8) >;

use File::Basename;
use File::Spec;
my $dirname = dirname(__FILE__);
$dirname = File::Spec->rel2abs("$dirname");
require "$dirname/extender.pl" or die "Could not load extender functions: $!";

my $file = $ARGV[0];
my $party_size = $ARGV[1];
my $temp_result = $ARGV[2];
my $preserve = 1;

if (not $file) {
	print "Missing arguments!\n";
	exit 1;
}
if (-z $file) {
	print "Skipping empty file: $file!\n";
	exit 2;
}

if (not $temp_result) {
	$temp_result = 'jkgbnmbnmhjh23gas_-_-_-_dabbnm45_67rd___-fmdsfghhg_87bhg6';
	$preserve = 0;
}
my $temp_result2 = $temp_result . "commentless";

my $rc = extend($file, $temp_result, $party_size);
if ($rc > 0) {
	use Cwd 'abs_path';
	my $run_dir = abs_path();
	mkdir "$run_dir/diffs";
	chdir "$dirname";
	my $basename = basename($file);

	if ($file =~ /[dD]$/) {
		# make a copy of the original and strip comments from it, so the diff is more readable for dialogs
		open(my $dlg_handle, "<:utf8", $run_dir . "/" . $file);
		my $input_text = do { local $/; <$dlg_handle> };
		close($dlg_handle);

		$input_text = $input_text =~ s{/\*(?:(?!\*/).)*\*/}{}gsr;
		$input_text = $input_text =~ s{^//.*\n}{}gmr;
		$input_text = $input_text =~ s{//.*}{}gr;

		open(my $dlg_handle2, ">:utf8", $run_dir . "/" . $temp_result2);
		say $dlg_handle2 $input_text;
		close($dlg_handle2);
	} else {
		$temp_result2 = $file;
	}

	my $cmd = "perl cdiff.pl -u " . quotemeta("$run_dir/$temp_result2") . " " . quotemeta("$run_dir/$temp_result") . " > " . quotemeta("$run_dir/diffs/$basename.diff");
	system($cmd) or die;
	chdir $run_dir;
	unlink $temp_result2 if ($temp_result2 ne $file);
}
if (not $preserve and -e $temp_result) {
	unlink $temp_result or warn "Could not unlink temporary file: $!";
}

exit 0;
