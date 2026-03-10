package Napizia::PosTools;

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

sub rid_accents { Napizia::TextTools::rid_accents( $_[0] );}

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ("mk_adjectives","mk_noun_plural","mk_forms",
    "conjugate","conjreflex","conjnonreflex");

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  ADJECTIVES
##  ==========

sub mk_adjectives {

    my $palora = $_[0] ;

    ##  Dieli's dictionary provides adjective in masculine singular
    ##  most masculine singular adjectives end in "-u", but some end in "-a" 
    ##  most  feminine  singular adjectives end in "-a" 
    ##  sometimes both masc. and fem. singular end in "-i"
    my $massi = $palora ;
    ( my $femsi = $palora ) =~ s/u$/a/ ;

    ##  most adjectives have only one plural form, but some have two:
    ##         l'omu catolicu -->    l'omini catolici
    ##    la fimmina catolica --> li fimmini catolichi 
    ( my $maspl = $palora ) =~ s/[ua]$/i/ ;
    my $fempl ; 
    if ( $palora =~ /cu$/ ) {
	( $fempl = $palora ) =~ s/cu$/chi/ ;
    } else {
	( $fempl = $palora ) =~ s/[ua]$/i/ ;
    }

    ##  l'omu vecchiu --> l'omini vecchi
    ##  so remove last "i"  when "-cchiu" or "-gghiu"
    if ( $palora =~ /cchiu$|gghiu$/ ) {
	$maspl =~ s/ii$/i/ ;
	$fempl =~ s/ii$/i/ ;
    }

    my @otarray = ( $massi , $femsi , $maspl , $fempl ) ;    
    return @otarray ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  NOUNS
##  =====

sub mk_noun_plural {

    my $palora  =    $_[0] ;
    my $gender  =    $_[1] ;
    my $plend   =    $_[2] ;
    my %nounpls = %{ $_[3] } ; 

    ##  plurals in "xi" need to be carefully paired
    ##  all others simple substitution
    
    ##  make plural
    my $plural ;

    if ( $gender eq "fem" || $gender eq "both" ) {
	##  if feminine or both
	##  all feminine nouns are plural in either "xi" or "xx"

	if ( $nounpls{$plend} eq "i" ) {
	    ##  case where:   xi => "i", 
	        
	    if ( $palora =~ /gghia$|cchia$/ ) {
		##  lu figghiu --> li figghi
		##  la figghia --> li figghi
		##  l'oricchia --> l'oricchi
		##  lu stinnicchiu --> li stinicchi
		( $plural = $palora ) =~ s/hia$/hi/ ;
		
	    } elsif ( $palora =~ /ia$/ ) {
		##  lu diu  --> li dii
		##  la malatia --> li malatii
		( $plural = $palora ) =~ s/ia$/ii/ ;
		
	    } elsif ( $palora =~ /ca$/ ) {
		##  lu parcu --> li parchi
		##  l'amica --> li amichi
		( $plural = $palora ) =~ s/ca$/chi/ ;
		##  note:  important exceptions to this rule:
		##  l'amicu -> l'amici
		
	    } elsif ( $palora =~ /nga$/ ) {
		##  la janga  --> li jagni 
		##  lu sgangu --> li sgagni 
		( $plural = $palora ) =~ s/nga$/gni/ ; 

	    } elsif ( $palora =~ /ga$/ ) {
		##  lu parcu --> li parchi
		##  l'amica --> li amichi
		( $plural = $palora ) =~ s/ga$/ghi/ ;
		##  note:  important exceptions to this rule:
		##  l'amicu -> l'amici

	    } elsif ( $palora =~ /a$/ ) {
		##  otherwise:  "-a" to "-i"
		( $plural = $palora ) =~ s/a$/i/ ; 
	    } else {		
		##  case where:  ( $palora =~ /[ui]$/ ) 
		$plural = $palora ;
	    }

	} else {
	    ##  case where:  ( $nounpls{$plend} eq "" ) 
	    ##  case where:   xx => "", 
		
	    ##  la ficu   --> li ficu
	    ##  la facci  --> li facci
	    ##  l'azzioni --> l'azzioni
	    ##  lu cafè   --> li cafè
	    ##  lu sport -- > li sport
	    $plural = $palora ;	    
	}

    } elsif  ( $gender eq "mas" ) {
	##  if masculine 

	if ( $nounpls{$plend} eq "i" ) {
	    ##  case where:   xi => "i", 

	    if ( $palora =~ /gghi[ua]$|cchi[ua]$/ ) {
		##  lu figghiu --> li figghi
		##  la figghia --> li figghi
		##  l'oricchia --> l'oricchi
		##  lu stinnicchiu --> li stinicchi
		( $plural = $palora ) =~ s/hi[ua]$/hi/ ;
		
	    } elsif ( $palora =~ /i[ua]$/ ) {
		##  lu diu  --> li dii
		##  la malatia --> li malatii
		( $plural = $palora ) =~ s/i[ua]$/ii/ ;
		
	    } elsif ( $palora =~ /c[ua]$/ ) {
		##  lu parcu --> li parchi
		##  lu duca --> li duchi
		( $plural = $palora ) =~ s/c[ua]$/chi/ ;
		##  note:  important exceptions to this rule:
		##  l'amicu -> l'amici

	    } elsif ( $palora =~ /ng[ua]$/ ) {
		##  la janga  --> li jagni 
		##  lu sgangu --> li sgagni 
		( $plural = $palora ) =~ s/ng[ua]$/gni/ ; 

	    } elsif ( $palora =~ /g[ua]$/ ) {
		##  lu parcu --> li parchi
		##  lu duca --> li duchi
		( $plural = $palora ) =~ s/g[ua]$/ghi/ ;
		##  note:  important exceptions to this rule:
		##  l'amicu -> l'amici

	    } elsif ( $palora =~ /[au]$/ ) {
		##  lu capu --> li capi 
		( $plural = $palora ) =~ s/[au]$/i/ ; 

	    } else {		
		##  case where:  ( $palora =~ /i$/ ) 
		$plural = $palora ;
	    }

	} elsif ( $nounpls{$plend} =~ /a$/ ) {
	    ##  case where:   xa => "a",      
	    ##              eddu => "edda", 
	    ##               aru => "ara",   
	    ##               uni => "una",   
	    ##               uri => "ura",   
	    ##              xura => "ura",  

	    if ( $plend eq "xura" && $nounpls{$plend} =~ /^ura$/ ) {
		( $plural = $palora ) =~ s/u$/ura/ ;

	    } else {
		##  lu marteddu --> li martedda 
		##  lu firraru --> li firrara
		##  lu baruni  --> li baruna 
		##  lu dutturi --> li duttura
		( $plural = $palora ) =~ s/[aiu]$/a/ ;
	    }

	} else {
	    ##  case where:  ( $nounpls{$plend} eq "" ) 
	    ##  case where:   xx => "", 
		
	    ##  la ficu   --> li ficu
	    ##  la facci  --> li facci
	    ##  l'azzioni --> l'azzioni
	    ##  lu cafè   --> li cafè
	    ##  lu sport -- > li sport
	    $plural = $palora ;
	}
    }
    return $plural ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  CONJUGATION  SUBROUTINES
##  ===========  ===========

sub mk_forms {

    my %forms = (
	tenses => ["pri","pim","pai","imi","ims","fti","coi","ger","pap","adj","inf"],
	tnhash => {"pri" => "prisenti" ,
		   "pim" => "mpirativu",
		   "pai" => "passatu" ,
		   "imi" => "mpirfettu ndi." ,
		   "ims" => "mpirfettu cung." ,
		   "fti" => "futuru" ,
		   "coi" => "cundiziunali",
		   "ger" => "girunniu",
		   "pap" => "participiu",
		   "adj" => "aggittivu",
		   "inf" => "nfinitu"},
	people => ["us","ds","ts","up","dp","tp"]
	) ;
    return %forms ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub conjugate {

    my $palora =    $_[0]   ;
    my %vnotes = %{ $_[1] } ;
    my $vbcref =    $_[2]   ;  ##  hash reference

    ##  which word do we display?
    my %othash ;

    ##  which are defined?
    my $reflex  = ( ! defined $vnotes{$palora}{reflex} ) ? undef : $vnotes{$palora}{reflex} ; 
    my $prepend ; 
    if ( ! defined $reflex ) {
	$prepend = $vnotes{$palora}{prepend} ;
    } else {	
	$prepend = ( ! defined $vnotes{$reflex}{prepend} ) ? $vnotes{$palora}{prepend} : $vnotes{$reflex}{prepend} ;
    }
    my $prep  = ( ! defined ${$prepend}{prep} ) ? ""      : ${$prepend}{prep} ;
    my $verb  = ( ! defined ${$prepend}{verb} ) ? $palora : ${$prepend}{verb} ;  
    
    ##  if not reflexive, then conjugate non-reflexively; 
    ##  otherwise reflexive
    if ( ! defined $reflex ) {
	%othash = conjnonreflex( $vnotes{$verb} , $vbcref , $prep );
    } else {
	##  it's reflexive, so ...
	##  if "$reflex" (the non-reflexive verb) is not a prepend, then reflexively conjugate "$reflex"  
	##  otherwise it's a prepend, so reflexively conjugate "$verb" (the verb to be prepended)
	if ( ! defined 	$vnotes{$reflex}{prepend} ) {
	    %othash = conjreflex( $vnotes{$reflex} , $vbcref , $prep );
	} else {
	    %othash = conjreflex( $vnotes{$verb} , $vbcref , $prep );
	}
    }

    return %othash ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  conjugate reflexive verb
sub conjreflex {

    my %nonreflex = %{ $_[0] } ; 
    my %vbconj    = %{ $_[1] } ;  
    my $prep      =    $_[2]   ;

    ##  conjugate the verb
    my %conjug = conjnonreflex( \%nonreflex , \%vbconj , $prep );

    my %rprons = ("us" => "mi" , "ds" => "ti" , "ts" => "si" ,
		  "up" => "ni" , "dp" => "vi" , "tp" => "si" );

    ##  add the reflexive pronoun to the front
    foreach my $tense ("pri","pai","imi","ims","fti","coi") {
	foreach my $person ("us","ds","ts","up","dp","tp") {
	    $conjug{$tense}{$person} = $rprons{$person} . " " . $conjug{$tense}{$person} ;
	}
    }
    ##  add the reflexive pronoun to the end
    $conjug{ger} = $conjug{ger} . $rprons{ts} ;
    $conjug{inf} = $conjug{inf} . $rprons{ts} ;

    ##  boot, stem and conj
    my $boot = $prep . $nonreflex{verb}{boot} ; 
    my $stem = $prep . $nonreflex{verb}{stem} ; 
    my $conj = $nonreflex{verb}{conj} ;

    ##  PIM -- imperative -- using PIMR forms to account for accents
    ##  accent on boot
    ##  boot will not be penultimate with reflex pronoun, so keep accents
    my $pimconj = $boot . $vbconj{$conj}{pimr}{ds} ;
    $conjug{pim}{ds} = ( ! defined $nonreflex{verb}{irrg}{pim}{ds} ) ? $pimconj : $prep . $nonreflex{verb}{irrg}{pim}{ds} ; 
    foreach my $person ("ts","up","dp") { 
	##  accent on unstressed stem
	my $pimconj = $stem . $vbconj{$conj}{pimr}{$person} ;
	$conjug{pim}{$person} = ( ! defined $nonreflex{verb}{irrg}{pim}{$person} ) ? $pimconj : $prep . $nonreflex{verb}{irrg}{pim}{$person} ; 
    }    
    ##  add the reflexive pronoun to the end
    foreach my $person ("ds","dp") { 
	$conjug{pim}{$person} = $conjug{pim}{$person} . $rprons{$person} ; 
    }
    ##  add the reflexive pronoun to the beginning -- polite form
    foreach my $person ("ts") { 
	##  my $abbrevORnot = ( $conjug{pim}{$person} =~ /^[aeiouàèìòù]/ ) ? "s'" : $rprons{$person} ;
	my $abbrevORnot = $rprons{$person} ;
	$conjug{pim}{$person} = $abbrevORnot . " " . $conjug{pim}{$person} ; 
    }
    ##  "double n" in 1st pl.  -- "nzignamunni lu sicilianu!"
    $conjug{pim}{up} = $conjug{pim}{up} ."n". $rprons{up} ; 

    return %conjug ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  conjugate nonreflexive verb
sub conjnonreflex {
    
    my %palora = %{ $_[0] } ; 
    my %vbconj = %{ $_[1] } ;
    my $prep   =    $_[2]   ;

    my %forms  = mk_forms() ; 
    my @tenses = @{ $forms{tenses} } ; 
    my %tnhash = %{ $forms{tnhash} } ; 
    my @people = @{ $forms{people} } ; 

    ##  get conjugation and subconjugation
    my %conjug ; 
    my $conj = $palora{verb}{conj} ;
    
    ##  get stem and boot -- prepend if necessary
    my $stem = $prep . $palora{verb}{stem} ; 
    my $boot = $prep . $palora{verb}{boot} ;

    ##  PRI -- present indicative
    foreach my $person ("us","ds","ts") { 
	##  accent on boot, but boot has penultimate, so rid accents
	my $priconj = rid_accents( $boot ) . $vbconj{$conj}{pri}{$person} ;
	$conjug{pri}{$person} = ( ! defined $palora{verb}{irrg}{pri}{$person} ) ? $priconj : 
	    $prep . $palora{verb}{irrg}{pri}{$person} ; 
    } 
    foreach my $person ("tp") { 
	##  accent on boot, so keep it
	my $priconj = $boot . $vbconj{$conj}{pri}{$person} ;
	$conjug{pri}{$person} = ( ! defined $palora{verb}{irrg}{pri}{$person} ) ? $priconj : 
	    $prep . $palora{verb}{irrg}{pri}{$person} ; 
    } 
    foreach my $person ("up","dp") { 
	##  accent on unstressed stem
	my $priconj = $stem . $vbconj{$conj}{pri}{$person} ;
	$conjug{pri}{$person} = ( ! defined $palora{verb}{irrg}{pri}{$person} ) ? $priconj : 
	    $prep . $palora{verb}{irrg}{pri}{$person} ; 
    } 

    ##  FTI  -- future
    ##  COI  -- conditional
    foreach my $tense ("fti","coi") { 
	if ( ! defined $palora{verb}{irrg}{$tense}{stem} ) {
	    ##  without new stem
	    foreach my $person (@people) {
		my $regconj = $stem . $vbconj{$conj}{$tense}{$person} ;
		$conjug{$tense}{$person} = ( ! defined $palora{verb}{irrg}{$tense}{$person} ) ? $regconj : 
		    $prep . $palora{verb}{irrg}{$tense}{$person} ; 
	    }
	} else { 
	    ##  with new stem
	    foreach my $person (@people) {
		my $regconj = $palora{verb}{irrg}{$tense}{stem} . $vbconj{restem}{$tense}{$person} ;
		$conjug{$tense}{$person} = ( ! defined $palora{verb}{irrg}{$tense}{$person} ) ? $regconj : 
		    $prep . $palora{verb}{irrg}{$tense}{$person} ;
	    }
	}
    }
    
    ##  PIM -- imperative
    foreach my $person ("ds") {
	##  accent on boot, but boot has penultimate, so rid accents
	my $pimconj = rid_accents( $boot ) . $vbconj{$conj}{pim}{$person} ;
	$conjug{pim}{$person} = ( ! defined $palora{verb}{irrg}{pim}{$person} ) ? $pimconj : 
	    $prep . $palora{verb}{irrg}{pim}{$person} ; 	
    }
    foreach my $person ("ts","up","dp") {
	##  accent on unstressed stem
	my $pimconj = $stem . $vbconj{$conj}{pim}{$person} ;
	$conjug{pim}{$person} = ( ! defined $palora{verb}{irrg}{pim}{$person} ) ? $pimconj : 
	    $prep . $palora{verb}{irrg}{pim}{$person} ; 
    }    

    ##  PAI  -- ds,dp
    foreach my $person ("ds","dp") {
	##  accent on unstressed stem
	my $regconj = $stem . $vbconj{$conj}{pai}{$person} ;
	$conjug{pai}{$person} = ( ! defined $palora{verb}{irrg}{pai}{$person} ) ? $regconj : 
	    $prep . $palora{verb}{irrg}{pai}{$person} ; 
    }
    ##  PAI  -- us,ts
    foreach my $person ("us","ts") {
	##  accent on unstressed stem -- regular conjugation
	my $regconj = $stem . $vbconj{$conj}{pai}{$person} ; 

	##  quadcjs replaces regular conjugation -- rid accents
	my $quadcjs = ( ! defined $palora{verb}{irrg}{pai}{quad} ) ? $regconj : 
	    $prep . rid_accents( $palora{verb}{irrg}{pai}{quad} ) . $vbconj{quad}{pai}{$person} ;
	
	##  irregular conjugation replaces quadcjs -- pass the final choice
	$conjug{pai}{$person} = ( ! defined $palora{verb}{irrg}{pai}{$person} ) ? $quadcjs : 
	    $prep . $palora{verb}{irrg}{pai}{$person} ; 
    }
    ##  PAI  -- up,tp
    foreach my $person ("up","tp") {
	##  accent on unstressed stem -- regular conjugation
	my $regconj = $stem . $vbconj{$conj}{pai}{$person} ; 

	##  quadcjs replaces regular conjugation
	my $quadcjs = ( ! defined $palora{verb}{irrg}{pai}{quad} ) ? $regconj : 
	    $prep . rid_accents( $palora{verb}{irrg}{pai}{quad} ) . $vbconj{quad}{pai}{$person} ;

	##  irregular conjugation replaces quadcjs -- pass the final choice
	$conjug{pai}{$person} = ( ! defined $palora{verb}{irrg}{pai}{$person} ) ? $quadcjs : 
	    $prep . $palora{verb}{irrg}{pai}{$person} ; 
    }

    ##  IMI  IMS  
    foreach my $tense ("imi","ims") { 
	foreach my $person (@people) {
	    ##  accent on unstressed stem
	    my $regconj = $stem . $vbconj{$conj}{$tense}{$person} ;
	    $conjug{$tense}{$person} = ( ! defined $palora{verb}{irrg}{$tense}{$person} ) ? $regconj : 
		$prep . $palora{verb}{irrg}{$tense}{$person} ; 
	}
    }
    ##  GER  PAP  ADJ
    ##  accent on unstressed stem
    my $gerconj = $stem . $vbconj{$conj}{ger} ; 
    my $papconj = $stem . $vbconj{$conj}{pap} ; 
    my $adjconj = $stem . $vbconj{$conj}{pap} ; ##  making adjective with PAP
    $conjug{ger} = ( ! defined $palora{verb}{irrg}{ger} ) ? $gerconj : $prep . $palora{verb}{irrg}{ger} ;
    $conjug{pap} = ( ! defined $palora{verb}{irrg}{pap} ) ? $papconj : $prep . $palora{verb}{irrg}{pap} ;
    $conjug{adj} = ( ! defined $palora{verb}{irrg}{adj} ) ? $adjconj : $prep . $palora{verb}{irrg}{adj} ;

    ##  INF
    my $infconj ;
    if ($conj eq "xxiri" ) {
	$infconj = $boot . $vbconj{$conj}{inf} ; 
    } else {
	##  ( $conj =~ /^sciri$|^xxari$|^xcari$|^xgari$|^xiari$|^ciari$|^giari$/ )
	$infconj = $stem . $vbconj{$conj}{inf} ; 
    }
    $conjug{inf} = ( ! defined $palora{verb}{irrg}{inf} ) ? $infconj : $prep . $palora{verb}{irrg}{inf} ; 

    ##  return result
    return %conjug ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

1;
