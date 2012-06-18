#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Markdown::Pod;
use Encode;

my $main_pm_fp = $ARGV[0];
my $main_git_fp = $ARGV[1];

my $readme_from_markdown;
my $final_module_pm_file;

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");

_read_readme_markdown();
_read_main_pm_file();
_write_result();


# =============================

sub _read_readme_markdown {

    my $fp = $main_git_fp . '/README.markdown';

    open (my $file, "<", $fp)
        or die "cant open $fp";
    binmode($file, ":utf8");
    my $markdown = '';

    while (my $l = <$file>) {
        $markdown .= $l;
    }

    close $file;


    my $m2p = Markdown::Pod->new;
    my $pod = $m2p->markdown_to_pod(
        markdown => $markdown,
        encoding => 'utf8',
    );

    $readme_from_markdown = Encode::decode("utf8", $pod);
}

sub _read_main_pm_file {
    my $fp = $main_pm_fp;
    open (my $file, "<", $fp)
        or die "cant open $fp";
    binmode($file, ":utf8");

    while (my $l = <$file>) {

        if ($l =~ /\@\@\@FROM_MARKDOWN\@\@\@/){
            $final_module_pm_file .= "\n$readme_from_markdown\n";
        } else {
            $final_module_pm_file .= $l;
        }
    }

    close $file;
}

sub _write_result {
    print $final_module_pm_file;
}

1;
