#!/bin/env perl
use strict;
use warnings;

# FIXME: check what weidu uses; for the miscompiled cases the comments may be useful
# but that also means that strrefs could bring in wierd chars
use open qw< :encoding(UTF-8) >;

my $dir = 'tests';
my $fixer = ''; # path to script fixer script
# TODO: include $fixer

my $QUIET = 0;
foreach (@ARGV) {
	$QUIET=1 if ($_ eq "-q")
}


my @tests = glob("$dir/*[0-9]");

# run fixer over all tests and compare results
my $temp_result = 'jkgbnmbnmhjh23gas_-_-_-_dabbnm45_67rd___-fmdsfghhg_87bhg6';
foreach my $test (@tests) {
	my $expected_file = $test . "_expected";
	my $test_handle = undef;
	my $expected_handle = undef;
	my $result_handle = undef;
	open($test_handle, "<", $test);
	open($expected_handle, "<", $expected_file);
	open($result_handle, "+>", $temp_result);

	fixScript($test_handle, $result_handle);
#use File::Copy;
#copy($expected_handle, $result_handle);

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

sub fixScript {
	my $self = shift;
	my $test = shift;
	my $result = shift;
	# FIXME
	# $fixer->fix($test, $result)
}

exit 0;
