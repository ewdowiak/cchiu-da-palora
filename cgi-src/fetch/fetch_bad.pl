#!/usr/bin/env perl

##  "fetch_bad.pl" -- find bad and missing parts of speech
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

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

use strict ;
use warnings ;
use Storable qw( retrieve ) ;

my %dieli_sc = %{ retrieve('../../cgi-lib/dieli-sc-dict' ) } ;

my $otfile = "fetch_bad_" . datestamp() . ".txt" ;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  good parts of speech
my @goodlist = ('{v}','{m}','{f}','{adj}','{}','{adv}','{prep}',
		'{pron}','{mpl}','{fpl}','{n}','{conj}','{m/f}');
my $goodre = '^'. join( '$|^' , @goodlist ) . '$';

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  find Sicilian words with bad parts of speech
my @badlist ;
foreach my $palora (sort keys %dieli_sc) {
    foreach my $i (0..$#{$dieli_sc{$palora}}) {
	my $sc_part = ${$dieli_sc{$palora}[$i]}{"sc_part"} ;
	if ( ! defined $sc_part || $sc_part !~ /$goodre/ ) {
	    push( @badlist , $palora );
	}
    }
}

##  prepare output
my $ottxt ;
foreach my $search (sort uniq(@badlist)) {
    
    ## format for dieli edits file
    $ottxt .= "\n";
    $ottxt .= '## $ ./query-dieli.pl '. 'sc' .' strittu '. $search  ."\n";

    foreach my $i (0..$#{$dieli_sc{$search}}) {
	my %th = %{ ${$dieli_sc{$search}}[$i] } ;

	##  create output list
	my $sc_part = ( ! defined $th{"sc_part"} ) ? "" : $th{"sc_part"} ;
	$ottxt .= "## \t" . $i . "  ==  " ;
	$ottxt .= $th{"sc_word"} . " " . $sc_part . " --> " ;
	$ottxt .= $th{"it_word"} . " " . $th{"it_part"} . " --> " ;
	$ottxt .= $th{"en_word"} . " " . $th{"en_part"} . "\n" ;
    }
}

## print output
open( OTFILE , ">$otfile" ) || die "could not open:  $otfile";
print OTFILE "\n";
print OTFILE $otfile ."\n";
print OTFILE "\n";
print OTFILE $ottxt ."\n";
close OTFILE ;

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
