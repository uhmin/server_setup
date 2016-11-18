#!/usr/bin/perl
use strict;
our $LOGFILE="/var/log/tripwire.log";
&main;

sub main{
    my $sw=0;
    if(open FIN, "$LOGFILE"){
        while(my $line=<FIN>){
#           print $line;
            if($line=~/^Added:/ || $line=~/^Modified:/){
#               print $line;
                $sw=1;
            }elsif($line!~/\S/){
#               print "--$line--\n";
                $sw=0;
            }elsif($sw==1){
                $line=~s/^\"(.*)\"/$1/;
                chomp($line);
                if ( ! -d $line ){
                    print "$line\n";
                }
            }
        }
        close  FIN;
    }
}
