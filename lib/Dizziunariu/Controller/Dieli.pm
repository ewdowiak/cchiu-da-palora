package Dizziunariu::Controller::Dieli;

##  makes a searchable version of the Dieli dictionary
##  Copyright (C) 2018-2026 Eryk Wdowiak
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
#no warnings qw(uninitialized);
use utf8;

use Mojo::Base 'Mojolicious::Controller', -signatures;

use Storable qw( retrieve ) ;
#{   no warnings;             
    ## $Storable::Deparse = 1;  
    $Storable::Eval    = 1;  
#}

use URI::Escape;

use Napizia::TextTools;
use Napizia::Utils;
use Napizia::HtmlDieli;

my $home = $ENV{HOME};

##  retrieve storables
my $stor_dieli_en = retrieve("$home/website/dizziunariu/lib/stor/dieli-en-dict");
my $stor_dieli_sc = retrieve("$home/website/dizziunariu/lib/stor/dieli-sc-dict");
my $stor_dplus_sc = retrieve("$home/website/dizziunariu/lib/stor/dieliplus-sc-dict");
my $stor_dplus_en = retrieve("$home/website/dizziunariu/lib/stor/dieliplus-en-dict");
my $stor_dplus_it = retrieve("$home/website/dizziunariu/lib/stor/dieliplus-it-dict");

##  for HEAD of HTML page
my $card_descrip = 'Sicilian-Italian-English Dictionary by Arthur Dieli';
my $card_keywords = 'Sicilian, language, dictionary, Dieli, Arthur Dieli';
my $card_image = 'https://dizziunariu.napizia.com/pics/dizziunariu-dieli.jpg';

##  for HEADLINE (h1) of HTML page
my $page_hline = 'Dizziunariu Dieli';

##  for STYLE of HTML page
my $page_style = '';
## this style now handled by "eryk_widenme.css"
# $page_style .= '<style>'."\n";
# $page_style .= 'p.zero { margin-top: 0em; margin-bottom: 0em; }'."\n";
# $page_style .= 'div.cunzigghiu { position: relative; margin: auto; width: 50%;}'."\n";
# $page_style .= '@media only screen and (max-width: 835px) {'."\n";
# $page_style .= 'div.cunzigghiu { position: relative; margin: auto; width: 90%;}'."\n";
# $page_style .= '}'."\n";
# $page_style .= '</style>'."\n";

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  WELCOME
##  =======

sub welcome ($self) {

    ##  retrieve parameters
    my $par_search = $self->param('search') || '';
    my $par_langs  = $self->param('langs')  || '';
    
    ##  prepare HTML page
    my %othash = mk_htmlpage( $par_search , $par_langs );
    my $otpage  = $othash{htmlpage};
    my $socials = $othash{socials};
    my $card_title = $othash{card_title};
    my $card_url = $othash{card_url};

    ##  and render it
    $self->render(
	card_title    => $card_title ,
	card_descrip  => $card_descrip , 
	card_keywords => $card_keywords ,
	card_url      => $card_url ,
	card_image    => $card_image , 
	page_style    => $page_style ,
	page_hline    => $page_hline ,
	htmlpage      => $otpage ,
	socials       => $socials 
	);
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  CREATE WEBPAGE
##  ====== =======

sub mk_htmlpage{ 

    ##  in arguments
    my $par_search = $_[0];
    my $par_langs  = $_[1];

    ##  what are we looking for?
    my $insearch = $par_search ;
    my $rquest   = $par_langs ;
    my $lgparm   = ( $par_langs !~ /^SCEN$|^SCIT$|^ENSC$|^ITSC$/ ) ? "SCEN" : $par_langs ;
    $rquest = $lgparm;

    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

    ##  searches split by vertical bar
    my @searches = split( "_OR_" , $insearch ) ; 
    s/^\s*// for @searches ; 
    s/\s*$// for @searches ; 
    s/'/_SQUOTE_/g for @searches ; 
    
    ##  which dictionary to retrieve?
    my $dieli_slang ; 
    if ( $insearch =~ /^COLL_have$/ ) {
	$dieli_slang = $stor_dieli_en ;
    } elsif ( $insearch =~ /^COLL_/ ) {
	$dieli_slang = $stor_dieli_sc ;
    } elsif ( $rquest =~ /SCEN|SCIT/ ) {
	$dieli_slang = $stor_dplus_sc ;
    } elsif ( $rquest =~ /ENSC/ ) {
	$dieli_slang = $stor_dplus_en ;
    } elsif ( $rquest =~ /ITSC/ ) {
	$dieli_slang = $stor_dplus_it ;
    } else {
	my $blah = "retrieve nothing -- no language requested" ;
    }

    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    
    ##  initialize output HTML
    my $otline ; 
    $otline .= "\n";
    
    ##  translate and pass output to HTML
    foreach my $search (@searches) {
	
	##  if "collection" ...
	if ( $search =~ /^COLL_/ ) {
	    my %collections = mk_collections() ;
	    my @whichcolls = grep( /$search/ , keys( %collections ) ); 
	    foreach my $collection (@whichcolls) {
		
		##  get the reference
		my $cref  = $collections{$collection};
		my $slang = ${${$cref}[0]}[0] ;
		
		for my $i (1..$#{$cref}) { 
		    $otline .= '<br>' . "\n" ; 
		    my $pclass = ' class="zero"' ;
		    $otline .= '<div align="center">'."\n";
		    $otline .= mk_search($slang , \@{${$cref}[$i]} , $dieli_slang , $lgparm , $pclass ,"BeNice");
		    $otline .= '</div>' . "\n" ; 	
		}
	    }
	    
	    
	} elsif ( $rquest =~ /SCEN|SCIT|ENSC|ITSC/ ) { 
	    ##  no collection was requested, so 
	    ##  check if language specified in request
	    ##  if language not specified, then there is no request
	    
	    if ( length($insearch) < 5 ) {
		###  ( $rquest =~ /SCEN|SCIT/ && 
		###    ( length($insearch) < 2 || 
		###      $search =~ /lu|la|li|ca|cu|di|nna|nni|nta|ntra|pi|pri/ ) )  
		##  
		##  search string less than five
		##  search string small, but broaden results by dropping accents

		my @subsearches ; 
		foreach my $key (sort keys(%{$dieli_slang}) ) {
		    my $sch_noa = rid_accents( scn_lowercase( $search ));
		    my $key_noa = rid_accents( scn_lowercase( $key ));
		    $key_noa =~ s/[\(\)]//g;  $key_noa =~ s/'/_SQUOTE_/g;  $key_noa =~ s/_squote_/_SQUOTE_/g;
		    $sch_noa =~ s/[\(\)]//g;  $sch_noa =~ s/'/_SQUOTE_/g;  $sch_noa =~ s/_squote_/_SQUOTE_/g;
		    if ( $key_noa eq $sch_noa ) {
			push( @subsearches , $key ) ;
		    }
		}
		@subsearches = uniq(@subsearches);
		
		if ( $#subsearches > -1 ) {
		    my $pclass = ' style="margin-top: 0em; margin-bottom: 0.35em;"';
		    $otline .= '<div align="center" style="margin-bottom: 0.5em; margin-top: 1.0em;">'."\n";
		    $otline .= mk_search( $rquest, \@subsearches , $dieli_slang , $lgparm , $pclass , "BeNice");
		    $otline .= '</div>'."\n";
		    
		} else {
		    my $rsrch = $search ;
		    $rsrch =~ s/_SQUOTE_/'/g;
		    $otline .= '<div align="center">' . "\n" ; 
		    $otline .= "<p>nun c'è na traduzzioni dâ palora: " . '&nbsp; <b>' . $rsrch . '</b></p>';
		    $otline .= '</div>' . "\n" ; 
		}
		
	    } else {
		##  search string five characters or more, so let's broaden search further
		##  drop accents and check for matching word within key
		my @subsearches ; 
		foreach my $key (sort keys(%{$dieli_slang}) ) {
		    my $sch_noa = rid_accents( scn_lowercase( $search ));
		    my $key_noa = rid_accents( scn_lowercase( $key ));
		    $key_noa =~ s/[\(\)]//g;  $key_noa =~ s/'/_SQUOTE_/g;  $key_noa =~ s/_squote_/_SQUOTE_/g;
		    $sch_noa =~ s/[\(\)]//g;  $sch_noa =~ s/'/_SQUOTE_/g;  $sch_noa =~ s/_squote_/_SQUOTE_/g;

		    if ( $key_noa =~ /$sch_noa/ ) {
			##  found search term in key
			##  does search term match a word in key?
			my @key_wds = split( / /, $key_noa ) ;
			foreach my $keyword (@key_wds) {
			    ##  need to match on keyword beginning and ending,
			    ##  otherwise excess (bad) results
			    if ( $sch_noa =~ /^$keyword$/ || ( $sch_noa =~ / / && $sch_noa =~ /$keyword/ )  ) {
				## if ( $sch_noa =~ /^$keyword$/ ) {
				push( @subsearches , $key ) ;
			    }
			}
		    }
		}
		@subsearches = uniq(@subsearches);

		my @lcrids;
		foreach my $subsearch (@subsearches) {
		    my $lcrid = rid_accents( scn_lowercase( $subsearch ) );
		    push( @lcrids , $lcrid );
		}
		@lcrids = uniq( @lcrids );
		
		if ( $#lcrids > -1 ) {
		    my $pclass = ' style="margin-top: 0em; margin-bottom: 0.35em;"';
		    $otline .= '<div align="center" style="margin-bottom: 0.5em; margin-top: 1.0em;">'."\n";
		    $otline .= mk_search( $rquest, \@lcrids , $dieli_slang , $lgparm , $pclass ,"BeNice");
		    $otline .= '</div>'."\n";
		    
		} else {
		    my $rsrch = $search ;
		    $rsrch =~ s/_SQUOTE_/'/g;
		    $otline .= '<div align="center">'."\n";
		    $otline .= "<p>nun c'è na traduzzioni dâ palora: ".'&nbsp; <b>'. $rsrch .'</b></p>';
		    $otline .= '</div>'."\n";
		}
	    } 
	}
    }
    
    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

    ##  prepare the social media shares
    my $text_url   = 'https://dizziunariu.napizia.com/dieli/';
    my $text_title;
    if ( ! defined $insearch ) {
	my $blah  = 'do nothing';
    } else { 
	$text_url .= '?search='. $insearch ;
	if ( $insearch !~ /^COLL_/ ) {
	    $text_url .= '&langs='. $lgparm ;
	}
	$text_title = fetch_pagetitle($insearch, $lgparm);
    }
    $text_title  .= 'Dizziunariu Dieli :: Napizia';
    
    my $url   = uri_escape($text_url);
    my $title = uri_escape($text_title);
    my $share = mk_share( $url , $title );

    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    
    ##  make HTML page
    my $htmlpage ;
    $htmlpage .= mk_newform( $lgparm , $insearch );
    $htmlpage .= $otline  ;
    ## ##  template now handles thanks and list of collections
    ## # $htmlpage .= thank_dieli();
    ## # $htmlpage .= mk_ricota();

    ##  return the HTML page and the Socials
    my %othash = ( htmlpage => $htmlpage ,
		   socials => $share ,
		   card_title => $text_title ,
		   card_url => $text_url
	);
    return %othash ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  OTHER SUBROUTINES
##  ===== ===========

##  subroutine to fetch page title for social media shares
sub fetch_pagetitle {

    ##  the word searched for, and only if single-item
    my $search = $_[0];
    $search = ( ! defined $search ) ? "" : $search ;
    $search =~ s/_SQUOTE_/'/g;
    $search =~ s/_OR_.*$//;
    
    ##  language parameter
    my $lgtext = $_[1] ;
    $lgtext = ( ! defined $lgtext ) ? "" : $lgtext ;
    $lgtext =~ s/ENSC/En-Sc/;
    $lgtext =~ s/ITSC/It-Sc/;
    $lgtext =~ s/SCEN/Sc-En/;
    $lgtext =~ s/SCIT/Sc-It/;

    ##  lang parameter if collection
    $lgtext = ( $search =~ /COLL_/ ) ? "Sc-En" : $lgtext ;
    $lgtext = ( $search =~ /COLL_have/ ) ? "En-Sc" : $lgtext ;

    ##  clean collections
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
    
    ##  text of title
    my $lg_textparen = ( $lgtext eq "" ) ? "" : ' ('. $lgtext .')';
    my $ot_title = ( $search eq "" ) ? "" : $search . $lg_textparen .' :: ';
    
    ##  return the title
    return $ot_title;
}

##  subroutine to make social media shares
sub mk_share {

    my $url   = uri_escape($_[0]);
    my $title = uri_escape($_[1]);
    
    my $html ;
    
    $html .= '<div class="message" style="margin: 0.10em auto 0em auto; width: 100%;">'."\n";
    $html .= '<p style="text-align: center; margin-top: 0.15em; margin-bottom: 0.25em;">'."\n";
    $html .= '<a href="https://www.facebook.com/sharer/sharer.php?u='. $url .'"'."\n";
    $html .= '   class="fa fa-facebook" style="color:white;"'."\n";
    $html .= '   target="_blank"></a>'."\n";
    $html .= '<a href="https://bsky.app/intent/compose?text='. $title .'%0A'. $url .'"'."\n";
    $html .= '   class="fa fa-bluesky" style="color:white;"'."\n";
    $html .= '   target="_blank"></a>'."\n";
    $html .= '<a href="https://www.linkedin.com/sharing/share-offsite/?url='. $url .'"'."\n";
    $html .= '   class="fa fa-linkedin" style="color:white;"'."\n";
    $html .= '   target="_blank"></a>'."\n";
    $html .= '<a href="mailto:?subject='. $title .'&body=' . $url .'"'."\n";
    $html .= '   class="fa fa-envelope" style="color:white;"'."\n";
    $html .= '   target="_blank"></a>'."\n";
    $html .= '</p>'."\n";
    $html .= '</div>'."\n";

    return $html ;
}

##  make collections
sub mk_collections {

    ##  hash to output
    my %othash ;

    ##  COLL_have
    @{ $othash{"COLL_have"} } = ( 
	["ENSC"],
	["have"],
	["have to"],
	["have to do"],
	["have a light complexion","have a dark complexion"],
	["have dinner"], 
	["have fun"],
	["have a good time","have pleasure"],
	["have knowledge"],
	["have makeup on"],
	["have a limp"],
	["have a desire"],
	["have an urge"],
	## ["have homosexual relations","have intercourse","have an orgasm"],
	);

    ##  COLL_aviri
    @{ $othash{"COLL_aviri"} } = (
	["SCEN"],
	["aviri"],
	["aviri a"],
	["aviri a chi fari","aviri a chi fari (cu)"],	
	["aviri bisognu","aviri di bisognu"],
	["aviri disidderiu"],
	["aviri ficatu"],
	["nun aviri fiducia"],
	["aviri fami"],
	["aviri paura"],
	["aviri sapuri"],
	["aviri siti"],
	["aviri spinnu"],
	["aviri vogghia"],
	);

    ##  COLL_essiri
    @{ $othash{"COLL_essiri"} } = (
	["SCEN"],
	["essiri"],
	["essiri chiaru di peddi","essiri scuru di peddi"],
	["po essiri"],
	["essiri d_SQUOTE_accordu"],
	["essiri dignu"],
	["essiri eredi"],
	["essiri nnamuratu"],
	["essiri paru"],
	["essiri umanu"],
	["essiri utili"],
	);
    
    ##  COLL_fari
    @{ $othash{"COLL_fari"} } = ( 
	["SCEN"],
	["fari"],
	["farisi"],
	["farisi largu"],
	["farisi mpristari"],
	["farisi nnarreri"],
	["farisi vidiri"],
	["fari abbozzi"],
	["fari a cura du suli"],
	["fari affari con"],
	["fari a guardia"],
	["fari a pugna"],
	["fari attenzioni"],
	["fari capiri"],
	["fari cascare"],
	["fari causa"],
	["fari cena"],
	["fari contattu"],
	["fari cumpiri"],
	["fari dumanna pr_SQUOTE_impiegu"],
	["fari dumanni"],
	["fari ecu"],
	["fari fermari"],
	["fari finta"],
	["fari fretta"],
	["fari i provi"],
	["fari i spisi"],
	["fari lu dittu"],
	["fari mali"],
	["fari marcia ndarreri"],
	["fari na culletta"],
	["fari na durmitina"],
	["fari na passiata"],
	["fari na scampagnata"],
	["fari nutari"],
	["fari obbiezzioni"],
	["fari pagari"],
	["fari premura"],
	["fari priggiuneri"],
	["fari ricerchi"],
	["fari risposta"],
	["fari sapiri"],
	["fari sculari"],
	["fari taciri"],
	["fari tortu"],
	["fari u bagnu"],
	["fari u buffuni"],
	["fari u cruscè"],
	["fari un votu"],				     
	["fari u_SQUOTE_vai e veni"],
	["fari vela"],
	["fari veniri"],
	["fari ventu"],
	);
    
    ##  COLL_timerel
    @{ $othash{"COLL_timerel"} } = ( 
	["SCEN"],
	["oi","oj","òggi","stirnata"],
	["aieri","ajeri"],
	["dumani","rumani"],
	["oggi","oggigiornu"],
	["cutidianu"],
	["antura","avantìeri","dopporumani"],
	["vigghia"],
	["nnumani"],
	["agghiurnari"],
	["arburi","livata","luci du iornu","menziornu","nnoccu","notti"],
	["iornu","a lu iornu","iurnata","iurnata di travagghiu","jurnateri"],
	["festa","festa civili (ital)","iornu di festa"],
	["onomasticu"],
	["vacanza"],
	["simana","simanali","a la simana","fini da simana","fini di simana"],
	["misi","mensili","misaloru"],
	["annu","annuu","annata"], 
	["annaloru"],
	["bisesta"],
	["ovannu","avannu","avannu passatu","oggellannu","notrannu"],
	["cinquant'anni"],
	);
    
    ##  COLL_daysweek
    @{ $othash{"COLL_daysweek"} } = ( 
	["SCEN"],
	["luneddì","luniddì","luniddìa","lunidì","lùniri"],
	["marteddì","martiddì","martiddìa","màrtidi","màrtiri"],
	["mercoldì","mercoleddì","mercuccì","mercuddì","mercuddìa","merculiddì","merculiddìa","mèrcuri","mìerculi"],
	["gioveddì","giuviddì","giuviddìa","ioviddì","iuviddì","iuviddìa","iòviri","jòvidi","jòviri"],
	["vennadi","venneddì","vinniddì","vinniddìa","vènnari","vìenniri"],
	["sabbatu","sabbatuddì","sabbatuddìa"],
	["dumìnica","dumìnicaddi","dumìnicaddia"],
	);

    ##  COLL_months
    @{ $othash{"COLL_months"} } = ( 
	["SCEN"],
	["Jinnaru","ginnaiu","jinnaru"],
	["fibraiu","frivaru"],
	["marzu"],
	["aprili"],
	["maggiu","maju","majulinu"],
	["giugnu"],
	["giugnettu","lugliu"],
	["agustu","austu"],
	["settembri","settìmeri"],
	["ottubbri"],
	["novembri","novemmiru","nuvìemri"],
	["decembri"],
	);
    
    ##  COLL_holidays
    @{ $othash{"COLL_holidays"} } = ( 
	["SCEN"],
	["compleannu"],
	["natali"],["capudannu"],
	["carnilivari"],
	["sdirri","sdirrisira"],
	["marteddì grassu"],
	["pasqua"],
	["pentecosti"],
	["u primu maggiu"],
	["nespola di màiu"],
	);

    ##  COLL_seasons
    @{ $othash{"COLL_seasons"} } = ( 
	["SCEN"],
	["autunnu"],
	["invernu","invirnata"],
	["primavera"],
	["estati","estivu"],
	["ura estiva"],
	["menza estati","agustinu"],
	["sta","staggiuni","stagghiuni"],
	["statizzari"],
	["stati","statia"],
	## ["colonia di vacanze (ital)"],
	);
    
    ## COLL_places
    @{ $othash{"COLL_italy"} } = (
	["SCEN"],
	["Italia",],
	["Sicilia","Calabbria","Pugghia",],
	["Sardigna","Lucania","Campania","Abbruzzu","Mulisi",
	 "Lazziu","Umbria","Marchi","Tuscana","Emilia","Rumagna","Liguria",
	 "Friuli","Venezzia Giulia","Vènitu","Trentinu","Autu Adici","Suttu Tirolu",
	 "Vaddi d'Aosta","Lummardìa","Piemunti",], 	
	["Casteddammari","Tràpani","Castedduvitranu","Palermu","Carini","Partinicu",
	 "Missina","Patti","Girgenti","Nissa","Enna","Catania","Cartagiruni","Rausa","Sarausa",],
	["Pizzu","Vibbu Valenzia","Riggiu Calabbria","Cutroni","Cusenza","Catanzaru",],
	["Lecci","Barletta","Andria","Trani","Foggia","Tàrantu","Brìndisi","Bari",],
	["Càgliari","Putenza","Nàpuli","L'Aquila","Campubbassu",
	 "Roma","Perugia","Ancona","Firenzi","Bulogna","Gènuva",
	 "Vinezzia","Triesti","Trentu","Buzzanu",
	 "Aosta","Milanu","Turinu",], 
	);
    
    ## COLL_places
    @{ $othash{"COLL_places"} } = ( 
	["SCEN"],
	["munnu",],
	["Arabbia Saudita","Australia","Austria","Belgiu","Bolivia","Brasili","Bulgaria",
	 "Cecoslovacchia","Cile","Cina","Colombia","Cuba","Danimarca","Ecuaturi","Egittu",
	 "Li Filipini","Francia","Galles","Girmania","Gran Britagna","Grecia","India",
	 "Indonisia","Inghilterra","Iran","Iraq","Irlanda","Islanda","Israeli","Italia",
	 "Iugoslavia","Marocco","Messicu","Nepal","Nicaragua","Nigeria","Norveggia",
	 "Nova Zilanna","Olanda","Pakistan","Persia","Perù","Polonia","Portugallu",
	 "Regnu Unitu","Rumanìa","Russia","Sardegna","Scandinavia","Scozzia","Siria","Spagna",
	 "Stati Uniti","Sud Àfrica","Svezzia","Svizzira","Ungheria","Unioni suvietica","Uruguai",],
	["Ceca","Cilenu","Cinisi","Danesi","Egizianu","Indianu","Indonisianu","Inglisi","Irachenu",
	 "Iranianu","Irlandesi","Islandisi","Israelanu","Missicanu","Olandisi","Pakistanu",
	 "Scandinavu","Scuzzisi","Tedescu","Ungheresi",],
	["Atlanticu","Europa","Sud America",],
    );

    return %othash ;
}

##  people
##  ["Cristu","Franciscu","Salamuni","Sammartinu","Omèru","Pirinnellu","Umèru",],
##   
##  random
##  ["Imprisa","Re Filippu",],

1;
