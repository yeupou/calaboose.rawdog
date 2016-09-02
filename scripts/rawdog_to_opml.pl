#
# FILE DISCONTINUED HERE
# UPDATED VERSION AT
#         https://gitlab.com/yeupou/calaboose.rawdog/raw/master/scripts/rawdog_to_opml.pl
#
#                                 |     |
#                                 \_V_//
#                                 \/=|=\/
#                                  [=v=]
#                                __\___/_____
#                               /..[  _____  ]
#                              /_  [ [  M /] ]
#                             /../.[ [ M /@] ]
#                            <-->[_[ [M /@/] ]
#                           /../ [.[ [ /@/ ] ]
#      _________________]\ /__/  [_[ [/@/ C] ]
#     <_________________>>0---]  [=\ \@/ C / /
#        ___      ___   ]/000o   /__\ \ C / /
#           \    /              /....\ \_/ /
#        ....\||/....           [___/=\___/
#       .    .  .    .          [...] [...]
#      .      ..      .         [___/ \___]
#      .    0 .. 0    .         <---> <--->
#   /\/\.    .  .    ./\/\      [..]   [..]
#
#!/usr/bin/perl
#
# Rawdog 2 OPML generator
#
######################### 
# $Id: rawdog_to_opml.pl 126 2004-11-16 18:37:00Z steve $
#########################
# $Log$
# Revision 1.5  2004/11/16 18:37:00  steve
# should now handle the new time system
#
# Revision 1.4  2004/03/02 15:31:34  steve
# only creates a category if it has feeds in it
#
# Revision 1.3  2004/03/01 08:25:51  steve
# * removed dependancy on XML::Simple, as I really dislike it for anything other
#   than config files
# * replaced it with really nasty hand-coding (escaped properly though!)
# * now outputs stuff in categories based on special comments
#
# Revision 1.2  2004/01/20 17:29:56  steve
# corrected the OPML output format syntax and groups things in a subscription
# outline
#
# Revision 1.1  2004/01/06 22:02:46  steve
# added
#
#########################

use strict;
use Getopt::Std;

my ($version) = '$Revision: 126 $' =~ /Revision:\s*(.+)\$/;

our ( $opt_h, $opt_o, $opt_e, $opt_V );
getopts("o:e:hV");

die "$0 version: $version\n" if $opt_V;
usage() if ($opt_h || @ARGV != 1);


#### end init

my %cats = ();
my $file = $ARGV[0];

open FILE, $file or die "cannot open $file for reading: $!\n";

my $ownerName = $opt_o if $opt_o;
my $ownerEmail = $opt_e if $opt_e;

my $curcat = "Subscriptions";

foreach my $line (<FILE>){

    # extract the category. Uses the notation: "### category name"
    if( $line =~ /^\s*\#{3,3}\s*(.+?)\s*(?:\#*)$/ ){
	($curcat) = $1;
    }

    # remove comments
    $line =~ s/\#.+$//;

    # add the feeds
    if( $line =~ /^\s*feed\s+\d+[hmsd]?\s+(.+)/i ){
	$cats{$curcat} = [] unless exists $cats{$curcat};
	push @{$cats{$curcat}}, $1;
    }
}

close FILE;

print<<XHEAD;
<?xml version="1.0" encoding="ISO-8859-1"?>
XHEAD

    my $title = "Rawdog feed listing";

# prettify the title
$title = "$title for $ownerName" if $ownerName;

my $date = scalar localtime( time );

    my $head=<<HEAD;

    <title>$title</title>
    <ownerName>$ownerName</ownerName>
    <ownerEmail>$ownerEmail</ownerEmail>
    <dateCreated>$date</dateCreated>
HEAD

# add in the body
my $outlines = [];

# squish the %cats data structure into OPMLy XML
my $xcategories = join ("\n", map {
    "    <outline title='".escape_xml($_)."'>".
	join( "\n", map {
	    "\n      <outline type='rss' title='".
		escape_xml($_)."' xmlUrl='".
		escape_xml($_)."'/>"
	} @{$cats{$_}} )."\n    </outline>"
    } keys %cats);


# put it all together
print<<OPML;
<opml version='1.0'>
  <head>$head</head>
  <body>
$xcategories
  </body>
</opml>
OPML

# we're done
exit;

#### helper subs

sub escape_xml{
    @_[0] =~ s/\'/&apos;/g;
    @_[0] =~ s/\&/&amp;/g;
    @_[0] =~ s/\</&lt;/g;
    @_[0] =~ s/\>/&gt;/g;
    return @_[0];
}

sub usage(){
    die <<USAGE;
usage: $0 [options] rawdog_config

Reads a rawdog config file and generates an OPML file based on it.
 
options:
    -o STRING   OPML file owner name
    -e STRING   OPML file owner email
    -h          this help
    -V          print version information

Copyright(C) 2004 Steve Pomeroy <steve\@staticfree.info>
Licensed under the GNU GPL. See documentation for complete details.
To read full documentation, run:
   perldoc $0
USAGE

}

__END__

=head1 NAME

Rawdog to OPML exporter

=head1 SYNOPSIS

B<rawdog_to_opml> S<[ B<-h> ]> S<[ B<-o OWNER> ]> S<[ B<-e OWNER_MAIL> ]> I<file> 

=head1 DESCRIPTION

C<rawdog_to_opml>
Exports a rawdog listing to OMPL. Item headers are done as follows:

    ### kittens
    feed 60 http://purr.example.com/index.xml
    feed 45 http://kitten.example.com/feed.rdf

    ### news 
    feed 1h http://news.example.com/feed
    feed 45m http://morenews.example.com/news.xml

Where all lines starting with ### will be a header.

=head1 OPTIONS

=over 8

=item B<-h>

This help

=item B<-o STRING>

OPML file owner name

=item B<-e STRING>

OPML file email address

=back

=head1 ENVIRONMENT

No environment variables are used.

=head1 AUTHOR

Steve Pomeroy <steve@staticfree.info>
http://staticfree.info/

=head1 LICENSE

Copyright © 2003-2004 Steve Pomeroy <steve@staticfree.info>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

=head1 SEE ALSO

perl(1)

=head1 BUGS

Mail them to me. Preferably not through the USPS.

=cut
