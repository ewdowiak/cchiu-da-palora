package Napizia::HtmlDieli;

##  Copyright 2026 Eryk Wdowiak
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

use strict;
use warnings;
no warnings qw(uninitialized numeric void);

use utf8;

sub uniq { Napizia::Utils::uniq( @_ );}
sub scn_lowercase { Napizia::TextTools::scn_lowercase( $_[0] );}
sub scn_lowercase_trim { Napizia::TextTools::scn_lowercase_trim( $_[0] );}
sub rid_accents { Napizia::TextTools::rid_accents( $_[0] );}

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ("mk_search","translate","mk_ddtopinfo","mk_newform");

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  SUBROUTINES  for  DIELI DICTIONARY
##  ===========  ===  ===== ==========

sub mk_search {
    
    my $rlang    =   $_[0] ; 
    my @searches = @{$_[1]};
    my $dlirf    =   $_[2] ; 
    my $lgparm   =   $_[3] ; 
    my $pclass   =   $_[4] ; 
    my $benice   = ( ! defined $_[5] || $_[5] ne "BeNice" ) ? "BeMean" : "BeNice";
    
    my $othtml ;

    foreach my $rsrch (@searches) {

	my @translation = translate( $rlang , $rsrch , $dlirf ) ;
	my @inword = @{$translation[0]};
	my @inpart = @{$translation[1]};
	my @otword = @{$translation[2]};
	my @otpart = @{$translation[3]};
	my @linkto = @{$translation[4]};
	
	$rsrch =~ s/_SQUOTE_/'/g;
	
	
	if ($#inpart == -1 && $rsrch ne "") { 
	    if ( $benice eq "BeMean" ) {
		$othtml .= "<p>nun c'è na traduzzioni dâ palora: ".'&nbsp; <b>'. $rsrch .'</b></p>';
	    } else {
		$othtml .= '<p' . $pclass .'><b>'. $rsrch .'</b> {} &nbsp; &rarr; &nbsp; {}</p>';
	    }
	    
	} else {	    
	    my @otplines ;
	    if ( $rlang =~ /SCEN|SCIT/ ) {
		##  Sicilian is "IN" language
		foreach my $i (0..$#inpart) {
		    my $linkifany ;
		    if ( $linkto[$i] ne "" ) {
			$linkifany .= '<a href="/chiu/?';
			$linkifany .= 'palora='. $linkto[$i] .'&langs='. $lgparm .'">';
			$linkifany .= $inword[$i] .'</a>';
		    } else {
			$linkifany .= $inword[$i] ;
		    }
		    ##  create the output
		    my $otpline ;
		    $otpline .= '<p' . $pclass .'><b>'. $linkifany .'</b> '. $inpart[$i] .' &nbsp; &rarr; &nbsp; ';
		    $otpline .= '<b>'. $otword[$i] .'</b> '. $otpart[$i] .'</p>'."\n";
		    push( @otplines , $otpline ) ;
		}
	    } else {
		##  Sicilian is "OUT" language
		foreach my $i (0..$#otpart) {
		    ##  need to reverse the language for lookup
		    my $newlgparm = ( $lgparm eq "ITSC" ) ? "SCIT" : "SCEN" ;
		    my $linkifany ;
		    if ( $linkto[$i] ne "" ) {
			$linkifany .= '<a href="/chiu/?'; 
			$linkifany .= 'palora='. $linkto[$i] .'&langs='. $newlgparm .'">'; 
			$linkifany .= $otword[$i] .'</a>';
		    } else {
			$linkifany .= $otword[$i] ;
		    }
		    ##  create the output
		    my $otpline ;
		    $otpline .= '<p'. $pclass .'><b>'. $inword[$i] .'</b> '. $inpart[$i] .' &nbsp; &rarr; &nbsp; ';
		    $otpline .= '<b>'. $linkifany .'</b> '. $otpart[$i] .'</p>'."\n";
		    push( @otplines , $otpline ) ;
		}
	    }
	    
	    foreach my $otpline (sort( uniq( @otplines ))) {
		$othtml .= $otpline ; 
	    }
	}
    }

    ##  return HTML text for all of those searches
    return $othtml ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub translate {

    my $rlang =    $_[0]   ; 
    my $rsrch =    $_[1]   ; 
    my %dict  = %{ $_[2] } ;

    ##  assume SCEN
    $rlang = ( ! defined $rlang || ( $rlang ne "SCEN" && $rlang ne "SCIT" &&
				     $rlang ne "ENSC" && $rlang ne "ITSC") ) ? "SCEN" : $rlang;
    
    ##  prepare arrays of output
    my @inpart ;
    my @inword ;
    my @otpart ;
    my @otword ;
    my @linkto ;

    ##  clean the search
    my $lc_sch = $rsrch ;
    $lc_sch =~ s/^\s+//;
    $lc_sch =~ s/\s+$//;
    $lc_sch =  rid_accents( scn_lowercase( $lc_sch ));
    $lc_sch =~ s/^'//;
    $lc_sch =~ s/^_SQUOTE_//;

    ##  get matches
    my @matches;
    foreach my $key (sort keys %dict) {
	my $lc_key = $key;
	
	##  clean the key
	$lc_key = rid_accents( scn_lowercase( $lc_key ));

	## ## if LC_KEY loosely matches ...
	## if (grep {/^$lc_sch$/} $lc_key || grep {/^$lc_key$/} $lc_sch) {)

	## if LC_KEY exactly matches, then push KEY
	if ( $lc_sch eq $lc_key ) {
	    push( @matches , $key );
	}
    }
    @matches = uniq( @matches );

    
    ##  now append to output arrays
    foreach my $match (@matches) {
    
	##  how many entries are there?
	my $nu_entry = $#{ $dict{$match} };
	
	if ( $rlang =~ /SCEN/ ) {
	    for my $i (0..$nu_entry) {
		# if ( ${${$dict{$match}}[$i] }{"en_word"} ne '<br>' ) {}
		push( @inword , ${${ $dict{$match}}[$i] }{"sc_word"} );
		push( @inpart , ${${ $dict{$match}}[$i] }{"sc_part"} );
		push( @otpart , ${${ $dict{$match}}[$i] }{"en_part"} );
		push( @otword , ${${ $dict{$match}}[$i] }{"en_word"} );
		my $link = (! defined ${${$dict{$match}}[$i]}{"linkto"}) ? "" : ${${$dict{$match}}[$i]}{"linkto"};
		push( @linkto , $link );
	    }
	} elsif ( $rlang =~ /SCIT/ ) {  
	    for my $i (0..$nu_entry) {
		# if ( ${${$dict{$match}}[$i]}{"it_word"} ne '<br>' ) {}
		push( @inword , ${${$dict{$match}}[$i]}{"sc_word"} );
		push( @inpart , ${${$dict{$match}}[$i]}{"sc_part"} );
		push( @otpart , ${${$dict{$match}}[$i]}{"it_part"} );
		push( @otword , ${${$dict{$match}}[$i]}{"it_word"} );
		my $link = (! defined ${${$dict{$match}}[$i]}{"linkto"}) ? "" : ${${$dict{$match}}[$i]}{"linkto"};
		push( @linkto , $link );
	    }
	} elsif ( $rlang =~ /ENSC/ ) {  
	    for my $i (0..$nu_entry) {
		# if ( ${${$dict{$match}}[$i]}{"sc_word"} ne '<br>' ) {}
		push( @inword , ${${$dict{$match}}[$i]}{"en_word"} );
		push( @inpart , ${${$dict{$match}}[$i]}{"en_part"} );
		push( @otpart , ${${$dict{$match}}[$i]}{"sc_part"} );
		push( @otword , ${${$dict{$match}}[$i]}{"sc_word"} );
		my $link = (! defined ${${$dict{$match}}[$i]}{"linkto"}) ? "" : ${${$dict{$match}}[$i]}{"linkto"};
		push( @linkto , $link );
	    }
	} elsif ( $rlang =~ /ITSC/ ) {  
	    for my $i (0..$nu_entry) {
		# if ( ${${$dict{$match}}[$i]}{"sc_word"} ne '<br>' ) {}
		push( @inword , ${${$dict{$match}}[$i]}{"it_word"} );
		push( @inpart , ${${$dict{$match}}[$i]}{"it_part"} );
		push( @otpart , ${${$dict{$match}}[$i]}{"sc_part"} );
		push( @otword , ${${$dict{$match}}[$i]}{"sc_word"} );
		my $link = (! defined ${${$dict{$match}}[$i]}{"linkto"}) ? "" : ${${$dict{$match}}[$i]}{"linkto"};
		push( @linkto , $link );
	    }
	}
    }

    ##  clean it all up
    s/_SQUOTE_/'/g for @inpart ; 
    s/_SQUOTE_/'/g for @inword ;
    s/<br>//g for @inword ;
    s/_SQUOTE_/'/g for @otpart ; 
    s/_SQUOTE_/'/g for @otword ;
    s/<br>//g for @otword ;
    ## s/_SQUOTE_/'/g for @linkto ;
    
    ##  return the results
    return( \@inword , \@inpart , \@otword , \@otpart , \@linkto ); 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub mk_ddtopinfo {

    ##  the word searched for and the language parameter
    my $search = $_[0];
    my $lgtext = $_[1];

    ##  if not defined
    $search = ( ! defined $search ) ? "" : $search ;
    $lgtext = ( ! defined $lgtext ) ? "" : $lgtext ;

    ##  hold the word searched for and the language parameter
    my $param_search = $search;
    my $param_lgtext = ( $lgtext =~ /^ENSC$|^ITSC$|^SCEN$|^SCIT$/) ? "" : $lgtext ;
    
    ##  clean up the text
    $lgtext =~ s/ENSC/En-Sc/;
    $lgtext =~ s/ITSC/It-Sc/;
    $lgtext =~ s/SCEN/Sc-En/;
    $lgtext =~ s/SCIT/Sc-It/;
    
    ##  the word searched for -- only if single-item
    $search =~ s/_SQUOTE_/'/g;
    $search =~ s/_OR_.*$//;

    $search =~ s/COLL_aviri/ricota - aviri/; 
    $search =~ s/COLL_have/ricota - to have/;
    $search =~ s/COLL_essiri/ricota - essiri/;
    $search =~ s/COLL_fari/ricota - fari/;
    $search =~ s/COLL_places/ricota - munnu/;
    $search =~ s/COLL_italy/ricota - Italia/;
    $search =~ s/COLL_timerel/ricota - tempu/;
    $search =~ s/COLL_daysweek/ricota - jorna/;
    $search =~ s/COLL_months/ricota - misi/;
    $search =~ s/COLL_holidays/ricota - festi/;
    $search =~ s/COLL_seasons/ricota - staggiuni/;
    $search =~ s/COLL_/ricota - /;
	    
    ##  text to insert into the title
    my $title_insert = ( $search eq "" ) ? "" : $search .' ('. $lgtext .') :: ';

    ##  and here's the TITLE
    my $title_concat = $title_insert . 'Dizziunariu Dieli :: Napizia';

    ##  form the URL
    my $urlref = 'https://dizziunariu.napizia.com/dieli/';
    if ( $param_search eq "" ) {
	my $blah = 'do nothing';
    } else {
	$urlref .= '?search='. $param_search ;
	$urlref .= ($param_lgtext eq "") ? "" : "&langs=". $param_lgtext ;	
    }

    ##  prepare hash to return
    my %otinfo = (
	"card_title" => $title_concat ,
	"card_url" => $urlref
	);
    
    ##  and return it
    return %otinfo ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub mk_newform {

    ##  language parameter
    my $lgparm = $_[0] ;

    ##  the word searched for, and only if single-item
    my $insearch = $_[1];
    my $search = ( $insearch =~ /^COLL_|_OR_/ ) ? "" : $insearch;

    ##  place that word in the correct search box
    my $sc_search = ($lgparm =~ /SCIT|SCEN/) ? $search : "" ;
    my $ie_search = ($lgparm =~ /ITSC|ENSC/) ? $search : "" ;
    
    my $ottxt ;
    # $ottxt .= '<form enctype="multipart/form-data" action="/dieli/" method="post">'."\n";
    $ottxt .= '<form enctype="multipart/form-data" action="/dieli/" method="get">'."\n";
    $ottxt .= '<table style="max-width:500px;"><tbody>'."\n";
    $ottxt .= '<tr><td colspan="2">' ; 
    $ottxt .= '<input type=text name="search" value="'. $sc_search .'" size=36 maxlength=72>' ; 
    $ottxt .= '</td></tr>'."\n";
    $ottxt .= '<tr><td>'."\n"; 

    $ottxt .= '<select name="langs">'."\n";
    if ( $lgparm =~ /SCEN|ENSC/ ) {
	$ottxt .= '<option value="SCEN">Sicilianu-Nglisi' ."\n";
	$ottxt .= '<option value="SCIT">Sicilianu-Talianu'."\n";
    } else {
	$ottxt .= '<option value="SCIT">Sicilianu-Talianu'."\n";
	$ottxt .= '<option value="SCEN">Sicilianu-Nglisi' ."\n";
    }
    
    $ottxt .= '</select>'."\n";
    $ottxt .= '</td>'."\n";
    $ottxt .= '<td align="right">' . '<input type="submit" value="Traduci">'."\n";
    ## $ottxt .= '<input type=reset value="Clear Form">'."\n"; 
    $ottxt .= '</td></tr>'."\n";
    $ottxt .= '</tbody></table>'."\n";
    $ottxt .= '</form>'."\n";

    ## $ottxt .= '<form enctype="multipart/form-data" action="/dieli/" method="post">'."\n";
    $ottxt .= '<form enctype="multipart/form-data" action="/dieli/" method="get">'."\n";
    $ottxt .= '<table style="max-width:500px;"><tbody>'."\n";
    $ottxt .= '<tr><td colspan="2">' ;
    $ottxt .= '<input type=text name="search" value="'. $ie_search .'" size=36 maxlength=72>' ; 
    $ottxt .= '</td></tr>'."\n";
    $ottxt .= '<tr><td>'."\n"; 

    $ottxt .= '<select name="langs">'."\n";
    if ( $lgparm =~ /SCEN|ENSC/ ) {
	$ottxt .= '<option value="ENSC">Nglisi-Sicilianu' ."\n";
	$ottxt .= '<option value="ITSC">Talianu-Sicilianu'."\n";
    } else {
	$ottxt .= '<option value="ITSC">Talianu-Sicilianu'."\n";
	$ottxt .= '<option value="ENSC">Nglisi-Sicilianu' ."\n";
    }
    
    $ottxt .= '</select>'."\n";
    $ottxt .= '</td>'."\n";
    $ottxt .= '<td align="right">' . '<input type="submit" value="Traduci">'."\n";
    ## $ottxt .= '<input type=reset value="Clear Form">'."\n"; 
    $ottxt .= '</td></tr>'."\n";
    $ottxt .= '</tbody></table>'."\n";
    $ottxt .= '</form>'."\n";
        
    return $ottxt ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
# ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

1;
