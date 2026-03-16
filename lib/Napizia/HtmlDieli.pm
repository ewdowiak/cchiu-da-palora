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

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

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
our @EXPORT = ("mk_search","translate","mk_ddtophtml",## "mk_ddtopnav",
	       "mk_newform","thank_dieli","mk_ricota","mk_foothtml");

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

sub mk_ddtophtml {

    ##  top navigation panel
    my $topnav = $_[0] ;

    ##  language parameter
    my $lgtext = $_[1] ;
    $lgtext = ( ! defined $lgtext ) ? "" : $lgtext ;

    ##  hold that parameter
    my $param_lgtext = ( $lgtext =~ /^ENSC$|^ITSC$|^SCEN$|^SCIT$/) ? "" : $lgtext ;
    
    ##  clean up the text
    $lgtext =~ s/ENSC/En-Sc/;
    $lgtext =~ s/ITSC/It-Sc/;
    $lgtext =~ s/SCEN/Sc-En/;
    $lgtext =~ s/SCIT/Sc-It/;

    ##  the word searched for
    my $search = $_[2];
    $search = ( ! defined $search ) ? "" : $search ;

    ##  hold that search
    my $param_search = $search;
    
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

    my $ottxt ;
    ## $ottxt .= "Content-type: text/html\n\n";
    $ottxt .= '<!DOCTYPE html>' . "\n" ;
    $ottxt .= '<html>' . "\n" ;
    $ottxt .= '  <head>' . "\n" ;

    my $title_concat = $title_insert . 'Dizziunariu Dieli :: Napizia';
    $ottxt .= '    <title>'. $title_concat .'</title>'."\n";
    $ottxt .= '    <meta property="og:title" content="'. $title_concat .'">'."\n";
    $ottxt .= '    <meta name="twitter:title" content="'. $title_concat .'">'."\n";

    my $descrip = 'Sicilian-Italian-English Dictionary by Arthur Dieli';
    $ottxt .= '    <meta name="DESCRIPTION" content="'. $descrip .'">'."\n";
    $ottxt .= '    <meta property="og:description" content="'. $descrip .'">'."\n";
    $ottxt .= '    <meta name="twitter:description" content="'. $descrip .'">'."\n";

    $ottxt .= '    <meta name="KEYWORDS" content="Sicilian, language, dictionary, Dieli, Arthur Dieli">' . "\n" ;

    if ( $param_search eq "" ) {
	my $urlref = 'https://dizziunariu.napizia.com/dieli/';
	$ottxt .= '    <meta property="og:url" content="'. $urlref .'">'."\n";
	$ottxt .= '    <meta name="twitter:url" content="'. $urlref .'">'."\n";

    } else {
	my $urlref = 'https://dizziunariu.napizia.com/dieli/';
	$urlref .= '?search='. $param_search ;
	$urlref .= ($param_lgtext eq "") ? "" : "&langs=". $param_lgtext ;
	
	$ottxt .= '    <meta property="og:url" content="'. $urlref .'">'."\n";
	$ottxt .= '    <meta name="twitter:url" content="'. $urlref .'">'."\n";
    }

    ## my $logopic = 'https://dizziunariu.napizia.com/config/napizia_logo-w-descrip.jpg';
    my $logopic = 'https://dizziunariu.napizia.com/pics/dizziunariu-dieli.jpg';
    $ottxt .= '    <meta property="og:image" content="'. $logopic .'">'."\n";
    $ottxt .= '    <meta name="twitter:image" content="'. $logopic .'">'."\n";
    $ottxt .= '    <meta property="og:type" content="website">'."\n";
    $ottxt .= '    <meta name="twitter:site" content="@ProjectNapizia">'."\n";
    $ottxt .= '    <meta name="twitter:card" content="summary_large_image">'."\n";
    
    $ottxt .= '    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">' . "\n" ;
    $ottxt .= '    <meta name="Author" content="Eryk Wdowiak">' . "\n" ;
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/eryk.css">' . "\n" ;
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/eryk_theme-blue.css">' . "\n" ;
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/eryk_widenme.css">' . "\n" ;
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/dieli_forms.css">' . "\n" ;

    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/font-awesome.min.css">'."\n";
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/w3-fa-styles.css">'."\n";
    
    $ottxt .= '    <link rel="icon" type="image/png" href="/config/napizia-icon.png">' . "\n" ;
    $ottxt .= "\n";
    $ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    $ottxt .= '          title="SC-EN Dieli Dict"'."\n";
    $ottxt .= '          href="https://dizziunariu.napizia.com/search/dieli_sc-en.xml">'."\n";
    $ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    $ottxt .= '          title="SC-IT Dieli Dict"'."\n";
    $ottxt .= '          href="https://dizziunariu.napizia.com/search/dieli_sc-it.xml">'."\n";
    $ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    $ottxt .= '          title="EN-SC Dieli Dict"'."\n";
    $ottxt .= '          href="https://dizziunariu.napizia.com/search/dieli_en-sc.xml">'."\n";
    $ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    $ottxt .= '          title="IT-SC Dieli Dict"'."\n";
    $ottxt .= '          href="https://dizziunariu.napizia.com/search/dieli_it-sc.xml">'."\n";
    $ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    $ottxt .= '          title="Trova na Palora"'."\n";
    $ottxt .= '          href="https://dizziunariu.napizia.com/search/trova-palora.xml">'."\n";
    #$ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    #$ottxt .= '          title="Cosine Sim Skipgram"'."\n";
    #$ottxt .= '          href="https://dizziunariu.napizia.com/search/cosine-sim_skip.xml">'."\n";
    #$ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    #$ottxt .= '          title="Cosine Sim CBOW"'."\n";
    #$ottxt .= '          href="https://dizziunariu.napizia.com/search/cosine-sim_cbow.xml">'."\n";
    $ottxt .= "\n";
    $ottxt .= '    <meta name="viewport" content="width=device-width, initial-scale=1">' . "\n" ;
    $ottxt .= '    <style>' . "\n" ;
    $ottxt .= '    p.zero { margin-top: 0em; margin-bottom: 0em; }' . "\n" ;
    $ottxt .= '    div.cunzigghiu { position: relative; margin: auto; width: 50%;}' . "\n" ;
    $ottxt .= '    @media only screen and (max-width: 835px) { ' . "\n" ;
    $ottxt .= '        div.cunzigghiu { position: relative; margin: auto; width: 90%;}' . "\n" ;
    $ottxt .= '    }' . "\n" ;

    ## ##  spacing for second column of Dieli collections
    ## ##  now handled by "eryk_widenme.css"
    ## $ottxt .= '    ul.ddcoltwo { margin-top: 0em; }' . "\n" ;
    ## $ottxt .= '    @media only screen and (min-width: 600px) { ' . "\n" ;
    ## $ottxt .= '        ul.ddcoltwo { margin-top: 2.25em; }' . "\n" ;
    ## $ottxt .= '    }' . "\n" ;
    
    $ottxt .= '    </style>' . "\n" ;
    $ottxt .= '  </head>' . "\n" ;

    ##     return $ottxt ;
    ## }
    ## sub mk_ddtopnav {
    ##     ##  top navigation panel
    ##     my $topnav = $_[0] ;
    ##     my $ottxt ;

    $ottxt .= '  <body>'."\n";

    open( my $fh_topnav , "<:encoding(utf-8)" , $topnav ); ## || die "could not read:  $topnav";
    while(<$fh_topnav>){ chomp;  $ottxt .= $_ . "\n" ; };
    close $fh_topnav ;
    
    $ottxt .= '  <!-- begin row div -->' . "\n" ;
    $ottxt .= '  <div class="row">' . "\n" ;
    $ottxt .= '    <div class="col-m-12 col-12">' . "\n" ;
    ## $ottxt .= '      <h1>Dizziunariu Sicilianu</h1> <h2>di Arthur Dieli</h2>' . "\n" ;
    $ottxt .= '      <h1>Dizziunariu Dieli</h1>'."\n";
    $ottxt .= '    </div>' . "\n" ;
    $ottxt .= '  </div>' . "\n" ;
    $ottxt .= '  <!-- end row div -->' . "\n" ;
    $ottxt .= '  ' . "\n" ;
    $ottxt .= '  <!-- begin row div -->' . "\n" ;
    $ottxt .= '  <div class="row">' . "\n" ;
    
    return $ottxt ;
}

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
    $ottxt .= '<table style="max-width:500px;"><tbody>' . "\n" ;
    $ottxt .= '<tr><td colspan="2">' ; 
    $ottxt .= '<input type=text name="search" value="'. $sc_search .'" size=36 maxlength=72>' ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '<tr><td>' . "\n" ; 

    $ottxt .= '<select name="langs">' . "\n" ;
    if ( $lgparm =~ /SCEN|ENSC/ ) {
	$ottxt .= '<option value="SCEN">Sicilianu-Nglisi'  . "\n" ;
	$ottxt .= '<option value="SCIT">Sicilianu-Talianu' . "\n" ;
    } else {
	$ottxt .= '<option value="SCIT">Sicilianu-Talianu' . "\n" ;
	$ottxt .= '<option value="SCEN">Sicilianu-Nglisi'  . "\n" ;
    }
    
    $ottxt .= '</select>' . "\n" ;
    $ottxt .= '</td>' . "\n" ;
    $ottxt .= '<td align="right">' . '<input type="submit" value="Traduci">' . "\n" ;
    ## $ottxt .= '<input type=reset value="Clear Form">' . "\n" ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '</tbody></table>' . "\n" ;
    $ottxt .= '</form>' . "\n" ;

    ## $ottxt .= '<form enctype="multipart/form-data" action="/dieli/" method="post">'."\n";
    $ottxt .= '<form enctype="multipart/form-data" action="/dieli/" method="get">'."\n";
    $ottxt .= '<table style="max-width:500px;"><tbody>' . "\n" ;
    $ottxt .= '<tr><td colspan="2">' ;
    $ottxt .= '<input type=text name="search" value="'. $ie_search .'" size=36 maxlength=72>' ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '<tr><td>' . "\n" ; 

    $ottxt .= '<select name="langs">' . "\n" ;
    if ( $lgparm =~ /SCEN|ENSC/ ) {
	$ottxt .= '<option value="ENSC">Nglisi-Sicilianu'  . "\n" ;
	$ottxt .= '<option value="ITSC">Talianu-Sicilianu' . "\n" ;
    } else {
	$ottxt .= '<option value="ITSC">Talianu-Sicilianu' . "\n" ;
	$ottxt .= '<option value="ENSC">Nglisi-Sicilianu'  . "\n" ;
    }
    
    $ottxt .= '</select>' . "\n" ;
    $ottxt .= '</td>' . "\n" ;
    $ottxt .= '<td align="right">' . '<input type="submit" value="Traduci">' . "\n" ;
    ## $ottxt .= '<input type=reset value="Clear Form">' . "\n" ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '</tbody></table>' . "\n" ;
    $ottxt .= '</form>' . "\n" ;
        
    return $ottxt ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub thank_dieli {
    my $ot ;
    $ot .= '<p style="margin-top: 1.5em; margin-bottom: 0.50em; text-align: center;">Grazzii a ';
    $ot .= '<b><a href="http://www.dieli.net/" target="_blank">' ;
    $ot .= 'Arthur Dieli</a></b> pi cumpilari stu dizziunariu.</p>' . "\n" ; 
    return $ot ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  make "word harvest"
sub mk_ricota {

    ##  prepare output
    my $othtml ;

    ##  open project DIV
    $othtml .= '<div class="row" style="margin: 2px 0px; border: 1px solid black; background-color: rgb(255,255,204);">'."\n";
    
    ## $othtml .= '  <div class="minicol"></div>'."\n";
    ## $othtml .= '  <div class="minicol"></div>'."\n";
    ## $othtml .= '  <div class="minicol"></div>'."\n";
    $othtml .= '  <div class="minicol"></div>'."\n";
    $othtml .= '  <div class="col-t-2"></div>'."\n";
    $othtml .= '  <div class="col-m-10 col-3">'."\n";

    $othtml .= '    <p style="margin-top: 0.25em; margin-bottom: 0.25em; padding-left: 0px;"><b><i>ricota di palori:</i></b></p>'."\n";

    $othtml .= '    <ul class="ricota-margin">'."\n";
    $othtml .= '      <li><a href="/dieli/?search=COLL_aviri">aviri</a> &amp; '."\n";
    $othtml .= '	<a href="/dieli/?search=COLL_have">to have</a></li>'."\n";
    $othtml .= '      <li><a href="/dieli/?search=COLL_essiri">essiri</a></li>'."\n";
    $othtml .= '      <li><a href="/dieli/?search=COLL_fari">fari</a></li>'."\n";
    $othtml .= '    </ul>'."\n";

    $othtml .= '  </div>'."\n";
    $othtml .= '  <div class="col-t-2"></div>'."\n";
    $othtml .= '  <div class="col-m-10 col-2">'."\n";

    $othtml .= '    <ul class="ricota-margin-plus">'."\n";
    $othtml .= '      <li><a href="/dieli/?search=COLL_italy">l'."'".'Italia</a></li>'."\n";
    $othtml .= '      <li><a href="/dieli/?search=COLL_places">lu munnu</a></li>'."\n";
    $othtml .= '      <li><a href="/dieli/?search=COLL_timerel">lu tempu</a></li>'."\n";
    $othtml .= '      <li><a href="/dieli/?search=COLL_daysweek">li jorna</a></li>'."\n";
    $othtml .= '    </ul>'."\n";

    $othtml .= '  </div>'."\n";
    $othtml .= '  <div class="minicol"></div>'."\n";
    $othtml .= '  <div class="col-t-2"></div>'."\n";
    $othtml .= '  <div class="col-m-10 col-3">'."\n";

    $othtml .= '    <ul class="ricota-margin-plus">'."\n";
    $othtml .= '      <li><a href="/dieli/?search=COLL_months">li misi</a></li>'."\n";
    $othtml .= '      <li><a href="/dieli/?search=COLL_holidays">li festi</a></li>'."\n";
    $othtml .= '      <li><a href="/dieli/?search=COLL_seasons">li staggiuni</a></li>'."\n";
    $othtml .= '    </ul>'."\n";

    $othtml .= '  </div>'."\n";
    $othtml .= '  <div class="col-t-2"></div>'."\n";
    $othtml .= '  <div class="col-m-10 col-3">'."\n";

    $othtml .= '    <p style="margin-top: 0.25em; margin-bottom: 0.25em;"><b><i>lingua siciliana:</i></b></p>'."\n";
    $othtml .= '    <ul class="ricota-margin">'."\n";
    $othtml .= '      <li style="margin-bottom: 0.125em;"><a href="https://arbasicula.org/" target="_blank">Arba Sicula</a></li>'."\n";
    $othtml .= '      <li style="margin-bottom: 0.125em;"><a href="http://www.dieli.net/" target="_blank">Arthur Dieli</a></li>'."\n";
    $othtml .= '    </ul>'."\n";

    $othtml .= '  </div>'."\n";
    $othtml .= '</div>'."\n";
    ##  close project DIV
    
    ##  let's keep this thing wide on large screens
    $othtml .= '<div class="widenme"></div>' . "\n" ; 

    ##  add some space on the bottom
    ## $othtml .= '<br>' . "\n" ;

    $othtml .= '  </div>' . "\n" ;
    $othtml .= '  <!-- end row div -->' . "\n" ;

    return $othtml ;
}

##  navigation footer
sub mk_foothtml {

    ##  footer navigation
    my $footnav = $_[0] ; 

    ##  prepare output
    my $othtml ;

    open( my $fh_footnav , "<:encoding(utf-8)" , $footnav ); ## || die "could not read:  $footnav";
    while(<$fh_footnav>){ chomp;  $othtml .= $_ . "\n" ; };
    close $fh_footnav ;
    
    $othtml .= "  </body>"."\n";
    $othtml .= "</html>"."\n";
    
    return $othtml ;
}

1;
