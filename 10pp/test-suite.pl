#!/bin/env perl
use strict;
use warnings;

# FIXME: check what weidu uses; for the miscompiled cases the comments may be useful
# but that also means that strrefs could bring in wierd chars
use open qw< :encoding(UTF-8) >;

my $dir = 'tests';
require 'extender.pl' or die "Could not load extender functions: $!";

my $QUIET = 0;
foreach (@ARGV) {
	$QUIET=1 if ($_ eq "-q")
}


my @tests = glob("$dir/*[0-9]");

# run fixer over all tests and compare results
my $temp_result = 'jkgbnmbnmhjh23gas_-_-_-_dabbnm45_67rd___-fmdsfghhg_87bhg6';
foreach my $test (@tests) {
	my $expected_file = $test . "_expected";
	open(my $test_handle, "<", $test);
	open(my $expected_handle, "<", $expected_file);
	open(my $result_handle, "+>", $temp_result);

	extend($test_handle, $result_handle, 8); # tests are written with 8pp in mind

	# compare contents of $result_handle and $expected_handle
	my $result = do { local $/; <$result_handle> };
	my $expected = do { local $/; <$expected_handle> };
	if ($result eq $expected) {
		print "$test: SUCCESS!\n";
	} else {
		print "$test: FAILURE!\n";
		#print $result . "\n\n\n\n" . $expected;
		if (!$QUIET) {
			system("diff -su " . $expected_file . " " . $temp_result);
		}
	}

	close($test_handle);
	close($expected_handle);
	close($result_handle);
}
unlink $temp_result or warn "Could not unlink temporary file: $!";
exit 0;
