#!/usr/bin/env perl

use strict;
use warnings;
use Storable qw( retrieve ) ;

my $vnhash = retrieve('/home/eryk/website/napizia/cgi-lib/vocab-notes' );
my %vnotes = %{ $vnhash } ;

my $otfile = "fetch_counts_" . datestamp() . ".txt" ;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

my @notes ;
my @proverbs ;
my @poems ;
my @examples ;

my $nongram = 0 ; 

foreach my $key (sort keys %vnotes) {

    if ( ! defined $vnotes{$key}{hide} ) { 
	push( @notes , $key );
    }

    if ( ! defined $vnotes{$key}{proverb} ) { my $blah = "do nothing";
    } else { push( @proverbs , @{ $vnotes{$key}{proverb} } );
    }
    
    if ( ! defined $vnotes{$key}{poetry} ) { my $blah = "do nothing";
    } else { push( @poems    , @{ $vnotes{$key}{poetry} }  );
    }

    if ( ! defined $vnotes{$key}{notex} ) { my $blah = "do nothing";
    } else { push( @examples , @{ $vnotes{$key}{notex} } );
    }

    if ( ! defined $vnotes{$key}{proverb} && ! defined $vnotes{$key}{poetry} && 
	 ! defined $vnotes{$key}{notex}   && ! defined $vnotes{$key}{hide} ) {
	my $blah = "do nothing";
    } else {
	$nongram += 1;
    }
}

my @uniq_notes     = uniq( @notes );
my @uniq_proverbs  = uniq( @proverbs );
my @uniq_poems     = uniq( @poems );
my @uniq_examples  = uniq( @examples );

my $ct_notes    = sprintf("% 5d", $#uniq_notes    + 1 ); 
my $ct_proverbs = sprintf("% 5d", $#uniq_proverbs + 1 );
my $ct_poems    = sprintf("% 5d", $#uniq_poems    + 1 );
my $ct_examples = sprintf("% 5d", $#uniq_examples + 1 );

my $tt_notes    = sprintf("% 5d", $#notes    + 1 );
my $tt_proverbs = sprintf("% 5d", $#proverbs + 1 );
my $tt_poems    = sprintf("% 5d", $#poems    + 1 );
my $tt_examples = sprintf("% 5d", $#examples + 1 );

my $tt_nongram  = sprintf("% 5d", $nongram );

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

open( OTFILE , ">$otfile" ) || die "could not open:  $otfile" ;
print OTFILE "\n" ;
print OTFILE $otfile . "\n" ;
print OTFILE "counts of annotated words" . "\n" ;
print OTFILE "-------------------------" . "\n\n" ;

print OTFILE "\t" . $ct_notes    . ' notes     -- ' . $tt_notes     . ' total' ."\n";
print OTFILE "\t" . $ct_proverbs . ' proverbs  -- ' . $tt_proverbs  . ' total' ."\n";
print OTFILE "\t" . $ct_poems    . ' poems     -- ' . $tt_poems     . ' total' ."\n";
print OTFILE "\t" . $ct_examples . ' examples  -- ' . $tt_examples  . ' total' ."\n";
print OTFILE "\n";
print OTFILE "\t" . $tt_nongram  . ' non-grammar annotated words' ."\n";

close OTFILE;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  SUBROUTINES
##  ===========

##  tip of the hat to List::MoreUtils for this sub
sub uniq { 
    my %h;  
    map { $h{$_}++ == 0 ? $_ : () } @_;
}

sub datestamp {
    my($day, $month, $year)=(localtime)[3,4,5]; 
    $year += 1900 ; 
    $month = sprintf( "%02d" , $month + 1) ;
    $day = sprintf( "%02d" , $day ) ;
    my $ot = $year . "-" . $month . "-" . $day ;
    return $ot ;
}
