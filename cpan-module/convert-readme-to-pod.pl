#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Markdown::Pod;
use Encode;

my $fp = $ARGV[0];

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");


open (my $file, "<", $fp)
    or die "cant open $fp";
binmode($file, ":utf8");
my $markdown = '';

while (my $l = <$file>){
    $markdown .= $l;
}

close $file;


my $m2p = Markdown::Pod->new;
my $pod = $m2p->markdown_to_pod(
    markdown => $markdown,
    encoding => 'utf8',
);

$pod = Encode::decode("utf8", $pod);

print $pod;

1;
