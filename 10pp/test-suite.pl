#!/usr/bin/env perl
use strict;
use warnings;
use open qw(:encoding(UTF-8));

use File::Basename qw(basename);
use File::Spec;
use File::Temp qw(tempfile);
use FindBin qw($Bin);
use Term::ANSIColor qw(:constants);

{
    local @INC = ($Bin, @INC);
    my $loaded = eval q{
        use feature qw(say);
        require "extender.pl";
        1;
    };
    die "Could not load extender functions: $@" unless $loaded;
}

my $quiet = 0;
my @patterns;
for my $argument (@ARGV) {
    if ($argument eq '-q') {
        $quiet = 1;
        next;
    }
    push @patterns, $argument;
}

my $tests_dir = File::Spec->catdir($Bin, 'tests');
@patterns = (File::Spec->catfile($tests_dir, '*[0-9D]')) unless @patterns;

my %seen;
my @tests;
for my $pattern (@patterns) {
    my $resolved = File::Spec->file_name_is_absolute($pattern)
        || $pattern =~ m{[\\/]}
        ? $pattern
        : File::Spec->catfile($tests_dir, $pattern);
    push @tests, grep { !$seen{$_}++ } glob($resolved);
}
@tests = sort grep { $_ !~ /_expected$/ } @tests;
die "No tests matched the supplied patterns\n" unless @tests;

sub read_text {
    my ($path) = @_;
    open(my $handle, '<:encoding(UTF-8)', $path)
        or die "Could not read $path: $!";
    my $text = do { local $/; <$handle> };
    close($handle) or die "Could not close $path: $!";
    return $text;
}

sub normalize_newlines {
    my ($text) = @_;
    $text =~ s/\r\n?/\n/g;
    return $text;
}

my $successes = 0;
my $failures = 0;
for my $test (@tests) {
    my $expected_file = $test . '_expected';
    die "$expected_file does not exist or is not readable\n"
        unless -f $expected_file && -r $expected_file;

    my ($result_handle, $result_file) = tempfile('10pp-test-XXXXXX', DIR => $Bin, UNLINK => 0);
    close($result_handle) or die "Could not close $result_file: $!";

    my $rc = extend($test, $result_file, 8);
    if (!$rc) {
        print basename($test), ': ', GREEN, 'SUCCESS', RESET, " (skipped)\n";
        $successes++;
        unlink $result_file if -e $result_file;
        next;
    }

    my $result = read_text($result_file);
    my $expected = read_text($expected_file);

    if (normalize_newlines($result) eq normalize_newlines($expected)) {
        print basename($test), ': ', GREEN, 'SUCCESS', RESET, "\n";
        $successes++;
    } else {
        print basename($test), ': ', RED, 'FAILURE', RESET, "\n";
        $failures++;
        unless ($quiet) {
            system($^X, "-I$Bin", File::Spec->catfile($Bin, 'cdiff.pl'), '-u', $expected_file, $result_file);
        }
    }

    unlink $result_file if -e $result_file;
}

my $total = $successes + $failures;
if ($failures) {
    print RED, "SOME TESTS FAILED ($failures/$total)", RESET, "\n";
    exit 1;
}

print GREEN, "ALL $successes TESTS PASSED", RESET, "\n";
exit 0;
