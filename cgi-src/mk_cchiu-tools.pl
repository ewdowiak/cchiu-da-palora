#!/usr/bin/env perl

##  "mk_cchiu-tools.pl" -- makes tools for web interface to cchiu-da-palora
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

use strict;
use warnings;
no warnings qw( uninitialized );
use Storable qw( nstore ) ;
{   no warnings;             
    $Storable::Deparse = 1;  
    ## $Storable::Eval    = 1;  
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

my $otfile = '../cgi-lib/cchiu-tools' ; 

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  SUBROUTINES  for  CCHIU-DA-PALORA
##  ===========  ===  ===============

sub ask_help {

    ##  pass in the hash key and vocabulary notes
    my $palora  =   $_[0];
    my %vnotes  = %{$_[1]};

    ##  strip part of speech identifier
    my $strip = $palora;
    $strip =~ s/_[a-z]*$//;

    ##  what is the display?
    my $display = ( ! defined $vnotes{$palora}{display_as} ) ? $strip : $vnotes{$palora}{display_as} ; 
    
    ##  prepare request text
    my $request = '<i>Mi dici cchiù dâ palora:</i> '. $display .'<i>? Clicca ccà!</i>';

    ##  prepare output
    my $ot;
    
    ##  DIV to limit width
    $ot .= '<div class="transconj">' . "\n" ;
    $ot .= '<p style="margin-bottom: 0.5em;"><a href="/cgi-bin/aiutami.pl?palora='. $palora .'">' ; 
    $ot .= $request . '</a></p>' . "\n" ;
    $ot .= '</div>'."\n";

    ##  ask for help!
    return $ot;
}

sub mk_nounhtml { 
    my $palora  =    $_[0]   ;  ( my $singular = $palora ) =~ s/_noun$// ; 
    my $lgparm  =    $_[1]   ;
    my %vnotes  = %{ $_[2] } ;
    my $nounpls =    $_[3]   ;  ##  hash reference
    my %vbsubs  = %{ $_[4] } ;  

    ##  first choice is "display_as",  second choice is hash key (less noun marker)
    my $display = ( ! defined $vnotes{$palora}{display_as} ) ? $singular : $vnotes{$palora}{display_as} ; 

    ##  prepare output
    my $ot ;

    ##  which word do we redirect to? 
    my $redirect = ( ! defined $vnotes{$palora}{dieli} ) ? $display : join( "_OR_", @{$vnotes{$palora}{dieli}} ) ;
    
    ##  outer DIV to limit width
    $ot .= '<div class="transconj">' . "\n" ;
    $ot .= '<p style="margin-bottom: 0.5em;"><b><a href="/cgi-bin/sicilian.pl?' . 'search=' . $redirect . '&langs=' . $lgparm . '">' ; 
    $ot .= $display . '</a></b></p>' . "\n" ;
    

    ##  $vbsubs{mk_noun_plural}() assumes "mas" or "fem" noun, some nouns are "both"
    ##  such "both" nouns end in "-a" in singular and "-i" in plural
    ##  the sub is written in such a way that it should be able to handle "both"
    my $gender = $vnotes{$palora}{noun}{gender} ; 
    my $plend = $vnotes{$palora}{noun}{plend} ; 

    ##  set up plural as array -- for the plends: "xixa" and "xura"
    ##  leave "@plurals" undefined if no plural
    my @plurals ;
    if ( $plend eq "nopl" ) {
	my $blah = "no plural.";
    } elsif ( $plend eq "ispl" ) {
	##  already plural
	push( @plurals , $display ) ; 

    } elsif ( ! defined $vnotes{$palora}{noun}{plural} && ( $plend eq "xixa" || $plend eq "xura" || $plend eq "eddu" ) ) {
	##  if an irregular plural is not defined AND plend is either "xixa" or "xura"
	push( @plurals , $vbsubs{mk_noun_plural}( $display , $gender , $plend  , $nounpls ) );
	push( @plurals , $vbsubs{mk_noun_plural}( $display , $gender , "xi"  , $nounpls ) );

    } elsif ( ! defined $vnotes{$palora}{noun}{plural} ) {
	##  if an irregular plural is not defined
	push( @plurals , $vbsubs{mk_noun_plural}( $display , $gender , $plend  , $nounpls ) );

    } else {
	##  if an irregular plural is defined
	push( @plurals , $vnotes{$palora}{noun}{plural} );
    }
    
    
    ##  singular forms
    if ( $gender eq "mas" || $gender eq "both" ) {
	my $defart = ( $vbsubs{rid_accents}( $display ) =~ /^[aeiouAEIOU]/ ) ? "l' " : "lu " ; 
	$ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><i>ms.:</i> &nbsp; ' . $defart . $display . "</p>" . "\n";
    }
    if ( $gender eq "fem" || $gender eq "both" ) {
	my $defart = ( $vbsubs{rid_accents}( $display ) =~ /^[aeiouAEIOU]/ ) ? "l' " : "la " ; 
	$ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><i>fs.:</i> &nbsp; &nbsp; ' . $defart . $display . "</p>" . "\n";
    }

    ##  plural form
    if ( $#plurals < 0 ) {
	my $blah = "no plural.";
    } else {
	my $abbrev = 'pl.' ; 
	$abbrev = ( $gender eq "mpl" ) ? "mpl." : $abbrev ;
	$abbrev = ( $gender eq "fpl" ) ? "fpl." : $abbrev ;
	
	$ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><i>'. $abbrev .':</i> &nbsp; &nbsp; ' ;
	
	##  array because of the plends: "xixa" and "xura"
	my @otplurals ;
	foreach my $plural (@plurals) {
	    my $defart = ( $vbsubs{rid_accents}( $plural ) =~ /^[aeiouAEIOU]/ ) ? "l' " : "li " ; 
	    my $otplural = $defart . $plural ; 
	    push( @otplurals , $otplural );
	}
	##  join them together
	$ot .= join( ' &nbsp;<i>o</i>&nbsp; ' , @otplurals ) ; 
	$ot .= '</p>' . "\n";
    }   
    ##  close DIV that limits width
    $ot .= '</div>' . "\n" ; 

    ##  send it out!
    return $ot ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

sub mk_adjhtml { 
    my $palora  =    $_[0]   ;  ( my $singular = $palora ) =~ s/_adj$// ; 
    my $lgparm  =    $_[1]   ;
    my %vnotes  = %{ $_[2] } ;
    my %vbsubs  = %{ $_[3] } ;  

    ##  first choice is "display_as",  second choice is hash key (less adj marker)
    my $display = ( ! defined $vnotes{$palora}{display_as} ) ? $singular : $vnotes{$palora}{display_as} ;	
    
    ##  prepare output
    my $ot ;
    ##  which word do we redirect to? 
    my $redirect = ( ! defined $vnotes{$palora}{dieli} ) ? $display : join( "_OR_", @{$vnotes{$palora}{dieli}} );
    
    ##  if it is not an adjective phrase 
    if ( ! defined $vnotes{$palora}{adj}{phrase} ) {

	##  outer DIV to limit width
	$ot .= '<div class="transconj">' . "\n" ;
	$ot .= '<p style="margin-bottom: 0.5em;"><b><a href="/cgi-bin/sicilian.pl?' ; 
	$ot .= 'search=' . $redirect . '&langs=' . $lgparm . '">' ; 
	$ot .= $display . '</a></b></p>' . "\n" ;

	##  fetch singular and plural forms
	my $massi ; my $femsi ; my $maspl ; my $fempl ;

	##  check to see if adjective is invariant (e.g. "la megghiu cosa") 
	##  or only feminine changes (e.g. "giuvini, giuvina")
	if ( ! defined $vnotes{$palora}{adj}{invariant} && 
	     ! defined $vnotes{$palora}{adj}{femsi} && 
	     ! defined $vnotes{$palora}{adj}{plural} ) {
	    ##  not invariant, regular femsi and regular plural
	    ($massi , $femsi , $maspl , $fempl) = $vbsubs{mk_adjectives}($display) ;
	} elsif ( ! defined $vnotes{$palora}{adj}{plural} ) {
	    ##  either invariant or only fem form changes
	    $massi = $display  ;  
	    $femsi = ( ! defined $vnotes{$palora}{adj}{femsi}  ) ? $display : $vnotes{$palora}{adj}{femsi} ;
	    $maspl = $display ;
	    $fempl = $display ;
	} else {
	    ##  plural is special
	    ($massi , $femsi , $maspl , $fempl) = $vbsubs{mk_adjectives}($display) ;
	    $femsi = ( ! defined $vnotes{$palora}{adj}{femsi}  ) ? $femsi : $vnotes{$palora}{adj}{femsi} ;
	    $maspl = ( ! defined $vnotes{$palora}{adj}{plural} ) ? $maspl : $vnotes{$palora}{adj}{plural};
	    $fempl = ( ! defined $vnotes{$palora}{adj}{plural} ) ? $fempl : $vnotes{$palora}{adj}{plural};
	}
	
	##  make note of masculine singular forms that precedes the noun (if any)
	$massi = ( ! defined $vnotes{$palora}{adj}{massi_precede} ) ? $massi : 
	    $vnotes{$palora}{adj}{massi_precede} . '&nbsp;&#47;&nbsp;' . $massi ;
	
	##  singular and plural forms
	$ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><i>ms.:</i> &nbsp; ' . $massi . "</p>" . "\n";
	$ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><i>fs.:</i> &nbsp; &nbsp; ' . $femsi . "</p>" . "\n";
	if ( $maspl ne $fempl ) {
	    $ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><i>mp.:</i> &nbsp; '        . $maspl . "</p>" . "\n";
	    $ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><i>fp.:</i> &nbsp; &nbsp; ' . $fempl . "</p>" . "\n";
	} else {
	    $ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><i>pl.:</i> &nbsp; &nbsp; ' . $maspl . "</p>" . "\n";
	}	
	
	##  close DIV that limits width
	$ot .= '</div>' . "\n" ; 
    }
    
    return $ot ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

sub mk_conjhtml {
    
    my $palora =    $_[0]   ;
    my $lgparm =    $_[1]   ;
    my %vnotes = %{ $_[2] } ;
    my $vbcref =    $_[3]   ;  ##  hash reference
    my %vbsubs = %{ $_[4] } ;  
    
    my %forms  = $vbsubs{mk_forms}() ; 
    my @tenses = @{ $forms{tenses} } ; 
    my %tnhash = %{ $forms{tnhash} } ; 
    my @people = ( ! defined $vnotes{$palora}{verb}{people} ) ? @{ $forms{people} } : @{ $vnotes{$palora}{verb}{people} };

    ##  conjugate the verb
    my %othash = $vbsubs{conjugate}( $palora , \%vnotes , $vbcref , \%vbsubs ) ; 

    ##  prepare output
    my $ot ;

    ##  which word do we redirect to? 
    my $redirect = ( ! defined $vnotes{$palora}{dieli} ) ? $palora : join( "_OR_", @{$vnotes{$palora}{dieli}} ) ;
    
    ##  which word do we display?
    my $display ;
    $display = ( ! defined $othash{inf} ) ? $palora : $othash{inf} ;
    $display = ( ! defined $vnotes{$palora}{display_as} ) ? $display : $vnotes{$palora}{display_as} ;
    
    ##  outer DIV to limit width
    $ot .= '<div class="transconj">' . "\n" ;
    $ot .= '<p><b><a href="/cgi-bin/sicilian.pl?' . 'search=' . $redirect . '&langs=' . $lgparm . '">' ; 
    $ot .= $display . '</a></b></p>' . "\n" ;
    
    ##  PRI -- present indicative 
    $ot .= '<div class="row">' . "\n" ; 
    $ot .= '<p style="margin-bottom: 0.5em"><u>' . $tnhash{pri} . '</u></p>' . "\n" ;
    $ot .= '<div class="col-m-6 col-6">' . "\n" ;
    foreach my $person (@people[0..2]) {
	$ot .= '<p class="zero">' ;
	$ot .= $othash{pri}{$person} ; 
	$ot .= '</p>' . "\n" ;
    }
	    $ot .= '</div>' . "\n" ; 
    $ot .= '<div class="col-m-6 col-6">' . "\n" ;
    foreach my $person (@people[3..5]) {
	$ot .= '<p class="zero">' ;
	$ot .= $othash{pri}{$person} ; 
	$ot .= '</p>' . "\n" ; 
    }
    $ot .= '</div>' . "\n" ; 	
    $ot .= '</div>' . "\n" ; 

    
    ##  PIM -- present imperative

    ##  which persons should we list?
    my $us_print = grep {/^us$/} @people ;
    my $ds_print = grep {/^ds$/} @people ;
    my $ts_print = grep {/^ts$/} @people ;
    my $up_print = grep {/^up$/} @people ;
    my $dp_print = grep {/^dp$/} @people ;
    my $tp_print = grep {/^tp$/} @people ;

    $ot .= '<div class="row">' . "\n" ; 
    $ot .= '<p style="margin-bottom: 0.5em"><u>' . $tnhash{pim} . '</u></p>' . "\n" ;
    $ot .= '<div class="col-m-6 col-6">' . "\n" ;
    
    if ( $us_print > 0 ) { $ot .= '<p class="zero">' . '--' . '</p>' . "\n" ; }
    if ( $ds_print > 0 ) { $ot .= '<p class="zero">' . $othash{pim}{"ds"} . '</p>' . "\n" ; }
    if ( $ts_print > 0 ) { $ot .= '<p class="zero">' . $othash{pim}{"ts"} . '</p>' . "\n" ; } 
        
    $ot .= '</div>' . "\n" ; 
    $ot .= '<div class="col-m-6 col-6">' . "\n" ;

    if ( $up_print > 0 ) { $ot .= '<p class="zero">' . $othash{pim}{"up"} . '</p>' . "\n" ; }
    if ( $dp_print > 0 ) { $ot .= '<p class="zero">' . $othash{pim}{"dp"} . '</p>' . "\n" ; }
    if ( $tp_print > 0 ) { $ot .= '<p class="zero">' . '--' . '</p>' . "\n" ; }

    $ot .= '</div>' . "\n" ; 	
    $ot .= '</div>' . "\n" ; 
    
    ##  PAI -- past ind. (preterite) 
    ##  IMI -- imperfect ind.
    ##  IMS -- imperfect subjunctive
    foreach my $tense ("pai","imi","ims") {
	$ot .= '<div class="row">' . "\n" ; 
	$ot .= '<p style="margin-bottom: 0.5em"><u>' . $tnhash{$tense} . '</u></p>' . "\n" ;
	$ot .= '<div class="col-m-6 col-6">' . "\n" ;
	foreach my $person (@people[0..2]) {
	    $ot .= '<p class="zero">' ;
	    $ot .= $othash{$tense}{$person} ; 
	    $ot .= '</p>' . "\n" ;
	}
	$ot .= '</div>' . "\n" ; 
	$ot .= '<div class="col-m-6 col-6">' . "\n" ;
	foreach my $person (@people[3..5]) {
	    $ot .= '<p class="zero">' ;
	    $ot .= $othash{$tense}{$person} ; 
	    $ot .= '</p>' . "\n" ; 
	}
	$ot .= '</div>' . "\n" ; 	
	$ot .= '</div>' . "\n" ; 
    }
    

    ##  FTI -- future indicative
    ##  COI -- conditional indicative
    #$ot .= '<p><small><i><a href="#fticoi">mustra li àutri tempi</a></i></small></p>' . "\n" ; 
    #$ot .= '<div id="fticoi">' . "\n" ; 
    foreach my $tense ("fti","coi") {
	$ot .= '<div class="row">' . "\n" ; 
	$ot .= '<p style="margin-bottom: 0.5em"><u>' . $tnhash{$tense} . '</u></p>' . "\n" ;
	$ot .= '<div class="col-m-6 col-6">' . "\n" ;
	foreach my $person (@people[0..2]) {
	    $ot .= '<p class="zero">' ;
	    $ot .= $othash{$tense}{$person} ; 
	    $ot .= '</p>' . "\n" ;
	}
	$ot .= '</div>' . "\n" ; 
	$ot .= '<div class="col-m-6 col-6">' . "\n" ;
	foreach my $person (@people[3..5]) {
	    $ot .= '<p class="zero">' ;
	    $ot .= $othash{$tense}{$person} ; 
	    $ot .= '</p>' . "\n" ; 
	}
	$ot .= '</div>' . "\n" ; 	
	$ot .= '</div>' . "\n" ; 
    }
    #$ot .= '<p><small><i><a href="#closeme">ammucciali</a></i></small></p>' . "\n" ; 
    #$ot .= '</div>' . "\n" ; 
    
    ##  GER -- gerund
    ##  PAP -- past participle
    $ot .= '<div class="row">' . "\n" ; 
    $ot .= '<div class="col-m-6 col-6">' . "\n" ;
    $ot .= '<p style="margin-bottom: 0.5em"><u>' . $tnhash{ger} . '</u></p>' . "\n" ;
    $ot .= '<p class="zero">' ;
    $ot .= $othash{ger} ; 
    $ot .= '</p>' . "\n" ;
    $ot .= '</div>' . "\n" ; 
    $ot .= '<div class="col-m-6 col-6">' . "\n" ;
    $ot .= '<p style="margin-bottom: 0.5em"><u>' . $tnhash{pap} . '</u></p>' . "\n" ;
    $ot .= '<p class="zero">' ;
    $ot .= ( ! defined $vnotes{$palora}{reflex} ) ? "aviri" : "avirisi" ;
    $ot .= " " . $othash{pap} ; 
    $ot .= '</p>' . "\n" ; 
    $ot .= '<p class="zero">' ;
    $ot .= '<i>agg.:</i>  &nbsp; ' . $othash{adj} ; 
    $ot .= '</p>' . "\n" ; 
    $ot .= '</div>' . "\n" ; 	
    $ot .= '</div>' . "\n" ; 

    ##  close DIV that limits width
    $ot .= '</div>' . "\n" ; 
    return $ot ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

sub mk_dielitrans {

    my $palora =    $_[0]   ;
    my $lgparm =    $_[1]   ;
    my %vnotes = %{ $_[2] } ;
    my $vbcref =    $_[3]   ;  ##  hash reference
    my %vbsubs = %{ $_[4] } ;  
    
    ##  prepare output
    my $ot ;    
    my %othash ;

    ##  are we working with a verb?
    my $isverb = ( ! defined $vnotes{ $palora }{verb}     && 
		   ! defined $vnotes{ $palora }{reflex}   && 
		   ! defined $vnotes{ $palora }{prepend}  ) ? "false" : "true" ;
    if ( $isverb eq "true" ) {
	%othash = $vbsubs{conjugate}( $palora , \%vnotes , $vbcref , \%vbsubs ) ; 
    }
    
    ##  which word do we display?
    my $display ;
    $display = ( ! defined $othash{inf} ) ? $palora : $othash{inf} ;
    $display = ( ! defined $vnotes{$palora}{display_as} ) ? $display : $vnotes{$palora}{display_as} ;
    
    ##  which word do we redirect to? 
    my $redirect = ( ! defined $vnotes{$palora}{dieli} ) ? $display : join( "_OR_", @{$vnotes{$palora}{dieli}} ) ;
    
    ##  outer DIV to limit width
    $ot .= '<div class="transconj">' . "\n" ; 
    $ot .= '<p><b><a href="/cgi-bin/sicilian.pl?' . 'search=' . $redirect . '&langs=' . $lgparm . '">' ; 
    $ot .= $display . '</a></b>' ;

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
    
    $ot .= '&nbsp;&nbsp;{' . $part_speech . '}</p>' . "\n" ;
    
    $ot .= '<div class="row">' . "\n" ; 

    ##  what variants of the word did Dr. Dieli identify?
    ##  what does the word translate to?
    my @dieli_sc_links  ; 
    my @dieli_en_links  ; 
    my @dieli_it_links  ; 
    foreach my $trans (@{$vnotes{$palora}{dieli}}) {
	push( @dieli_sc_links , '<a href="/cgi-bin/sicilian.pl?search=' . $trans . '&langs='. $lgparm .'">' . $trans . '</a>' );
    } 
    foreach my $trans (@{$vnotes{$palora}{dieli_en}}) {
	push( @dieli_en_links , '<a href="/cgi-bin/sicilian.pl?search=' . $trans . '&langs=ENSC">' . $trans . '</a>' );
    } 
    foreach my $trans (@{$vnotes{$palora}{dieli_it}}) {
	push( @dieli_it_links , '<a href="/cgi-bin/sicilian.pl?search=' . $trans . '&langs=ITSC">' . $trans . '</a>' );
    } 
    my $dieli_sc_str = join( ', ' , @dieli_sc_links ); 
    my $dieli_en_str = join( ', ' , @dieli_en_links ); 
    my $dieli_it_str = join( ', ' , @dieli_it_links ); 
    
    ##  only show Sicilian list if more than one
    if ( $#dieli_sc_links > 0 ) {
	$ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><b>SC:</b> &nbsp; ' . $dieli_sc_str . '</p>' . "\n" ;
    }
    ##  always show English list
    $ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><b>EN:</b> &nbsp; ' . $dieli_en_str . '</p>' . "\n" ; 
    #
    ##  only show Italian list if more than zero
    if ( $#dieli_it_links > -1 ) {
	$ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><b>IT:</b> &nbsp; ' . $dieli_it_str . '</p>' . "\n" ; 
    }
    
    $ot .= '</div>' . "\n" ;
    $ot .= '</div>' . "\n" ;

    return $ot ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

sub mk_notex {

    my $palora =    $_[0]   ;
    my %vnotes = %{ $_[1] } ;
    my %ccsubs = %{ $_[2] } ;
    
    my $othtml ;
    
    if ( ! defined $vnotes{$palora}{poetry} ) {
	my $blah = "nothing to do here." ;
    } else {
	my $typeof = 'puisìa:';
	my @poetry  = @{ $vnotes{$palora}{poetry} };
	$othtml .= $ccsubs{mk_notex_list}( $typeof , \@poetry ) ; 
    }
    
    if ( ! defined $vnotes{$palora}{proverb} ) {
	my $blah = "nothing to do here." ;
    } else {
	my @proverbs  = @{ $vnotes{$palora}{proverb} };	
	my $typeof = ($#proverbs > 0) ? 'pruverbi:' : 'pruverbiu:' ;
	$othtml .= $ccsubs{mk_notex_list}( $typeof , \@proverbs ) ; 
    }

    if ( ! defined $vnotes{$palora}{usage} ) {
	my $blah = "nothing to do here." ;
    } else {
	my $typeof = 'usu dâ palora:';
	my @usage  = @{ $vnotes{$palora}{usage} };
	$othtml .= $ccsubs{mk_notex_list}( $typeof , \@usage ) ; 
    }

    if ( ! defined $vnotes{$palora}{notex} ) {
	my $blah = "nothing to do here." ;
    } else {
	my $typeof = 'pi esempiu:';
	my @notex  = @{ $vnotes{$palora}{notex} };
	$othtml .= $ccsubs{mk_notex_list}( $typeof , \@notex ) ; 
    }
    
    return $othtml ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

sub mk_notex_list {

    my $typeof =     $_[0] ;
    my @inarray = @{ $_[1] } ;

    my $othtml ;

    $othtml .= '<div class="transconj">' ."\n"; 
    $othtml .= '<p style="margin-bottom: 0.25em;"><i>' . $typeof . '</i></p>' ."\n";
    $othtml .= '<ul style="margin-top: 0.25em;">' ."\n";
    foreach my $line (@inarray) {
	##  omit names of dictionary sources
	$line =~ s/\(Nicotra\)//g;
	$line =~ s/\(Mortillaro\)//g;
	$line =~ s/\(Mortillaro, Nicotra\)//g;

	##  make poet names one size smaller
	#$line =~ s/\(V. Conigliaro\)/<small>\(V. Conigliaro\)<\/small>/g;
	#$line =~ s/\(Buttitta\)/<small>\(Buttitta\)<\/small>/g;

	##  clean up dashes
	$line =~ s/\-\-/\&ndash;/g;
	    
	##  append the line
	$othtml .= "<li>" . $line . "</li>" ."\n";
    }
    $othtml .= "</ul>" ."\n";
    $othtml .= "</div>" ."\n";
    
    return $othtml ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

sub mk_showall {

    my %vnotes = %{ $_[0] } ;
    my $vbcref =    $_[1]   ;  ##  hash reference
    my %vbsubs = %{ $_[2] } ;  
    my %ccsubs = %{ $_[3] } ;  
    
    ##  scalars to adjust length of columns (for appearances)
    my $adjustone =  $_[4] ;
    my $adjusttwo =  $_[5] ;
    my $adjusttre =  $_[6] ;
    
    ##  let's split the print over four columns
    ##  keep words together by first letter
    my @vnkeys = sort( {lc($vbsubs{rid_accents}($a)) cmp lc($vbsubs{rid_accents}($b))} keys(%vnotes) );
    my $vnkqtr = int( $#vnkeys / 4 ) ; 
        
    ##  first column
    my $vnstart = 0 ; 
    my $vnkidx = $vnkqtr + $adjustone ; 
    my @vnkone = @vnkeys[$vnstart..$vnkidx] ; 
    foreach my $palora (@vnkeys[$vnkidx+1..$#vnkeys] ) {
	##  if same letter, add to column and increment the index
	my $newletter = lc(substr($vbsubs{rid_accents}($palora),0,1)) ; 
	my $oldletter = lc(substr($vbsubs{rid_accents}($vnkeys[$vnkidx]),0,1)) ;
	if ( $newletter eq $oldletter ) { 
	    push( @vnkone , $palora ) ;
	    $vnkidx += 1 ; 
	}
    }

    ##  second column
    $vnstart = $vnkidx+1 ; 
    $vnkidx += $vnkqtr + $adjusttwo ; 
    my @vnktwo = @vnkeys[$vnstart..$vnkidx] ; 
    foreach my $palora (@vnkeys[$vnkidx+1..$#vnkeys] ) {
	##  if same letter, add to column and increment the index
	my $newletter = lc(substr($vbsubs{rid_accents}($palora),0,1)) ; 
	my $oldletter = lc(substr($vbsubs{rid_accents}($vnkeys[$vnkidx]),0,1)) ;
	if ( $newletter eq $oldletter ) { 
	    push( @vnktwo , $palora ) ;
	    $vnkidx += 1 ; 
	}
    }

    ##  third column
    $vnstart = $vnkidx+1 ; 
    $vnkidx += $vnkqtr + $adjusttre ; 
    my @vnktre = @vnkeys[$vnstart..$vnkidx] ; 
    foreach my $palora (@vnkeys[$vnkidx+1..$#vnkeys] ) {
	##  if same letter, add to column and increment the index
	my $newletter = lc(substr($vbsubs{rid_accents}($palora),0,1)) ; 
	my $oldletter = lc(substr($vbsubs{rid_accents}($vnkeys[$vnkidx]),0,1)) ;
	if ( $newletter eq $oldletter ) { 
	    push( @vnktre , $palora ) ;
	    $vnkidx += 1 ; 
	}
    }

    ##  fourth column
    $vnstart = $vnkidx+1 ; 
    my @vnkqtt = @vnkeys[$vnstart..$#vnkeys] ; 
      

    ##  open the div
    my $othtml ;
    $othtml .= '<div class="listall">' . "\n" ; 
    $othtml .= '<div class="row">' . "\n" ; 

    ##  now print
    $othtml .= '<div class="rolltb">' . "\n" ; 
    $othtml .= '<div class="rolldk">' . "\n" ; 
    $othtml .= $ccsubs{mk_vnkcontent}( \@vnkone , \%vnotes , $vbcref , \%vbsubs );
    $othtml .= '</div>' . "\n" ;
    $othtml .= '<div class="rolldk">' . "\n" ; 
    $othtml .= $ccsubs{mk_vnkcontent}( \@vnktwo , \%vnotes , $vbcref , \%vbsubs );
    $othtml .= '</div>' . "\n" ;
    $othtml .= '</div>' . "\n" ;
    

    $othtml .= '<div class="rolltb">' . "\n" ; 
    $othtml .= '<div class="rolldk">' . "\n" ; 
    $othtml .= $ccsubs{mk_vnkcontent}( \@vnktre , \%vnotes , $vbcref , \%vbsubs );
    $othtml .= '</div>' . "\n" ;
    $othtml .= '<div class="rolldk">' . "\n" ; 
    $othtml .= $ccsubs{mk_vnkcontent}( \@vnkqtt , \%vnotes , $vbcref , \%vbsubs );
    $othtml .= '</div>' . "\n" ;
    $othtml .= '</div>' . "\n" ;

    ##  close the div
    $othtml .= '</div>' . "\n" ; 
    $othtml .= '</div>' . "\n" ; 

    return $othtml ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

sub mk_vnkcontent {

    my $vnkarf =    $_[0]   ;
    my %vnotes = %{ $_[1] } ;
    my $vbcref =    $_[2]   ;  ##  hash reference
    my %vbsubs = %{ $_[3] } ;  
    
    my $hold_letter = "" ; 
    my $othtml ;
    
    foreach my $palora (@{$vnkarf}) {
	##  which word do we display?
	##  get the infinitive
	
	if ( ! defined $vnotes{$palora}{hide} ) {
	    ##  if not hiding a (theoretical) non-reflexive form 
	    
	    ##  print initial letter if necessary
	    my $initial_letter = lc(substr($vbsubs{rid_accents}($palora),0,1)) ; 
	    if ( $initial_letter ne $hold_letter ) {
		$hold_letter = $initial_letter ; 
		$othtml .= '<p style="margin-left: 10px"><b><i>' . uc($hold_letter) . '</i></b></p>' . "\n" ;
	    }
	    

	    ## initialize the word to display
	    my $display ;
	    if ( ! defined $vnotes{ $palora }{verb}     || 
		 ! defined $vnotes{ $palora }{reflex}   || 
		 ! defined $vnotes{ $palora }{prepend}  ) { 
		
		##  not a verb, so ...
		##  first choice is "display_as",  second choice is hash key
		$display = ( ! defined $vnotes{$palora}{display_as} ) ? $palora : $vnotes{$palora}{display_as} ;		
		
	    } else { 
		##  fetching to get conjugated infinitive
		my %othash = $vbsubs{conjugate}( $palora , \%vnotes , $vbcref , \%vbsubs ) ; 

		##  is a verb, so ...
		##  first choice is "display_as",  second choice is conjugated infinitive,  third choice is hash key
		$display = ( ! defined $othash{inf} ) ? $palora : $othash{inf} ;
		$display = ( ! defined $vnotes{$palora}{display_as} ) ? $display : $vnotes{$palora}{display_as} ;
	    }

	    ##  create link and part of speech

	    ##  part of speech ... in Sicilian
	    my $partsp = $vnotes{ $palora }{part_speech} ;
	    $partsp =~ s/^verb$/verbu/ ;
	    $partsp =~ s/^noun$/sust./ ;
	    $partsp =~ s/^adj$/agg./   ;
	    $partsp =~ s/^adv$/avv./   ;
	    $partsp =~ s/^prep$/prip./ ;
	    $partsp =~ s/^pron$/prun./ ;
	    $partsp =~ s/^conj$/cunj./ ;
	    $partsp =~ s/^other$/àutru./ ;
	    
	    my $link    = '<a href="/cgi-bin/cchiu-da-palora.pl?palora=' . $palora . '">' . $display . '</a>' ;
	    my $partsp_disp  = '<small>{' . $partsp  . '}</small>' ;

	    ##  prepare output
	    $othtml .= '<p class="cchiu">' . $link . " " . $partsp_disp  . '</p>' . "\n" ; 
	}
    }
    
    return $othtml ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

sub mk_cctophtml {

    my $topnav = $_[0] ;
    my $palora = $_[1] ;

    my %vnotes = %{ $_[2] };
    my $vbcref =    $_[3]  ;
    my %vbsubs = %{ $_[4] };

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
	    %othash = $vbsubs{conjugate}( $palora , \%vnotes , $vbcref , \%vbsubs ) ; 
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
    my $descrip_fmt = ( $display ne "" ) ? $display . ' ' . $part_fmt : "";
    my $english_fmt = ( ! defined $vnotes{ $palora }{part_speech} ) ? "" : '(' . $vnotes{ $palora }{part_speech} . ')';
    
    my $ottxt ;
    $ottxt .= "Content-type: text/html\n\n";
    $ottxt .= '<!DOCTYPE html>' . "\n" ;
    $ottxt .= '<html>' . "\n" ;
    $ottxt .= '  <head>' . "\n" ;

    $ottxt .= '    <title>' . $title_fmt ;
    $ottxt .= 'Cchiù dâ Palora :: Napizia</title>' ."\n";

    if ( $descrip_fmt ne "" ) { 
	$ottxt .= '    <meta name="DESCRIPTION" content="Cchiù dâ palora: ';
	$ottxt .= $descrip_fmt . '. More about the Sicilian word: ' . $display . ' ' . $english_fmt . '.'; 
	$ottxt .= '">'."\n";
    } else {
	$ottxt .= '    <meta name="DESCRIPTION" content="Annotazzioni a nu dizziunariu sicilianu. ';
	$ottxt .= ' Annotations to a Sicilian dictionary.">'."\n";
    }

    $ottxt .= '    <meta name="KEYWORDS" content="'; 
    if ( $display ne "" ) { 
	$ottxt .= $display . ', ' ;
    }
    $ottxt .= 'Sicilian dictionary, dizziunariu sicilianu, dizionario siciliano">' . "\n" ;
    
    $ottxt .= '    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">' . "\n" ;
    $ottxt .= '    <meta name="Author" content="Eryk Wdowiak">' . "\n" ;
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/eryk.css">' . "\n" ;
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/eryk_theme-blue.css">' . "\n" ;
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/eryk_widenme.css">' . "\n" ;
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/dieli_forms.css">' . "\n" ;
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
    $ottxt .= "\n";
    $ottxt .= '    <meta name="viewport" content="width=device-width, initial-scale=1">' . "\n" ;

    ##  extra CSS
    $ottxt .= '    <style>' . "\n" ;

    ##  show/hide future and conditional
    #$ottxt .= '      #fticoi {  display: none; }' . "\n" ;
    #$ottxt .= '      #fticoi:target {  display: block; }' . "\n" ;
    #$ottxt .= '      #closeme {  display: none; }' . "\n" ;
    #$ottxt .= '      #closeme:target {  display: block; }' . "\n" ;

    ##  small entry spacing on desktops, large entry spacing on mobile
    $ottxt .= '      p.cchiu { margin-top: 0em; margin-bottom: 0em; }' . "\n" ;
    $ottxt .= '      @media only screen and (max-width: 600px) { ' . "\n" ;
    $ottxt .= '            p.cchiu { margin-top: 0.5em; margin-bottom: 0.5em; }' . "\n" ;
    $ottxt .= '      }' . "\n" ;
    
    ## ##  zero paragraph spacing
    ## ##  now handled by "eryk_widenme.css"
    ## $ottxt .= '      p.zero { margin-top: 0em; margin-bottom: 0em; }' . "\n" ;

    ##  DIV -- translations and conjugations
    $ottxt .= '      div.transconj { position: relative; margin: auto; width: 50%;}' . "\n" ;
    $ottxt .= '      @media only screen and (max-width: 835px) { ' . "\n" ;
    $ottxt .= '          div.transconj { position: relative; margin: auto; width: 90%;}' . "\n" ;
    $ottxt .= '      }' . "\n" ;

    ## ##  DIV -- suggestions
    ## ##  now handled by "eryk_widenme.css"
    ## $ottxt .= '      div.cunzigghiu { position: relative; margin: auto; width: 50%;}' . "\n" ;
    ## $ottxt .= '      @media only screen and (max-width: 835px) { ' . "\n" ;
    ## $ottxt .= '          div.cunzigghiu { position: relative; margin: auto; width: 90%;}' . "\n" ;
    ## $ottxt .= '      }' . "\n" ;

    ## ## spacing for second column of Dieli collections
    ## ##  now handled by "eryk_widenme.css"
    ## $ottxt .= '    ul.ddcoltwo { margin-top: 0em; }' . "\n" ;
    ## $ottxt .= '    @media only screen and (min-width: 600px) { ' . "\n" ;
    ## $ottxt .= '        ul.ddcoltwo { margin-top: 2.25em; }' . "\n" ;
    ## $ottxt .= '    }' . "\n" ;

    ##  close CSS -- close head
    $ottxt .= '    </style>' . "\n" ;
    $ottxt .= '  </head>' . "\n" ;

    open( TOPNAV , $topnav ) || die "could not read:  $topnav";
    while(<TOPNAV>){ chomp;  $ottxt .= $_ . "\n" ; };
    close TOPNAV ;

    $ottxt .= '  <!-- begin row div -->' . "\n" ;
    $ottxt .= '  <div class="row">' . "\n" ;
    $ottxt .= '    <div class="col-m-12 col-12">' . "\n" ;
    $ottxt .= '      <h1>Cchiù dâ Palora</h1>' . "\n" ;
    ## $ottxt .= '      <h2>di Eryk Wdowiak</h2>' . "\n" ;
    $ottxt .= '    </div>' . "\n" ;
    $ottxt .= '  </div>' . "\n" ;
    $ottxt .= '  <!-- end row div -->' . "\n" ;
    $ottxt .= '  ' . "\n" ;
    $ottxt .= '  <!-- begin row div -->' . "\n" ;
    $ottxt .= '  <div class="row">' . "\n" ;
    
    return $ottxt ;
}


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  SUBROUTINES  for  DIELI DICTIONARY
##  ===========  ===  ===== ==========

## tip of the hat to List::MoreUtils for this sub
sub uniq { 
    my %h;  
    map { $h{$_}++ == 0 ? $_ : () } @_;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub mk_search {
    
    my $rlang  =    $_[0] ; 
    my $rsrch  =    $_[1] ; 
    my $dlirf  =    $_[2] ; 
    my %ddsubs = %{ $_[3] } ; 
    my $lgparm =    $_[4] ; 
    my $pclass =    $_[5] ; 
    my $benice = ( ! defined $_[6] || $_[6] ne "BeNice" ) ? "BeMean" : "BeNice";

    my @translation = $ddsubs{translate}( $rlang , $rsrch , $dlirf ) ;
    my @inpart = @{ $translation[0] } ;
    my @otpart = @{ $translation[1] } ;
    my @otword = @{ $translation[2] } ;
    my @linkto = @{ $translation[3] } ;
	
    $rsrch =~ s/_SQUOTE_/'/g;

    my $othtml ;
    if ($#inpart == -1 && $rsrch ne "") { 
	if ( $benice eq "BeMean" ) {
	    $othtml .= "<p>nun c'è na traduzzioni dâ palora: " . '&nbsp; <b>' . $rsrch . '</b></p>';
	} else {
	    $othtml .= '<p' . $pclass . '><b>' . $rsrch . '</b> {} &nbsp; &rarr; &nbsp; {}</p>';
	}
	
    } else {	    
	my @otplines ;
	if ( $rlang =~ /SCEN|SCIT/ ) {
	    ##  Sicilian is "IN" language
	    foreach my $i (0..$#inpart) {
		my $linkifany ;
		if ( $linkto[$i] ne "" ) {
		    $linkifany .= '<a href="/cgi-bin/cchiu-da-palora.pl?' ; 
		    $linkifany .= 'palora=' . $linkto[$i] . '&langs=' . $lgparm . '">' ; 
		    $linkifany .= $rsrch . '</a>' ;
		} else {
		    $linkifany .= $rsrch ;
		}
		##  create the output
		my $otpline ;
		$otpline .= '<p' . $pclass . '><b>' . $linkifany . '</b> ' . $inpart[$i] . ' &nbsp; &rarr; &nbsp; ' ;
		$otpline .= '<b>' . $otword[$i] . '</b> ' . $otpart[$i] . '</p>' . "\n" ;
		push( @otplines , $otpline ) ;
	    }
	} else {
	    ##  Sicilian is "OUT" language
	    foreach my $i (0..$#otpart) {
		##  need to reverse the language for lookup
		my $newlgparm = ( $lgparm eq "ITSC" ) ? "SCIT" : "SCEN" ;
		my $linkifany ;
		if ( $linkto[$i] ne "" ) {
		    $linkifany .= '<a href="/cgi-bin/cchiu-da-palora.pl?' ; 
		    $linkifany .= 'palora=' . $linkto[$i] . '&langs=' . $newlgparm . '">' ; 
		    $linkifany .= $otword[$i] . '</a>' ;
		} else {
		    $linkifany .= $otword[$i] ;
		}
		##  create the output
		my $otpline ;
		$otpline .= '<p' . $pclass . '><b>' . $rsrch . '</b> ' . $inpart[$i] . ' &nbsp; &rarr; &nbsp; ' ;
		$otpline .= '<b>' . $linkifany . '</b> ' . $otpart[$i] . '</p>' . "\n" ;
		push( @otplines , $otpline ) ;
	    }
	}
	
	foreach my $otpline (sort( $ddsubs{uniq}( @otplines ))) {
	    $othtml .= $otpline ; 
	}
    }
    return $othtml ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub translate {

    my $rlang =    $_[0]   ; 
    my $rsrch =    $_[1]   ; 
    my %dict  = %{ $_[2] } ;

    ##  prepare arrays of output
    my @inpart ;
    my @otpart ;
    my @otword ;
    my @linkto ;

    ##  how many entries are there?
    my $nu_entry = $#{ $dict{$rsrch} } ;
    
    if ( $rlang =~ /SCEN/ ) {  
	for my $i (0..$nu_entry) {
	    if ( ${ ${ $dict{$rsrch} }[$i] }{"en_word"} ne '<br>') {
		push( @inpart , ${ ${ $dict{$rsrch} }[$i] }{"sc_part"} );
		push( @otpart , ${ ${ $dict{$rsrch} }[$i] }{"en_part"} );
		push( @otword , ${ ${ $dict{$rsrch} }[$i] }{"en_word"} );
		my $link = ( ! defined ${ ${ $dict{$rsrch} }[$i] }{"linkto"} ) ? "" : ${ ${ $dict{$rsrch} }[$i] }{"linkto"} ;
		push( @linkto , $link );
	    }
	}
    } elsif ( $rlang =~ /SCIT/ ) {  
	for my $i (0..$nu_entry) {
	    if ( ${ ${ $dict{$rsrch} }[$i] }{"it_word"} ne '<br>') {
		push( @inpart , ${ ${ $dict{$rsrch} }[$i] }{"sc_part"} );
		push( @otpart , ${ ${ $dict{$rsrch} }[$i] }{"it_part"} );
		push( @otword , ${ ${ $dict{$rsrch} }[$i] }{"it_word"} );
		my $link = ( ! defined ${ ${ $dict{$rsrch} }[$i] }{"linkto"} ) ? "" : ${ ${ $dict{$rsrch} }[$i] }{"linkto"} ;
		push( @linkto , $link );
	    }
	}
    } elsif ( $rlang =~ /ENSC/ ) {  
	for my $i (0..$nu_entry) {
	    if ( ${ ${ $dict{$rsrch} }[$i] }{"sc_word"} ne '<br>') {
		push( @inpart , ${ ${ $dict{$rsrch} }[$i] }{"en_part"} );
		push( @otpart , ${ ${ $dict{$rsrch} }[$i] }{"sc_part"} );
		push( @otword , ${ ${ $dict{$rsrch} }[$i] }{"sc_word"} );
		my $link = ( ! defined ${ ${ $dict{$rsrch} }[$i] }{"linkto"} ) ? "" : ${ ${ $dict{$rsrch} }[$i] }{"linkto"} ;
		push( @linkto , $link );
	    }
	}
    } elsif ( $rlang =~ /ITSC/ ) {  
	for my $i (0..$nu_entry) {
	    if ( ${ ${ $dict{$rsrch} }[$i] }{"sc_word"} ne '<br>') {
		push( @inpart , ${ ${ $dict{$rsrch} }[$i] }{"it_part"} );
		push( @otpart , ${ ${ $dict{$rsrch} }[$i] }{"sc_part"} );
		push( @otword , ${ ${ $dict{$rsrch} }[$i] }{"sc_word"} );
		my $link = ( ! defined ${ ${ $dict{$rsrch} }[$i] }{"linkto"} ) ? "" : ${ ${ $dict{$rsrch} }[$i] }{"linkto"} ;
		    push( @linkto , $link );
	    }
	}
    }
    
    
    s/_SQUOTE_/'/g for @inpart ; 
    s/_SQUOTE_/'/g for @otpart ; 
    s/_SQUOTE_/'/g for @otword ; 
    ## s/_SQUOTE_/'/g for @linkto ; 
    return( \@inpart , \@otpart , \@otword , \@linkto ) ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub mk_ddtophtml {

    ##  top navigation panel
    my $topnav = $_[0] ;

    ##  language parameter
    my $lgtext = $_[1] ;
    $lgtext = ( ! defined $lgtext ) ? "" : $lgtext ;
    $lgtext =~ s/ENSC/En-Sc/;
    $lgtext =~ s/ITSC/It-Sc/;
    $lgtext =~ s/SCEN/Sc-En/;
    $lgtext =~ s/SCIT/Sc-It/;

    ##  the word searched for, and only if single-item
    my $search = $_[2];
    $search = ( ! defined $search ) ? "" : $search ;
    $search =~ s/_SQUOTE_/'/g;
    $search =~ s/_OR_.*$//;

    $search =~ s/COLL_aviri/ricota - aviri/; 
    $search =~ s/COLL_have/ricota - to have/;
    $search =~ s/COLL_essiri/ricota - essiri/;
    $search =~ s/COLL_fari/ricota - fari/;
    $search =~ s/COLL_places/ricota - munnu/;
    $search =~ s/COLL_timerel/ricota - tempu/;
    $search =~ s/COLL_daysweek/ricota - jorna/;
    $search =~ s/COLL_months/ricota - misi/;
    $search =~ s/COLL_holidays/ricota - festi/;
    $search =~ s/COLL_seasons/ricota - staggiuni/;
    $search =~ s/COLL_/ricota - /;
	    
    ##  text to insert into the title
    my $title_insert = ( $search eq "" ) ? "" : $search .' ('. $lgtext .') :: ';

    my $ottxt ;
    $ottxt .= "Content-type: text/html\n\n";
    $ottxt .= '<!DOCTYPE html>' . "\n" ;
    $ottxt .= '<html>' . "\n" ;
    $ottxt .= '  <head>' . "\n" ;
    $ottxt .= '    <title>' . $title_insert  . 'Dizziunariu di Dieli :: Napizia</title>' . "\n" ;
    $ottxt .= '    <meta name="DESCRIPTION" content="Sicilian-Italian-English Dictionary by Arthur Dieli">' . "\n" ;
    $ottxt .= '    <meta name="KEYWORDS" content="Sicilian, language, dictionary, Dieli, Arthur Dieli">' . "\n" ;
    $ottxt .= '    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">' . "\n" ;
    $ottxt .= '    <meta name="Author" content="Eryk Wdowiak">' . "\n" ;
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/eryk.css">' . "\n" ;
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/eryk_theme-blue.css">' . "\n" ;
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/eryk_widenme.css">' . "\n" ;
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/dieli_forms.css">' . "\n" ;
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

    open( TOPNAV , $topnav ) || die "could not read:  $topnav";
    while(<TOPNAV>){ chomp;  $ottxt .= $_ . "\n" ; };
    close TOPNAV ;

    $ottxt .= '  <!-- begin row div -->' . "\n" ;
    $ottxt .= '  <div class="row">' . "\n" ;
    $ottxt .= '    <div class="col-m-12 col-12">' . "\n" ;
    ## $ottxt .= '      <h1>Dizziunariu Sicilianu</h1> <h2>di Arthur Dieli</h2>' . "\n" ;
    $ottxt .= '      <h1>Dizziunariu di Dieli</h1>'."\n";
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
    $ottxt .= '<form enctype="multipart/form-data" action="/cgi-bin/sicilian.pl" method="post">' . "\n" ;
    $ottxt .= '<table style="max-width:500px;"><tbody>' . "\n" ;
    $ottxt .= '<tr><td colspan="2">' ; 
    $ottxt .= '<input type=text name="search" value="'. $sc_search .'" size=36 maxlength=72>' ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '<tr><td>' . "\n" ; 

    $ottxt .= '<select name="langs">' . "\n" ;
    if ( $lgparm =~ /SCEN|ENSC/ ) {
	$ottxt .= '<option value="SCEN">Sicilianu-Ngrisi'  . "\n" ;
	$ottxt .= '<option value="SCIT">Sicilianu-Talianu' . "\n" ;
    } else {
	$ottxt .= '<option value="SCIT">Sicilianu-Talianu' . "\n" ;
	$ottxt .= '<option value="SCEN">Sicilianu-Ngrisi'  . "\n" ;
    }
    
    $ottxt .= '</select>' . "\n" ;
    $ottxt .= '</td>' . "\n" ;
    $ottxt .= '<td align="right">' . '<input type="submit" value="Traduci">' . "\n" ;
    ## $ottxt .= '<input type=reset value="Clear Form">' . "\n" ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '</tbody></table>' . "\n" ;
    $ottxt .= '</form>' . "\n" ;

    $ottxt .= '<form enctype="multipart/form-data" action="/cgi-bin/sicilian.pl" method="post">' . "\n" ;
    $ottxt .= '<table style="max-width:500px;"><tbody>' . "\n" ;
    $ottxt .= '<tr><td colspan="2">' ;
    $ottxt .= '<input type=text name="search" value="'. $ie_search .'" size=36 maxlength=72>' ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '<tr><td>' . "\n" ; 

    $ottxt .= '<select name="langs">' . "\n" ;
    if ( $lgparm =~ /SCEN|ENSC/ ) {
	$ottxt .= '<option value="ENSC">Ngrisi-Sicilianu'  . "\n" ;
	$ottxt .= '<option value="ITSC">Talianu-Sicilianu' . "\n" ;
    } else {
	$ottxt .= '<option value="ITSC">Talianu-Sicilianu' . "\n" ;
	$ottxt .= '<option value="ENSC">Ngrisi-Sicilianu'  . "\n" ;
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
    $ot .= '<p style="margin-top: 1.5em; margin-bottom: 0.50em; text-align: center;">Grazzi a ';
    $ot .= '<b><a href="http://www.dieli.net/" target="_blank">' ;
    $ot .= 'Arthur Dieli</a></b> pi cumpilari stu dizziunariu.</p>' . "\n" ; 
    return $ot ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  $othtml .= '    <p style="margin-bottom: 0.25em;"><b><i>stu prujettu:</i></b></p>'."\n";
##  $othtml .= '    <ul style="margin-top: 0em; margin-bottom: 0em; padding-left: 25px;">'."\n";
##  $othtml .= '      <li><i><a href="/cgi-bin/sicilian.pl">Dizziunariu di Dieli</a></i></li>'."\n";
##  $othtml .= '      <li><i><a href="/cgi-bin/cchiu-da-palora.pl">Cchiù dâ Palora</a></i></li>'."\n";
##  $othtml .= '      <li style="margin-bottom: 0.5em;"><i><a href="/cgi-bin/aiutami.pl">Aiùtami!</a></i></li>'."\n";
##  $othtml .= '      <li><a href="/pages/sicilian/index.shtml">dictionary specification</a></li>'."\n";
##  $othtml .= '      <li><a href="/pages/sicilian/sicilian-verbs.shtml">boot and stem theory</a></li>'."\n";
##  $othtml .= '      <li style="margin-bottom: 0.5em;"><a href="/pages/sicilian/bibliography.shtml">bibliography</a></li>'."\n";
##  $othtml .= '      <li><i><a href="https://www.wdowiak.me/archive/sicilian/giuvini-sicilianu.shtml">Manifestu dûn Giùvini Sicilianu</a></i></li>'."\n";
##  $othtml .= '      <li style="margin-bottom: 0.5em;"><i><a href="https://www.wdowiak.me/archive/sicilian/young-sicilian.shtml">Young Sicilian Manifesto</a></i></li>'."\n";
##  $othtml .= '      <li><a href="https://github.com/ewdowiak/cchiu-da-palora" target="_blank">source code</a> <small>(GitHub)</small></li>'."\n";
##  $othtml .= '    </ul>'."\n";

## ## $othtml .= '      <li style="margin-bottom: 0.125em;"><a href="http://www.cademiasiciliana.org/" target="_blank">Cadèmia Siciliana</a></li>'."\n";
## $othtml .= '      <li style="margin-bottom: 0.125em;"><a href="http://www.pizzocalabro.it/Orlando/Dizionario%20Napitino/bozza_di_studio_per_un_dizionario%20napitino.htm"'."\n";
## $othtml .= '	     target="_blank"><i>Napitinu</i> <small>(O.&nbsp;Accetta)</small></a></li>'."\n";
## $othtml .= '      <li style="margin-bottom: 0.125em;"><a href="http://www.dialettosalentino.it" target="_blank"><i>Salentinu</i> <small>(G.&nbsp;Presicce)</small></a></li>'."\n";
## $othtml .= '      <li style="margin-bottom: 0.125em;"><a href="http://wiki.apertium.org/wiki/Siciliano_y_castellano/Informe_final"'."\n"; 
## $othtml .= '             target="_blank">Translator <small>(U.&nbsp;Sentsova)</small></a></li>'."\n";
## $othtml .= '      <li style="margin-bottom: 0.125em;"><a href="https://scn.wiktionary.org/" target="_blank">Wikizziunariu</a></li>'."\n";

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  make "word harvest"
sub mk_ricota {

    ##  prepare output
    my $othtml ;

    ##  open project DIV
    $othtml .= '<div class="row" style="margin: 5px 0px; border: 1px solid black; background-color: rgb(255,255,204);">'."\n";
    
    ## $othtml .= '  <div class="minicol"></div>'."\n";
    ## $othtml .= '  <div class="minicol"></div>'."\n";
    ## $othtml .= '  <div class="minicol"></div>'."\n";
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
    $othtml .= '      <li style="margin-bottom: 0.125em;"><a href="http://www.arbasicula.org/" target="_blank">Arba Sicula</a></li>'."\n";
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

    open( FOOTNAV , $footnav ) || die "could not read:  $footnav";
    while(<FOOTNAV>){ chomp;  $othtml .= $_ . "\n" ; };
    close FOOTNAV ;
    
    return $othtml ;
}


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  hash to store subs for cchiu-da-palora
my %ccsubs ; 

$ccsubs{ask_help}       = \&ask_help;

$ccsubs{mk_nounhtml}    = \&mk_nounhtml;
$ccsubs{mk_adjhtml}     = \&mk_adjhtml;
$ccsubs{mk_conjhtml}    = \&mk_conjhtml;

$ccsubs{mk_dielitrans}  = \&mk_dielitrans; 
$ccsubs{mk_notex}       = \&mk_notex;
$ccsubs{mk_notex_list}  = \&mk_notex_list;

$ccsubs{mk_showall}     = \&mk_showall; 
$ccsubs{mk_vnkcontent}  = \&mk_vnkcontent;

$ccsubs{mk_cctophtml}   = \&mk_cctophtml;


##  hash to store subs for dieli dictionary
my %ddsubs ;

$ddsubs{uniq}         = \&uniq;
$ddsubs{mk_search}    = \&mk_search;
$ddsubs{translate}    = \&translate;

$ddsubs{mk_ddtophtml} = \&mk_ddtophtml;
$ddsubs{mk_newform}   = \&mk_newform;

$ddsubs{thank_dieli}  = \&thank_dieli;

$ddsubs{mk_ricota}    = \&mk_ricota;
$ddsubs{mk_foothtml}  = \&mk_foothtml;


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  store it all
nstore( { ccsubs  => \%ccsubs , 
	  ddsubs  => \%ddsubs } , $otfile ); 


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##


##  ##  ##  ##  ##  ##  ##  ##  ##

##  À à  Â â
##  È è  Ê ê
##  Ì ì  Î î
##  Ò ò  Ô ô
##  Ù ù  Û û

##  ##  ##  ##  ##  ##  ##  ##  ##

