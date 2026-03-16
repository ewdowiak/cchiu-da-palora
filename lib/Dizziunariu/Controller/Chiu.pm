package Dizziunariu::Controller::Chiu;

##  annotates the Dieli dictionary
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
#    ## $Storable::Deparse = 1;  
    $Storable::Eval    = 1;  
#}

use URI::Escape;

use Napizia::TextTools;
use Napizia::PosTools;
use Napizia::HtmlChiu;
use Napizia::HtmlDieli;
use Napizia::HtmlTraina;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  navigation panels
my $topnav_html = '/home/eryk/website/dizziunariu/public/config/eryk2-topnav.html';
my $navbar_html = '/home/eryk/website/dizziunariu/public/config/eryk2-navbar.html';

##  scalars to adjust length of columns (for appearances)
my $adjustone =  -30 ;
my $adjusttwo =  -70 ;
my $adjusttre =    0 ;

##  retrieve hashes and subroutines
my $vthash  = retrieve('/home/eryk/website/dizziunariu/lib/stor/verb-tools' );
my $vbconj  = $vthash->{vbconj};
my $nounpls = $vthash->{nounpls};

my $vnhash = retrieve('/home/eryk/website/dizziunariu/lib/stor/vocab-notes-plus' );
my %vnotes = %{ $vnhash };

##  retrieve Traina dictionary and tools
my $ttline = retrieve('/home/eryk/website/dizziunariu/lib/stor/traina_line-to-traina' );
my %lt_hash = %{ $ttline };

my $tthead = retrieve('/home/eryk/website/dizziunariu/lib/stor/traina_hdword-to-line' );
my %hl_hash = %{ $tthead };

my $ttspan = retrieve('/home/eryk/website/dizziunariu/lib/stor/traina_span-to-hdword' );
my %sh_hash = %{ $ttspan };

my $ttlist = retrieve('/home/eryk/website/dizziunariu/lib/stor/traina-list' );
my @ttarry = @{ ${ $ttlist->{ttarry} }{old_chiu_arry} };

##  smaller (older) list
my %vnotes_sml;
foreach my $small (@ttarry) {
    $vnotes_sml{$small} = $vnotes{$small};
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  WELCOME
##  =======

sub welcome ($self) {

    my $par_palora = $self->param('palora') || '';
    my $par_langs  = $self->param('langs')  || '';
    my $par_traina = $self->param('traina') || '';

    $par_palora = ( $par_palora eq '') ? undef : $par_palora ;
    $par_langs  = ( $par_langs  eq '') ? undef : $par_langs  ;
    $par_traina = ( $par_traina eq '') ? undef : $par_traina ;

    my $otpage = mk_htmlpage( $par_palora , $par_langs , $par_traina );
    $self->render( htmlpage => $otpage );
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub mk_htmlpage{ 

    ##  in arguments
    my $par_palora = $_[0];
    my $par_langs  = $_[1];
    my $par_traina = $_[2];

    ##  what are we looking for?
    my $inword = $par_palora;
    if ( ! defined $inword ) {
	my $blah = "leave it undefined";
    } elsif ( ! defined $vnotes{ $inword } ) {
	## try to fix it
	$inword = fixurl($inword);
    }

    ##  set the language pair
    my $lgparm = ( ! defined $par_langs  ) ? "SCEN" : $par_langs  ;
    
    ##  search for Traina internal links
    my @traina;
    if ( ! defined $par_traina ) {
	my $blah = "do nothing";
    } else {
	my $tsearch = $par_traina;
	$tsearch =~ s/-n[0-9]+$//;
	$tsearch =~ s/-eryk$//;
	
	if ( $tsearch eq "" || ! defined $sh_hash{$tsearch} ) {
	    my $blah = "do nothing";
	    
	} else {
	    my @thdwrds_orig = @{ $sh_hash{$tsearch} };
	    my @thdwrds;
	    foreach my $thdwrd_orig (@thdwrds_orig) {
		my $thdwrd_lc = scn_lowercase_trim( rid_accents( $thdwrd_orig ));
		push( @thdwrds , scn_lowercase_trim( $thdwrd_lc ));
	    }
	    
	    foreach my $thdwrd (@thdwrds) {
		if ( ! defined $vnotes{$thdwrd} ) {
		    my $blah = "do nothing";
		} else {
		    push( @traina , $thdwrd );
		}
	    }
	    foreach my $thdwrd (@thdwrds) {
		foreach my $suffix ("_tdonly","_noun","_adj","_adv","_prep","_pron") {
		    my $thdwrd_suffix = $thdwrd . $suffix;
		    
		    if ( ! defined $vnotes{$thdwrd_suffix} ) {
			my $blah = "do nothing";
		    } else {
			push( @traina , $thdwrd_suffix );
		    }
		}
	    }
	}
    }
    
    ##  if inword not defined, then try to pass first match
    if ( ! defined $vnotes{ $inword } && $#traina > -1 ){
	$inword = $traina[0];
    }
    
    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

    ##  scalar to store HTML page
    my $htmlpage;
    
    ##  make webpage; if input word not defined, cannot conjugate/decline, so show all
    if ( ! defined $inword || ! defined $vnotes{ $inword } ) {
	## make top
	$htmlpage .= mk_cctophtml($topnav_html , "" , \%vnotes , $vbconj );
	$htmlpage .= mk_newform( $lgparm );
	
	## show all
	$htmlpage .= mk_showall(  \%vnotes_sml , $vbconj , $adjustone , $adjusttwo , $adjusttre );
	
    } else { 
	## make top
	$htmlpage .= mk_cctophtml($topnav_html , $inword , \%vnotes , $vbconj );
	$htmlpage .= mk_newform( $lgparm );
	
	##  print translations and notes
	$htmlpage .= mk_dielitrans( $inword , $lgparm , \%vnotes , $vbconj );
	$htmlpage .= mk_notex( $inword , \%vnotes );
	
	##  are we working with a verb, noun or adjective?
	my $isverb = ( ! defined $vnotes{ $inword }{verb}     && 
		       ! defined $vnotes{ $inword }{reflex}   && 
		       ! defined $vnotes{ $inword }{prepend}            ) ? "false" : "true" ;
	my $isnoun = ( ! defined $vnotes{ $inword }{noun}               ) ? "false" : "true" ;
	my $isadj  = ( $vnotes{ $inword }{part_speech} ne "adj" ) ? "false" : "true" ;
	
	##  "other" parts of speech currently include:  {adv} {prep} {pron}
	my $isother  = ( ! defined $vnotes{ $inword }{part_speech} ) ? "false" : "true" ;
	
	if ( $isverb eq "true" ) {
	    $htmlpage .= mk_conjhtml( $inword , $lgparm , \%vnotes , $vbconj );
	    # ask_help( $inword , \%vnotes );
	    
	} elsif ( $isnoun eq "true" ) {
	    $htmlpage .= mk_nounhtml( $inword , $lgparm , \%vnotes , $nounpls );
	    # ask_help( $inword , \%vnotes );
	    
	} elsif ( $isadj  eq "true" ) {
	    $htmlpage .= mk_adjhtml( $inword , $lgparm , \%vnotes );
	    # ask_help( $inword , \%vnotes );
	    
	} elsif ( $isother  eq "true" ) {
	    ##  other, so only ask for help 
	    # ask_help( $inword , \%vnotes );
	    my $blah = "do nothing";
	    
	} else {
	    # ##  outer DIV to limit width
	    # my $othtml ; 
	    # $othtml .= '<div class="transconj">' . "\n" ; 
	    # $othtml .= '<div class="row">' . "\n" ; 
	    # $othtml .= '<p>'."nun c'è n'".' annotazzioni dâ palora: &nbsp; <b>'. $inword .'</b></p>'."\n";
	    # $othtml .= '</div>'."\n"; 
	    # $othtml .= '</div>'."\n"; 

	    ## $htmlpage .= mk_showall(  \%vnotes_sml , $vbconj , $adjustone , $adjusttwo , $adjusttre );
	    
	    my $blah = "do nothing";
	}
	
	##  print Traina definitions (if available)
	if ( ! defined $vnotes{$inword}{traina} ) {
	    my $blah = "do nothing";
	} else {
	    $htmlpage .= '<hr style="max-width: 400px;">'."\n";
	    
	    $htmlpage .= '<h3>Traina (1868)</h3>'."\n";
	    
	    $htmlpage .= print_traina( $inword , $vnotes{$inword}{traina} , $ttline );
	    
	    
	    $htmlpage .= '<p style="margin: 0.20em auto; text-align: center;">';
	    $htmlpage .= '<small>La vuci di Traina veni dû '."\n";
	    $htmlpage .= '<a href="https://it.wikisource.org/wiki/Nuovo_vocabolario_siciliano-italiano">';
	    $htmlpage .= 'Wikisource Talianu</a> '."\n";
	    $htmlpage .= 'e veni pubblicata sutta la licenza '."\n";
	    ## $htmlpage .= '<a href="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons '."\n";
	    ## $htmlpage .= 'Attribuzioni-SpartiÔStissuModu 4.0 Internaziunali</a>.</small></p>'."\n";
	    $htmlpage .= '<a href="https://creativecommons.org/licenses/by-sa/4.0/">'."\n";
	    $htmlpage .= 'CC BY-SA&nbsp;4.0</a>.</small></p>'."\n";
	}
	
    }
    
    ##  print list of collections
    $htmlpage .= mk_ricota();
    
    ##  print the social media shares
    my $text_url   = 'https://dizziunariu.napizia.com/chiu/';
    my $text_title;
    if ( ! defined $inword || ! defined $vnotes{ $inword } ) {
	my $blah  = 'do nothing';
    } else { 
	$text_url   .= '?palora='. $inword ;
	$text_title = fetch_pagetitle($inword);
    }
    $text_title  .= 'Chiù dâ Palora :: Napizia';
    my $url   = uri_escape($text_url);
    my $title = uri_escape($text_title);
    $htmlpage .= mk_share( $url , $title );
    
    ##  print footer
    $htmlpage .= mk_foothtml($navbar_html);


    ##  return the HTML page
    return $htmlpage;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  SUBROUTINES
##  ===========

##  subroutine to fetch page title for social media shares
sub fetch_pagetitle {

    my $palora = $_[0];

    ##  holder for display and part of speech
    my $display ;
    my $part_speech = ""; 
    
    ##  which word do we display?
    if ( ! defined $palora || $palora eq "" ) {
	$display = "";
    } else {

	##  which word do we display?
	my %othash ;
	
	##  are we working with a verb?
	my $isverb = ( ! defined $vnotes{ $palora }{verb}     && 
		       ! defined $vnotes{ $palora }{reflex}   && 
		       ! defined $vnotes{ $palora }{prepend}  ) ? "false" : "true" ;
	if ( $isverb eq "true" ) {
	    %othash = conjugate( $palora , \%vnotes , $vbconj ) ; 
	}
	
	##  which word do we display?	
	$display = ( ! defined $othash{inf} ) ? $palora : $othash{inf} ;

	##  strip part of speech identifier
	$display =~ s/_[a-z]*$//;

	##  check for a "display_as"
	$display = ( ! defined $vnotes{$palora}{display_as} ) ? $display : $vnotes{$palora}{display_as};

	##  parti di discursu 
	$part_speech = ( ! defined $vnotes{ $palora }{part_speech} ) ? "" : $vnotes{ $palora }{part_speech};

	##  translate to Sicilian
	$part_speech =~ s/^verb$/verbu/ ;
	$part_speech =~ s/^noun$/sust/ ;
	$part_speech =~ s/^adj$/agg/   ;
	$part_speech =~ s/^adv$/avv/   ;
	$part_speech =~ s/^prep$/prip/ ;
	$part_speech =~ s/^pron$/prun/ ;
	$part_speech =~ s/^conj$/cunj/ ;
    }

    ##  format it a little
    my $part_fmt = ( $part_speech ne "" ) ? '(' . $part_speech . ')' : "";
    my $title_fmt   = ( $display ne "" ) ? $display . ' ' . $part_fmt . ' :: ' : "";

    ##  do NOT append either an ending or the title
    #$title_fmt  .= 'Chiù dâ Palora :: Napizia';
    
    ##  return the formatted title
    return $title_fmt;
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

1;
