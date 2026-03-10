#!/usr/bin/env perl

##  "mk_pos-tools.pl" -- makes tools for verbs, nouns and adjectives
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

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

use strict;
#use warnings;
#no warnings qw( uninitialized );

use utf8;

use Storable qw( nstore ) ;
#{   no warnings;             
    $Storable::Deparse = 1;  
    ## $Storable::Eval    = 1;  
#}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

my $otfile = '../cgi-lib/verb-tools' ; 

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  NOUNS
##  =====

##  hash of noun plurals
my %nounpls = (
    xi => "i",      ##  xi   -- most noun plurals are "xi"
    xixa => "a",    ##  xixa -- some dialects "xi", others "xa" ... here "xa"
    xa => "a",      ##  xa   -- some masculine nouns are plural in "xa"
    xura => "ura",  ##  xura -- some dialects "xura", others "xi" ... here "xura"
    xx => "",       ##  xx   -- no change
    eddu => "edda", ##  eddu -- "eddu" to "edda"
    aru => "ara",   ##  aru  --  "aru" to  "ara"
    uni => "una",   ##  uni  --  "uni" to  "una"
    uri => "ura",   ##  uri  --  "uri" to  "ura"
) ;


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
    pai => { us => "ai"     , ds => "asti"   , ts => "au"      ,   ## us => "avi" , 
	     up => "amu"    , dp => "àstivu" , tp => "aru"    },   ## up => "ammu" , 
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

##  same throughout -IRI ... with one exception
my %alliri = (
    inf => "iri",
    pim => {                  ds => "i"      , ts => "issi"    ,
	     up => "emu"    , dp => "iti"    }, ## tp => "ìssiru" },
    pai => { us => "ivi"    , ds => "isti"   , ts => "ìu"      ,   ## us => "ìi" , 
	     up => "emu"    , dp => "ìstivu" , tp => "eru"    },   ## up => "emmu" , 

    imi => { us => "eva"    , ds => "evi"    , ts => "eva" ,
	     up => "èvamu"  , dp => "èvavu"  , tp => "èvanu" },
    ## imi => { us => "ìa"     , ds => "ivi"    , ts => "ìa"      ,  
    ##          up => "ìamu"   , dp => "ìavu"   , tp => "ìanu"   },  

    ims => { us => "issi"   , ds => "issi"   , ts => "issi"    ,
	     up => "ìssimu" , dp => "ìssivu" , tp => "ìssiru" },
    ger => "ennu" ,
    
    ##  imperative -- for use with reflexive pronouns
    pimr => {                 ds => "i"      , ts => "issi"    ,
	     up => "èmu"    , dp => "ìti"    }, ## tp => "ìssiru" },
    );
%{ $vbconj{xxiri} } = %alliri ;
%{ $vbconj{xciri} } = %alliri ;
%{ $vbconj{xgiri} } = %alliri ;
%{ $vbconj{xsiri} } = %alliri ;
%{ $vbconj{sciri} } = %alliri ;

##  the exception
my %xxhiri = (
    inf => "iri",
    pim => {                  ds => "i"      , ts => "issi"    ,
	     up => "iemu"   , dp => "iti"    }, ## tp => "ìssiru" },
    pai => { us => "ivi"    , ds => "isti"   , ts => "ìu"      ,   ## us => "ìi" , 
	     up => "iemu"   , dp => "ìstivu" , tp => "ieru"   },   ## up => "iemmu" , 

    imi => { us => "ieva"   , ds => "ievi"   , ts => "ieva" ,
	     up => "ièvamu" , dp => "ièvavu" , tp => "ièvanu" },
    ## imi => { us => "ìa"     , ds => "ivi"   , ts => "ìa"     , 
    ##          up => "ìamu"   , dp => "ìavu"  , tp => "ìanu"   },

    ims => { us => "issi"   , ds => "issi"   , ts => "issi"    ,
	     up => "ìssimu" , dp => "ìssivu" , tp => "ìssiru" },
    ger => "iennu" ,
    
    ##  imperative -- for use with reflexive pronouns
    pimr => {                 ds => "i"      , ts => "issi"    ,
	     up => "ièmu"   , dp => "ìti"    }, ## tp => "ìssiru" },
    );
%{ $vbconj{xhiri} } = %xxhiri ;


##  PAP -- past participle
$vbconj{xxiri}{pap} = "utu";
$vbconj{xciri}{pap} = "iutu";
$vbconj{xgiri}{pap} = "iutu";
$vbconj{xhiri}{pap} = "iutu";
$vbconj{xsiri}{pap} = "iutu";
$vbconj{sciri}{pap} = "utu";

##  PRI -- present indicative
##  -ARI verbs
my %prixxxi = ( us => "u"   , ds => "i"   , ts => "a"   ,
		up => "amu" , dp => "ati" , tp => "anu");  ##  tp => "unu" );
%{ $vbconj{xxari}{pri} } = %prixxxi ;
%{ $vbconj{xiari}{pri} } = %prixxxi ;

my %prixcxg = ( us => "u"   , ds => "hi"  , ts => "a"   ,
		up => "amu" , dp => "ati" , tp => "anu");  ##  tp => "unu" );
%{ $vbconj{xcari}{pri} } = %prixcxg ;
%{ $vbconj{xgari}{pri} } = %prixcxg ;


my %pricigi = ( us => "u"   , ds => ""    , ts => "a"   ,
		up => "amu" , dp => "ati" , tp => "anu");  ##  tp => "unu" );
%{ $vbconj{ciari}{pri} } = %pricigi ;
%{ $vbconj{giari}{pri} } = %pricigi ;

##  PRI -- present indicative
##  -IRI verbs
my %prixxiri = ( us => "u"   , ds => "i"   , ts => "i"   ,
		 up => "emu" , dp => "iti" , tp => "unu" );  ##  tp => "inu" );
%{ $vbconj{xxiri}{pri} } = %prixxiri ;

my %pricgiri = ( us => "iu"  , ds => "i"   , ts => "i"   ,
		 up => "emu" , dp => "iti" , tp => "iunu" );  ##  tp => "inu" );
%{ $vbconj{xciri}{pri} } = %pricgiri ;
%{ $vbconj{xgiri}{pri} } = %pricgiri ;
%{ $vbconj{xsiri}{pri} } = %pricgiri ;			   
%{ $vbconj{sciri}{pri} } = %pricgiri ;

my %prixhiri = ( us => "iu"  , ds => "i"   , ts => "i"   ,
		 up => "iemu", dp => "iti" , tp => "iunu" );  ##  tp => "inu" );   
%{ $vbconj{xhiri}{pri} } = %prixhiri ;


##  FTI -- future
my %ftixir = ( us => "irò"    , ds => "irai"   , ts => "irà"     ,
	       up => "iremu"  , dp => "iriti"  , tp => "irannu" );
%{ $vbconj{xxari}{fti} } = %ftixir ;
%{ $vbconj{xxiri}{fti} } = %ftixir ;
%{ $vbconj{xciri}{fti} } = %ftixir ;
%{ $vbconj{xgiri}{fti} } = %ftixir ;
%{ $vbconj{xhiri}{fti} } = %ftixir ;
%{ $vbconj{xsiri}{fti} } = %ftixir ;
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
%{ $vbconj{xciri}{coi} } = %coixir ;
%{ $vbconj{xgiri}{coi} } = %coixir ;
%{ $vbconj{xhiri}{coi} } = %coixir ;
%{ $vbconj{xsiri}{coi} } = %coixir ;
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
%{ $vbconj{quad}{pai} } = ( us => "i"   , ts => "i"  , 
			    up => "imu" , tp => "iru" );

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  store it all
nstore( { nounpls  => \%nounpls  , 
	  vbconj   => \%vbconj   } , $otfile ); 

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##


##  ##  ##  ##  ##  ##  ##  ##  ##

##  À à  Â â
##  È è  Ê ê
##  Ì ì  Î î
##  Ò ò  Ô ô
##  Ù ù  Û û

