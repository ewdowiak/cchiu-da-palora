#!/usr/bin/env perl

##  ./mk_traina-into-chiu.pl -- add Traina into Chiu and Dieli
##  Copyright (C) 2026 Eryk Wdowiak
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
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

use strict;
# use warnings;
# no warnings qw( uninitialized numeric void ) ; 

use utf8;

use Storable qw( retrieve nstore ) ;

use lib "../cgi-lib";
use Napizia::TextTools;
use Napizia::Utils;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  input files 
my $vnotesfile = '../cgi-lib/vocab-notes';
my $traina_hlfile = "../cgi-lib/traina_hdword-to-line";
my $dieli_sc_dict = '../cgi-lib/dieli-sc-dict'; 
my $dieli_en_dict = '../cgi-lib/dieli-en-dict'; 
my $dieli_it_dict = '../cgi-lib/dieli-it-dict'; 

##  output files
my $vnotesplusfile = '../cgi-lib/vocab-notes-plus';
my $dieliplus_sc_dict = '../cgi-lib/dieliplus-sc-dict'; 
my $dieliplus_en_dict = '../cgi-lib/dieliplus-en-dict'; 
my $dieliplus_it_dict = '../cgi-lib/dieliplus-it-dict'; 

##  error log file
my $erfile = "./errors_traina-into-chiu.txt";

##  retrieve verb hash
my $vnhash = retrieve( $vnotesfile );
my %vnotes = %{ $vnhash } ;

##  retrieve SiCilian
my %dieli_sc = %{ retrieve( $dieli_sc_dict ) };

##  retrieve Traina headword to line id
my %hl_hash = %{ retrieve( $traina_hlfile ) };

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  open error log file
open( my $fh_error , ">$erfile" ) || die "could not overwrite $erfile";

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  add Traina to Chiu
foreach my $palora (sort keys %vnotes) {

    ##  strip part of speech identifier
    my $strip = $palora;
    $strip =~ s/_[a-z]*$//;

    ##  what is the display?
    my $display = ( ! defined $vnotes{$palora}{display_as} ) ? $strip : $vnotes{$palora}{display_as} ; 

    ##  upcase the display name
    my $uc_disp = scn_ucfirst( $display );
 
    ##  try to obtain line ids
    if ( ! defined $hl_hash{$uc_disp} ) {
	print $fh_error "chiu key: ". $palora ." -- no Traina lines"."\n";

    } else {
	##  retrieve the line ids and add them to vnotes
	my @lineidxs = @{$hl_hash{$uc_disp}} ;
	@{$vnotes{$palora}{traina}} = @lineidxs ;
    }
}
    
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  add Traina to existing Dieli
foreach my $dieli (sort keys %dieli_sc) {
    foreach my $index (0..$#{ $dieli_sc{$dieli}}) {

	##  only replace the linkto if not already defined
	if ( ! defined ${$dieli_sc{$dieli}[$index]}{"linkto"} ) {

	    ##  upcase the Dieli entry
	    my $uc_dieli = scn_ucfirst( $dieli );

	    ##  try to obtain line ids
	    if ( ! defined $hl_hash{$uc_dieli} ) {
		print $fh_error "Dieli entry: ". $dieli ." -- no Traina lines"."\n";
		
	    } else {
		##  retrieve the line ids
		my @lineidxs = @{$hl_hash{$uc_dieli}} ;
		
		##  new key name
		##  "tdonly" = "Traina dictionary only"
		my $newkey = $dieli ."_tdonly";
		
		##  add to vnotes and to Dieli
		@{$vnotes{$newkey}{traina}} = @lineidxs ;
		${$dieli_sc{$dieli}[$index]}{"linkto"} = $newkey ;
	    }
	}
    }
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  close error log file
close $fh_error;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  add Traina to existing Dieli
foreach my $hword (sort keys %hl_hash) {
    
    ##  headword to store
    ##  my $lc_hword = rm_diaeresis($hword);
    my $lc_hword = scn_lowercase_trim($hword);
    $lc_hword =~ s/^\s+//;
    $lc_hword =~ s/\s+$//;
    $lc_hword =~ s/'/_SQUOTE_/g;
    $lc_hword =~ s/^_SQUOTE_//;

    ##  already trimmed, trim it again (??)
    $lc_hword =~ s/ \(.*$//;
    
    ##  new key name
    ##  "tdonly" = "Traina dictionary only"
    my $newkey = $lc_hword ."_tdonly";

    ##  only add if word does not already exist in Dieli list
    if ( ! defined $dieli_sc{$lc_hword} ) {
	
	##  retrieve the line ids
	my @lineidxs = @{$hl_hash{$hword}};

	##  add (lower case) word to Dieli dictionary
    	my %th ;  
	$th{"sc_word"} = $lc_hword ; $th{"sc_part"} = "{}";
	$th{"it_word"} = "<br>"    ; $th{"it_part"} = "{}";
	$th{"en_word"} = "<br>"    ; $th{"en_part"} = "{}";
	$th{"linkto"}  = $newkey;
	push( @{ $dieli_sc{$lc_hword} } , \%th );
	
	##  add to vnotes
	@{$vnotes{$newkey}{traina}} = @lineidxs ;
    }
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  make ENglish and ITalian dictionaries
my %dieli_en = make_en_dict( \%dieli_sc ) ;
my %dieli_it = make_it_dict( \%dieli_sc ) ;

##  ##  ##  ##

##  store the verb notes
nstore( \%vnotes , $vnotesplusfile ) ; 

##  store the dictionaries
nstore( \%dieli_sc , $dieliplus_sc_dict );
nstore( \%dieli_en , $dieliplus_en_dict );
nstore( \%dieli_it , $dieliplus_it_dict );

# ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #

##  SUBROUTINES
##  ===========

# sub replace_part {
#     my $hashref = $_[0] ; 
#     my $part    = $_[1] ; 
#    
#     foreach my $lang_part ("sc_part","it_part","en_part") {
# 	${$hashref}{$lang_part} = "{" . $part . "}" ; 
#     }
#     return $hashref ;
# }

##  remove diaresis from vowels
sub rm_diaeresis {
    my $char = $_[0] ;
    $char =~ s/\303\244/a/g;
    $char =~ s/\303\253/e/g;
    $char =~ s/\303\257/i/g;
    $char =~ s/\303\266/o/g;
    $char =~ s/\303\274/u/g;
    $char =~ s/\303\204/A/g;
    $char =~ s/\303\213/E/g;
    $char =~ s/\303\217/I/g;
    $char =~ s/\303\226/O/g;
    $char =~ s/\303\234/U/g;
    return $char ;
}

sub make_en_dict {

    my %dieli_sc = %{ $_[0] } ;
    my %dieli_en ; 
    foreach my $sc_word ( sort keys %dieli_sc ) {	
	for my $i (0..$#{ $dieli_sc{$sc_word} }) {
	    my %sc_hash = %{ ${ $dieli_sc{$sc_word}}[$i] } ; 
	    if ($sc_hash{"en_word"} ne '<br>') {
		push( @{ $dieli_en{$sc_hash{"en_word"}} } , \%sc_hash ) ; 
	    }
	}
    }
    return %dieli_en ;
}

sub make_it_dict {
    
    my %dieli_sc = %{ $_[0] } ;
    my %dieli_it ; 
    foreach my $sc_word ( sort keys %dieli_sc ) {	
	for my $i (0..$#{ $dieli_sc{$sc_word} }) {
	    my %sc_hash = %{ ${ $dieli_sc{$sc_word}}[$i] } ; 
	    if ($sc_hash{"it_word"} ne '<br>') {
		push( @{ $dieli_it{$sc_hash{"it_word"}} } , \%sc_hash ) ; 
	    }
	}
    }
    return %dieli_it ;
}
