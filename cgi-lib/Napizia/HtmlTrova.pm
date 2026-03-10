package Napizia::HtmlTrova;

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

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

use strict;
use warnings;
no warnings qw(uninitialized numeric void);

use utf8;

sub conjugate { Napizia::PosTools::conjugate($_[0], $_[1], $_[2]);}
sub rid_accents { Napizia::TextTools::rid_accents( $_[0] );}

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ("mk_header","mk_ricota","mk_footer","mk_form","mk_wdheader",
	       "get_sample_author","find_poem_matches","mk_notex_list",
	       "strip_line");

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  make HTML header
sub mk_header {

    ##  top navigation panel
    my $topnav = $_[0] ;

    ##  the words, title and author searched for
    my $palori_str = ( ! defined $_[1] ) ? "" : $_[1] ;
    my $autori_str = ( ! defined $_[2] ) ? "" : $_[2] ;
    my $titulu_str = ( ! defined $_[3] ) ? "" : $_[3] ;

    $palori_str = ( $palori_str !~ /[a-z]/ ) ? "" : "pa: " . $palori_str . ", ";
    $autori_str = ( $autori_str !~ /[a-z]/ ) ? "" : "au: " . $autori_str . ", ";
    $titulu_str = ( $titulu_str !~ /[a-z]/ ) ? "" : "ti: " . $titulu_str . ", ";

    ##  create search string
    my $search = $palori_str . $titulu_str . $autori_str ;
    $search =~ s/, $//;
    $search =~ s/^ //;
    $search =~ s/ $//;
    
    ##  text to insert into the title
    my $title_insert = ( $search eq "" ) ? "" : $search .' :: ';
  
    ##  prepare output HTML
    my $ottxt ;
    ## $ottxt .= "Content-type: text/html\n\n";
    $ottxt .= '<!DOCTYPE html>' . "\n" ;
    $ottxt .= '<html>' . "\n" ;
    $ottxt .= '  <head>' . "\n" ;

    my $title_concat = $title_insert . 'Trova na Palora :: Napizia';
    $ottxt .= '    <title>'. $title_concat .'</title>'."\n";
    $ottxt .= '    <meta property="og:title" content="'. $title_concat .'">'."\n";
    $ottxt .= '    <meta name="twitter:title" content="'. $title_concat .'">'."\n";

    if ( $title_insert ne "") {
	my $descrip ;
	$descrip .= 'puisia e pruverbi pi: '. $search .', ';
	$descrip .= 'poetry and proverbs for: '. $search ;
	$ottxt .= '    <meta name="DESCRIPTION" content="'. $descrip .'">'."\n";
	$ottxt .= '    <meta property="og:description" content="'. $descrip .'">'."\n";
	$ottxt .= '    <meta name="twitter:description" content="'. $descrip .'">'."\n";
    } else {
	my $descrip ;
	$descrip .= 'Attrova na palora o na frasi ntra li pruverbi e versi di puisia. ';
	$descrip .= 'Find a word or phrase within the proverbs and verses of poetry.';
	$ottxt .= '    <meta name="DESCRIPTION" content="'. $descrip .'">'."\n";
	$ottxt .= '    <meta property="og:description" content="'. $descrip .'">'."\n";
	$ottxt .= '    <meta name="twitter:description" content="'. $descrip .'">'."\n";	
    }

    ##  continue header
    $ottxt .= '    <meta name="KEYWORDS" content="poetry, proverbs, Sicilian, Sicilian language">' ."\n";

    ##  search information to add to URL
    if ( $palori_str !~ /[a-z]/ && $autori_str !~ /[a-z]/ && $titulu_str !~ /[a-z]/ ) {

	my $urlref = 'https://www.napizia.com/cgi-bin/trova-palora.pl';
	$ottxt .= '    <meta property="og:url" content="'. $urlref .'">'."\n";
	$ottxt .= '    <meta name="twitter:url" content="'. $urlref .'">'."\n";

    } else {
	##  searches to add to the URL
	my $addtourl ;
	$addtourl .= ( $palori_str !~ /[a-z]/ ) ? "" : '&palori='. $palori_str ;
	$addtourl .= ( $autori_str !~ /[a-z]/ ) ? "" : '&autori='. $autori_str ;
	$addtourl .= ( $titulu_str !~ /[a-z]/ ) ? "" : '&titulu='. $titulu_str ;
	$addtourl =~ s/^\&/?/;
	
	##  add them to the URL
	my $urlref = 'https://www.napizia.com/cgi-bin/trova-palora.pl';
	$urlref .= $addtourl ;

	##  append to the HTML
	$ottxt .= '    <meta property="og:url" content="'. $urlref .'">'."\n";
	$ottxt .= '    <meta name="twitter:url" content="'. $urlref .'">'."\n";	    
    }

    ##  image, og:type and twitter card
    ## my $logopic = 'https://www.napizia.com/config/napizia_logo-w-descrip.jpg';
    my $logopic = 'https://www.napizia.com/pics/trova-palora.jpg';
    $ottxt .= '    <meta property="og:image" content="'. $logopic .'">'."\n";
    $ottxt .= '    <meta name="twitter:image" content="'. $logopic .'">'."\n";
    $ottxt .= '    <meta property="og:type" content="website">'."\n";
    $ottxt .= '    <meta name="twitter:site" content="@ProjectNapizia">'."\n";
    $ottxt .= '    <meta name="twitter:card" content="summary_large_image">'."\n";

    ##  continue header
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
    $ottxt .= '          href="https://www.napizia.com/pages/sicilian/search/dieli_sc-en.xml">'."\n";
    $ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    $ottxt .= '          title="SC-IT Dieli Dict"'."\n";
    $ottxt .= '          href="https://www.napizia.com/pages/sicilian/search/dieli_sc-it.xml">'."\n";
    $ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    $ottxt .= '          title="EN-SC Dieli Dict"'."\n";
    $ottxt .= '          href="https://www.napizia.com/pages/sicilian/search/dieli_en-sc.xml">'."\n";
    $ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    $ottxt .= '          title="IT-SC Dieli Dict"'."\n";
    $ottxt .= '          href="https://www.napizia.com/pages/sicilian/search/dieli_it-sc.xml">'."\n";
    $ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    $ottxt .= '          title="Trova na Palora"'."\n";
    $ottxt .= '          href="https://www.napizia.com/pages/sicilian/search/trova-palora.xml">'."\n";
    #$ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    #$ottxt .= '          title="Cosine Sim Skipgram"'."\n";
    #$ottxt .= '          href="https://www.napizia.com/pages/sicilian/search/cosine-sim_skip.xml">'."\n";
    #$ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    #$ottxt .= '          title="Cosine Sim CBOW"'."\n";
    #$ottxt .= '          href="https://www.napizia.com/pages/sicilian/search/cosine-sim_cbow.xml">'."\n";
    $ottxt .= "\n";
    $ottxt .= '    <meta name="viewport" content="width=device-width, initial-scale=1">' . "\n" ;
    $ottxt .= '    <style>' . "\n" ;
    $ottxt .= '    p.zero { margin-top: 0em; margin-bottom: 0em; }' . "\n" ;
    $ottxt .= '    div.transconj { position: relative; margin: auto; width: 50%;}' . "\n" ;
    $ottxt .= '    @media only screen and (max-width: 835px) { ' . "\n" ;
    $ottxt .= '        div.transconj { position: relative; margin: auto; width: 90%;}' . "\n" ;
    $ottxt .= '    }' . "\n" ;

    ## ##  spacing for second column of Dieli collections
    ## ##  now handled by "eryk_widenme.css"
    ## $ottxt .= '    ul.ddcoltwo { margin-top: 0em; }' . "\n" ;
    ## $ottxt .= '    @media only screen and (min-width: 600px) { ' . "\n" ;
    ## $ottxt .= '        ul.ddcoltwo { margin-top: 2.25em; }' . "\n" ;
    ## $ottxt .= '    }' . "\n" ;
    
    $ottxt .= '    </style>' . "\n" ;
    $ottxt .= '  </head>' . "\n" ;
    $ottxt .= '  <body>' . "\n" ;

    open( my $fh_topnav , "<:encoding(utf-8)" , $topnav ); ## || die "could not read:  $topnav";
    while(<$fh_topnav>){ chomp;  $ottxt .= $_ . "\n" ; };
    close $fh_topnav ;

    $ottxt .= '  <!-- begin row div -->' . "\n" ;
    $ottxt .= '  <div class="row">' . "\n" ;
    $ottxt .= '    <div class="col-m-12 col-12">' . "\n" ;
    $ottxt .= '      <h1>Trova na Palora</h1>'."\n";
    $ottxt .= '    </div>' . "\n" ;
    $ottxt .= '  </div>' . "\n" ;
    $ottxt .= '  <!-- end row div -->' . "\n" ;
    $ottxt .= '  ' . "\n" ;
    $ottxt .= '  <!-- begin row div -->' . "\n" ;
    $ottxt .= '  <div class="row">' . "\n" ;
    
    return $ottxt ;
}

##  make word collection
sub mk_ricota {

    ##  prepare output
    my $othtml ;
    $othtml .= '<div class="row" style="margin: 2px 0px; border: 1px solid black; background-color: rgb(255,255,204);">'."\n";
    $othtml .= '  <div class="minicol"></div>'."\n";
    $othtml .= '  <div class="col-t-2"></div>'."\n";
    $othtml .= '  <div class="col-m-10 col-3">'."\n";
    $othtml .= '    <p style="margin-top: 0.25em; margin-bottom: 0.25em; padding-left: 0px;"><b><i>ricota di palori:</i></b></p>'."\n";
    $othtml .= '    <ul class="ricota-margin">'."\n";
    $othtml .= '      <li><a href="/cgi-bin/sicilian.pl?search=COLL_aviri">aviri</a> &amp; '."\n";
    $othtml .= '	<a href="/cgi-bin/sicilian.pl?search=COLL_have">to have</a></li>'."\n";
    $othtml .= '      <li><a href="/cgi-bin/sicilian.pl?search=COLL_essiri">essiri</a></li>'."\n";
    $othtml .= '      <li><a href="/cgi-bin/sicilian.pl?search=COLL_fari">fari</a></li>'."\n";
    $othtml .= '    </ul>'."\n";
    $othtml .= '  </div>'."\n";
    $othtml .= '  <div class="col-t-2"></div>'."\n";
    $othtml .= '  <div class="col-m-10 col-2">'."\n";
    $othtml .= '    <ul class="ricota-margin-plus">'."\n";
    $othtml .= '      <li><a href="/cgi-bin/sicilian.pl?search=COLL_italy">l'."'".'Italia</a></li>'."\n";
    $othtml .= '      <li><a href="/cgi-bin/sicilian.pl?search=COLL_places">lu munnu</a></li>'."\n";
    $othtml .= '      <li><a href="/cgi-bin/sicilian.pl?search=COLL_timerel">lu tempu</a></li>'."\n";
    $othtml .= '      <li><a href="/cgi-bin/sicilian.pl?search=COLL_daysweek">li jorna</a></li>'."\n";
    $othtml .= '    </ul>'."\n";
    $othtml .= '  </div>'."\n";
    $othtml .= '  <div class="minicol"></div>'."\n";
    $othtml .= '  <div class="col-t-2"></div>'."\n";
    $othtml .= '  <div class="col-m-10 col-3">'."\n";
    $othtml .= '    <ul class="ricota-margin-plus">'."\n";
    $othtml .= '      <li><a href="/cgi-bin/sicilian.pl?search=COLL_months">li misi</a></li>'."\n";
    $othtml .= '      <li><a href="/cgi-bin/sicilian.pl?search=COLL_holidays">li festi</a></li>'."\n";
    $othtml .= '      <li><a href="/cgi-bin/sicilian.pl?search=COLL_seasons">li staggiuni</a></li>'."\n";
    $othtml .= '    </ul>'."\n";
    $othtml .= '  </div>'."\n";
    $othtml .= '  <div class="col-t-2"></div>'."\n";
    $othtml .= '  <div class="col-m-10 col-3">'."\n";
    $othtml .= '    <p style="margin-top: 0.25em; margin-bottom: 0.25em;"><b><i>lingua siciliana:</i></b></p>'."\n";
    $othtml .= '    <ul class="ricota-margin">'."\n";
    $othtml .= '      <li style="margin-bottom: 0.125em;"><a href="http://www.arbasicula.org/" '."\n";
    $othtml .= '          target="_blank">Arba Sicula</a></li>'."\n";
    $othtml .= '      <li style="margin-bottom: 0.125em;"><a href="http://www.dieli.net/" '."\n";
    $othtml .= '      	  target="_blank">Arthur Dieli</a></li>'."\n";
    $othtml .= '    </ul>'."\n";
    $othtml .= '  </div>'."\n";
    $othtml .= '</div>'."\n";
    
    ##  let's keep this thing wide on large screens
    $othtml .= '<div class="widenme"></div>'."\n";

    ##  add some space on the bottom
    ## $othtml .= '<br>'."\n";

    $othtml .= '  </div>' . "\n" ;
    $othtml .= '  <!-- end row div -->'."\n";

    ##  return the collection
    return $othtml;
}


##  make footer
sub mk_footer {

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

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  make form
sub mk_form {

    ##  embedding and search
    my $in_palori = $_[0];
    my $in_autori = $_[1];
    my $in_titulu = $_[2]; 
    
    my $ottxt ;
    $ottxt .= '<form enctype="multipart/form-data" action="/cgi-bin/trova-palora.pl" method="post">' . "\n" ;
    $ottxt .= '<table style="max-width:500px;"><tbody>' ."\n";
    $ottxt .= '<tr><td><small>palora</small></td>' ."\n";
    $ottxt .= '<td colspan="2">' ."\n";
    $ottxt .= '<input type=text name="palori" value="'. $in_palori .'" size=27 maxlength=48>' ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '<tr><td><small>tìtulu</small></td>' ."\n";
    $ottxt .= '<td colspan="2">' ."\n";
    $ottxt .= '<input type=text name="titulu" value="'. $in_titulu .'" size=27 maxlength=48>' ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '<tr><td><small>autori</small></td>' ."\n";
    $ottxt .= '<td>' ."\n";
    $ottxt .= '<input type=text name="autori" value="'. $in_autori .'" size=15 maxlength=24>' ; 
    $ottxt .= '</td>' . "\n" ;
    $ottxt .= '<td align="right">' . '<input type="submit" value="Attrova">' . "\n" ;
    ## $ottxt .= '<input type=reset value="Clear Form">' . "\n" ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '</tbody></table>' . "\n" ;
    $ottxt .= '</form>' . "\n" ;
        
    return $ottxt ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  make word header
sub mk_wdheader {

    ##  inputs for word header
    my $palora =   $_[0];
    my %vnotes = %{$_[1]};
    my $vbconj =   $_[2];
    
    ##  are we working with a verb?
    my %wdhash ;
    my $isverb = ( ! defined $vnotes{ $palora }{verb}     && 
		   ! defined $vnotes{ $palora }{reflex}   && 
		   ! defined $vnotes{ $palora }{prepend}  ) ? "false" : "true" ;
    if ( $isverb eq "true" ) {
	%wdhash = conjugate( $palora , \%vnotes , $vbconj ) ; 
    }
    
    ##  which word do we display?
    ( my $display = $palora ) =~ s/_([a-z])+$//;
    $display = ( ! defined $wdhash{inf} ) ? $display : $wdhash{inf} ;
    $display = ( ! defined $vnotes{$palora}{display_as} ) ? $display : $vnotes{$palora}{display_as} ;
    
    ##  parti di discursu 
    my $part_speech = $vnotes{ $palora }{part_speech} ;
    
    ##  translate to Sicilian
    $part_speech =~ s/^verb$/verbu/ ;
    $part_speech =~ s/^noun$/sust./ ;
    $part_speech =~ s/^adj$/agg./   ;
    $part_speech =~ s/^adv$/avv./   ;
    $part_speech =~ s/^prep$/prip./ ;
    $part_speech =~ s/^pron$/prun./ ;
    $part_speech =~ s/^conj$/cunj./ ;
	    
    ##  HEADER
    my $header;
    $header .= '<p><b><a href="/cgi-bin/cchiu-da-palora.pl?' . 'palora=' . $palora . '">' ; 
    $header .= $display . '</a></b>&nbsp;&nbsp;{'. $part_speech .'}</p>'."\n";

    return $header;
}

##  get stripped sample and author
sub get_sample_author {

    my $line = $_[0];
    $line = strip_line( $line );
    
    ##  identify citation
    my $citation = $line ;
    $citation =~ s/^.*\(//;

    ##  make matching parenthesis
    my $cite_paren = $citation ;
    if ( $cite_paren =~ /\)/ && $cite_paren !~ /\(/ ) {
	$cite_paren =~ s/^/\(/
    }

    ##  identify sample
    my $sample   = $line ;
    $sample =~ s/$cite_paren//;
        
    ##  remove matching parenthesis
    $citation =~ s/[\(\)]//g;
    $sample   =~ s/[\(\)]//g;
    
    ##  identify title and author
    my $author = $citation ;
    my $title  = $citation ;
    $author =~ s/^.*",//;
    $title =~ s/$author//;

    ##  clean them up
    $sample =~ s/\s+/ /g; $author =~ s/\s+/ /g; $title =~ s/\s+/ /g; 
    $sample =~ s/\"//g;   $author =~ s/\"//g;   $title =~ s/\"//g;
    $sample =~ s/\,//g;   $author =~ s/\,//g;   $title =~ s/\,//g;
    $sample =~ s/^ //;    $author =~ s/^ //;    $title =~ s/^ //; 
    $sample =~ s/ $//;    $author =~ s/ $//;    $title =~ s/ $//; 

    ##  citations of Pitre's "Canti" and "Fiabe" have numbers
    $author = ( $title eq "canti" && $author =~ /pitre/ ) ? "pitre" : $author ;
    $author = ( $title eq "fiabe" && $author =~ /pitre/ ) ? "pitre" : $author ;
    
    ##  return stripped sample, author and title
    return( $sample , $author , $title );
}

##  find poem/proverb matches
sub find_poem_matches {

    my $palora     =   $_[0];
    my $autori_str =   $_[1];
    my $palori_str =   $_[2];
    my $titulu_str =   $_[3];
    my $typeof     =   $_[4];  ## "poetry", "prose", or "proverb"
    my %vnotes     = %{$_[5]};
    
    my @poem_matches;
        
    if ( ! defined $vnotes{$palora}{$typeof} ) {
	my $blah = "do nothing" ;
    } else {
	
	my @poetry  = @{ $vnotes{$palora}{$typeof} };
	foreach my $poem (@poetry) {
	    ##  get stripped sample and author
	    my ( $sample , $author , $title ) = get_sample_author( $poem );
	    
	    ##  fix "la mattina", "di marco" and "de vita"
	    $author =~ s/la mattina/la~mattina/g;
	    $author =~ s/di marco/di~marco/g;
	    $author =~ s/de vita/de~vita/g;

	    ##  add spacing
	    my @au_sch = split(' ',$author);
	    $author = ' ' . join( ' | ' , @au_sch ) . ' ';
	    $sample = ' ' . $sample . ' ';
	    $title  = ' ' . $title  . ' ';
	    
	    ##  create author search string
	    my $autori_new = $autori_str;
	    $autori_new =~ s/la mattina/la~mattina/g;
	    $autori_new =~ s/di marco/di~marco/g;
	    $autori_new =~ s/de vita/de~vita/g;
	    my @autori_list = split(' ',$autori_new );
	    
	    ##  create word search string
	    my $palori_new = ' ' . $palori_str . ' ';

	    ##  create title search string
	    my $titulu_new = ' ' . $titulu_str . ' ';
		    
	    ##  search sample and author
	    if ( $autori_str ne "" && $palori_str ne "" && $titulu_str ne "" ) {
		foreach my $author_new (@autori_list) {
		    my $author_sch = ' ' . $author_new . ' ';
		    if ( $author_sch =~ /$author/ && $sample =~ /$palori_new/ && $title =~ /$titulu_new/ ) {
			push( @poem_matches , $poem );
		    }
		}

	    } elsif ( $autori_str ne "" && $titulu_str ne "" ) {
		foreach my $author_new (@autori_list) {
		    my $author_sch = ' ' . $author_new . ' ';
		    if ( $author_sch =~ /$author/ && $title =~ /$titulu_new/ ) {
			push( @poem_matches , $poem );
		    }
		}

	    } elsif ( $autori_str ne "" && $palori_str ne "" ) {
		foreach my $author_new (@autori_list) {
		    my $author_sch = ' ' . $author_new . ' ';
		    if ( $author_sch =~ /$author/ && $sample =~ /$palori_new/ ) {
			push( @poem_matches , $poem );
		    }
		}

	    } elsif ( $palori_str ne "" && $titulu_str ne "" ) {
		if ( $sample =~ /$palori_new/ && $title =~ /$titulu_new/ ) {
		    push( @poem_matches , $poem );
		}

	    } elsif ( $titulu_str ne "" ) {
		if ( $title =~ /$titulu_new/ ) {
		    push( @poem_matches , $poem );
		}
		
	    } elsif ( $palori_str ne "" ) {
		if ( $sample =~ /$palori_new/ ) {
		    push( @poem_matches , $poem );
		}		       			
	    } elsif ( $autori_str ne "" ) {
		foreach my $author_new (@autori_list) {	
		    my $author_sch = ' ' . $author_new . ' ';
		    if ( $author_sch =~ /$author/ ) {
			push( @poem_matches , $poem );
		    }
		}
	    }
	    
	}
    }

    ##  return matching poems/proverbs
    return @poem_matches ;
}

##  make list of examples
sub mk_notex_list {

    my $typeof =     $_[0] ;
    my @inarray = @{ $_[1] } ;

    my $othtml ;

    ## $othtml .= '<div class="transconj">' ."\n"; 
    $othtml .= '<p style="margin-bottom: 0.25em;"><i>' . $typeof . '</i></p>' ."\n";
    $othtml .= '<ul style="margin-top: 0.25em;">' ."\n";
    foreach my $line (@inarray) {

	##  clean up dashes
	$line =~ s/\-\-/\&ndash;/g;
	    
	##  append the line
	$othtml .= "<li>" . $line . "</li>" ."\n";
    }
    $othtml .= "</ul>" ."\n";
    ## $othtml .= "</div>" ."\n";
    
    return $othtml ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  strip line to (almost) lower-case letters only, removing unicode accents
##  but leave parenthesis, double quotes and commas (to identify sources)
sub strip_line {

    my $line    =  $_[0];

    ##  remove stuff
    $line =~ s/\n/ /g;
    $line =~ s/<br>/ /g;
    $line =~ s/<i>/ /g;
    $line =~ s/<\/i>/ /g;
    $line =~ s/&nbsp;/ /g;
    $line =~ s/&lpar;/ /g;
    $line =~ s/&rpar;/ /g;
    $line =~ s/[\[\]\{\}\+\=\'\-\*\/\#\|\%\@\$_\;\:\.\!\?]/ /g;
    $line =~ s/\d+/ /g;
    $line =~ s/’/ /g;

    ##  remove accents
    $line = rid_accents( $line ) ;

    ##  and make it all lower case
    $line = lc($line); 

    ##  remove anything that is not lower case letter, space or parenthesis, single quote or comma
    $line =~ s/[^\(\)\"\,a-z]/ /g;
    
    ##  remove excess spaces
    $line =~ s/\s+/ /g;

    ##  remove spaces from beginning and end
    $line =~ s/^ //;
    $line =~ s/ $//;
    
    ##  return the stripped line
    return $line ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

1;
