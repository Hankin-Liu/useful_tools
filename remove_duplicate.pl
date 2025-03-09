#################################################################################################################
# remove_duplicate.pl  remove duplicate info of file.
#
# Platform: linux
#
# USAGE: perl remove_duplicate.pl [-h] [-f filename] [-d delimiter] [-i keyword_index]
# Run "perl remove_duplicate.pl -h" for detail.
#
# Copyright (c) 2025 Liu Hua Jun.
# Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE(the "License")
#
# 9-Mar-2025   Liu Hua Jun       Created this.
#################################################################################################################
#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

sub print_help
{
    print << "END_USAGE";
Usage: $0 -f <filename> [-d <delimiter> -i <index>] [-h]

Options:
  -f <filename>   Specify the input file (required)
  -d <delimiter>  Specify the delimiter (optional, must be used with -i)
  -i <index>      Specify the column index for deduplication (0-based, optional, must be used with -d)
  -h              Show this help message

Behavior:
  - If only -f is provided, deduplication is performed based on entire lines.
  - If -d and -i are provided, deduplication is performed based on the specified column, the first one will be kept.
  - Both -d and -i must be specified together; otherwise, an error occurs.

Examples:
  1. Deduplicate based on entire lines:
     perl $0 -f data.csv

  2. Deduplicate based on the second column (index 1) with a comma as the delimiter:
     perl $0 -f data.csv -d ',' -i 1
END_USAGE
}

# Parse command-line arguments# Parse command-line arguments
my ($file, $delimiter, $index, $help);
GetOptions(
    "f=s" => \$file,      # Required: filename
    "d=s" => \$delimiter, # Optional: delimiter (must be used with -i)
    "i=i" => \$index,     # Optional: column index (must be used with -d)
    "h"   => \$help       # Show help message
) or die "Usage: $0 -f <filename> [-d <delimiter> -i <index>] [-h]\n";

# Show help message
if ($help) {
    print_help;
    exit;
}

# Ensure the filename is provided# Ensure the filename is provided
die "Error: -f <filename> is required\n" unless $file;

# If either -d or -i is specified, both must be provided
if (defined $delimiter xor defined $index) {
    die "Error: Both -d and -i must be specified together\n";
}

# Open the file in read-only mode
open my $fh, '<', $file or die "Error: Cannot open file '$file': $!\n";

# Store unique lines or unique column values
my %seen;

while (<$fh>) {
    chomp;
    if (defined $delimiter && defined $index) {
        my @fields = split /$delimiter/, $_, $index + 2;  # Limit splitting for efficiency
        my $key = $fields[$index];  # Extract the specified column
        next if !defined $key || $seen{$key}++;  # Skip if already seen
    } else {
        next if $seen{$_}++;  # Deduplicate based on entire lines
    }
    print "$_\n";  # Êä³öÎ¨Ò»ÐÐ
}

close $fh;

