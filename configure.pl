#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;
use URI;
use URI::QueryParam;
use URI::Escape qw(uri_escape_utf8);

print("Select your target printer:\n");
my @printers = `lpstat -v` =~ /device for (.*?): (.*?)$/gm;
for(my $i = 0; $i < @printers / 2; $i++){
    print("[$i] $printers[$i*2] -> $printers[$i*2+1]\n")
}

my $target="";
while(chomp(my $line = <STDIN>)){
    if($line ne '' && $line >= 0 && $line<@printers/2){
        $target = $printers[$line*2];
        print("You have selected: $target\n");
        last
    }else{
        print("Please select one from the list.\n")
    }
}

print("Set name for the new Printing Queue:\n");
my $name = "";
while(chomp(my $line = <STDIN>)){
    if($line ne ''){
        $name = $line;
        print("Name is: $line\n");
        last
    }else{
        print("Please input a valid name.\n")
    }
}

print("Set Notification Message when duplex is required(empty for default value, one line only):\n");
my $hint = <STDIN>;
chomp($hint);

my $uri = URI->new("","smdu");
$uri->authority(uri_escape_utf8($target));
if($hint ne ""){
    $uri->query_param("flipMessage",$hint);
}

my $result='smdu:'.$uri->as_string();
system('lpadmin','-p',$name,'-v',$result,'-P','/usr/share/ppd/cupsfilters/Generic-PDF_Printer-PDF.ppd','-E');
print("Result URI: $result. Created Printing Queue.\n");