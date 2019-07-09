#!/usr/bin/env perl

##  "fetch_nouns.pl" -- searches for nouns in Dieli dictionary and creates "proto-hashes"
##  Copyright (C) 2018 Eryk Wdowiak
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##  
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <https://www.gnu.org/licenses/>.

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

use strict ;
use warnings ;
no warnings qw( uninitialized );
use Storable qw( retrieve ) ;

my %dieli_sc = %{ retrieve('../../cgi-lib/dieli-sc-dict' ) } ;
my $otnouns = "fetch_nouns_" . datestamp() . ".txt" ;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  sort the nouns into alphabetical order
my @order = get_alpha_order( \%dieli_sc );

##  now let's create some proto hashes
open( OTNOUNS , ">$otnouns" ) || die "could not open:  $otnouns" ;
print OTNOUNS "\n" . '##  DO  NOT  EDIT  THIS  FILE' . "\n" ;
print OTNOUNS        '##  Just copy-paste what you need into:  "/cgi-src/mk_noun-notes.pl"' . "\n" ;
print OTNOUNS        '##  ================================================================' . "\n\n" ;

foreach my $palora (@order) {

    ##  collect translations and part of speech
    my @dieli_en ;
    my @dieli_it ;
    my $sc_part ;
    foreach my $i (0..$#{$dieli_sc{$palora}}) {
	my %th = %{ ${$dieli_sc{$palora}}[$i] } ; 
	if ( $th{"en_word"} ne '<br>' ) { push( @dieli_en , $th{"en_word"} );};
	if ( $th{"it_word"} ne '<br>' ) { push( @dieli_it , $th{"it_word"} );};
	$sc_part = ${$dieli_sc{$palora}[$i]}{"sc_part"} ;
    }
    @dieli_en = uniq( @dieli_en ) ; 
    @dieli_it = uniq( @dieli_it ) ; 

    ##  fetch/infer gender
    my $gender ;
    if ( $sc_part eq '{m}' || $sc_part eq '{mpl}' ) {
	$gender = "mas" ;
    } elsif ( $sc_part eq '{f}' || $sc_part eq '{fpl}' ) {
	$gender = "fem" ;
    } elsif ( $sc_part eq '{m/f}' ) {
	$gender = "both" ;
    }

    ##  generate proto hash
    my $ottxt = mk_proto( $palora , \@dieli_en , \@dieli_it , $gender ) ;

    print OTNOUNS $ottxt ;
}
close OTNOUNS ;


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  SUBROUTINES
##  ===========

sub mk_proto {

    my $dieli    =    $_[0]   ;
    my @dieli_en = @{ $_[1] } ;
    my @dieli_it = @{ $_[2] } ;
    my $gender   =    $_[3]   ;
    
    ##  guess  "plend"
    my $plend ;
    if ( $dieli =~ /eddu$/ && $gender eq "mas" ) {
	$plend = "eddu" ;
    } elsif ( $dieli =~ /aru$/ && $gender eq "mas" ) {
	$plend = "aru" ;
    } elsif ( $dieli =~ /uni$/ && $gender eq "mas" ) {	
	$plend = "uni" ;
    } elsif ( $dieli =~ /uri$/ && $gender eq "mas" ) {
	$plend = "uri" ;
    } elsif ( $dieli =~ /u$/ && $gender eq "fem" ) {
	$plend = "xx" ;
    } elsif ( $dieli =~ /[bcdfghjklmnpqrstvwxyz]$/ ) {
	##  probably foreign word
	$plend = "xx" ;
    } else {
	$plend = "xi" ;
    }

    my $ottxt ;
    $ottxt .= "\n";
    $ottxt .= '##  ##  ##  ##  ##  ##  ##  ##  ##' . "\n";
    $ottxt .= "\n";
    $ottxt .= '##  ##  ' . $dieli . ' -- proto hash -- MUST check for accuracy' . "\n";
    $ottxt .= '##  %{ $vnotes{"' . $dieli . '_noun"} } = (' . "\n";
    $ottxt .= '##      display_as => "' . $dieli . '",' . "\n";
    $ottxt .= '##      dieli => ["' . $dieli . '",],' . "\n";
    $ottxt .= '##      dieli_en => ['; 
    foreach my $listing (@dieli_en) { $ottxt .= '"' . $listing . '",';};
    $ottxt .= '],' . "\n";
    $ottxt .= '##      dieli_it => ['; 
    foreach my $listing (@dieli_it) { $ottxt .= '"' . $listing . '",';};
    $ottxt .= '],' . "\n";
    $ottxt .= '##      ## notex => ["","",],' . "\n";
    $ottxt .= '##      part_speech => "noun",' . "\n";
    $ottxt .= '##      noun => {' . "\n";
    $ottxt .= '##  	gender => "'    . $gender . '",' . "\n";
    $ottxt .= '##  	plend => "' . $plend  . '",' . "\n";
    $ottxt .= '##  	## plural => "",' . "\n";
    $ottxt .= '##      },);' . "\n";
    
    return $ottxt ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##

##  tip of the hat to List::MoreUtils for this sub
sub uniq { 
    my %h;  
    map { $h{$_}++ == 0 ? $_ : () } @_;
}

##  ##  ##  ##  ##  ##  ##  ##  ##

sub datestamp {
    my($day, $month, $year)=(localtime)[3,4,5]; 
    $year += 1900 ; 
    $month = sprintf( "%02d" , $month + 1) ;
    $day = sprintf( "%02d" , $day ) ;
    my $ot = $year . "-" . $month . "-" . $day ;
    return $ot ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##

sub get_alpha_order {
    my %dieli_sc = %{ $_[0] } ;
    my @order ;
    
    foreach my $palora (sort keys %dieli_sc) {
	foreach my $i (0..$#{$dieli_sc{$palora}}) {
	    my $sc_part = ${$dieli_sc{$palora}[$i]}{"sc_part"} ;
	    if ( $sc_part eq '{m}'   || $sc_part eq '{f}' ||  $sc_part eq '{m/f}' || 
		 $sc_part eq '{mpl}' || $sc_part eq '{fpl}' ) {
		push( @order , $palora );
	    }
	}
    }
    @order = uniq( @order ) ; 
    return @order ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##

sub fix_accents {

    my $line = $_[0] ;
    
    ##  fix accents
    $line =~ s/~aG~/à/g;
    $line =~ s/~eG~/è/g;
    $line =~ s/~iG~/ì/g;
    $line =~ s/~oG~/ò/g;
    $line =~ s/~uG~/ù/g;
    
    $line =~ s/~AG~/À/g;
    $line =~ s/~EG~/È/g;
    $line =~ s/~IG~/Ì/g;
    $line =~ s/~OG~/Ò/g;
    $line =~ s/~UG~/Ù/g;
	           
    $line =~ s/~aH~/â/g;
    $line =~ s/~eH~/ê/g;
    $line =~ s/~iH~/î/g;
    $line =~ s/~oH~/ô/g;
    $line =~ s/~uH~/û/g;
	           
    $line =~ s/~AH~/Â/g;
    $line =~ s/~EH~/Ê/g;
    $line =~ s/~IH~/Î/g;
    $line =~ s/~OH~/Ô/g;
    $line =~ s/~UH~/Û/g;
    
    return $line;
}

##  ##  ##  ##  ##  ##  ##  ##  ##

sub accents_to_tildas {

    my $line = $_[0];

    $line =~ s/à/~aG~/g;
    $line =~ s/è/~eG~/g;
    $line =~ s/ì/~iG~/g;
    $line =~ s/ò/~oG~/g;
    $line =~ s/ù/~uG~/g;

    $line =~ s/À/~AG~/g;
    $line =~ s/È/~EG~/g;
    $line =~ s/Ì/~IG~/g;
    $line =~ s/Ò/~OG~/g;
    $line =~ s/Ù/~UG~/g;

    $line =~ s/â/~aH~/g;
    $line =~ s/ê/~eH~/g;
    $line =~ s/î/~iH~/g;
    $line =~ s/ô/~oH~/g;
    $line =~ s/û/~uH~/g;

    $line =~ s/Â/~AH~/g;
    $line =~ s/Ê/~EH~/g;
    $line =~ s/Î/~IH~/g;
    $line =~ s/Ô/~OH~/g;
    $line =~ s/Û/~UH~/g;
    
    return $line;
}
