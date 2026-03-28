package Napizia::HtmlChiu;

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
# no warnings qw(uninitialized numeric void);

use utf8;

sub mk_adjectives { Napizia::PosTools::mk_adjectives($_[0]);}
sub mk_noun_plural { Napizia::PosTools::mk_noun_plural($_[0], $_[1], $_[2], $_[3]);}
sub mk_forms { Napizia::PosTools::mk_forms();}
sub conjugate { Napizia::PosTools::conjugate($_[0], $_[1], $_[2]);}

sub rid_accents { Napizia::TextTools::rid_accents($_[0]);}

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ("mk_nounhtml","mk_adjhtml", "mk_conjhtml",
	       "mk_dielitrans","mk_notex","mk_notex_list","mk_showall",
	       "mk_vnkcontent","mk_cctopinfo");

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  SUBROUTINES  for  CHIU-DA-PALORA
##  ===========  ===  ==============

sub mk_nounhtml { 
    my $palora  =    $_[0]   ;  ( my $singular = $palora ) =~ s/_noun$// ; 
    my $lgparm  =    $_[1]   ;
    my %vnotes  = %{ $_[2] } ;
    my $nounpls =    $_[3]   ;  ##  hash reference

    ##  first choice is "display_as",  second choice is hash key (less noun marker)
    my $display = ( ! defined $vnotes{$palora}{display_as} ) ? $singular : $vnotes{$palora}{display_as} ; 

    ##  prepare output
    my $ot ;

    ##  which word do we redirect to? 
    my $redirect = ( ! defined $vnotes{$palora}{dieli} ) ? $display : join( "_OR_", @{$vnotes{$palora}{dieli}} ) ;
    
    ##  outer DIV to limit width
    $ot .= '<div class="transconj">'."\n";
    $ot .= '<p style="margin-bottom: 0.5em;"><b><a href="/dieli/?' . 'search=' . $redirect . '&langs=' . $lgparm . '">' ; 
    $ot .= $display . '</a></b></p>'."\n";
    

    ##  mk_noun_plural() assumes "mas" or "fem" noun, some nouns are "both"
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
	push( @plurals , mk_noun_plural( $display , $gender , $plend  , $nounpls ) );
	push( @plurals , mk_noun_plural( $display , $gender , "xi"  , $nounpls ) );

    } elsif ( ! defined $vnotes{$palora}{noun}{plural} ) {
	##  if an irregular plural is not defined
	push( @plurals , mk_noun_plural( $display , $gender , $plend  , $nounpls ) );

    } else {
	##  if an irregular plural is defined
	push( @plurals , $vnotes{$palora}{noun}{plural} );
    }
    
    
    ##  singular forms
    if ( $gender eq "mas" || $gender eq "both" ) {
	my $defart = ( rid_accents( $display ) =~ /^[aeiouAEIOU]/ ) ? "l' " : "lu " ; 
	$ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><i>ms.:</i> &nbsp; ' . $defart . $display . "</p>" . "\n";
    }
    if ( $gender eq "fem" || $gender eq "both" ) {
	my $defart = ( rid_accents( $display ) =~ /^[aeiouAEIOU]/ ) ? "l' " : "la " ; 
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
	    my $defart = ( rid_accents( $plural ) =~ /^[aeiouAEIOU]/ ) ? "l' " : "li " ; 
	    my $otplural = $defart . $plural ; 
	    push( @otplurals , $otplural );
	}
	##  join them together
	$ot .= join( ' &nbsp;<i>o</i>&nbsp; ' , @otplurals ) ; 
	$ot .= '</p>' . "\n";
    }   
    ##  close DIV that limits width
    $ot .= '</div>'."\n"; 

    ##  send it out!
    return $ot ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #
# ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #

sub mk_adjhtml { 
    my $palora  =    $_[0]   ;  ( my $singular = $palora ) =~ s/_adj$// ; 
    my $lgparm  =    $_[1]   ;
    my %vnotes  = %{ $_[2] } ;

    ##  first choice is "display_as",  second choice is hash key (less adj marker)
    my $display = ( ! defined $vnotes{$palora}{display_as} ) ? $singular : $vnotes{$palora}{display_as} ;	
    
    ##  prepare output
    my $ot ;
    ##  which word do we redirect to? 
    my $redirect = ( ! defined $vnotes{$palora}{dieli} ) ? $display : join( "_OR_", @{$vnotes{$palora}{dieli}} );
    
    ##  if it is not an adjective phrase 
    if ( ! defined $vnotes{$palora}{adj}{phrase} ) {

	##  outer DIV to limit width
	$ot .= '<div class="transconj">'."\n";
	$ot .= '<p style="margin-bottom: 0.5em;"><b><a href="/dieli/?' ; 
	$ot .= 'search=' . $redirect . '&langs=' . $lgparm . '">' ; 
	$ot .= $display . '</a></b></p>'."\n";

	##  fetch singular and plural forms
	my $massi ; my $femsi ; my $maspl ; my $fempl ;

	##  check to see if adjective is invariant (e.g. "la megghiu cosa") 
	##  or only feminine changes (e.g. "giuvini, giuvina")
	if ( ! defined $vnotes{$palora}{adj}{invariant} && 
	     ! defined $vnotes{$palora}{adj}{femsi} && 
	     ! defined $vnotes{$palora}{adj}{plural} ) {
	    ##  not invariant, regular femsi and regular plural
	    ($massi , $femsi , $maspl , $fempl) = mk_adjectives($display) ;
	} elsif ( ! defined $vnotes{$palora}{adj}{plural} ) {
	    ##  either invariant or only fem form changes
	    $massi = $display  ;  
	    $femsi = ( ! defined $vnotes{$palora}{adj}{femsi}  ) ? $display : $vnotes{$palora}{adj}{femsi} ;
	    $maspl = $display ;
	    $fempl = $display ;
	} else {
	    ##  plural is special
	    ($massi , $femsi , $maspl , $fempl) = mk_adjectives($display) ;
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
	$ot .= '</div>'."\n"; 
    }
    
    return $ot ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #
# ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #

sub mk_conjhtml {
    
    my $palora =    $_[0]   ;
    my $lgparm =    $_[1]   ;
    my %vnotes = %{ $_[2] } ;
    my $vbcref =    $_[3]   ;  ##  hash reference
    
    my %forms  = mk_forms() ; 
    my @tenses = @{ $forms{tenses} } ; 
    my %tnhash = %{ $forms{tnhash} } ; 
    my @people = ( ! defined $vnotes{$palora}{verb}{people} ) ? @{ $forms{people} } : @{ $vnotes{$palora}{verb}{people} };

    ##  conjugate the verb
    my %othash = conjugate( $palora , \%vnotes , $vbcref ) ; 

    ##  prepare output
    my $ot ;

    ##  which word do we redirect to? 
    my $redirect = ( ! defined $vnotes{$palora}{dieli} ) ? $palora : join( "_OR_", @{$vnotes{$palora}{dieli}} ) ;
    
    ##  which word do we display?
    my $display ;
    $display = ( ! defined $othash{inf} ) ? $palora : $othash{inf} ;
    $display = ( ! defined $vnotes{$palora}{display_as} ) ? $display : $vnotes{$palora}{display_as} ;
    
    ##  outer DIV to limit width
    $ot .= '<div class="transconj">'."\n";
    $ot .= '<p><b><a href="/dieli/?' . 'search=' . $redirect . '&langs=' . $lgparm . '">' ; 
    $ot .= $display . '</a></b></p>'."\n";
    
    ##  PRI -- present indicative 
    $ot .= '<div class="row">'."\n"; 
    $ot .= '<p style="margin-bottom: 0.5em"><u>' . $tnhash{pri} . '</u></p>'."\n";
    $ot .= '<div class="col-m-6 col-6">'."\n";
    foreach my $person (@people[0..2]) {
	$ot .= '<p class="zero">' ;
	$ot .= $othash{pri}{$person} ; 
	$ot .= '</p>'."\n";
    }
	    $ot .= '</div>'."\n"; 
    $ot .= '<div class="col-m-6 col-6">'."\n";
    foreach my $person (@people[3..5]) {
	$ot .= '<p class="zero">' ;
	$ot .= $othash{pri}{$person} ; 
	$ot .= '</p>'."\n"; 
    }
    $ot .= '</div>'."\n"; 	
    $ot .= '</div>'."\n"; 

    
    ##  PIM -- present imperative

    ##  which persons should we list?
    my $us_print = grep {/^us$/} @people ;
    my $ds_print = grep {/^ds$/} @people ;
    my $ts_print = grep {/^ts$/} @people ;
    my $up_print = grep {/^up$/} @people ;
    my $dp_print = grep {/^dp$/} @people ;
    my $tp_print = grep {/^tp$/} @people ;

    $ot .= '<div class="row">'."\n"; 
    $ot .= '<p style="margin-bottom: 0.5em"><u>' . $tnhash{pim} . '</u></p>'."\n";
    $ot .= '<div class="col-m-6 col-6">'."\n";
    
    if ( $us_print > 0 ) { $ot .= '<p class="zero">' . '--' . '</p>'."\n"; }
    if ( $ds_print > 0 ) { $ot .= '<p class="zero">' . $othash{pim}{"ds"} . '</p>'."\n"; }
    if ( $ts_print > 0 ) { $ot .= '<p class="zero">' . $othash{pim}{"ts"} . '</p>'."\n"; } 
        
    $ot .= '</div>'."\n"; 
    $ot .= '<div class="col-m-6 col-6">'."\n";

    if ( $up_print > 0 ) { $ot .= '<p class="zero">' . $othash{pim}{"up"} . '</p>'."\n"; }
    if ( $dp_print > 0 ) { $ot .= '<p class="zero">' . $othash{pim}{"dp"} . '</p>'."\n"; }
    if ( $tp_print > 0 ) { $ot .= '<p class="zero">' . '--' . '</p>'."\n"; }

    $ot .= '</div>'."\n"; 	
    $ot .= '</div>'."\n"; 
    
    ##  PAI -- past ind. (preterite) 
    ##  IMI -- imperfect ind.
    ##  IMS -- imperfect subjunctive
    foreach my $tense ("pai","imi","ims") {
	$ot .= '<div class="row">'."\n"; 
	$ot .= '<p style="margin-bottom: 0.5em"><u>' . $tnhash{$tense} . '</u></p>'."\n";
	$ot .= '<div class="col-m-6 col-6">'."\n";
	foreach my $person (@people[0..2]) {
	    $ot .= '<p class="zero">' ;
	    $ot .= $othash{$tense}{$person} ; 
	    $ot .= '</p>'."\n";
	}
	$ot .= '</div>'."\n"; 
	$ot .= '<div class="col-m-6 col-6">'."\n";
	foreach my $person (@people[3..5]) {
	    $ot .= '<p class="zero">' ;
	    $ot .= $othash{$tense}{$person} ; 
	    $ot .= '</p>'."\n"; 
	}
	$ot .= '</div>'."\n"; 	
	$ot .= '</div>'."\n"; 
    }
    

    ##  FTI -- future indicative
    ##  COI -- conditional indicative
    #$ot .= '<p><small><i><a href="#fticoi">mustra li àutri tempi</a></i></small></p>'."\n"; 
    #$ot .= '<div id="fticoi">'."\n"; 
    foreach my $tense ("fti","coi") {
	$ot .= '<div class="row">'."\n"; 
	$ot .= '<p style="margin-bottom: 0.5em"><u>' . $tnhash{$tense} . '</u></p>'."\n";
	$ot .= '<div class="col-m-6 col-6">'."\n";
	foreach my $person (@people[0..2]) {
	    $ot .= '<p class="zero">' ;
	    $ot .= $othash{$tense}{$person} ; 
	    $ot .= '</p>'."\n";
	}
	$ot .= '</div>'."\n"; 
	$ot .= '<div class="col-m-6 col-6">'."\n";
	foreach my $person (@people[3..5]) {
	    $ot .= '<p class="zero">' ;
	    $ot .= $othash{$tense}{$person} ; 
	    $ot .= '</p>'."\n"; 
	}
	$ot .= '</div>'."\n"; 	
	$ot .= '</div>'."\n"; 
    }
    #$ot .= '<p><small><i><a href="#closeme">ammucciali</a></i></small></p>'."\n"; 
    #$ot .= '</div>'."\n"; 
    
    ##  GER -- gerund
    ##  PAP -- past participle
    $ot .= '<div class="row">'."\n"; 
    $ot .= '<div class="col-m-6 col-6">'."\n";
    $ot .= '<p style="margin-bottom: 0.5em"><u>' . $tnhash{ger} . '</u></p>'."\n";
    $ot .= '<p class="zero">' ;
    $ot .= $othash{ger} ; 
    $ot .= '</p>'."\n";
    $ot .= '</div>'."\n"; 
    $ot .= '<div class="col-m-6 col-6">'."\n";
    $ot .= '<p style="margin-bottom: 0.5em"><u>' . $tnhash{pap} . '</u></p>'."\n";
    $ot .= '<p class="zero">' ;
    $ot .= ( ! defined $vnotes{$palora}{reflex} ) ? "aviri" : "avirisi" ;
    $ot .= " " . $othash{pap} ; 
    $ot .= '</p>'."\n"; 
    $ot .= '<p class="zero">' ;
    $ot .= '<i>agg.:</i>  &nbsp; ' . $othash{adj} ; 
    $ot .= '</p>'."\n"; 
    $ot .= '</div>'."\n"; 	
    $ot .= '</div>'."\n"; 

    ##  close DIV that limits width
    $ot .= '</div>'."\n"; 
    return $ot ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #
# ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #

sub mk_dielitrans {

    my $palora =    $_[0]   ;
    my $lgparm =    $_[1]   ;
    my %vnotes = %{ $_[2] } ;
    my $vbcref =    $_[3]   ;  ##  hash reference
    
    ##  prepare output
    my $ot ;    
    my %othash ;

    ##  are we working with a verb?
    my $isverb = ( ! defined $vnotes{ $palora }{verb}     && 
		   ! defined $vnotes{ $palora }{reflex}   && 
		   ! defined $vnotes{ $palora }{prepend}  ) ? "false" : "true" ;
    if ( $isverb eq "true" ) {
	%othash = conjugate( $palora , \%vnotes , $vbcref ) ; 
    }
    
    ##  which word do we display?
    my $display ;
    $display = ( ! defined $othash{inf} ) ? $palora : $othash{inf} ;
    $display = ( ! defined $vnotes{$palora}{display_as} ) ? $display : $vnotes{$palora}{display_as} ;
    
    ##  which word do we redirect to? 
    my $redirect = ( ! defined $vnotes{$palora}{dieli} ) ? $display : join( "_OR_", @{$vnotes{$palora}{dieli}} ) ;

    ##  clean up display
    $display  =~ s/_tdonly//;
    $redirect =~ s/_tdonly//;
    $redirect =  ( $redirect eq "" ) ? $display : $redirect ;
    $display  =~ s/_SQUOTE_/'/g;
    
    ##  outer DIV to limit width
    $ot .= '<div class="transconj">'."\n"; 
    $ot .= '<p><b><a href="/dieli/?' . 'search=' . $redirect . '&langs=' . $lgparm . '">' ; 
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
    
    $ot .= '&nbsp;&nbsp;{' . $part_speech . '}</p>'."\n";
    
    $ot .= '<div class="row">'."\n"; 

    ##  what variants of the word did Dr. Dieli identify?
    ##  what does the word translate to?
    my @dieli_sc_links  ; 
    my @dieli_en_links  ; 
    my @dieli_it_links  ; 
    foreach my $trans (@{$vnotes{$palora}{dieli}}) {
	push( @dieli_sc_links , '<a href="/dieli/?search=' . $trans . '&langs='. $lgparm .'">' . $trans . '</a>' );
    } 
    foreach my $trans (@{$vnotes{$palora}{dieli_en}}) {
	push( @dieli_en_links , '<a href="/dieli/?search=' . $trans . '&langs=ENSC">' . $trans . '</a>' );
    } 
    foreach my $trans (@{$vnotes{$palora}{dieli_it}}) {
	push( @dieli_it_links , '<a href="/dieli/?search=' . $trans . '&langs=ITSC">' . $trans . '</a>' );
    } 
    my $dieli_sc_str = join( ', ' , @dieli_sc_links ); 
    my $dieli_en_str = join( ', ' , @dieli_en_links ); 
    my $dieli_it_str = join( ', ' , @dieli_it_links ); 
    
    ##  only show Sicilian list if more than one
    if ( $#dieli_sc_links > 0 ) {
	$ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><b>SC:</b> &nbsp; ' . $dieli_sc_str . '</p>'."\n";
    }
    ##  only show English if more than zero
    if ( $#dieli_en_links > -1 ) {
	$ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><b>EN:</b> &nbsp; ' . $dieli_en_str . '</p>'."\n"; 
    }
    ##  only show Italian list if more than zero
    if ( $#dieli_it_links > -1 ) {
	$ot .= '<p style="margin-top: 0em; margin-bottom: 0em;"><b>IT:</b> &nbsp; ' . $dieli_it_str . '</p>'."\n"; 
    }
    
    $ot .= '</div>'."\n";
    $ot .= '</div>'."\n";

    return $ot ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #
# ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #

sub mk_notex {

    my $palora =    $_[0]   ;
    my %vnotes = %{ $_[1] } ;
    
    my $othtml ;
    
    if ( ! defined $vnotes{$palora}{poetry} ) {
	my $blah = "nothing to do here." ;
    } else {
	my $typeof = 'puisìa:';
	my @poetry  = @{ $vnotes{$palora}{poetry} };
	$othtml .= mk_notex_list( $typeof , \@poetry ) ; 
    }
    
    if ( ! defined $vnotes{$palora}{prose} ) {
	my $blah = "nothing to do here." ;
    } else {
	my $typeof = 'prosa:';
	my @prose  = @{ $vnotes{$palora}{prose} };
	$othtml .= mk_notex_list( $typeof , \@prose ) ; 
    }

    if ( ! defined $vnotes{$palora}{proverb} ) {
	my $blah = "nothing to do here." ;
    } else {
	my @proverbs  = @{ $vnotes{$palora}{proverb} };	
	my $typeof = ($#proverbs > 0) ? 'pruverbi:' : 'pruverbiu:' ;
	$othtml .= mk_notex_list( $typeof , \@proverbs ) ; 
    }

    if ( ! defined $vnotes{$palora}{usage} ) {
	my $blah = "nothing to do here." ;
    } else {
	my $typeof = 'usu dâ palora:';
	my @usage  = @{ $vnotes{$palora}{usage} };
	$othtml .= mk_notex_list( $typeof , \@usage ) ; 
    }

    if ( ! defined $vnotes{$palora}{notex} ) {
	my $blah = "nothing to do here." ;
    } else {
	my $typeof = 'pi esempiu:';
	my @notex  = @{ $vnotes{$palora}{notex} };
	$othtml .= mk_notex_list( $typeof , \@notex ) ; 
    }
    
    return $othtml ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #
# ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #

sub mk_notex_list {

    my $typeof =     $_[0] ;
    my @inarray = @{ $_[1] } ;

    my $othtml ;

    $othtml .= '<div class="transconj">' ."\n"; 
    $othtml .= '<p style="margin-bottom: 0.25em;"><i>' . $typeof . '</i></p>' ."\n";
    $othtml .= '<ul style="margin-top: 0.25em;">' ."\n";
    foreach my $i (0..$#inarray) {
	my $line = $inarray[$i];
	##  omit names of dictionary sources
	$line =~ s/\(Nicotra\)//g;
	#$line =~ s/\(Mortillaro\)//g;
	#$line =~ s/\(Mortillaro, Nicotra\)//g;

	##  clean up dashes
	$line =~ s/\-\-/\&ndash;/g;
	    
	##  append the line
	$othtml .= ( $typeof eq 'puisìa:' && $#inarray > 0 && $i < $#inarray ) ? '<li style="margin-bottom: 0.5em;">' : "<li>";
	$othtml .= $line . "</li>" ."\n";
    }
    $othtml .= "</ul>" ."\n";
    $othtml .= "</div>" ."\n";
    
    return $othtml ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #
# ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #

sub mk_showall {

    my %vnotes = %{ $_[0] } ;
    my $vbcref =    $_[1]   ;  ##  hash reference
    
    ##  scalars to adjust length of columns (for appearances)
    my $adjustone =  $_[2] ;
    my $adjusttwo =  $_[3] ;
    my $adjusttre =  $_[4] ;
    
    ##  let's split the print over four columns
    ##  keep words together by first letter
    my @vnkeys = sort( {lc(rid_accents($a)) cmp lc(rid_accents($b))} keys(%vnotes) );
    my $vnkqtr = int( $#vnkeys / 4 ) ; 
        
    ##  first column
    my $vnstart = 0 ; 
    my $vnkidx = $vnkqtr + $adjustone ; 
    my @vnkone = @vnkeys[$vnstart..$vnkidx] ; 
    foreach my $palora (@vnkeys[$vnkidx+1..$#vnkeys] ) {
	##  if same letter, add to column and increment the index
	my $newletter = lc(substr(rid_accents($palora),0,1)) ; 
	my $oldletter = lc(substr(rid_accents($vnkeys[$vnkidx]),0,1)) ;
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
	my $newletter = lc(substr(rid_accents($palora),0,1)) ; 
	my $oldletter = lc(substr(rid_accents($vnkeys[$vnkidx]),0,1)) ;
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
	my $newletter = lc(substr(rid_accents($palora),0,1)) ; 
	my $oldletter = lc(substr(rid_accents($vnkeys[$vnkidx]),0,1)) ;
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
    $othtml .= '<div class="listall">'."\n"; 
    $othtml .= '<div class="row">'."\n"; 

    ##  now print
    $othtml .= '<div class="rolltb">'."\n"; 
    $othtml .= '<div class="rolldk">'."\n"; 
    $othtml .= mk_vnkcontent( \@vnkone , \%vnotes , $vbcref );
    $othtml .= '</div>'."\n";
    $othtml .= '<div class="rolldk">'."\n"; 
    $othtml .= mk_vnkcontent( \@vnktwo , \%vnotes , $vbcref );
    $othtml .= '</div>'."\n";
    $othtml .= '</div>'."\n";
    

    $othtml .= '<div class="rolltb">'."\n"; 
    $othtml .= '<div class="rolldk">'."\n"; 
    $othtml .= mk_vnkcontent( \@vnktre , \%vnotes , $vbcref );
    $othtml .= '</div>'."\n";
    $othtml .= '<div class="rolldk">'."\n"; 
    $othtml .= mk_vnkcontent( \@vnkqtt , \%vnotes , $vbcref );
    $othtml .= '</div>'."\n";
    $othtml .= '</div>'."\n";

    ##  close the div
    $othtml .= '</div>'."\n"; 
    $othtml .= '</div>'."\n"; 

    return $othtml ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #
# ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #

sub mk_vnkcontent {

    my $vnkarf =    $_[0]   ;
    my %vnotes = %{ $_[1] } ;
    my $vbcref =    $_[2]   ;  ##  hash reference
    
    my $hold_letter = "" ; 
    my $othtml ;
    
    foreach my $palora (@{$vnkarf}) {
	##  which word do we display?
	##  get the infinitive
	
	if ( ! defined $vnotes{$palora}{hide} ) {
	    ##  if not hiding a (theoretical) non-reflexive form 
	    
	    ##  print initial letter if necessary
	    my $initial_letter = lc(substr(rid_accents($palora),0,1)) ; 
	    if ( $initial_letter ne $hold_letter ) {
		$hold_letter = $initial_letter ; 
		$othtml .= '<p style="margin-left: 10px"><b><i>' . uc($hold_letter) . '</i></b></p>'."\n";
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
		my %othash = conjugate( $palora , \%vnotes , $vbcref ) ; 

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
	    
	    my $link    = '<a href="/chiu/?palora=' . $palora . '">' . $display . '</a>' ;
	    my $partsp_disp  = '<small>{' . $partsp  . '}</small>' ;

	    ##  prepare output
	    $othtml .= '<p class="cchiu">' . $link . " " . $partsp_disp  . '</p>'."\n"; 
	}
    }
    
    return $othtml ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #
# ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #

sub mk_cctopinfo {

    my $palora =    $_[0]  ;
    my %vnotes = %{ $_[1] };
    my $vbcref =    $_[2]  ;

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
	    %othash = conjugate( $palora , \%vnotes , $vbcref ) ; 
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
    
    ##  and here's the TITLE
    my $title_concat = $title_fmt . 'Chiù dâ Palora :: Napizia';

    ##  prepare the description
    my $descrip ;
    if ( $descrip_fmt ne "" ) { 

	$descrip .= 'Chiù dâ palora: '. $descrip_fmt .'. More about the Sicilian word: ';
	$descrip .= $display .' '. $english_fmt .'.';
    } else {
	$descrip = 'Annotazzioni a nu dizziunariu sicilianu. Annotations to a Sicilian dictionary.';

    }

    ##  prepare keywords
    my $keywords;
    if ( $display ne "" ) { 
	$keywords .= $display .', ';
    }
    $keywords .= 'Sicilian dictionary, dizziunariu sicilianu, dizionario siciliano';
    
    ##  form the URL
    my $urlref = 'https://dizziunariu.napizia.com/chiu/';
    if ( ! defined $palora || $palora eq "" ) {
	my $blah = 'do nothing';
    } else {
	$urlref .= '?palora='. $palora ;
    }
    
    ##  prepare hash to return
    my %otinfo = (
	"card_title"    => $title_concat ,
	"card_descrip"  => $descrip ,
	"card_keywords" => $keywords ,
	"card_url"      => $urlref
	);
    
    ##  and return it
    return %otinfo ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #
# ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## #

1;
