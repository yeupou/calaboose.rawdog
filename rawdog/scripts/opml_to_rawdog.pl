#!/usr/bin/perl
# opml-export-feeds 0.5 - export feed urls from OPML file, optionally in rawdog config format
# (c) 2007-09-07 Tero Karvinen www.iki.fi/karvinen
#     2010       yeupou@gnu
# GNU General Public License, version 2 or later
# usage:
# opml-export-feeds --rawdog-config foo-opml.xml > foo.txt
# cat foo.txt >> ~/.rawdog/config
 
use strict;
use POSIX qw(strftime locale_h);

print "# built on ".strftime("%c", localtime)."\n";

my $rawdog_config=1; # false
#if ($ARGV[0] =~ "--rawdog-config") { 
#        $rawdog_config=1;
#        shift;
#};
 
my $filename=$ARGV[0];
open(FILE, "$filename") or die "Can't open \"$filename\": $!";
 
my $xmlUrl=0;
my $category=0;
while (<FILE>) {
    $category = $1 if /outline\ isOpen\=\"true\"\ id\=\"\d*\" text\=\"(\w*)\"/;
    $xmlUrl = $1 if /xmlUrl=\"([^\"]+)\"/;
    if ($xmlUrl ne 0) {
	print "feed 30m " if $rawdog_config;
	print "$xmlUrl";
	print " define_group=$category" if $category;
	print "\n";
    }
    $xmlUrl=0;
}
close FILE;
