#!/usr/bin/env perl
use strict;
use warnings;

use Term::ANSIColor qw(:constants);

# FIXME: check what weidu uses; for the miscompiled cases the comments may be useful
# but that also means that strrefs could bring in wierd chars
use open qw< :encoding(UTF-8) >;

my $dir = 'tests';
require 'extender.pl' or die "Could not load extender functions: $!";

my $QUIET = 0;
my $TESTS_GLOB;
foreach (@ARGV) {
	if ($_ eq "-q") {
		$QUIET = 1;
		next;
	}
	$TESTS_GLOB .= $_;
}
if (not $TESTS_GLOB) {
	$TESTS_GLOB = "$dir/*[0-9D]";
}


my @tests = glob($TESTS_GLOB);

# run fixer over all tests and compare results
my $temp_result = 'jkgbnmbnmhjh23gas_-_-_-_dabbnm45_67rd___-fmdsfghhg_87bhg6';
my $successes = 0;
my $failures = 0;
foreach my $test (sort @tests) {
    next if ($test =~ /expected$/);
	my $expected_file = $test . "_expected";
	open(my $expected_handle, "<", $expected_file) or die "$expected_file does not exist or not readable!";

	my $rc = extend($test, $temp_result, 8); # tests are written with 8pp in mind
	if ($rc eq 0) {
		# this test needed no work
		print "$test: ", GREEN, "SUCCESS", RESET, " (skipped)!\n";
		$successes++;
		next;
	}

	# compare contents of $result_handle and $expected_handle
	open(my $result_handle, "<", $temp_result);
	my $result = do { local $/; <$result_handle> };
	my $expected = do { local $/; <$expected_handle> };
	if ($result eq $expected) {
		print "$test: ", GREEN, "SUCCESS!", RESET, "\n";
		$successes++;
	} else {
		print "$test: ", RED, "FAILURE!", RESET, "\n";
		$failures++;
		#print $result . "\n\n\n\n" . $expected;
		if (!$QUIET) {
			system("diff -su " . $expected_file . " " . $temp_result);
		}
	}

	close($expected_handle);
	close($result_handle);
}
unlink $temp_result or warn "Could not unlink temporary file: $!";

# print summary
if ($failures == 0) {
	print GREEN, "ALL $successes TESTS PASSED!", RESET, "\n";
} else {
	$successes += $failures;
	print RED, "SOME ($failures/$successes) TESTS FAILED!", RESET, "\n";
}
exit 0;
