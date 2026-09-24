#!/usr/bin/env perl
use strict;
use warnings;
use open qw(:encoding(UTF-8));

use Cwd qw(getcwd);
use File::Basename qw(basename dirname);
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempfile);

my $mod_dir = File::Spec->rel2abs(dirname(__FILE__));
{
    local @INC = ($mod_dir, @INC);
    my $loaded = eval q{
        use feature qw(say);
        require "extender.pl";
        1;
    };
    die "Could not load extender functions: $@" unless $loaded;
}

my ($file, $party_size, $output_file) = @ARGV;
die "Usage: $0 INPUT_FILE PARTY_SIZE [OUTPUT_FILE]\n"
    unless defined $file && defined $party_size;
die "Input file does not exist: $file\n" unless -f $file;
die "Input file is not readable: $file\n" unless -r $file;
die "Party size must be a whole number between 1 and 10\n"
    unless $party_size =~ /^\d+$/ && $party_size >= 1 && $party_size <= 10;

if (-z $file) {
    warn "Skipping empty file: $file\n";
    exit 0;
}

my $run_dir = getcwd();
my $input_abs = File::Spec->rel2abs($file, $run_dir);
my $preserve_output = defined $output_file;
my $temporary_output;

if ($preserve_output) {
    $output_file = File::Spec->rel2abs($output_file, $run_dir);
    die "Input and output files must be different\n"
        if File::Spec->canonpath($input_abs) eq File::Spec->canonpath($output_file);
} else {
    my ($handle, $path) = tempfile('10pp-output-XXXXXX', DIR => $run_dir, UNLINK => 0);
    close($handle) or die "Could not close temporary output $path: $!";
    $output_file = $path;
    $temporary_output = $path;
}

my $rc = extend($input_abs, $output_file, $party_size);
if (!$rc) {
    unlink $output_file if -e $output_file && -z $output_file;
    exit 0;
}

my $diff_dir = File::Spec->catdir($run_dir, 'diffs');
make_path($diff_dir) unless -d $diff_dir;
my $source_for_diff = $input_abs;
my $commentless_file;

if ($file =~ /(?:\.d|\.dlg)$/i) {
    open(my $input_handle, '<:encoding(UTF-8)', $input_abs)
        or die "Could not read dialog $input_abs: $!";
    my $input_text = do { local $/; <$input_handle> };
    close($input_handle) or die "Could not close dialog $input_abs: $!";

    $input_text =~ s{/\*(?:(?!\*/).)*\*/}{}gs;
    $input_text =~ s{^//.*\n}{}gm;
    $input_text =~ s{//.*}{}g;

    my ($commentless_handle, $path) = tempfile('10pp-dialog-XXXXXX', DIR => $run_dir, UNLINK => 0);
    binmode($commentless_handle, ':encoding(UTF-8)');
    print {$commentless_handle} $input_text;
    close($commentless_handle) or die "Could not close temporary dialog $path: $!";
    $source_for_diff = $path;
    $commentless_file = $path;
}

my $diff_path = File::Spec->catfile($diff_dir, basename($file) . '.diff');
my $cdiff = File::Spec->catfile($mod_dir, 'cdiff.pl');
open(my $diff_output, '>:encoding(UTF-8)', $diff_path)
    or die "Could not create diff $diff_path: $!";
open(my $diff_pipe, '-|', $^X, "-I$mod_dir", $cdiff, '-u', $source_for_diff, $output_file)
    or die "Could not start cdiff.pl: $!";
while (my $line = <$diff_pipe>) {
    print {$diff_output} $line;
}
close($diff_output) or die "Could not close diff $diff_path: $!";
close($diff_pipe);
my $diff_status = $? >> 8;
die "cdiff.pl failed with exit code $diff_status\n" if $diff_status > 1;

unlink $commentless_file if defined $commentless_file && -e $commentless_file;
unlink $temporary_output if defined $temporary_output && -e $temporary_output;
exit 0;
