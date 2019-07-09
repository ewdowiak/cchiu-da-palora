#!/usr/bin/env perl

##  "cchiu-da-palora.pl" -- annotates the Dieli dictionary
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

use strict;
#use warnings;
use CGI qw(:standard);
use Storable qw( retrieve ) ;
#{   no warnings;             
#    ## $Storable::Deparse = 1;  
    $Storable::Eval    = 1;  
#}

##  scalars to adjust length of columns (for appearances)
my $adjustone =     0 ;
my $adjusttwo =    -8 ;
my $adjusttre =   -20 ;

##  retrieve hashes and subroutines
my $vthash  = retrieve('../cgi-lib/verb-tools' );
my $vbconj  = $vthash->{vbconj} ;
my $vbsubs  = $vthash->{vbsubs} ;
my $nounpls = $vthash->{nounpls} ;

my $vnhash = retrieve('../cgi-lib/vocab-notes' );
my %vnotes = %{ $vnhash } ;

my $cchash = retrieve('../cgi-lib/cchiu-tools' );
my %ccsubs = %{ $cchash->{ccsubs} } ;
my %ddsubs = %{ $cchash->{ddsubs} } ;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  what are we looking for?
my $inword = param('palora');
if ( ! defined $inword ) {
    my $blah = "leave it undefined";
} elsif ( ! defined $vnotes{ $inword } ) {
    ## try to fix it
    $inword = fixurl($inword);
}

##  set the language pair
my $lgparm = ( ! defined param('langs') ) ? "SCEN" : param('langs') ;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  make webpage; if input word not defined, cannot conjugate/decline, so show all
if ( ! defined $inword || ! defined $vnotes{ $inword } ) {
    ## make top
    print $ccsubs{mk_cctophtml}("../config/topnav.html" , "" , \%vnotes , $vbconj , $vbsubs );
    print $ddsubs{mk_newform}( $lgparm );

    ## show all
    print $ccsubs{mk_showall}(  \%vnotes , $vbconj , $vbsubs , \%ccsubs , $adjustone , $adjusttwo , $adjusttre ) ;

} else { 
    ## make top
    print $ccsubs{mk_cctophtml}("../config/topnav.html" , $inword , \%vnotes , $vbconj , $vbsubs );
    print $ddsubs{mk_newform}( $lgparm );
    
    ##  print translations and notes
    print $ccsubs{mk_dielitrans}( $inword , $lgparm , \%vnotes , $vbconj , $vbsubs ) ;
    print $ccsubs{mk_notex}( $inword , \%vnotes , \%ccsubs ) ;

    ##  are we working with a verb, noun or adjective?
    my $isverb = ( ! defined $vnotes{ $inword }{verb}     && 
		   ! defined $vnotes{ $inword }{reflex}   && 
		   ! defined $vnotes{ $inword }{prepend}            ) ? "false" : "true" ;
    my $isnoun = ( ! defined $vnotes{ $inword }{noun}               ) ? "false" : "true" ;
    my $isadj  = ( $vnotes{ $inword }{part_speech} ne "adj" ) ? "false" : "true" ;

    ##  "other" parts of speech currently include:  {adv} {prep} {pron}
    my $isother  = ( ! defined $vnotes{ $inword }{part_speech} ) ? "false" : "true" ;
    
    if ( $isverb eq "true" ) {
	print $ccsubs{mk_conjhtml}( $inword , $lgparm , \%vnotes , $vbconj , $vbsubs ) ;
	print $ccsubs{ask_help}( $inword , \%vnotes );
	
    } elsif ( $isnoun eq "true" ) {
	print $ccsubs{mk_nounhtml}( $inword , $lgparm , \%vnotes , $nounpls , $vbsubs ) ;
	print $ccsubs{ask_help}( $inword , \%vnotes );
	
    } elsif ( $isadj  eq "true" ) {
	print $ccsubs{mk_adjhtml}( $inword , $lgparm , \%vnotes , $vbsubs ) ;
	print $ccsubs{ask_help}( $inword , \%vnotes );

    } elsif ( $isother  eq "true" ) {
	##  other, so only ask for help 
	print $ccsubs{ask_help}( $inword , \%vnotes );
	
    } else {
	##  outer DIV to limit width
	my $othtml ; 
	$othtml .= '<div class="transconj">' . "\n" ; 
	$othtml .= '<div class="row">' . "\n" ; 
	$othtml .= '<p>'."nun c'è n'".' annotazzioni dâ palora: &nbsp; <b>'. $inword .'</b></p>'."\n";
	$othtml .= '</div>'."\n"; 
	$othtml .= '</div>'."\n"; 
	print $othtml ; 
	print $ccsubs{mk_showall}(  \%vnotes , $vbconj , $vbsubs , $adjustone , $adjusttwo , $adjusttre ) ;
    }
}
print $ddsubs{mk_ricota}();
print $ddsubs{mk_foothtml}("../config/navbar-footer.html");

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  SUBROUTINES
##  ===========

##  fix URL encodings
sub fixurl {

    my $encode = $_[0];
    $encode =~ s/%25([89ABC][023489ABCE])/%$1/gi;

    my $decode = $encode ;
    
    $decode =~ s/%C3%80/À/gi;
    $decode =~ s/%C3%88/È/gi;
    $decode =~ s/%C3%8C/Ì/gi;
    $decode =~ s/%C3%92/Ò/gi;
    $decode =~ s/%C3%99/Ù/gi;

    $decode =~ s/%C3%A0/à/gi;
    $decode =~ s/%C3%A8/è/gi;
    $decode =~ s/%C3%AC/ì/gi;
    $decode =~ s/%C3%B2/ò/gi;
    $decode =~ s/%C3%B9/ù/gi;

    $decode =~ s/%C3%82/Â/gi;
    $decode =~ s/%C3%8A/Ê/gi;
    $decode =~ s/%C3%8E/Î/gi;
    $decode =~ s/%C3%94/Ô/gi;
    $decode =~ s/%C3%9B/Û/gi;
    
    $decode =~ s/%C3%A2/â/gi;
    $decode =~ s/%C3%AA/ê/gi;
    $decode =~ s/%C3%AE/î/gi;
    $decode =~ s/%C3%B4/ô/gi;
    $decode =~ s/%C3%BB/û/gi;
    
    return $decode; 
}

##  À à  Â â   ##  %C3%80  %C3%A0  %C3%82  %C3%A2
##  È è  Ê ê   ##  %C3%88  %C3%A8  %C3%8A  %C3%AA
##  Ì ì  Î î   ##  %C3%8C  %C3%AC  %C3%8E  %C3%AE
##  Ò ò  Ô ô   ##  %C3%92  %C3%B2  %C3%94  %C3%B4
##  Ù ù  Û û   ##  %C3%99  %C3%B9  %C3%9B  %C3%BB

