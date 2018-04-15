#!/usr/bin/env perl

##  "mk_pos-tools.pl" -- makes tools for verbs, nouns and adjectives
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
use Storable qw( nstore ) ;
{   no warnings;             
    $Storable::Deparse = 1;  
    ## $Storable::Eval    = 1;  
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

my $otfile = '../cgi-lib/verb-tools' ; 

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
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  NOUNS
##  =====

sub mk_noun_plural {

    my $palora = $_[0] ;
    my $gender = $_[1] ;
    
    my $plural ;
    
    if ( $palora =~ /gghi[ua]$|cchi[ua]$/ ) {
	##  lu figghiu --> li figghi
	##  la figghia --> li figghi
	##  l'oricchia --> l'oricchi
	( $plural = $palora ) =~ s/hi[ua]$/hi/ ;

    } elsif ( $palora =~ /i[ua]$/ ) {
	##  lu studiu  --> li studii
	##  la grazzia --> la grazzii 
	( $plural = $palora ) =~ s/i[ua]$/ii/ ;

    } elsif ( ( $palora =~ /cu$/ && $gender eq "mas" ) || ( $palora =~ /ca$/ && $gender eq "fem" ) ) {
	##  lu parcu --> li parchi
	##  l'amica --> li amichi
	( $plural = $palora ) =~ s/c[ua]$/chi/ ;
	##  note:  important exceptions to this rule:
	##  l'amicu -> l'amici

    } elsif ( ( $palora =~ /eddu$/ || $palora =~ /aru$/ ) && $gender eq "mas" ) {
	##  lu marteddu --> li martedda 
	##  lu firraru --> li firrara
	( $plural = $palora ) =~ s/u$/a/ ;

    } elsif ( $palora =~ /uni$/ && $gender eq "mas" ) {
	##  lu baruni  --> li baruna 
	( $plural = $palora ) =~ s/uni$/una/ ;
	
    ##  
    ##  } elsif ( $palora =~ /uri$/ && $gender eq "mas" ) {
    ##  ##  lu dutturi --> li duttura
    ##  ( $plural = $palora ) =~ s/uri$/ura/ ;
    ##  ##  PERICULUSU !!!  plurals generally end in "i"
    ##  ##  so just mark these as irregular
    ##  

    } elsif ( $palora =~ /ng[ua]$/ ) {
	##  lu sgangu --> li sgagni 
	##  la janga  --> li jagni 
	( $plural = $palora ) =~ s/ng[ua]$/gni/ ; 
	
    } elsif ( ( $palora =~ /cu$/ && $gender eq "fem" ) || ( $palora =~ /[iàèìòù]$/ ) ) {
	##  la ficu   --> li ficu
	##  la facci  --> li facci
	##  l'azzioni --> l'azzioni
	##  lu cafè   --> li cafè
	$plural = $palora ;

    } elsif ( ( $palora =~ /u$/ && $gender eq "mas" ) || $palora =~ /a$/ ) {
	##  otherwise:  "-u/-a" to "-i"
	( $plural = $palora ) =~ s/[ua]$/i/ ; 
	
    } else {
	##  otherwise, probably foreign word
	##  lu sport -- > li sport
	$plural = $palora ;
    }

    return $plural ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  HASH of VERB ENDINGS
##  ==== == ==== =======

##  the hash to create
my %vbconj ;

##  same throughout -ARI
my %allari = (
    inf => "ari",
    pim => {                  ds => "a"      , ts => "assi"    ,
	     up => "amu"    , dp => "ati"    }, ## tp => "àssiru" },
    pai => { us => "avi"    , ds => "asti"   , ts => "au"      ,
	     up => "amu"    , dp => "àstivu" , tp => "aru"    },
    imi => { us => "ava"    , ds => "avi"    , ts => "ava"     ,
	     up => "àvamu"  , dp => "àvavu"  , tp => "àvanu"  },
    ims => { us => "assi"   , ds => "assi"   , ts => "assi"    ,
	     up => "àssimu" , dp => "àssivu" , tp => "àssiru" },
    ger => "annu" ,
    pap => "atu"  ,

    ##  imperative -- for use with reflexive pronouns
    pimr => {                 ds => "a"      , ts => "assi"   ,
	     up => "àmu"    , dp => "àti"    }, ## tp => "àssiru" },
    ); 
%{ $vbconj{xxari} } = %allari ;
%{ $vbconj{xcari} } = %allari ;
%{ $vbconj{xgari} } = %allari ;
%{ $vbconj{xiari} } = %allari ;
%{ $vbconj{ciari} } = %allari ;
%{ $vbconj{giari} } = %allari ;

##  same throughout -IRI
my %alliri = (
    inf => "iri",
    pim => {                  ds => "i"      , ts => "issi"    ,
	     up => "emu"    , dp => "iti"    }, ## tp => "ìssiru" },
    pai => { us => "ivi"    , ds => "isti"   , ts => "ìu"      ,
	     up => "emu"    , dp => "ìstivu" , tp => "eru"    },
    imi => { us => "eva"    , ds => "evi"    , ts => "eva"     ,
	     up => "èvamu"  , dp => "èvavu"  , tp => "èvanu"   },
    ims => { us => "issi"   , ds => "issi"   , ts => "issi"    ,
	     up => "ìssimu" , dp => "ìssivu" , tp => "ìssiru" },
    ger => "ennu" ,
    pap => "utu"  ,

    ##  imperative -- for use with reflexive pronouns
    pimr => {                 ds => "i"      , ts => "issi"    ,
	     up => "èmu"    , dp => "ìti"    }, ## tp => "ìssiru" },
    );
%{ $vbconj{xxiri} } = %alliri ;
%{ $vbconj{sciri} } = %alliri ;


##  PRI -- present indicative
my %prixxxi = ( us => "u"   , ds => "i"   , ts => "a"   ,
		up => "amu" , dp => "ati" , tp => "anu");
%{ $vbconj{xxari}{pri} } = %prixxxi ;
%{ $vbconj{xiari}{pri} } = %prixxxi ;

my %prixcxg = ( us => "u"   , ds => "hi"  , ts => "a"   ,
		up => "amu" , dp => "ati" , tp => "anu");
%{ $vbconj{xcari}{pri} } = %prixcxg ;
%{ $vbconj{xgari}{pri} } = %prixcxg ;


my %pricigi = ( us => "u"   , ds => ""    , ts => "a"   ,
		up => "amu" , dp => "ati" , tp => "anu");
%{ $vbconj{ciari}{pri} } = %pricigi ;
%{ $vbconj{giari}{pri} } = %pricigi ;


%{ $vbconj{xxiri}{pri} } = ( us => "u"   , ds => "i"   , ts => "i"   ,
			     up => "emu" , dp => "iti" , tp => "inu" );
%{ $vbconj{sciri}{pri} } = ( us => "iu"  , ds => "i"   , ts => "i"   ,
			     up => "emu" , dp => "iti" , tp => "inu" ) ; 


##  FTI -- future
my %ftixir = ( us => "irò"    , ds => "irai"   , ts => "irà"     ,
	       up => "iremu"  , dp => "iriti"  , tp => "irannu" );
%{ $vbconj{xxari}{fti} } = %ftixir ;
%{ $vbconj{xxiri}{fti} } = %ftixir ;
%{ $vbconj{sciri}{fti} } = %ftixir ;


my %ftihir = ( us => "hirò"   , ds => "hirai"  , ts => "hirà"   ,
	       up => "hiremu" , dp => "hiriti" , tp => "hirannu");
%{ $vbconj{xcari}{fti} } = %ftihir ;
%{ $vbconj{xgari}{fti} } = %ftihir ;


my %ftixxr = ( us => "rò"    , ds => "rai"   , ts => "rà"     ,
	       up => "remu"  , dp => "riti"  , tp => "rannu" );
%{ $vbconj{xiari}{fti} } = %ftixxr ;
%{ $vbconj{ciari}{fti} } = %ftixxr ;
%{ $vbconj{giari}{fti} } = %ftixxr ;


##  COI -- conditional
my %coixir = ( us => "irìa"   , ds => "irivi"  , ts => "irìa"   ,
	       up => "irìamu" , dp => "irìavu" , tp => "irìanu");
%{ $vbconj{xxari}{coi} } = %coixir ;
%{ $vbconj{xxiri}{coi} } = %coixir ;
%{ $vbconj{sciri}{coi} } = %coixir ;

my %coihir = ( us => "hirìa"   , ds => "hirivi"  , ts => "hirìa"   ,
	       up => "hirìamu" , dp => "hirìavu" , tp => "hirìanu");
%{ $vbconj{xcari}{coi} } = %coihir ;
%{ $vbconj{xgari}{coi} } = %coihir ;

my %coixxr = ( us => "rìa"   , ds => "rivi"  , ts => "rìa"   ,
	       up => "rìamu" , dp => "rìavu" , tp => "rìanu");
%{ $vbconj{xiari}{coi} } = %coixxr ;
%{ $vbconj{ciari}{coi} } = %coixxr ;
%{ $vbconj{giari}{coi} } = %coixxr ;


##  restemmed FTI and COI  -- same for all
%{ $vbconj{restem}{fti} } = %ftixxr ;
%{ $vbconj{restem}{coi} } = %coixxr ;

##  restemmed PAI  -- only for us,up,ts,tp
%{ $vbconj{quad}{pai} } = ( us => "ivi" , ts => "ìu"  ,
			    up => "emu" , tp => "eru" );


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  CONJUGATION  SUBROUTINES
##  ===========  ===========

##  ##  ##  ##  ##  ##  ##  ##  ##

##  remove all accents
sub rid_accents {
    my $boot = $_[0] ;
    $boot =~ s/à/a/g ; $boot =~ s/À/A/g ;
    $boot =~ s/è/e/g ; $boot =~ s/È/E/g ;
    $boot =~ s/ì/i/g ; $boot =~ s/Ì/I/g ;
    $boot =~ s/ò/o/g ; $boot =~ s/Ò/O/g ;
    $boot =~ s/ù/u/g ; $boot =~ s/Ù/U/g ;
    return $boot; 
}

##  only remove accent from the "boot" if on penultimate
##  but ultimate is already removed from "boot"
##  so in this sub want to remove the ultimate accent
sub rid_penult_accent {
    my $boot = $_[0] ;
    
    ##  strip consonants, then strip vowels before accent
    ( my $vowels = $boot ) =~ s/[bcdfghjklmnpqrstvwxyz]//g ;
    $vowels =~ s/^[aeiou]*// ;

    ##  count remaining vowels
    ##  if more than one vowel, keep accent, otherwise rid accent
    if ( length( $vowels ) > 2 ) { 
	my $blah = "keep accent" ;
    } else {
	$boot =~ s/à/a/g ; $boot =~ s/À/A/g ;
	$boot =~ s/è/e/g ; $boot =~ s/È/E/g ;
	$boot =~ s/ì/i/g ; $boot =~ s/Ì/I/g ;
	$boot =~ s/ò/o/g ; $boot =~ s/Ò/O/g ;
	$boot =~ s/ù/u/g ; $boot =~ s/Ù/U/g ;
    }    
    ##  NOTE:  the length function counts an accent vowel as "2"
    ##  and it counts an unaccented vowel as "1"
    ##  so we want to test if length greater than two
    
    return $boot ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##

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

##  ##  ##  ##  ##  ##  ##  ##  ##

##  conjugate reflexive verb
sub conjreflex {

    my %nonreflex = %{ $_[0] } ; 
    my %vbconj    = %{ $_[1] } ;  
    my %vbsubs    = %{ $_[2] } ;  
    my $prep      =    $_[3]   ;

    ##  conjugate the verb
    my %conjug = $vbsubs{conjnonreflex}( \%nonreflex , \%vbconj , \%vbsubs , $prep );

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

##  conjugate nonreflexive verb
sub conjnonreflex {
    
    my %palora = %{ $_[0] } ; 
    my %vbconj = %{ $_[1] } ;
    my %vbsubs = %{ $_[2] } ;
    my $prep   =    $_[3]   ;

    my %forms  = $vbsubs{mk_forms}() ; 
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
	my $priconj = $vbsubs{rid_penult_accent}( $boot ) . $vbconj{$conj}{pri}{$person} ;
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
	my $pimconj = $vbsubs{rid_penult_accent}( $boot ) . $vbconj{$conj}{pim}{$person} ;
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
	    $prep . $vbsubs{rid_penult_accent}( $palora{verb}{irrg}{pai}{quad} ) . $vbconj{quad}{pai}{$person} ;
	
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
	    $prep . $vbsubs{rid_penult_accent}( $palora{verb}{irrg}{pai}{quad} ) . $vbconj{quad}{pai}{$person} ;

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
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  hash to store subs
my %vbsubs ; 

##  conjugation subroutines
$vbsubs{rid_accents}        = \&rid_accents ;
$vbsubs{rid_penult_accent}  = \&rid_penult_accent ;
$vbsubs{mk_forms}           = \&mk_forms ;
$vbsubs{conjnonreflex}      = \&conjnonreflex ;
$vbsubs{conjreflex}         = \&conjreflex ;

##  noun and adjective subroutines
$vbsubs{mk_adjectives}  = \&mk_adjectives ;
$vbsubs{mk_noun_plural} = \&mk_noun_plural ;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  store it all
nstore( { vbconj   => \%vbconj   , 
	  vbsubs   => \%vbsubs   } , $otfile ); 


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##


##  ##  ##  ##  ##  ##  ##  ##  ##

##  À à  Â â
##  È è  Ê ê
##  Ì ì  Î î
##  Ò ò  Ô ô
##  Ù ù  Û û
