#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;
use URI;
use URI::Escape qw(uri_unescape);

my $PROTO = "smdu";

my $SHARE = '/usr/share/skyfalls-manual-duplex';
my $EMPTY_FILE = "$SHARE/empty.pdf";

my $DEFAULT_FLIP_MESSAGE='After the printer has completed printing, flip the papers over without changing its orientation. Then feed them into the paper tray.';

# Device Discovery
if(@ARGV == 0){
    print("file $PROTO:// \"Unknown\" \"Skyfalls' Manual duplex utility\"");
    exit(0);
}

# Parse ARGV
my $jobID=$ARGV[0];
my $user=$ARGV[1];
my $jobName=$ARGV[2];
my $copies=$ARGV[3];

# Parse Env
my $tmpFolder="/tmp";
# using a anonymous function to keep global variables clean
my ($targetPrinterName, $flipMessage) = (sub(){
    my $uri = URI->new($ENV{'DEVICE_URI'});
    # loading the URI::QueryParam module adds some extra methods to URIs that support query methods. https://metacpan.org/pod/URI::QueryParam
    use URI::QueryParam;
    if($uri->authority eq ''){
        println('ERROR: empty target server in URI.');
        exit(1);
    }
    # Since 'false' is considered true, we'll use numbers in the params. 0->false, 1-> true
    return (uri_unescape($uri->authority), $uri->query_param('flipMessage') // $DEFAULT_FLIP_MESSAGE);
})->();

println("New JOB: #$jobID-\"$jobName\"*$copies by USER $user");
println("Temp Folder: $tmpFolder, Target Name: $targetPrinterName");

# Write STDIN to temp file
# when dealing with binary data, use binmode(STDIN);https://stackoverflow.com/a/40637207/11939026
my $sourceFile=(sub{
    binmode(STDIN);
    my $path = "$tmpFolder/$PROTO-original-$jobID.pdf";
    open(my $sourceFile, '>', $path) or die("Failed to Open $path");
    while (<STDIN>) {
        print $sourceFile $_;
    }
    close($sourceFile);
    return $path;
})->();

println("Original file written to: $sourceFile");

# Get PDF length
my $pageCount = pdfPages($sourceFile);

#Single page
if ($pageCount == 1){
    # no need to duplex
    println("Single page. No need to duplex.");
    lp($sourceFile, "single", 1);
    exit(0);
}

# Make even pages
if ($pageCount % 2 == 1) {
    my $evened = "$tmpFolder/$PROTO-evened-$jobID.pdf";
    pdfunite($sourceFile, $EMPTY_FILE, $evened);
    $sourceFile = $evened;
    println("Odd pages. Evened: $evened");
    $pageCount++;
}

# Split pages then print
lp($sourceFile, "odd", join(",",odd((1..$pageCount))));
msgbox($flipMessage);
lp($sourceFile, "even", join(",",even((1..$pageCount))));

sub println{
    print STDERR $_[0]."\n";
}

sub pdfPages{
    open(my $handle, '-|', 'pdfinfo', $_[0]);
    while(my $line = <$handle>){
        if($line =~ /Pages: [ ]+(\d+)/){
            println("$1 Total page(s).");
            return $1;
        }
    }
}

# lp file name(ODD/EVEN) pages
sub lp{
    system('lp', '-d', $targetPrinterName, '-n', $copies, '-t', "#$jobID-$_[1]($PROTO)-$jobName", '-P', $_[2], $_[0]);
}

# pdfunite SOURCE1 SOURCE2 OUTPUT
sub pdfunite{
    system('pdfunite', $_[0], $_[1], $_[2]);
}

sub odd{
    return grep {$_%2==1} @_
}

sub even{
    return grep {$_%2==0} @_
}

# msgbox TEXT <TIMEOUT>
sub msgbox{
    system('sudo','-u',$user,'zenity','--warning', '--title="Manual Duplex"', '--width=500', '--display=:0.0','--text',$_[0]);
}