#!/usr/bin/env perl

##  "mk_dieli-edits.pl" -- edits the Dieli dictionary
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

use Storable qw( retrieve nstore ) ;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  list of Dieli hashes
my $dieli_sc_dict = '../cgi-lib/dieli-sc-dict' ; 
my $dieli_en_dict = '../cgi-lib/dieli-en-dict' ; 
my $dieli_it_dict = '../cgi-lib/dieli-it-dict' ; 

##  retrieve SiCilian
my %dieli_sc = %{ retrieve( $dieli_sc_dict ) } ;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  ERRORS
##  ======

##  $ ./query-dieli.pl sc largu Stti 
##  	0  ==  Stti Uniti {mpl} --> stati uniti {mpl} --> United States {pl}
$dieli_sc{"Stati Uniti"} = $dieli_sc{"Stti Uniti"} ; 
${$dieli_sc{"Stati Uniti"}[0]}{"sc_word"} = 'Stati Uniti';
delete( $dieli_sc{"Stti Uniti"} );

## $ ./query-dieli.pl sc strittu inviitari
## 	0  ==  inviitari {v} --> invitare {v} --> invite {v}
{ my $search = "invitari" ; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "invitare" ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "invite"   ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
delete($dieli_sc{"inviitari"});

## $ ./query-dieli.pl sc strittu nviitari
## 	0  ==  nviitari {v} --> invitare {v} --> invite {v}
{ my $search = "nvitari" ; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "invitare" ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "invite"   ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
delete($dieli_sc{"nviitari"});

## $ ./query-dieli.pl sc strittu pati
## 	0  ==  pati {} --> <br> {} --> suffers {}
##  so ADD:  "patiri"
{ my $search = "patiri" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "patire"  ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "suffer"  ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "patiri" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "soffrire"; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "suffer"  ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
##  
## Mortillaro conjugates as:  "patisci"
## "Cui nun patisci un godisci." (Mortillaro)
## 
## Dieli and Sicilian Wikipedia both conjugate as:  "pati"
## see:  https://scn.wikipedia.org/wiki/Pruverbi_siciliani
##
## $ ./query-dieli.pl sc strittu pati
## 	0  ==  pati {} --> <br> {} --> suffers {}
delete($dieli_sc{"pati"});
##
#${$dieli_sc{"pati"}[0]}{"sc_part"} = '{v}';
#${$dieli_sc{"pati"}[0]}{"it_word"} = 'patisce';
#${$dieli_sc{"pati"}[0]}{"it_part"} = '{v}';
#${$dieli_sc{"pati"}[0]}{"en_part"} = '{v}';

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  HOMONYMS
##  ========

##  $ ./query-dieli.pl sc strittu amuri
##  	0  ==  amuri {f} --> mora {f} --> blackberry {n}
##  	1  ==  amuri {m} --> amore {m} --> love {n}
${$dieli_sc{"amuri"}[0]}{"linkto"} = "amuri_blackberry";
${$dieli_sc{"amuri"}[1]}{"linkto"} = "amuri_love";

## $ ./query-dieli.pl sc strittu cantu
## 	0  ==  cantu {m} --> angolo {m} --> angle (corner) {n}
## 	1  ==  cantu {m} --> angolo {m} --> corner {n}
## 	2  ==  cantu {m} --> melodia {f} --> melody {n}
## 	3  ==  cantu {m} --> <br> {} --> side {n}
## 	4  ==  cantu {m} --> canzone {m} --> song {n}
${$dieli_sc{"cantu"}[0]}{"linkto"} = "cantu_angle";
${$dieli_sc{"cantu"}[1]}{"linkto"} = "cantu_angle";
${$dieli_sc{"cantu"}[2]}{"linkto"} = "cantu_song";
${$dieli_sc{"cantu"}[3]}{"linkto"} = "cantu_angle";
${$dieli_sc{"cantu"}[4]}{"linkto"} = "cantu_song";

##  $ ./query-dieli.pl sc strittu corpu 
##  
##  	0  ==  corpu {m} --> colpo {m} --> blow {n}
##  	1  ==  corpu {m} --> corpo {m} --> body {n}
##  	2  ==  corpu {m} --> colpo {m} --> bump {n}
##  	3  ==  corpu {} --> <br> {} --> corpus {}
##  	4  ==  corpu {} --> colpo {} --> hit {}
##  	5  ==  corpu {m} --> <br> {m} --> shot {n}
##  	6  ==  corpu {m} --> colpo {m} --> stroke {n}
${$dieli_sc{"corpu"}[0]}{"linkto"} = "corpu_blow";
${$dieli_sc{"corpu"}[1]}{"linkto"} = "corpu_body";
${$dieli_sc{"corpu"}[2]}{"linkto"} = "corpu_blow";
${$dieli_sc{"corpu"}[3]}{"linkto"} = "corpu_body";
${$dieli_sc{"corpu"}[4]}{"linkto"} = "corpu_blow";
${$dieli_sc{"corpu"}[5]}{"linkto"} = "corpu_blow";
${$dieli_sc{"corpu"}[6]}{"linkto"} = "corpu_blow";

${$dieli_sc{"corpu"}[3]}{"sc_part"} = '{m}';
${$dieli_sc{"corpu"}[3]}{"en_part"} = '{n}';
${$dieli_sc{"corpu"}[4]}{"sc_part"} = '{m}';
${$dieli_sc{"corpu"}[4]}{"it_part"} = '{m}';
${$dieli_sc{"corpu"}[4]}{"en_part"} = '{n}';
${$dieli_sc{"corpu"}[5]}{"it_part"} = '{}';

## $ ./query-dieli.pl sc strittu cucina cucinu
## 	0  ==  cucina {f} --> cugina {f} --> cousin {n}
## 	1  ==  cucina {} --> cucina {} --> kitchen {}
## 	0  ==  cucinu {m} --> cugino {m} --> cousin {n}
${$dieli_sc{"cucinu"}[0]}{"linkto"} = "cucinu_cousin";
${$dieli_sc{"cucina"}[0]}{"linkto"} = "cucina_cousin";
${$dieli_sc{"cucina"}[1]}{"linkto"} = "cucina_kitchen";
${$dieli_sc{"cucina"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"cucina"}[1]}{"it_part"} = '{f}';
${$dieli_sc{"cucina"}[1]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu cuda cura
## 	0  ==  cuda {f} --> coda {f} --> tail {n}
## 	0  ==  cura {f} --> cura {f} --> care {n}
## 	1  ==  cura {f} --> cura {f} --> cure {n}
## 	2  ==  cura {f} --> <br> {f} --> diligence {n}
## 	3  ==  cura {} --> coda {} --> tail {}
${$dieli_sc{"cuda"}[0]}{"linkto"} = "cuda_noun";
${$dieli_sc{"cura"}[0]}{"linkto"} = "cura_noun";
${$dieli_sc{"cura"}[1]}{"linkto"} = "cura_noun";
${$dieli_sc{"cura"}[2]}{"linkto"} = "cura_noun";
${$dieli_sc{"cura"}[2]}{"it_word"} = "cura";
${$dieli_sc{"cura"}[3]}{"linkto"} = "cuda_noun";
${$dieli_sc{"cura"}[3]}{"sc_part"} = '{f}';
${$dieli_sc{"cura"}[3]}{"it_part"} = '{f}';
${$dieli_sc{"cura"}[3]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu guardia
## 	0  ==  guardia {m} --> guardia {m} --> policeman {n}
${$dieli_sc{"guardia"}[0]}{"linkto"} = 'guardia_police';
##  
##  ADD:  feminine form -- the act of watching
{ my $search = "guardia" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = '{f}';
  $th{"it_word"} = "guardia" ; $th{"it_part"} = '{f}';
  $th{"en_word"} = "watch"   ; $th{"en_part"} = '{n}';  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "guardia" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = '{f}';
  $th{"it_word"} = "guardia" ; $th{"it_part"} = '{f}';
  $th{"en_word"} = "guard"   ; $th{"en_part"} = '{n}';
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
${$dieli_sc{"guardia"}[1]}{"linkto"} = 'guardia_watch';
${$dieli_sc{"guardia"}[2]}{"linkto"} = 'guardia_watch';


## $ ./query-dieli.pl sc strittu matrici
## 	0  ==  matrici {f} --> chiesa {f} --> church (chief one) {n}
## 	1  ==  matrici {} --> matrice {} --> matrix {}
${$dieli_sc{"matrici"}[0]}{"linkto"} = 'matrici_church';
${$dieli_sc{"matrici"}[1]}{"linkto"} = 'matrici_matrix';
${$dieli_sc{"matrici"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"matrici"}[1]}{"it_part"} = '{f}';
${$dieli_sc{"matrici"}[1]}{"en_part"} = '{n}';


## $ ./query-dieli.pl sc strittu inglisi 
## 	0  ==  inglisi {adj} --> inglese {adj} --> English {adj}
## 	1  ==  inglisi {m} --> inglese {m} --> Englishman {n}
## 	2  ==  inglisi {f} --> <br> {f} --> Englishwoman {n}
${$dieli_sc{"inglisi"}[1]}{"linkto"} = 'ngrisi_man';
${$dieli_sc{"inglisi"}[2]}{"linkto"} = 'ngrisi_woman';
${$dieli_sc{"inglisi"}[2]}{"it_word"} = 'inglese';

{ my $search = "nglisi" ; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = '{adj}';
  $th{"it_word"} = "inglese"  ; $th{"it_part"} = '{adj}';
  $th{"en_word"} = "English"  ; $th{"en_part"} = '{adj}';
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "nglisi" ; 
  my %th ;  
  $th{"sc_word"} = $search        ; $th{"sc_part"} = '{f}';
  $th{"it_word"} = "inglese"      ; $th{"it_part"} = '{f}';
  $th{"en_word"} = "Englishwoman" ; $th{"en_part"} = '{n}';
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "nglisi" ; 
  my %th ;  
  $th{"sc_word"} = $search      ; $th{"sc_part"} = '{m}';
  $th{"it_word"} = "inglese"    ; $th{"it_part"} = '{m}';
  $th{"en_word"} = "Englishman" ; $th{"en_part"} = '{n}';
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
${$dieli_sc{"nglisi"}[0]}{"linkto"} = 'ngrisi_adj';
${$dieli_sc{"nglisi"}[1]}{"linkto"} = 'ngrisi_woman';
${$dieli_sc{"nglisi"}[2]}{"linkto"} = 'ngrisi_man';


## $ ./query-dieli.pl sc strittu reali
## 	0  ==  reali {adj} --> reale {adj} --> factual {adj}
## 	1  ==  reali {adj} --> reale {adj} --> real {adj}
## 	2  ==  reali {adj} --> reale {adj} --> royal {adj}
## 	3  ==  reali {adj} --> reale {adj} --> substantial {adj}
${$dieli_sc{"reali"}[0]}{"linkto"} = 'reali_factual';
${$dieli_sc{"reali"}[1]}{"linkto"} = 'reali_factual';
${$dieli_sc{"reali"}[2]}{"linkto"} = 'reali_royal';
${$dieli_sc{"reali"}[3]}{"linkto"} = 'reali_factual';

## $ ./query-dieli.pl sc strittu vasu
## 	0  ==  vasu {} --> bacia {} --> kiss {}
## 	1  ==  vasu {m} --> vaso {m} --> vase {n}
${$dieli_sc{"vasu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"vasu"}[0]}{"it_word"} = 'bacio';
${$dieli_sc{"vasu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"vasu"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"vasu"}[0]}{"linkto"} = 'vasu_kiss';
${$dieli_sc{"vasu"}[1]}{"linkto"} = 'vasu_vase';

## $ ./query-dieli.pl sc strittu viggilia
## 	0  ==  viggilia {f} --> vigilia {f} --> vigil {n}
## 	1  ==  viggilia {f} --> <br> {f} --> watch {n}
## $ ./query-dieli.pl sc strittu vigghia
## 	0  ==  vigghia {f} --> veglia {f} --> awake {n}
## 	1  ==  vigghia {f} --> vigilia {f} --> day before {n}
## 	2  ==  vigghia {f} --> vigilia {f} --> eve {n}
{ my $search = "vigghia" ;
  ${$dieli_sc{$search}[0]}{"linkto"}  = 'vigghia_vigil';
  ${$dieli_sc{$search}[0]}{"en_word"} = 'vigil';
  ${$dieli_sc{$search}[1]}{"linkto"}  = 'vigghia_eve';
  ${$dieli_sc{$search}[2]}{"linkto"}  = 'vigghia_eve';
}

## $ ./query-dieli.pl sc strittu vita
## 	0  ==  vita {f} --> <br> {f} --> life {n}
## 	1  ==  vita {f} --> vita {f} --> waist {n}
##  
${$dieli_sc{"vita"}[0]}{"it_word"} = 'vita';
${$dieli_sc{"vita"}[0]}{"linkto"} = 'vita_life';
${$dieli_sc{"vita"}[1]}{"linkto"} = 'vita_waist';

##  $ ./query-dieli.pl sc viviri
##  	0  ==  viviri {v} --> bere {v} --> drink {v}
##  	1  ==  viviri {v} --> vivere {v} --> live {v}
##  
${$dieli_sc{"viviri"}[0]}{"linkto"} = "biviri_drink";
${$dieli_sc{"viviri"}[1]}{"linkto"} = "viviri_live";

## $ ./query-dieli.pl sc strittu votu
## 	0  ==  votu {adj} --> vuoto {adj} --> hollow {adj}
## 	3  ==  votu {adj} --> nullo {adj} --> void {adj}
## 	2  ==  votu {m} --> vuoto {m} --> vacuum {n}
## 	4  ==  votu {f} --> votazione {f} --> vote {n}
## 	1  ==  votu {m} --> <br> {m} --> suffrage {n}
{ my $search = "votu";
  ${$dieli_sc{$search}[2]}{"linkto"}  = "votu_vacuum";
  ${$dieli_sc{$search}[4]}{"linkto"}  = "votu_vote";
  ${$dieli_sc{$search}[4]}{"sc_part"} = '{m}';
  ${$dieli_sc{$search}[1]}{"linkto"}  = "votu_vote";
}

## $ ./query-dieli.pl sc strittu vutari
## 	0  ==  vutari {v} --> <br> {v} --> screw {v}
## 	1  ==  vutari {v} --> volgere {v} --> turn {v}
## 	2  ==  vutari {v} --> voltare {v} --> turn {v}
## 	3  ==  vutari {v} --> girare {v} --> turn {v}
## 	4  ==  vutari {v} --> votare {v} --> turn {v}
## 	5  ==  vutari {v} --> volgere {v} --> vote {v}
## 	6  ==  vutari {v} --> voltare {v} --> vote {v}
## 	7  ==  vutari {v} --> <br> {v} --> vote {v}
## 	8  ==  vutari {v} --> votare {v} --> vote {v}
for my $i (0..4) {
    my $search = "vutari";
    ${$dieli_sc{$search}[$i]}{"linkto"} = 'vutari_turn';
}
for my $i (5..8) {
    my $search = "vutari";
    ${$dieli_sc{$search}[$i]}{"linkto"} = 'vutari_vote';
}
##  below we splice out (4,5,6) because repetitive and wrong


##  ${$dieli_sc{$search}[$i]}{"linkto"} = 'xxx';
##  STOPPED HERE


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  ADVERBS
##  =======

## $ ./query-dieli.pl sc strittu avanti
## 	0  ==  avanti {} --> prima {} --> before {}
## 	1  ==  avanti {adv} --> prima {adv} --> before {adv}
## 	2  ==  avanti {} --> prima {} --> in front {}
## 	3  ==  avanti {adv} --> <br> {adv} --> on {adv}
## 	4  ==  avanti {adj} --> <br> {adj} --> onward {adj}
## 	5  ==  avanti {} --> <br> {} --> prior to {}
${$dieli_sc{"avanti"}[0]}{"sc_part"} = '{adv}';
${$dieli_sc{"avanti"}[0]}{"it_part"} = '{adv}';
${$dieli_sc{"avanti"}[0]}{"en_part"} = '{adv}';
${$dieli_sc{"avanti"}[2]}{"sc_part"} = '{adv}';
${$dieli_sc{"avanti"}[2]}{"it_part"} = '{adv}';
${$dieli_sc{"avanti"}[2]}{"en_part"} = '{adv}';
${$dieli_sc{"avanti"}[3]}{"it_word"} = 'prima';
${$dieli_sc{"avanti"}[4]}{"it_word"} = 'prima';
${$dieli_sc{"avanti"}[5]}{"sc_part"} = '{adv}';
${$dieli_sc{"avanti"}[5]}{"it_word"} = 'prima';
${$dieli_sc{"avanti"}[5]}{"it_part"} = '{adv}';
${$dieli_sc{"avanti"}[5]}{"en_part"} = '{adv}';

## $ ./query-dieli.pl sc strittu beni
## 	0  ==  beni {} --> bene {} --> good {}
## 	1  ==  beni {mpl} --> beni {mpl} --> goods {pl}
## 	2  ==  beni {adv} --> bene {adv} --> well {adv}
${$dieli_sc{"beni"}[0]}{"sc_part"} = '{adv}';
${$dieli_sc{"beni"}[0]}{"it_part"} = '{adv}';
${$dieli_sc{"beni"}[0]}{"en_part"} = '{adv}';
{ my $search = "beni" ; 
  my %th ;  
  $th{"sc_word"} = $search ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "bene"  ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "good"  ; $th{"en_part"} = "{n}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu notrannu
## 	0  ==  notrannu {adv} --> l_SQUOTE_anno prossimo {adv} --> next year {adv}
${$dieli_sc{"notrannu"}[0]}{"it_word"} = 'un altro anno';
${$dieli_sc{"notrannu"}[0]}{"en_word"} = 'another year';

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  ADJECTIVES
##  ==========

## $ ./query-dieli.pl sc strittu amaru
## 	0  ==  amaru {} --> amaro {} --> bitter {}
## 	1  ==  amaru {adj} --> amaro {adj} --> bitter {adj}
${$dieli_sc{"amaru"}[0]}{"sc_part"} = '{adj}';
${$dieli_sc{"amaru"}[0]}{"it_part"} = '{adj}';
${$dieli_sc{"amaru"}[0]}{"en_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu arraggiatu
## 	0  ==  arraggiatu {adj} --> arrabbiato {adj} --> angry {adj}
## 	1  ==  arraggiatu {adj} --> <br> {adj} --> bothered {adj}
## 	2  ==  arraggiatu {} --> adirato {} --> irate {adj}
${$dieli_sc{"arraggiatu"}[2]}{"sc_part"} = '{adj}';
${$dieli_sc{"arraggiatu"}[2]}{"it_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu àvutru
## 	0  ==  àvutru {} --> altro {} --> other {}
${$dieli_sc{"àvutru"}[0]}{"it_part"} = '{adj}';
${$dieli_sc{"àvutru"}[0]}{"sc_part"} = '{adj}';
${$dieli_sc{"àvutru"}[0]}{"en_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu miatu biatu beatu miata biata beata
## 	0  ==  miatu {adj} --> beato {adj} --> delighted {adj}
## 	1  ==  miatu {adj} --> beato {adj} --> blessed {adj}
## 	0  ==  biatu {m} --> <br> {} --> blessed {n}
## 	1  ==  biatu {adj} --> <br> {adj} --> fortunate {adj}
## 	2  ==  biatu {adj} --> <br> {adj} --> happy {adj}
## 	0  ==  beatu {adj} --> <br> {adj} --> fortunate {adj}
## 	1  ==  beatu {adj} --> <br> {adj} --> happy {adj}
## 	miata  not found
## 	0  ==  biata {f} --> <br> {} --> blessed {n}
## 	0  ==  beata {m} --> <br> {} --> blessed {n}
${$dieli_sc{"biatu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"biatu"}[0]}{"it_word"} = 'beato';
${$dieli_sc{"biatu"}[1]}{"it_word"} = 'beato';
${$dieli_sc{"biatu"}[2]}{"it_word"} = 'beato';
##
${$dieli_sc{"beatu"}[0]}{"it_word"} = 'beato';
${$dieli_sc{"beatu"}[1]}{"it_word"} = 'beato';
##
${$dieli_sc{"biata"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"biata"}[0]}{"it_word"} = 'beata';
##
${$dieli_sc{"beata"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"beata"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"beata"}[0]}{"it_word"} = 'beata';

## $ ./query-dieli.pl sc strittu bonu
## 	0  ==  bonu {m} --> tagliando {m} --> coupon {n}
## 	1  ==  bonu {adj} --> <br> {adj} --> fair {adj}
## 	2  ==  bonu {} --> buona {} --> good {}
## 	3  ==  bonu {adj} --> buono {adj} --> good {adj}
## 	4  ==  bonu {adj} --> buono {adj} --> nice {adj}
## 	5  ==  bonu {} --> buono (di cibo) {} --> tasty {}
## 	6  ==  bonu {m} --> buono {m} --> voucher {n}
${$dieli_sc{"bonu"}[0]}{"it_word"} = 'buono';
${$dieli_sc{"bonu"}[2]}{"sc_part"} = '{adj}';
${$dieli_sc{"bonu"}[2]}{"it_word"} = 'buono';
${$dieli_sc{"bonu"}[2]}{"it_part"} = '{adj}';
${$dieli_sc{"bonu"}[2]}{"en_part"} = '{adj}';
${$dieli_sc{"bonu"}[5]}{"sc_part"} = '{adj}';
${$dieli_sc{"bonu"}[5]}{"it_part"} = '{adj}';
${$dieli_sc{"bonu"}[5]}{"en_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu cridìbbili
## 	0  ==  cridìbbili {} --> credibile {} --> credible {}
${$dieli_sc{"cridìbbili"}[0]}{"sc_part"} = '{adj}';
${$dieli_sc{"cridìbbili"}[0]}{"it_part"} = '{adj}';
${$dieli_sc{"cridìbbili"}[0]}{"en_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu cridìbbuli
## 	0  ==  cridìbbuli {} --> credibile {} --> credible {}
${$dieli_sc{"cridìbbuli"}[0]}{"sc_part"} = '{adj}';
${$dieli_sc{"cridìbbuli"}[0]}{"it_part"} = '{adj}';
${$dieli_sc{"cridìbbuli"}[0]}{"en_part"} = '{adj}';


## $ ./query-dieli.pl sc strittu dilizziusu
## 	0  ==  dilizziusu {adj} --> <br> {} --> delicious {}
${$dieli_sc{"dilizziusu"}[0]}{"it_word"} = 'delizioso';
${$dieli_sc{"dilizziusu"}[0]}{"it_part"} = '{adj}';
${$dieli_sc{"dilizziusu"}[0]}{"en_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu fintu 
## 	0  ==  fintu {adj} --> finto {adj} --> false {adj}
## 	1  ==  fintu {adj} --> <br> {adj} --> mock {adj}
${$dieli_sc{"fintu"}[0]}{"it_word"} = 'finto';

## $ ./query-dieli.pl sc strittu foddi
## 	0  ==  foddi {adj} --> folle {adj} --> crazy {adj}
## 	1  ==  foddi {adj} --> <br> {adj} --> insane {adj}
## 	2  ==  foddi {} --> folle {} --> mad {}
${$dieli_sc{"foddi"}[1]}{"it_word"} = 'folle';
${$dieli_sc{"foddi"}[2]}{"sc_part"} = '{adj}';
${$dieli_sc{"foddi"}[2]}{"it_part"} = '{adj}';
${$dieli_sc{"foddi"}[2]}{"en_part"} = '{adj}';

##  $ ./query-dieli.pl sc strittu giuvina
##  	0  ==  giuvina {adj} --> giovanotta {adj} --> young boy {adj}
${$dieli_sc{"giuvina"}[0]}{"en_word"} = 'young girl';
${$dieli_sc{"giuvina"}[0]}{"en_part"} = '{n}';

##  $ ./query-dieli.pl sc strittu giuvini 
##  	0  ==  giuvini {adj} --> giovanotto {adj} --> young boy {adj}
${$dieli_sc{"giuvini"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu intelliggenti
## 	0  ==  intelliggenti {adj} --> intelligente {adj} --> bright {adj}
## 	1  ==  intelliggenti {} --> intelligente {} --> cunning {}
## 	2  ==  intelliggenti {adj} --> intelligente {adj} --> smart {adj}
${$dieli_sc{"intelliggenti"}[1]}{"sc_part"} = '{adj}';
${$dieli_sc{"intelliggenti"}[1]}{"it_part"} = '{adj}';
${$dieli_sc{"intelliggenti"}[1]}{"en_part"} = '{adj}';

## $ qdieli sc strittu litiganti 
##     litiganti  not found
{ my $search = "litiganti" ; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{adj}" ;
  $th{"it_word"} = "litigante" ; $th{"it_part"} = "{adj}" ;
  $th{"en_word"} = "litigant"  ; $th{"en_part"} = "{adj}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu loccu
## 	0  ==  loccu {adj} --> <br> {adj} --> dumb {adj}
## 	1  ==  loccu {} --> stupido {} --> stupid {}
${$dieli_sc{"loccu"}[1]}{"sc_part"} = '{adj}';
${$dieli_sc{"loccu"}[1]}{"it_part"} = '{adj}';
${$dieli_sc{"loccu"}[1]}{"en_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu lustru
## 	3  ==  lustru {} --> luce {} --> light {}
## 	4  ==  lustru {} --> luce (naturale) {} --> luster, bright {}
## 	5  ==  lustru {m} --> lucido {m} --> polish {n}
## 	0  ==  lustru {} --> lucente {} --> bright {}
## 	1  ==  lustru {} --> luce {} --> clear {}
## 	2  ==  lustru {} --> lucente {} --> clear {}
## 	6  ==  lustru {adj} --> <br> {adj} --> shiny {adj}
${$dieli_sc{"lustru"}[3]}{"sc_part"} = '{m}';
${$dieli_sc{"lustru"}[3]}{"it_part"} = '{f}';
${$dieli_sc{"lustru"}[3]}{"en_part"} = '{n}';
${$dieli_sc{"lustru"}[4]}{"sc_part"} = '{m}';
${$dieli_sc{"lustru"}[4]}{"it_part"} = '{f}';
${$dieli_sc{"lustru"}[4]}{"en_part"} = '{n}';
${$dieli_sc{"lustru"}[0]}{"sc_part"} = '{adj}';
${$dieli_sc{"lustru"}[0]}{"it_part"} = '{adj}';
${$dieli_sc{"lustru"}[0]}{"en_part"} = '{adj}';
${$dieli_sc{"lustru"}[1]}{"sc_part"} = '{adj}';
${$dieli_sc{"lustru"}[1]}{"it_word"} = 'lucente';
${$dieli_sc{"lustru"}[1]}{"it_part"} = '{adj}';
${$dieli_sc{"lustru"}[1]}{"en_part"} = '{adj}';
${$dieli_sc{"lustru"}[2]}{"sc_part"} = '{adj}';
${$dieli_sc{"lustru"}[2]}{"it_part"} = '{adj}';
${$dieli_sc{"lustru"}[2]}{"en_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu magru
## 	0  ==  magru {adj} --> <br> {adj} --> skinny {adj}
## 	1  ==  magru {adj} --> <br> {adj} --> thin {adj}
${$dieli_sc{"magru"}[0]}{"it_word"} = 'magro';
${$dieli_sc{"magru"}[1]}{"it_word"} = 'magro';

## $ ./query-dieli.pl sc strittu malu
## 	0  ==  malu {} --> male {} --> bad {}
## 	1  ==  malu {adj} --> cattivo {adj} --> bad {adj}
## 	2  ==  malu {adj} --> <br> {adj} --> evil {adj}
## 	3  ==  malu {adj} --> malvagio {adj} --> ill {adj}
## 	4  ==  malu {adj} --> <br> {adj} --> wicked {adj}
${$dieli_sc{"malu"}[0]}{"sc_part"} = '{adv}';
${$dieli_sc{"malu"}[0]}{"it_part"} = '{adv}';
${$dieli_sc{"malu"}[0]}{"en_part"} = '{adv}';

## $ ./query-dieli.pl sc strittu maravigghiusu meravigghiusu
##	0  ==  maravigghiusu {adj} --> <br> {adj} --> astounding {adj}
##	1  ==  maravigghiusu {adj} --> meraviglioso {adj} --> fine {adj}
##	2  ==  maravigghiusu {adj} --> <br> {adj} --> marvellous {adj}
##	3  ==  maravigghiusu {adj} --> meraviglioso {adj} --> wonderful {adj}
## 	0  ==  meravigghiusu {adj} --> <br> {adj} --> marvellous {adj}
${$dieli_sc{"maravigghiusu"}[0]}{"it_word"} = 'meraviglioso';
${$dieli_sc{"maravigghiusu"}[2]}{"it_word"} = 'meraviglioso';
${$dieli_sc{"meravigghiusu"}[0]}{"it_word"} = 'meraviglioso';

## $ ./query-dieli.pl sc strittu maritata
## 	0  ==  maritata {} --> <br> {} --> married {}
delete( $dieli_sc{"maritata"} );
{ my $search = "maritatu" ; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{adj}" ;
  $th{"it_word"} = "maritato"  ; $th{"it_part"} = "{adj}" ;
  $th{"en_word"} = "married"   ; $th{"en_part"} = "{adj}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu misuratu
## 	0  ==  misuratu {v} --> <br> {} --> apportioned {v}
## 	1  ==  misuratu {} --> <br> {} --> measured {}
{ my $search = "misuratu" ;
  foreach my $index (0,1) {
      ${$dieli_sc{$search}[$index]}{"it_word"} = 'misurato';
      $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "adj" ) ;
  }
}

## $ ./query-dieli.pl sc strittu mmriacu
## 	0  ==  mmriacu {adj} --> ubriaco {} --> drunk {adj}
${$dieli_sc{"mmriacu"}[0]}{"it_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu  mortali
## 	0  ==  mortali {} --> mortale {} --> deathly {}
## 	1  ==  mortali {adj} --> mortale {adj} --> fatal {adj}
## 	2  ==  mortali {adj} --> mortale {adj} --> mortal {adj}
${$dieli_sc{"mortali"}[0]}{"sc_part"} = '{adj}';
${$dieli_sc{"mortali"}[0]}{"it_part"} = '{adj}';
${$dieli_sc{"mortali"}[0]}{"en_word"} = 'deadly';
${$dieli_sc{"mortali"}[0]}{"en_part"} = '{adj}';
## 
## $ ./query-dieli.pl sc strittu  mmurtali immurtali
## 	0  ==  mmurtali {adj} --> <br> {adj} --> immortal {adj}
## 	0  ==  immurtali {adj} --> <br> {adj} --> immortal {adj}
${$dieli_sc{"mmurtali"}[0]}{"it_word"}  = 'immortale';
${$dieli_sc{"immurtali"}[0]}{"it_word"} = 'immortale';

## $ ./query-dieli.pl sc strittu nicareddu
## 	0  ==  nicareddu {} --> piccolo {} --> child {}
## 	1  ==  nicareddu {} --> piccolo {} --> toddler {}
${$dieli_sc{"nicareddu"}[0]}{"sc_part"}  = '{adj}';
${$dieli_sc{"nicareddu"}[0]}{"it_part"}  = '{adj}';
${$dieli_sc{"nicareddu"}[0]}{"en_part"}  = '{n}';
${$dieli_sc{"nicareddu"}[1]}{"sc_part"}  = '{adj}';
${$dieli_sc{"nicareddu"}[1]}{"it_part"}  = '{adj}';
${$dieli_sc{"nicareddu"}[1]}{"en_part"}  = '{n}';

## $ ./query-dieli.pl sc strittu nnamuratu 
## 	0  ==  nnamuratu {} --> <br> {} --> enamored {}
## 	1  ==  nnamuratu {} --> <br> {} --> in love {}
${$dieli_sc{"nnamuratu"}[0]}{"sc_part"} = '{adj}';
${$dieli_sc{"nnamuratu"}[0]}{"it_word"} = 'innamorato';
${$dieli_sc{"nnamuratu"}[0]}{"it_part"} = '{adj}';
${$dieli_sc{"nnamuratu"}[0]}{"en_part"} = '{adj}';
${$dieli_sc{"nnamuratu"}[1]}{"sc_part"} = '{adj}';
${$dieli_sc{"nnamuratu"}[1]}{"it_word"} = 'innamorato';
${$dieli_sc{"nnamuratu"}[1]}{"it_part"} = '{adj}';
${$dieli_sc{"nnamuratu"}[1]}{"en_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu invidiusu
## 	0  ==  invidiusu {adj} --> invidioso {adj} --> envious {adj}
##
##  ADD:  "nvidiusu"
{ my $search = "nvidiusu"; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{adj}";
  $th{"it_word"} = "invidioso" ; $th{"it_part"} = "{adj}";
  $th{"en_word"} = "envious"   ; $th{"en_part"} = "{adj}";
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
## 
##  ADD:  "nvidiatu" and "invidiatu"
{ my $search = "nvidiatu"; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{adj}";
  $th{"it_word"} = "invidiato" ; $th{"it_part"} = "{adj}";
  $th{"en_word"} = "envied"    ; $th{"en_part"} = "{adj}";
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "invidiatu"; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{adj}";
  $th{"it_word"} = "invidiato" ; $th{"it_part"} = "{adj}";
  $th{"en_word"} = "envied"    ; $th{"en_part"} = "{adj}";
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu mmitatu
## 	0  ==  mmitatu {} --> <br> {} --> Invited {}
##
##	immitatu  not found
##	nvitatu  not found
##	invitatu  not found
${$dieli_sc{"mmitatu"}[0]}{"sc_part"} = '{adj}';
${$dieli_sc{"mmitatu"}[0]}{"it_word"} = 'invitato';
${$dieli_sc{"mmitatu"}[0]}{"it_part"} = '{adj}';
${$dieli_sc{"mmitatu"}[0]}{"en_part"} = '{adj}';
${$dieli_sc{"mmitatu"}[0]}{"en_word"} = 'invited';
##
{ my $search = "nvitatu"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{adj}";
  $th{"it_word"} = "invitato" ; $th{"it_part"} = "{adj}";
  $th{"en_word"} = "invited"  ; $th{"en_part"} = "{adj}";
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "invitatu"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{adj}";
  $th{"it_word"} = "invitato" ; $th{"it_part"} = "{adj}";
  $th{"en_word"} = "invited"  ; $th{"en_part"} = "{adj}";
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "immitatu"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{adj}";
  $th{"it_word"} = "invitato" ; $th{"it_part"} = "{adj}";
  $th{"en_word"} = "invited"  ; $th{"en_part"} = "{adj}";
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc largu orgo
## 	0  ==  orgogliusu {adj} --> fiero {adj} --> proud {adj}
## 	1  ==  orgogliusu {adj} --> orgoglioso {adj} --> proud {adj}
{ my $search = "orgogghiusu" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{adj}" ;
  $th{"it_word"} = "orgoglioso"  ; $th{"it_part"} = "{adj}" ;
  $th{"en_word"} = "proud"       ; $th{"en_part"} = "{adj}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu parmu
## 	0  ==  parmu {m} --> larghezza {f} --> breadth (of a hand) {n}
## 	1  ==  parmu {m} --> palmo {f} --> hand {n}
## 	2  ==  parmu {m} --> <br> {} --> measured {}
## 	3  ==  parmu {m} --> <br> {f} --> palm {n}
## 	4  ==  parmu {m} --> <br> {} --> restrained {}
${$dieli_sc{"parmu"}[1]}{"it_part"} = '{m}';
${$dieli_sc{"parmu"}[2]}{"sc_part"} = '{adj}';
${$dieli_sc{"parmu"}[2]}{"en_part"} = '{adj}';
${$dieli_sc{"parmu"}[4]}{"sc_part"} = '{adj}';
${$dieli_sc{"parmu"}[4]}{"en_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu paru
## 	0  ==  paru {m} --> paio {} --> equal {}
## 	1  ==  paru {m} --> pari {} --> equal {}
## 	2  ==  paru {m} --> paio {m} --> pair {n}
## 	3  ==  paru {m} --> pari {m} --> pair {n}
## 	4  ==  paru {} --> <br> {} --> peer {}
## 	5  ==  paru {} --> paio {} --> same {}
## 	6  ==  paru {} --> pari {} --> same {}
${$dieli_sc{"paru"}[0]}{"it_word"} = 'pari';
${$dieli_sc{"paru"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"paru"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"paru"}[1]}{"sc_part"} = '{adj}';
${$dieli_sc{"paru"}[1]}{"it_part"} = '{adj}';
${$dieli_sc{"paru"}[1]}{"en_part"} = '{adj}';
${$dieli_sc{"paru"}[3]}{"it_word"} = 'paio';
${$dieli_sc{"paru"}[4]}{"sc_part"} = '{m}';
${$dieli_sc{"paru"}[4]}{"it_word"} = 'pari';
${$dieli_sc{"paru"}[4]}{"it_part"} = '{m}';
${$dieli_sc{"paru"}[4]}{"en_part"} = '{n}';
${$dieli_sc{"paru"}[5]}{"sc_part"} = '{m}';
${$dieli_sc{"paru"}[5]}{"it_part"} = '{m}';
${$dieli_sc{"paru"}[5]}{"en_word"} = 'pair';
${$dieli_sc{"paru"}[5]}{"en_part"} = '{n}';
${$dieli_sc{"paru"}[6]}{"sc_part"} = '{adj}';
${$dieli_sc{"paru"}[6]}{"it_part"} = '{adj}';
${$dieli_sc{"paru"}[6]}{"en_part"} = '{adj}';
##
${$dieli_sc{"paru"}[0]}{"linkto"} = "paru_equal";
${$dieli_sc{"paru"}[2]}{"linkto"} = "paru_pair";
${$dieli_sc{"paru"}[3]}{"linkto"} = "paru_pair";
${$dieli_sc{"paru"}[4]}{"linkto"} = "paru_equal";
${$dieli_sc{"paru"}[5]}{"linkto"} = "paru_pair";

##  $ ./query-dieli.pl sc strittu pèggiu
## 	0  ==  pèggiu {adj} --> <br> {adj} --> bad {adj}
## 	1  ==  pèggiu {} --> <br> {} --> worse {}
## 	2  ==  pèggiu {adj} --> peggio {adj} --> worse {adj}
## 	3  ==  pèggiu {adv} --> peggio {adv} --> worse {adv}
${$dieli_sc{"pèggiu"}[0]}{"it_part"} = '{}';
${$dieli_sc{"pèggiu"}[1]}{"sc_part"} = '{adj}';
${$dieli_sc{"pèggiu"}[1]}{"en_part"} = '{adj}';
## 
##  $ ./query-dieli.pl sc strittu 'u pèggiu'
## 	0  ==  u pèggiu {} --> <br> {} --> worse {n}
## 	1  ==  u pèggiu {adj} --> <br> {adj} --> worst {adj}
## 	2  ==  u pèggiu {} --> <br> {} --> worst {n}
${$dieli_sc{"u pèggiu"}[0]}{"sc_part"} = '{adj}';
${$dieli_sc{"u pèggiu"}[1]}{"it_word"} = 'il peggiore';
${$dieli_sc{"u pèggiu"}[2]}{"sc_part"} = '{adj}';
## 
##  $ ./query-dieli.pl sc strittu 'u peggiu'
##  	0  ==  u peggiu {} --> <br> {} --> the worst {}
##  	1  ==  u peggiu {adj} --> pessimo {adj} --> worst {adj}
${$dieli_sc{"u peggiu"}[0]}{"sc_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu poco
## 	0  ==  poco {} --> <br> {} --> little {}
delete( $dieli_sc{"poco"} );
{ my $search = "pocu" ; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{adj}" ;
  $th{"it_word"} = "poco"   ; $th{"it_part"} = "{adj}" ;
  $th{"en_word"} = "little" ; $th{"en_part"} = "{adj}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu potenti
## 	0  ==  potenti {} --> <br> {} --> potent {}
## 	1  ==  potenti {} --> <br> {} --> strong {}
${$dieli_sc{"potenti"}[0]}{"sc_part"} = '{adj}';
${$dieli_sc{"potenti"}[0]}{"it_word"} = 'potente';
${$dieli_sc{"potenti"}[0]}{"it_part"} = '{adj}';
${$dieli_sc{"potenti"}[0]}{"en_part"} = '{adj}';
${$dieli_sc{"potenti"}[1]}{"sc_part"} = '{adj}';
${$dieli_sc{"potenti"}[1]}{"it_word"} = 'potente';
${$dieli_sc{"potenti"}[1]}{"it_part"} = '{adj}';
${$dieli_sc{"potenti"}[1]}{"en_part"} = '{adj}';

## $ qdieli sc strittu priputenti 
## 	priputenti  not found
{ my $search = "priputenti" ; 
  my %th ;  
  $th{"sc_word"} = $search      ; $th{"sc_part"} = "{adj}" ;
  $th{"it_word"} = "prepotente" ; $th{"it_part"} = "{adj}" ;
  $th{"en_word"} = "arrogant"   ; $th{"en_part"} = "{adj}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "priputenti" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{adj}" ;
  $th{"it_word"} = "prepotente"  ; $th{"it_part"} = "{adj}" ;
  $th{"en_word"} = "overbearing" ; $th{"en_part"} = "{adj}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu raggiatu
## 	0  ==  raggiatu {adj} --> <br> {adj} --> bothered {adj}
${$dieli_sc{"raggiatu"}[0]}{"it_word"} = 'arrabbiato';

## $ ./query-dieli.pl sc strittu reggiu
## 	0  ==  reggiu {adj} --> reale {adj} --> royal {adj}
{ my $search = "reggiu" ; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{adj}" ;
  $th{"it_word"} = "regio"  ; $th{"it_part"} = "{adj}" ;
  $th{"en_word"} = "royal"  ; $th{"en_part"} = "{adj}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu russu
## 	0  ==  russu {adj} --> rosso {adj} --> red {adj}
## 	1  ==  russu {adj} --> russo {adj} --> russian {adj}
## 	2  ==  russu {m} --> russo {m} --> russian {n}
${$dieli_sc{"russu"}[0]}{"linkto"}  = "russu_red";
${$dieli_sc{"russu"}[1]}{"linkto"}  = "russu_russian";
${$dieli_sc{"russu"}[1]}{"en_word"} = 'Russian';
${$dieli_sc{"russu"}[2]}{"en_word"} = 'Russian';

## $ ./query-dieli.pl sc strittu sarvaggiu
## 	0  ==  sarvaggiu {adj} --> selvaggio {adj} --> fierce {adj}
## 	1  ==  sarvaggiu {m} --> <br> {} --> heathen {n}
## 	2  ==  sarvaggiu {adj} --> <br> {adj} --> primitive {adj}
## 	3  ==  sarvaggiu {adj} --> selvaggio {adj} --> savage {adj}
## 	4  ==  sarvaggiu {adj} --> selvatico {adj} --> wild {adj}
## 	5  ==  sarvaggiu {} --> selvaggio {} --> wild (plants, animals) {}
## 	6  ==  sarvaggiu {} --> selvatico {} --> wild (plants, animals) {}
${$dieli_sc{"sarvaggiu"}[5]}{"sc_part"} = '{adj}';
${$dieli_sc{"sarvaggiu"}[5]}{"it_part"} = '{adj}';
${$dieli_sc{"sarvaggiu"}[5]}{"en_part"} = '{adj}';
${$dieli_sc{"sarvaggiu"}[6]}{"sc_part"} = '{adj}';
${$dieli_sc{"sarvaggiu"}[6]}{"it_part"} = '{adj}';
${$dieli_sc{"sarvaggiu"}[6]}{"en_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu sazziu
## 	0  ==  sazziu {adj} --> <br> {adj} --> satiated {adj}
${$dieli_sc{"sazziu"}[0]}{"it_word"} = 'sazio';

## $ ./query-dieli.pl sc strittu saziu
## 	0  ==  saziu {adj} --> <br> {adj} --> full {adj}
${$dieli_sc{"saziu"}[0]}{"it_word"} = 'sazio';

## $ ./query-dieli.pl sc strittu scuru
## 	0  ==  scuru {m} --> scuro {m} --> dark {n}
## 	1  ==  scuru {adj} --> carnagione scura {adj} --> dark complexioned {adj}
## 	2  ==  scuru {adj} --> oscuro {adj} --> dim {adj}
## 	3  ==  scuru {adj} --> buio {adj} --> obscure {adj}
## 	4  ==  scuru {adj} --> <br> {adj} --> overcast {adj}
${$dieli_sc{"scuru"}[0]}{"sc_part"} = '{adj}';
${$dieli_sc{"scuru"}[0]}{"it_part"} = '{adj}';
${$dieli_sc{"scuru"}[0]}{"en_part"} = '{adj}';

##  Mortillaro and Nicotra list "scuru" as a noun
{ my $search = "scuru" ; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "scuro"    ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "darkness" ; $th{"en_part"} = "{n}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu servu
## 	0  ==  servu {m} --> servo {m} --> boy {n}
## 	1  ==  servu {m} --> domestico {m} --> domestic {n}
## 	2  ==  servu {m} --> <br> {} --> indentured servant {n}
## 	3  ==  servu {m} --> <br> {m} --> servant {n}
## 	4  ==  servu {adv} --> <br> {adv} --> servile {adv}
## 	5  ==  servu {m} --> <br> {} --> slave {n}
${$dieli_sc{"servu"}[4]}{"sc_part"} = '{adj}';
${$dieli_sc{"servu"}[4]}{"it_word"} = 'servile';
${$dieli_sc{"servu"}[4]}{"it_part"} = '{adj}';
${$dieli_sc{"servu"}[4]}{"en_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu simili
## 	0  ==  simili {adj} --> <br> {adj} --> alike {adj}
## 	1  ==  simili {} --> <br> {} --> peer {}
## 	2  ==  simili {adj} --> simile {adj} --> similar {adj}
## 	3  ==  simili {adj} --> simile {adj} --> such {adj}
{ my $i = 1;
  my $search = "simili"; 
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{adj}';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{adj}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{adj}';
}

## $ ./query-dieli.pl sc strittu spissu
## 	0  ==  spissu {adj} --> <br> {adj} --> dense {adj}
## 	1  ==  spissu {adj} --> <br> {adj} --> frequent {adj}
## 	2  ==  spissu {adv} --> spesso {adv} --> often {adv}
${$dieli_sc{"spissu"}[1]}{"it_word"} = 'spesso';
${$dieli_sc{"spissu"}[1]}{"it_part"} = '{adj}';

## $ ./query-dieli.pl sc strittu stinnicchiatu
## 	0  ==  stinnicchiatu {} --> sdraiato {} --> lying down {}
{ my $i = 0;
  my $search = "stinnicchiatu";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{adj}';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{adj}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{adj}';
} 

## $ ./query-dieli.pl sc strittu strippa
## 	0  ==  strippa {adj} --> sterile (detto di donna) {adj} --> sterile {adj}
{ my $search = "strippa" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{adj}" ;
  $th{"it_word"} = "sterilizzata"; $th{"it_part"} = "{adj}" ;
  $th{"en_word"} = "spayed"      ; $th{"en_part"} = "{adj}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu tacitu
## 	0  ==  tacitu {adj} --> <br> {adj} --> silent {adj}
{ my $i = 0;
  my $search = "tacitu";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'taciuto';
} 

## $ ./query-dieli.pl sc strittu tantu
## 	0  ==  tantu {adj} --> <br> {adj} --> so much {adj}
## 	1  ==  tantu {pron} --> <br> {pron} --> so much {pron}
## 	2  ==  tantu {adj} --> <br> {adj} --> such {adj}
for my $i (0..2) {
  my $search = "tantu";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'tanto';
} 

## $ ./query-dieli.pl sc strittu tintu
## 	0  ==  tintu {adj} --> tinto {adj} --> bad {adj}
## 	1  ==  tintu {} --> <br> {} --> corrupt {}
## 	2  ==  tintu {v} --> tinto {v} --> dyed {v}
## 	3  ==  tintu {adj} --> <br> {adj} --> evil {adj}
## 	4  ==  tintu {adj} --> <br> {adj} --> inept {adj}
## 	5  ==  tintu {adv} --> <br> {adv} --> not good {adv}
## 	6  ==  tintu {adj} --> cattivo {adj} --> wicked {adj}
## 	7  ==  tintu {adj} --> misero {adj} --> needy {adj}
for my $i (1,2,5) {
  my $search = "tintu";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{adj}';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{adj}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{adj}';
} 

## $ ./query-dieli.pl sc strittu tunnu
## 	0  ==  tunnu {m} --> tonno {m} --> tuna {n}
## 	1  ==  tunnu {} --> <br> {} --> circular {}
## 	2  ==  tunnu {m} --> tonno {m} --> round {n}
## 	3  ==  tunnu {adj} --> rotondo {adj} --> round {adj}
## 	4  ==  tunnu {} --> <br> {} --> spherical {}
for my $i (1,2,4) {
  my $search = "tunnu";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{adj}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'tondo';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{adj}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{adj}';
} 

## $ ./query-dieli.pl sc strittu turcu
## 	0  ==  turcu {adj} --> non battezzato {adj} --> non-Catholic {adj}
## 	1  ==  turcu {m} --> non battezzato {m} --> non-Catholic {n}
## 	2  ==  turcu {adj} --> <br> {adj} --> Turk {adj}
## 	3  ==  turcu {m} --> <br> {m} --> Turk {n}
{ my $i = 2;
  my $search = "turcu";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'turco';
  ${$dieli_sc{$search}[$i]}{"en_word"} = 'Turkish';
} 
{ my $i = 3;
  my $search = "turcu";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'turco';
} 

## $ ./query-dieli.pl sc strittu universitariu
## 	0  ==  universitariu {adj} --> università {adj} --> university {adj}
{ my $i = 0;
  my $search = "universitariu";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'universitario';
} 

## $ ./query-dieli.pl sc strittu ultimu
## 	0  ==  ultimu {} --> <br> {} --> end {}
## 	1  ==  ultimu {adj} --> estremo {adj} --> extreme {adj}
## 	2  ==  ultimu {adj} --> ultimo {adj} --> last {adj}
## 	3  ==  ultimu {adj} --> ultimo {adj} --> ultimate {adj}
{ my $i = 0;
  my $search = "ultimu";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{m}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'ultimo';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{m}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
} 

## $ ./query-dieli.pl sc strittu urtimu
## 	0  ==  urtimu {adj} --> <br> {adj} --> last {adj}
{ my $i = 0;
  my $search = "urtimu";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'ultimo';
} 
{ my $search = "urtimu" ; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "ultimo" ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "last"   ; $th{"en_part"} = "{n}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu variu
## 	0  ==  variu {adj} --> vari {adj} --> various {adj}
{ my $i = 0;
  my $search = "variu";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'vario';
} 

## $ ./query-dieli.pl sc strittu vistutu
## 	0  ==  vistutu {} --> <br> {} --> clothed {}
## 	1  ==  vistutu {} --> <br> {} --> dressed {}
## 	2  ==  vistutu {m} --> vestito {m} --> suit {n}
## 	3  ==  vistutu {m} --> vestito da uomo {m} --> suit {n}
for my $i (0,1) {
    my $search = "vistutu";
    ${$dieli_sc{$search}[$i]}{"sc_part"} = '{adj}';
    ${$dieli_sc{$search}[$i]}{"it_word"} = 'vestito';
    ${$dieli_sc{$search}[$i]}{"it_part"} = '{adj}';
    ${$dieli_sc{$search}[$i]}{"en_part"} = '{adj}';
} 


##  { my $i = 0;
##    my $search = "";
##    ${$dieli_sc{$search}[$i]}{"sc_part"} = '{adj}';
##    ${$dieli_sc{$search}[$i]}{"it_part"} = '{adj}';
##    ${$dieli_sc{$search}[$i]}{"en_part"} = '{adj}';
##  } 
##  STOPPED HERE


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  NOUNS
##  =====

## $ ./query-dieli.pl sc strittu addauru
## 	0  ==  addauru {} --> <br> {} --> laurel {}
## 
## $ ./query-dieli.pl sc strittu addàuru
## 	0  ==  addàuru {} --> alloro {} --> bay {}
${$dieli_sc{"addauru"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"addauru"}[0]}{"it_word"} = 'alloro';
${$dieli_sc{"addauru"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"addauru"}[0]}{"en_part"} = '{m}';
${$dieli_sc{"addàuru"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"addàuru"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"addàuru"}[0]}{"en_word"} = 'bay laurel';
${$dieli_sc{"addàuru"}[0]}{"en_part"} = '{m}';

## $ ./query-dieli.pl sc strittu aduri
## 	0  ==  aduri {f} --> odore {f} --> odor {n}
## 	1  ==  aduri {m} --> odore {m} --> smell {n}
${$dieli_sc{"aduri"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"aduri"}[0]}{"it_part"} = '{m}';

## $ ./query-dieli.pl sc strittu agneddu
## 	0  ==  agneddu {m} --> <br> {} --> lamb {n}
${$dieli_sc{"agneddu"}[0]}{"it_word"} = 'agnello';
${$dieli_sc{"agneddu"}[0]}{"it_part"} = '{m}';

## $ ./query-dieli.pl sc strittu alligrizza
## 	0  ==  alligrizza {} --> <br> {} --> happiness {}
## 	1  ==  alligrizza {} --> <br> {} --> joy {}
## 	2  ==  alligrizza {} --> allegrezza {} --> joy {}
${$dieli_sc{"alligrizza"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"alligrizza"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"alligrizza"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"alligrizza"}[1]}{"en_part"} = '{n}';
${$dieli_sc{"alligrizza"}[2]}{"sc_part"} = '{f}';
${$dieli_sc{"alligrizza"}[2]}{"it_part"} = '{f}';
${$dieli_sc{"alligrizza"}[2]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu apa
## 	0  ==  apa {} --> ape {} --> bee {}
${$dieli_sc{"apa"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"apa"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"apa"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu aranciu
## 	0  ==  aranciu {f} --> arancia {f} --> orange {n}
## 	1  ==  aranciu {m} --> <br> {} --> orange tree {n}
${$dieli_sc{"aranciu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"aranciu"}[1]}{"it_word"} = 'arancio';
${$dieli_sc{"aranciu"}[1]}{"it_part"} = '{m}';

## $ ./query-dieli.pl sc strittu aricchiu 
## 	0  ==  aricchiu {f} --> orecchio {f} --> ear {n}
delete( $dieli_sc{"aricchiu"} );
{ my $search = "aricchia" ; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{f}" ;
  $th{"it_word"} = "orecchio"  ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "ear"       ; $th{"en_part"} = "{n}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu àrvulu
## 	0  ==  àrvulu {} --> albero {} --> tree {}
${$dieli_sc{"àrvulu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"àrvulu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"àrvulu"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu àrbulu
## 	0  ==  àrbulu {} --> albero {} --> tree {}
${$dieli_sc{"àrbulu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"àrbulu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"àrbulu"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu attu
## 	0  ==  attu {m} --> atto {} --> act {n}
## 	1  ==  attu {m} --> azione {} --> action {n}
## 	2  ==  attu {m} --> atto {m} --> deed {n}
## 	3  ==  attu {m} --> <br> {m} --> feat {n}
${$dieli_sc{"attu"}[0]}{"it_part"} = '{m}';

## $ ./query-dieli.pl sc strittu bannera
## 	0  ==  bannera {m} --> stendardo {m} --> banner {n}
## 	1  ==  bannera {f} --> bandiera {f} --> flag {n}
## 	2  ==  bannera {f} --> <br> {f} --> standard {n}
${$dieli_sc{"bannera"}[0]}{"sc_part"} = '{f}';

## $ ./query-dieli.pl sc strittu beccu
## 	0  ==  beccu {} --> <br> {} --> beak {}
## 	1  ==  beccu {m} --> becco {m} --> beak {n}
## 	2  ==  beccu {n} --> corna {n} --> cuckold {n}
## 	3  ==  beccu {m} --> becco {m} --> nozzle {n}
## 	4  ==  beccu {m} --> <br> {m} --> spout {n}
${$dieli_sc{"beccu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"beccu"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"beccu"}[2]}{"sc_part"} = '{m}';

## $  ./query-dieli.pl sc strittu biccheri 
## 	0  ==  biccheri {fpl} --> <br> {f} --> drinking glass {n}
${$dieli_sc{"biccheri"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"biccheri"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"biccheri"}[0]}{"it_word"} = 'bicchiere';

## $  ./query-dieli.pl sc strittu cannila
## 	0  ==  cannila {f} --> <br> {f} --> candle {n}
## 	1  ==  cannila {f} --> <br> {f} --> plug {n}
${$dieli_sc{"cannila"}[0]}{"it_word"} = 'candela';
${$dieli_sc{"cannila"}[1]}{"it_part"} = '{}';

## $ ./query-dieli.pl sc strittu carni
## 	0  ==  carni {m} --> manzo {m} --> beef {n}
## 	1  ==  carni {f} --> carne {f} --> flesh {n}
## 	2  ==  carni {f} --> carne {f} --> meat {n}
${$dieli_sc{"carni"}[0]}{"sc_part"} = '{f}';

## $ ./query-dieli.pl sc strittu causetta
## 	0  ==  causetta {f} --> calza {f} --> sock {n}
## 	1  ==  causetta {} --> calza {} --> stocking {n}
${$dieli_sc{"causetta"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"causetta"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"causetta"}[0]}{"en_part"} = '{n}';

##  $ ./query-dieli.pl sc strittu chiacchiara chiacchira
## 	0  ==  chiacchiara {f} --> <br> {f} --> chatter {n}
## 	1  ==  chiacchiara {m} --> pettegolezzo {m} --> gossip {n}
## 	2  ==  chiacchiara {f} --> <br> {f} --> rumor {n}
## 	0  ==  chiacchira {m} --> pettegolezzo {m} --> gossip {n}
${$dieli_sc{"chiacchiara"}[0]}{"it_word"} = 'chiacchiera';
${$dieli_sc{"chiacchiara"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"chiacchiara"}[2]}{"it_part"} = '{}';
${$dieli_sc{"chiacchira"}[0]}{"sc_part"}  = '{f}';

## $ qdieli sc strittu chiantu ciantu
## 	chiantu  not found
## 	ciantu  not found
{ my $search = "chiantu" ; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "pianto" ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "crying" ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "chiantu" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "pianto"  ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "weeping" ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "ciantu" ; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "pianto" ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "crying" ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu cità
## 	0  ==  cità {} --> città {} --> city {}
${$dieli_sc{"cità"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"cità"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"cità"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu ciumi
## 	0  ==  ciumi {m} --> ruscello {m} --> brook {n}
## 	1  ==  ciumi {m} --> fiume {m} --> river {n}
## 	2  ==  ciumi {} --> fiumi {} --> rivers {}
${$dieli_sc{"ciumi"}[2]}{"sc_part"} = '{m}';
${$dieli_sc{"ciumi"}[2]}{"it_word"} = 'fiume';
${$dieli_sc{"ciumi"}[2]}{"it_part"} = '{m}';
${$dieli_sc{"ciumi"}[2]}{"en_word"} = 'river';
${$dieli_sc{"ciumi"}[2]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu cori
## 	0  ==  cori {f} --> <br> {} --> depth {n}
## 	1  ==  cori {m} --> cuore {m} --> heart {n}
${$dieli_sc{"cori"}[0]}{"sc_part"} = '{m}';

## $ ./query-dieli.pl sc strittu cornu
## 	0  ==  cornu {m} --> disonore dei consorti {m} --> disgrace a spouse {n}
## 	1  ==  cornu {m} --> corno {m} --> horn {n}
## 
## $ ./query-dieli.pl sc strittu corna
## 	0  ==  corna {} --> corna {} --> horn {}
## 	1  ==  corna {m} --> disonore dei consorti {m} --> disgrace a spouse {n}
${$dieli_sc{"corna"}[0]}{"sc_part"} = '{mpl}';
${$dieli_sc{"corna"}[0]}{"it_part"} = '{fpl}';
${$dieli_sc{"corna"}[0]}{"en_word"} = 'horns';
${$dieli_sc{"corna"}[0]}{"en_part"} = '{n}';

##  $ ./query-dieli.pl sc strittu criatu
##  	0  ==  criatu {m} --> creato {m} --> servant {n}
##  
##  $ ./query-dieli.pl sc strittu criata
##  	0  ==  criata {} --> colf (abbr) {} --> maid {}
##  	1  ==  criata {} --> domestica {} --> maid {}
${$dieli_sc{"criata"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"criata"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"criata"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"criata"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"criata"}[1]}{"it_part"} = '{f}';
${$dieli_sc{"criata"}[1]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu cruci
## 	0  ==  cruci {f} --> croce {f} --> cross {n}
## 	1  ==  cruci {} --> <br> {} --> sacrifice {}
## 	2  ==  cruci {} --> <br> {} --> sacrifice {}
${$dieli_sc{"cruci"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"cruci"}[1]}{"en_part"} = '{n}';
${$dieli_sc{"cruci"}[2]}{"sc_part"} = '{f}';
${$dieli_sc{"cruci"}[2]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu cumpagnia
## 	0  ==  cumpagnia {f} --> compagnia {f} --> company {n}
## 	1  ==  cumpagnia {} --> <br> {} --> fellowship {}
## 	2  ==  cumpagnia {} --> <br> {} --> group {}
## 	3  ==  cumpagnia {f} --> compagnia {f} --> society {n}
${$dieli_sc{"cumpagnia"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"cumpagnia"}[1]}{"en_part"} = '{n}';
${$dieli_sc{"cumpagnia"}[2]}{"sc_part"} = '{f}';
${$dieli_sc{"cumpagnia"}[2]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu cumpari
## 	0  ==  cumpari {} --> <br> {} --> crony {}
## 	1  ==  cumpari {m} --> compare {m} --> friend {n}
## 	2  ==  cumpari {m} --> compare {m} --> godfather {n}
## 	3  ==  cumpari {m} --> <br> {m} --> peer {n}
${$dieli_sc{"cumpari"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"cumpari"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu cunfissuri
## 	0  ==  cunfissuri {} --> confessore {} --> confessor {}
${$dieli_sc{"cunfissuri"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"cunfissuri"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"cunfissuri"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu cuntentu
## 	0  ==  cuntentu {adj} --> contento {adj} --> content {adj}
{ my $search = "cuntentu" ; 
  my %th ;  
  $th{"sc_word"} = $search         ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "contentezza"   ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "contentedness" ; $th{"en_part"} = "{n}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "cuntentu" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "allegrezza"  ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "happiness"   ; $th{"en_part"} = "{n}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "cuntentu" ; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "ilarità"  ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "hilarity" ; $th{"en_part"} = "{n}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "cuntentu" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "giovialità"  ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "joviality"   ; $th{"en_part"} = "{n}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu dèbbuli debbuli dibbulizza 
## 	0  ==  dèbbuli {f} --> <br> {f} --> weakness {n}
## 	0  ==  debbuli {adj} --> debole {adj} --> dim {adj}
## 	1  ==  debbuli {adj} --> <br> {adj} --> faint {adj}
## 	2  ==  debbuli {adj} --> <br> {adj} --> feeble {adj}
## 	3  ==  debbuli {adj} --> <br> {adj} --> shaky {adj}
## 	4  ==  debbuli {adj} --> debole {adj} --> weak {adj}
## 	0  ==  dibbulizza {f} --> debolezza {f} --> weakness {n}
##
${$dieli_sc{"dèbbuli"}[0]}{"sc_part"} = '{m}';  ##  masc. noun, see Mortillaro
${$dieli_sc{"dèbbuli"}[0]}{"it_word"} = 'debolezza';  ##  def. from Mortillaro
${$dieli_sc{"debbuli"}[1]}{"it_word"} = 'debole';
${$dieli_sc{"debbuli"}[2]}{"it_word"} = 'debole';
${$dieli_sc{"debbuli"}[3]}{"it_word"} = 'debole';  

## $ ./query-dieli.pl sc strittu denti
## 	0  ==  denti {m} --> dente {m} --> cog {n}
## 	1  ==  denti {} --> dente {} --> teeth {}
## 	2  ==  denti {m} --> <br> {m} --> tooth {n}
${$dieli_sc{"denti"}[1]}{"sc_part"} = '{mpl}';
${$dieli_sc{"denti"}[1]}{"it_word"} = 'denti';  
${$dieli_sc{"denti"}[1]}{"it_part"} = '{mpl}';
${$dieli_sc{"denti"}[1]}{"en_part"} = '{npl}';  
${$dieli_sc{"denti"}[2]}{"it_word"} = 'dente';  

## $ ./query-dieli.pl sc strittu diunu
## 	0  ==  diunu {adj} --> <br> {adj} --> deprived of food {adj}
## 	1  ==  diunu {adj} --> <br> {adj} --> fasting {adj}
${$dieli_sc{"diunu"}[0]}{"it_word"} = 'digiuno';
${$dieli_sc{"diunu"}[1]}{"it_word"} = 'digiuno';
## 
## $ ./query-dieli.pl sc strittu diiunu
## 	0  ==  diiunu {m} --> digiuno {} --> fast {n}
${$dieli_sc{"diiunu"}[0]}{"it_part"} = '{m}';
##
## $ ./query-dieli.pl sc strittu dijunu
## 	0  ==  dijunu {adj} --> digiuno {adj} --> empty stomach {adj}
## 	1  ==  dijunu {m} --> digiuno {} --> extended privation {n}
## 	2  ==  dijunu {adj} --> digiuno {adj} --> hungry {adj}
${$dieli_sc{"dijunu"}[1]}{"it_part"} = '{m}';

##  $ ./query-dieli.pl sc largu diàvulu dimoniu
## 	0  ==  diàvulu {} --> <br> {} --> devil {}
## 	0  ==  dimoniu {} --> <br> {} --> demon {}
## 	1  ==  dimoniu {} --> <br> {} --> devil {}
${$dieli_sc{"diàvulu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"diàvulu"}[0]}{"it_word"} = 'diavolo';
${$dieli_sc{"diàvulu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"diàvulu"}[0]}{"en_part"} = '{n}';
## 
${$dieli_sc{"dimoniu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"dimoniu"}[0]}{"it_word"} = 'demonio';
${$dieli_sc{"dimoniu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"dimoniu"}[0]}{"en_part"} = '{n}';
## 
${$dieli_sc{"dimoniu"}[1]}{"sc_part"} = '{m}';
${$dieli_sc{"dimoniu"}[1]}{"it_word"} = 'demonio';
${$dieli_sc{"dimoniu"}[1]}{"it_part"} = '{m}';
${$dieli_sc{"dimoniu"}[1]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu dilizzia dilizziu 
## 	0  ==  dilizzia {f} --> <br> {f} --> delicacy {n}
## 	0  ==  dilizziu {m} --> <br> {} --> delicacy {n}
## 	1  ==  dilizziu {m} --> <br> {m} --> delicious thing {n}
${$dieli_sc{"dilizzia"}[0]}{"it_word"} = 'delizia';
${$dieli_sc{"dilizziu"}[0]}{"it_word"} = 'delizia';
${$dieli_sc{"dilizziu"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"dilizziu"}[1]}{"it_word"} = 'delizia';
${$dieli_sc{"dilizziu"}[1]}{"it_part"} = '{f}';

## $ ./query-dieli.pl sc strittu dimucrazzìa
## 	0  ==  dimucrazzìa {} --> democrazia {} --> democracy {}
${$dieli_sc{"dimucrazzìa"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"dimucrazzìa"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"dimucrazzìa"}[0]}{"en_part"} = '{n}';

##  $ ./query-dieli.pl sc strittu dinaru
## 	0  ==  dinaru {f} --> <br> {f} --> dough {n}
## 	1  ==  dinaru {m} --> denaro {m} --> money {n}
${$dieli_sc{"dinaru"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"dinaru"}[0]}{"it_word"} = 'denaro';
${$dieli_sc{"dinaru"}[0]}{"it_part"} = '{m}';

## $ ./query-dieli.pl sc strittu Diu
## 	0  ==  Diu {} --> Dio {} --> God {}
${$dieli_sc{"Diu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"Diu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"Diu"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu duluri
## 	0  ==  duluri {m} --> dolore {} --> afflication {n}
## 	1  ==  duluri {m} --> dolore {m} --> grief {n}
## 	2  ==  duluri {m} --> dolore {m} --> pain {n}
## 	3  ==  duluri {m} --> dolore {m} --> sorrow {n}
## 	4  ==  duluri {f} --> <br> {f} --> suffering {n}
${$dieli_sc{"duluri"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"duluri"}[4]}{"sc_part"} = '{m}';
${$dieli_sc{"duluri"}[4]}{"it_word"} = 'dolore';
${$dieli_sc{"duluri"}[4]}{"it_part"} = '{m}';

## $ ./query-dieli.pl sc strittu duci 
## 	0  ==  duci {adj} --> <br> {adj} --> mellow {adj}
## 	1  ==  duci {adj} --> dolce {adj} --> sweet {adj}
## 	2  ==  duci {adj} --> dolce {adj} --> sweet {adj}
${$dieli_sc{"duci"}[0]}{"it_word"} = 'dolce';
${$dieli_sc{"duci"}[2]}{"sc_part"} = '{m}';
${$dieli_sc{"duci"}[2]}{"it_part"} = '{m}';
${$dieli_sc{"duci"}[2]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu ruci 
## 	0  ==  ruci {f} --> dolce {f} --> sweet {n}
${$dieli_sc{"ruci"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"ruci"}[0]}{"it_part"} = '{m}';
{ my $search = "ruci" ; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{adj}" ;
  $th{"it_word"} = "dolce"  ; $th{"it_part"} = "{adj}" ;
  $th{"en_word"} = "sweet"  ; $th{"en_part"} = "{adj}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu èbbica èpuca èpica  
## 	0  ==  èbbica {f} --> epoca {f} --> epoch {n}
## 	1  ==  èbbica {f} --> epoca {f} --> era {n}
## 	2  ==  èbbica {f} --> periodo {} --> era {n}
## 	3  ==  èbbica {} --> epoca {} --> period {}
## 	4  ==  èbbica {} --> periodo {} --> period {}
${$dieli_sc{"èbbica"}[2]}{"it_part"} = '{m}';
${$dieli_sc{"èbbica"}[3]}{"sc_part"} = '{f}';
${$dieli_sc{"èbbica"}[3]}{"it_part"} = '{f}';
${$dieli_sc{"èbbica"}[3]}{"en_part"} = '{n}';
${$dieli_sc{"èbbica"}[4]}{"sc_part"} = '{f}';
${$dieli_sc{"èbbica"}[4]}{"it_part"} = '{m}';
${$dieli_sc{"èbbica"}[4]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu erruri 
## 	0  ==  erruri {m} --> errore {m} --> error {n}
## 	1  ==  erruri {m} --> errori {m} --> errors {n}
## 	2  ==  erruri {f} --> imperfezione {f} --> fault {n}
## 	3  ==  erruri {m} --> errore {m} --> mistake {n}
## 	4  ==  erruri {m} --> <br> {} --> mistakes {n}
${$dieli_sc{"erruri"}[1]}{"en_word"} = 'error';
${$dieli_sc{"erruri"}[2]}{"sc_part"} = '{m}';
${$dieli_sc{"erruri"}[4]}{"en_word"} = 'mistake';

## $ ./query-dieli.pl sc strittu fatiga fatica 
## 	0  ==  fatiga {n} --> duro lavore {n} --> fatigue {n}
## 	1  ==  fatiga {n} --> duro lavore {n} --> labor {n}
## 	2  ==  fatiga {n} --> fatica {n} --> labor {n}
## 	3  ==  fatiga {f} --> fatica {f} --> strain {n}
## 	4  ==  fatiga {n} --> duro lavore {n} --> toil {n}
## 	5  ==  fatiga {n} --> fatica {n} --> toil {n}
## 	6  ==  fatiga {f} --> duro lavore {f} --> work {n}
##	7  ==  fatiga {f} --> fatica {f} --> work {n}
## 
## 	0  ==  fatica {f} --> <br> {f} --> effort {n}
## 	1  ==  fatica {n} --> fatica {n} --> fatigue {n}
${$dieli_sc{"fatica"}[0]}{"it_word"} = 'fatica';
${$dieli_sc{"fatica"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"fatica"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"fatica"}[1]}{"it_part"} = '{f}';
for my $index (0..7) {
    ${$dieli_sc{"fatiga"}[$index]}{"sc_part"} = '{f}';
}
${$dieli_sc{"fatiga"}[2]}{"it_part"} = '{f}';
${$dieli_sc{"fatiga"}[5]}{"it_part"} = '{f}';
${$dieli_sc{"fatiga"}[6]}{"it_part"} = '{n}';

## $ ./query-dieli.pl sc strittu feli
## 	0  ==  feli {m} --> fiele {m} --> bile {n}
## 	1  ==  feli {f} --> bile {f} --> gall {n}
${$dieli_sc{"feli"}[1]}{"sc_part"} = '{m}';

## $ ./query-dieli.pl sc strittu ficatu
## 	0  ==  ficatu {} --> fegato {} --> liver {n}
${$dieli_sc{"ficatu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"ficatu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"ficatu"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu filu
## 	0  ==  filu {} --> spago {} --> string {}
## 	1  ==  filu {m} --> <br> {m} --> string {n}
## 	2  ==  filu {m} --> <br> {m} --> thread {n}
## 	3  ==  filu {m} --> filo {m} --> wire {n}
## 	4  ==  filu {m} --> filo {m} --> yarn {n}
${$dieli_sc{"filu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"filu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"filu"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu fimmini 
## 	0  ==  fimmini {} --> <br> {} --> women {}
${$dieli_sc{"fimmini"}[0]}{"sc_part"} = '{fpl}';
${$dieli_sc{"fimmini"}[0]}{"en_part"} = '{npl}';

## $ ./query-dieli.pl sc strittu fini
## 	0  ==  fini {m} --> ragione {} --> aim {n}
## 	4  ==  fini {m} --> ragione {m} --> motive {n}
## 	3  ==  fini {m} --> <br> {m} --> goal {n}
## 	5  ==  fini {m} --> fine {m} --> purpose {n}
## 	1  ==  fini {f} --> fine {f} --> end {n}
## 	2  ==  fini {f} --> fine {f} --> ending {n}
${$dieli_sc{"fini"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"fini"}[4]}{"it_part"} = '{f}';
${$dieli_sc{"fini"}[3]}{"it_word"} = 'fine';
for my $index (0,3,4,5) {
    ${$dieli_sc{"fini"}[$index]}{"linkto"} = 'fini_goal';
}
for my $index (1,2) {
    ${$dieli_sc{"fini"}[$index]}{"linkto"} = 'fini_end';
}

## $ ./query-dieli.pl sc strittu finocchiu
## 	0  ==  finocchiu {m} --> finocchio {} --> anise {}
## 	1  ==  finocchiu {} --> finocchio {} --> fennel {}
${$dieli_sc{"finocchiu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"finocchiu"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"finocchiu"}[1]}{"sc_part"} = '{m}';
${$dieli_sc{"finocchiu"}[1]}{"it_part"} = '{m}';
${$dieli_sc{"finocchiu"}[1]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu finta 
## 	0  ==  finta {adj} --> finto {adj} --> imitation {adj}
${$dieli_sc{"finta"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"finta"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"finta"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu firraru
## 	0  ==  firraru {} --> ferrajo {} --> blacksmith {}
## 	1  ==  firraru {m} --> fabbro {m} --> smith {n}
${$dieli_sc{"firraru"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"firraru"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"firraru"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu frasca
## 	0  ==  frasca {} --> rametto {} --> branch {}
## 	1  ==  frasca {f} --> cespuglio {m} --> bush {n}
${$dieli_sc{"frasca"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"frasca"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"frasca"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu frati
## 	0  ==  frati {} --> fratello {} --> brother {}
${$dieli_sc{"frati"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"frati"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"frati"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu furca
## 	0  ==  furca {f} --> forca {f} --> gallows {pl}
## 	1  ==  furca {f} --> <br> {f} --> halter {n}
## 	2  ==  furca {} --> <br> {} --> scaffold {}
${$dieli_sc{"furca"}[2]}{"sc_part"} = '{f}';
${$dieli_sc{"furca"}[2]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu gabbu
## 	0  ==  gabbu {m} --> gabbo {} --> fool {n}
## 	1  ==  gabbu {m} --> beffa {} --> joke {n}
## 	2  ==  gabbu {m} --> burla {} --> mock {n}
## 	3  ==  gabbu {m} --> gabbo {} --> ridicule {n}
## 	4  ==  gabbu {m} --> burla {} --> tease {n}
${$dieli_sc{"gabbu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"gabbu"}[1]}{"it_part"} = '{f}';
${$dieli_sc{"gabbu"}[2]}{"it_part"} = '{f}';
${$dieli_sc{"gabbu"}[3]}{"it_part"} = '{m}';
${$dieli_sc{"gabbu"}[4]}{"it_part"} = '{f}';

##  ##  ##  ##  

## ##  add multiple varieties of "gattu"
## $ ./query-dieli.pl en strittu cat
## 	0  ==  cat {n} --> gatta {f} --> gatta {f}
## 	1  ==  cat {n} --> gatto {m} --> gattu {m}
## 	2  ==  cat {n} --> gatto {m} --> iattu {m}
 
{ my $search = "attu" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "gattu"   ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "cat"     ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
##  ##  now take care of the homonym
## $ ./query-dieli.pl sc strittu attu
## 	0  ==  attu {m} --> atto {m} --> act {n}
## 	1  ==  attu {m} --> azione {} --> action {n}
## 	2  ==  attu {m} --> atto {m} --> deed {n}
## 	3  ==  attu {m} --> <br> {m} --> feat {n}
## 	4  ==  attu {m} --> gattu {m} --> cat {n}
${$dieli_sc{"attu"}[0]}{"linkto"} = "attu_noun";
${$dieli_sc{"attu"}[1]}{"linkto"} = "attu_noun";
${$dieli_sc{"attu"}[2]}{"linkto"} = "attu_noun";
${$dieli_sc{"attu"}[3]}{"linkto"} = "attu_noun";
${$dieli_sc{"attu"}[4]}{"linkto"} = "jattu_noun";

## ##  add multiple varieties of "gatta"
{ my $search = "atta" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}" ;
  $th{"it_word"} = "gatta"   ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "cat"     ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "iatta" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}" ;
  $th{"it_word"} = "gatta"   ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "cat"     ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## ##  add multiple varieties of "gattareddu/a"
## $ ./query-dieli.pl en strittu kitten
## 	0  ==  kitten {n} --> gattina {f} --> gattaredda {f}
## 	1  ==  kitten {n} --> gattino {m} --> gattareddu {m}

{ my $search = "attaredda" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}" ;
  $th{"it_word"} = "gattina" ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "kitten"  ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "iattaredda" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}" ;
  $th{"it_word"} = "gattina" ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "kitten"  ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "attareddu" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "gattino" ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "kitten"  ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "iattareddu" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "gattino" ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "kitten"  ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  ##  ##  ##  

## $ ./query-dieli.pl sc strittu gilusia
## 	0  ==  gilusia {f} --> <br> {} --> jealousy {n}
${$dieli_sc{"gilusia"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"gilusia"}[0]}{"it_word"} = 'gelosia';

##  $ ./query-dieli.pl sc strittu ginocchiu
##  	0  ==  ginocchiu {} --> ginocchio {} --> knee {}
${$dieli_sc{"ginocchiu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"ginocchiu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"ginocchiu"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu giru
## 	0  ==  giru {m} --> <br> {m} --> revolution {n}
## 	1  ==  giru {m} --> <br> {m} --> tour {n}
${$dieli_sc{"giru"}[0]}{"it_word"} = 'giro';
${$dieli_sc{"giru"}[1]}{"it_word"} = 'giro';

## $ qdieli sc strittu gnuranza
## 	gnuranza  not found
{ my $search = "gnuranza" ; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{f}" ;
  $th{"it_word"} = "ignoranza" ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "ignorance" ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu grazii
## 	0  ==  grazii {m} --> grazie {m} --> thank you {n}
## 	1  ==  grazii {m} --> grazie {m} --> thanks {n}
${$dieli_sc{"grazii"}[0]}{"sc_part"} = '{fpl}';
${$dieli_sc{"grazii"}[0]}{"it_part"} = '{fpl}';
${$dieli_sc{"grazii"}[0]}{"en_part"} = '{npl}';
${$dieli_sc{"grazii"}[1]}{"sc_part"} = '{fpl}';
${$dieli_sc{"grazii"}[1]}{"it_part"} = '{fpl}';
${$dieli_sc{"grazii"}[1]}{"en_part"} = '{npl}';

## $ ./query-dieli.pl sc strittu guadagnu
## 	0  ==  guadagnu {} --> <br> {} --> gain {}
## 	1  ==  guadagnu {m} --> profitto {m} --> gain {n}
## 	2  ==  guadagnu {m} --> guadagno {m} --> profiXt {n}
${$dieli_sc{"guadagnu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"guadagnu"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"guadagnu"}[2]}{"en_word"} = 'profit';

## $ ./query-dieli.pl sc strittu guaiu
## 	0  ==  guaiu {m} --> sventura {f} --> misfortune {n}
## 	1  ==  guaiu {f} --> <br> {} --> scrape {n}
## 	2  ==  guaiu {m} --> <br> {} --> trouble {}
## 	3  ==  guaiu {n} --> guaio {m} --> woe {n}
${$dieli_sc{"guaiu"}[1]}{"sc_part"} = '{m}';
${$dieli_sc{"guaiu"}[2]}{"en_part"} = '{n}';
${$dieli_sc{"guaiu"}[3]}{"sc_part"} = '{m}';

## $ ./query-dieli.pl sc strittu gustu
## 	0  ==  gustu {m} --> gusto {m} --> flavor {n}
## 	1  ==  gustu {m} --> <br> {} --> pleasure {n}
## 	2  ==  gustu {} --> <br> {} --> taste {}
## 	3  ==  gustu {m} --> gusto {m} --> zest {n}
${$dieli_sc{"gustu"}[2]}{"sc_part"} = '{m}';
${$dieli_sc{"gustu"}[2]}{"it_word"} = 'gusto';
${$dieli_sc{"gustu"}[2]}{"it_part"} = '{m}';
${$dieli_sc{"gustu"}[2]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu ippuni
## 	0  ==  ippuni {} --> camicetta {} --> blouse {}
${$dieli_sc{"ippuni"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"ippuni"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"ippuni"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu incendiu 
## 	0  ==  incendiu {m} --> incendio {m} --> fire {n}
## 	1  ==  incendiu {} --> <br> {} --> flash {n}
${$dieli_sc{"incendiu"}[1]}{"sc_part"} = '{m}';
${$dieli_sc{"incendiu"}[1]}{"it_word"} = 'incendio';
${$dieli_sc{"incendiu"}[1]}{"it_part"} = '{m}';

## $ ./query-dieli.pl sc strittu inciùria 
## 	0  ==  inciùria {} --> insulto {} --> injury {}
## 	1  ==  inciùria {} --> insulto {} --> injury {}
## 	2  ==  inciùria {f} --> insulto {m} --> insult {n}
## 	3  ==  inciùria {f} --> insulto {m} --> offense {n}
${$dieli_sc{"inciùria"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"inciùria"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"inciùria"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"inciùria"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"inciùria"}[1]}{"it_part"} = '{m}';
${$dieli_sc{"inciùria"}[1]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu iòcu
## 	0  ==  iòcu {} --> giocattolo {} --> toy {}
${$dieli_sc{"iòcu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"iòcu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"iòcu"}[0]}{"en_part"} = '{n}';

##  $ ./query-dieli.pl sc strittu jardinu 
##  	0  ==  jardinu {} --> giardino {} --> garden {}
${$dieli_sc{"jardinu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"jardinu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"jardinu"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu labbru
## 	0  ==  labbru {} --> labbro {} --> lip {}
${$dieli_sc{"labbru"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"labbru"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"labbru"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu lacu lagu 
## 	0  ==  lacu {m} --> <br> {m} --> lake {n}
## 	0  ==  lagu {m} --> <br> {m} --> lake {n}
${$dieli_sc{"lacu"}[0]}{"it_word"} = 'lago';
${$dieli_sc{"lagu"}[0]}{"it_word"} = 'lago';

## $ ./query-dieli.pl sc strittu lampa
## 	0  ==  lampa {f} --> <br> {f} --> lamp {n}
## 	1  ==  lampa {f} --> <br> {f} --> light post {n}
${$dieli_sc{"lampa"}[0]}{"it_word"} = 'lampada';
${$dieli_sc{"lampa"}[1]}{"it_word"} = 'lampada';

## $ ./query-dieli.pl sc strittu lettu
## 	0  ==  lettu {} --> letto {} --> bed {}
${$dieli_sc{"lettu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"lettu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"lettu"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu liggi
## 	0  ==  liggi {} --> <br> {} --> law {n}
${$dieli_sc{"liggi"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"liggi"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"liggi"}[0]}{"it_word"} = 'legge';

## $ ./query-dieli.pl sc strittu ligumi
## 	0  ==  ligumi {p} --> <br> {p} --> vegetables {n}
${$dieli_sc{"ligumi"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"ligumi"}[0]}{"it_word"} = 'legume';
${$dieli_sc{"ligumi"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"ligumi"}[0]}{"en_word"} = 'vegetable';
${$dieli_sc{"ligumi"}[0]}{"en_part"} = '{n}';
{ my $search = "ligumi" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{mpl}" ;
  $th{"it_word"} = "legumi"      ; $th{"it_part"} = "{mpl}" ;
  $th{"en_word"} = "vegetables"  ; $th{"en_part"} = "{npl}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu lingua
## 	0  ==  lingua {} --> <br> {} --> language {}
## 	1  ==  lingua {} --> lingua {} --> tongue {}
${$dieli_sc{"lingua"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"lingua"}[0]}{"it_word"} = 'lingua';
${$dieli_sc{"lingua"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"lingua"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"lingua"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"lingua"}[1]}{"it_part"} = '{f}';
${$dieli_sc{"lingua"}[1]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu lira
## 	0  ==  lira {f} --> <br> {f} --> Lira {n}
${$dieli_sc{"lingua"}[0]}{"it_word"} = 'lira';
${$dieli_sc{"lingua"}[0]}{"en_word"} = 'lira';

## $ ./query-dieli.pl sc strittu liuni
## 	0  ==  liuni {} --> <br> {} --> lion {}
${$dieli_sc{"liuni"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"liuni"}[0]}{"it_word"} = 'leone';
${$dieli_sc{"liuni"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"liuni"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu luci
## 	0  ==  luci {} --> <br> {} --> brightens {}
## 	1  ==  luci {} --> luce (elettrica) {} --> light {}
## 	2  ==  luci {} --> <br> {} --> lights {}
## 	3  ==  luci {m} --> fuoco {m} --> fire {n}
${$dieli_sc{"luci"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"luci"}[1]}{"it_part"} = '{f}';
${$dieli_sc{"luci"}[1]}{"en_part"} = '{n}';
${$dieli_sc{"luci"}[2]}{"sc_part"} = '{fpl}';
${$dieli_sc{"luci"}[2]}{"it_word"} = 'luci';
${$dieli_sc{"luci"}[2]}{"it_part"} = '{fpl}';
${$dieli_sc{"luci"}[2]}{"en_part"} = '{npl}';
${$dieli_sc{"luci"}[3]}{"sc_part"} = '{f}';

## $ ./query-dieli.pl sc strittu lumi
## 	0  ==  lumi {f} --> <br> {f} --> lamp {n}
## 	1  ==  lumi {m} --> <br> {} --> light {n}
${$dieli_sc{"lumi"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"lumi"}[0]}{"it_word"} = 'lume';
${$dieli_sc{"lumi"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"lumi"}[1]}{"it_word"} = 'lume';
${$dieli_sc{"lumi"}[1]}{"it_part"} = '{m}';

## $ ./query-dieli.pl sc strittu màchina
## 	0  ==  màchina {} --> automobile {} --> automobile {}
${$dieli_sc{"màchina"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"màchina"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"màchina"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu bonanova malanova
## 	bonanova  not found
## 	0  ==  malanova {f} --> cattiva nuova {f} --> bad news {n}
## 	1  ==  malanova {f} --> <br> {f} --> news (bad) {n}
${$dieli_sc{"malanova"}[1]}{"it_word"} = 'cattiva nuova';
{ my $search = "bonanova" ; my $index = 0 ; 
  ${$dieli_sc{$search}[$index]}{"sc_word"} = $search;
  ${$dieli_sc{$search}[$index]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$index]}{"it_word"} = 'buona nuova';
  ${$dieli_sc{$search}[$index]}{"it_part"} = '{f}';
  ${$dieli_sc{$search}[$index]}{"en_word"} = 'good news';
  ${$dieli_sc{$search}[$index]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu mali
## 	0  ==  mali {} --> male {} --> bad {n}
## 	1  ==  mali {} --> <br> {} --> bad thing {}
## 	2  ==  mali {m} --> <br> {m} --> disease {n}
## 	3  ==  mali {m} --> <br> {m} --> evil {n}
## 	4  ==  mali {m} --> male {m} --> harm {n}
## 	5  ==  mali {m} --> male {m} --> mischief {n}
## 	6  ==  mali {} --> <br> {} --> pain {}
## 	7  ==  mali {f} --> malattia {f} --> sickness {n}
## 	8  ==  mali {m} --> <br> {m} --> trouble {n}
## 	9  ==  mali {m} --> male {m} --> wrong {n}
foreach my $i (0,1,6) {
    my $search = "mali" ; 
    ${$dieli_sc{$search}[$i]}{"sc_part"} = '{m}';
    ${$dieli_sc{$search}[$i]}{"it_part"} = '{m}';
    ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}
{ my $index = 7 ; 
  my $search = "mali" ; 
  ${$dieli_sc{$search}[$index]}{"sc_part"} = '{m}';
}

## $ ./query-dieli.pl sc strittu maravigghia meravigghia
## 	0  ==  maravigghia {f} --> meraviglia {f} --> amazement {n}
## 	1  ==  maravigghia {f} --> <br> {f} --> marvel {n}
## 	2  ==  maravigghia {m} --> miracolo {m} --> wonder {n}
## 	0  ==  meravigghia {f} --> <br> {f} --> marvel {n}
${$dieli_sc{"maravigghia"}[1]}{"it_word"} = 'meraviglia';
${$dieli_sc{"maravigghia"}[2]}{"sc_part"} = '{f}';
${$dieli_sc{"meravigghia"}[0]}{"it_word"} = 'meraviglia';

## $ ./query-dieli.pl sc strittu minzugnaru
## 	0  ==  minzugnaru {} --> <br> {} --> liar {}
${$dieli_sc{"minzugnaru"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"minzugnaru"}[0]}{"it_word"} = 'menzognero';
${$dieli_sc{"minzugnaru"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"minzugnaru"}[0]}{"en_part"} = '{n}';
{ my $search = "minzugnaru" ; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "bugiardo"  ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "liar"      ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu minzogna
## 	0  ==  minzogna {} --> bugia {} --> fib {}
## 	1  ==  minzogna {} --> bugia {} --> lie {}
${$dieli_sc{"minzogna"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"minzogna"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"minzogna"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"minzogna"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"minzogna"}[1]}{"it_part"} = '{f}';
${$dieli_sc{"minzogna"}[1]}{"en_part"} = '{n}';
{ my $search = "minzogna" ; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{f}" ;
  $th{"it_word"} = "menzogna"  ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "lie"       ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu mircatu
## 	0  ==  mircatu {} --> <br> {} --> discounted {}
## 	1  ==  mircatu {m} --> mercato {} --> market {n}
## 	2  ==  mircatu {} --> <br> {} --> marketplace {}
## 	3  ==  mircatu {adj} --> <br> {adj} --> slashed {adj}
${$dieli_sc{"mircatu"}[0]}{"sc_part"} = '{adj}';
${$dieli_sc{"mircatu"}[0]}{"it_word"} = 'scontato';
${$dieli_sc{"mircatu"}[0]}{"it_part"} = '{adj}';
${$dieli_sc{"mircatu"}[0]}{"en_part"} = '{adj}';
${$dieli_sc{"mircatu"}[1]}{"it_part"} = '{m}';
${$dieli_sc{"mircatu"}[2]}{"sc_part"} = '{m}';
${$dieli_sc{"mircatu"}[2]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu missa
## 	0  ==  missa {} --> messa {} --> mass {}
${$dieli_sc{"missa"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"missa"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"missa"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu  muddichi muddica
## 	0  ==  muddichi {f} --> <br> {} --> crumbs {n}
## 	0  ==  muddica {f} --> briciola {f} --> crumb {n}
## 	1  ==  muddica {f} --> mollica {f} --> crumbs {n}
## 	2  ==  muddica {f} --> <br> {f} --> soft part of bread {n}
${$dieli_sc{"muddichi"}[0]}{"sc_part"} = '{fpl}';
${$dieli_sc{"muddichi"}[0]}{"it_word"} = 'briciole';
${$dieli_sc{"muddichi"}[0]}{"it_part"} = '{fpl}';
${$dieli_sc{"muddichi"}[0]}{"en_part"} = '{npl}';
##  instead of deleting, let's create a repeat
##  so we have space to edit it later
${$dieli_sc{"muddica"}[1]}{"en_word"} = 'soft part of bread';
${$dieli_sc{"muddica"}[2]}{"it_word"} = 'mollica';

## $ ./query-dieli.pl sc strittu  munita
## 	0  ==  munita {f} --> moneta {f} --> coin {n}
## 	1  ==  munita {f} --> <br> {f} --> dough {n}
## 	2  ==  munita {p} --> <br> {} --> money {n}
${$dieli_sc{"munita"}[2]}{"sc_part"} = '{f}';

## $ ./query-dieli.pl sc strittu  munnizzaru
## 	0  ==  munnizzaru {m} --> immondizzaio {m} --> dustbin {n}
## 	1  ==  munnizzaru {m} --> immondizzaio {m} --> garbage can {n}
## 	2  ==  munnizzaru {f} --> immondizia {f} --> rubbish {n}
## 	3  ==  munnizzaru {} --> immondizzaio {} --> trash can {}
${$dieli_sc{"munnizzaru"}[2]}{"sc_part"} = '{m}';
${$dieli_sc{"munnizzaru"}[3]}{"sc_part"} = '{m}';
${$dieli_sc{"munnizzaru"}[3]}{"it_part"} = '{f}';
${$dieli_sc{"munnizzaru"}[3]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu musca
## 	0  ==  musca {} --> mosca {} --> fly {}
## 	1  ==  musca {f} --> mosca {f} --> fly {}
${$dieli_sc{"musca"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"musca"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"musca"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"musca"}[1]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu muschi
## 	0  ==  muschi {} --> <br> {} --> flies {}
${$dieli_sc{"muschi"}[0]}{"sc_part"} = '{fpl}';
${$dieli_sc{"muschi"}[0]}{"it_word"} = 'mosche';
${$dieli_sc{"muschi"}[0]}{"it_part"} = '{fpl}';
${$dieli_sc{"muschi"}[0]}{"en_part"} = '{npl}';

## $ ./query-dieli.pl sc strittu mustu
## 	0  ==  mustu {} --> mosto {} --> must (fermenting new wine) {}
${$dieli_sc{"mustu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"mustu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"mustu"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu nespula
## 	0  ==  nespula {} --> nespola {} --> loquat {}
## 	1  ==  nespula {} --> nespola {} --> medlar {}
## 
## $ ./query-dieli.pl sc strittu nèspula
## 	0  ==  nèspula {} --> <br> {} --> loquat {}
## 
${$dieli_sc{"nèspula"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"nèspula"}[0]}{"it_word"} = 'nespola';
${$dieli_sc{"nèspula"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"nèspula"}[0]}{"en_part"} = '{n}';
## 
delete( $dieli_sc{"nespula"} );
{ my $search = "nèspula" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = '{f}' ;
  $th{"it_word"} = "nespola" ; $th{"it_part"} = '{f}' ;
  $th{"en_word"} = "medlar"  ; $th{"en_part"} = '{n}' ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu nessu
## 	0  ==  nessu {m} --> <br> {} --> connection {n}
## 	1  ==  nessu {m} --> <br> {m} --> link {n}
${$dieli_sc{"nessu"}[0]}{"it_word"} = 'nesso';
${$dieli_sc{"nessu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"nessu"}[1]}{"it_word"} = 'nesso';

## $ ./query-dieli.pl sc strittu negghia
## 	0  ==  negghia {} --> nube {} --> cloud {}
## 	1  ==  negghia {f} --> nebbia {f} --> fog {n}
## 	2  ==  negghia {f} --> foschia {f} --> haze {n}
## 	3  ==  negghia {f} --> nebbia {f} --> mist {n}
## 	4  ==  negghia {} --> individuo inutile {} --> useless person {}
${$dieli_sc{"negghia"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"negghia"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"negghia"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"negghia"}[4]}{"sc_part"} = '{f}';
${$dieli_sc{"negghia"}[4]}{"it_part"} = '{m}';
${$dieli_sc{"negghia"}[4]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu infernu
## 	0  ==  infernu {m} --> inferno {m} --> hell {n}
##
##  ADD:  "nfernu"
{ my $search = "nfernu"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "inferno" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "hell"    ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "vucca di nfernu"; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "maledico"  ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "bad mouth" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "lingua di nfernu"; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "maledico"  ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "bad mouth" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu invidia
## 	0  ==  invidia {f} --> invidia {f} --> envy {n}
##
##  ADD:  "nvidia"
{ my $search = "nvidia"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "invidia" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "envy"    ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu nicissità nicissitati
## 	0  ==  nicissità {f} --> necessità {f} --> necessity {n}
##	1  ==  nicissità {} --> <br> {} --> need {}
## 	2  ==  nicissità {f} --> necessità {f} --> need {n}
${$dieli_sc{"nicissità"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"nicissità"}[1]}{"it_word"} = 'necessità';
${$dieli_sc{"nicissità"}[1]}{"it_part"} = '{f}';
${$dieli_sc{"nicissità"}[1]}{"en_part"} = '{n}';

##   to make pair with "ava = grandmother", let's add "avo"
## $ ./query-dieli.pl sc strittu nonnu 
## 	0  ==  nonnu {m} --> nonno {m} --> granddad {n}
## 	1  ==  nonnu {m} --> nonno {m} --> grandfather {n}
${$dieli_sc{"nonnu"}[1]}{"it_word"} = 'avo';

## $ ./query-dieli.pl sc strittu nota
## 	0  ==  nota {f} --> <br> {f} --> footnote {n}
## 	1  ==  nota {} --> nota {f} --> note (gen) {n}
## 	2  ==  nota {} --> nota {f} --> note (music) {n}
${$dieli_sc{"nota"}[0]}{"it_word"} = 'nota';
${$dieli_sc{"nota"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"nota"}[2]}{"sc_part"} = '{f}';

## $ ./query-dieli.pl sc strittu ntiressi intiressi
## 	0  ==  ntiressi {m} --> interesse {m} --> interest {n}
## 	0  ==  intiressi {m} --> interesse {m} --> interest {n}
${$dieli_sc{"ntiressi"}[0]}{"sc_part"} = '{mpl}';
${$dieli_sc{"ntiressi"}[0]}{"it_word"} = 'interessi';
${$dieli_sc{"ntiressi"}[0]}{"it_part"} = '{mpl}';
${$dieli_sc{"ntiressi"}[0]}{"en_word"} = 'interests';
${$dieli_sc{"ntiressi"}[0]}{"en_part"} = '{npl}';
${$dieli_sc{"intiressi"}[0]}{"sc_part"} = '{mpl}';
${$dieli_sc{"intiressi"}[0]}{"it_word"} = 'interessi';
${$dieli_sc{"intiressi"}[0]}{"it_part"} = '{mpl}';
${$dieli_sc{"intiressi"}[0]}{"en_word"} = 'interests';
${$dieli_sc{"intiressi"}[0]}{"en_part"} = '{npl}';

## $ ./query-dieli.pl sc strittu notti
## 	0  ==  notti {f} --> notte {f} --> night {n}
## 	1  ==  notti {m} --> <br> {} --> nighttime {n}
${$dieli_sc{"notti"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"notti"}[1]}{"it_word"} = 'notte';
${$dieli_sc{"notti"}[1]}{"it_part"} = '{f}';

## $ ./query-dieli.pl sc strittu oduri 
## 	0  ==  oduri {f} --> odore {f} --> odor {n}
## 	1  ==  oduri {m} --> profumo {m} --> scent {n}
## 	2  ==  oduri {m} --> odore {m} --> smell {n}
${$dieli_sc{"oduri"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"oduri"}[0]}{"it_part"} = '{m}';

## $ ./query-dieli.pl sc strittu omu
## 	0  ==  omu {m} --> <br> {m} --> guy {n}
## 	1  ==  omu {} --> uomo {} --> man {}
${$dieli_sc{"omu"}[1]}{"it_word"} = 'uomo';
${$dieli_sc{"omu"}[1]}{"sc_part"} = '{m}';
${$dieli_sc{"omu"}[1]}{"it_part"} = '{m}';
${$dieli_sc{"omu"}[1]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu onuri 
## 	0  ==  onuri {m} --> onore {m} --> glory {n}
## 	1  ==  onuri {m} --> onore {m} --> honor {n}
## 	2  ==  onuri {f} --> <br> {f} --> reputation {n}
## 	3  ==  onuri {f} --> <br> {} --> respect {n}
${$dieli_sc{"onuri"}[2]}{"sc_part"} = '{m}';
${$dieli_sc{"onuri"}[3]}{"sc_part"} = '{m}';

## $ ./query-dieli.pl sc strittu pagghia
## 	0  ==  pagghia {} --> <br> {} --> hay {}
## 	1  ==  pagghia {f} --> paglia {f} --> straw {n}
${$dieli_sc{"pagghia"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"pagghia"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu paisi paìsi 
## 	0  ==  paisi {m} --> paese {m} --> country {n}
## 	1  ==  paisi {} --> paese {} --> nation {}
## 	2  ==  paisi {m} --> <br> {} --> town {}
## 	3  ==  paisi {m} --> <br> {} --> village {}
## 	0  ==  paìsi {} --> citta {} --> city {}
${$dieli_sc{"paisi"}[1]}{"sc_part"} = '{m}';
${$dieli_sc{"paisi"}[1]}{"it_part"} = '{m}';
${$dieli_sc{"paisi"}[1]}{"en_part"} = '{n}';
${$dieli_sc{"paisi"}[2]}{"en_part"} = '{n}';
${$dieli_sc{"paisi"}[3]}{"en_part"} = '{n}';
${$dieli_sc{"paìsi"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"paìsi"}[0]}{"it_word"} = 'città';
${$dieli_sc{"paìsi"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"paìsi"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu panza
## 	0  ==  panza {f} --> pancia {f} --> belly {n}
## 	1  ==  panza {f} --> <br> {} --> paunch {n}
## 	2  ==  panza {} --> pancia {} --> stomach {}
${$dieli_sc{"panza"}[2]}{"sc_part"} = '{f}';
${$dieli_sc{"panza"}[2]}{"it_part"} = '{f}';
${$dieli_sc{"panza"}[2]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu pariri
## 	0  ==  pariri {m} --> parere {m} --> advice {n}
## 	1  ==  pariri {v} --> apparire {v} --> appear {v}
## 	2  ==  pariri {f} --> parere {f} --> judgement {n}
## 	3  ==  pariri {m} --> parere {m} --> opinion {n}
## 	4  ==  pariri {v} --> parere {v} --> seem {v}
## 	5  ==  pariri {v} --> <br> {v} --> think (seem) {v}
## 	6  ==  pariri {m} --> parere {m} --> view {n}
${$dieli_sc{"pariri"}[2]}{"sc_part"} = '{m}';
${$dieli_sc{"pariri"}[2]}{"it_part"} = '{m}';

## $ ./query-dieli.pl sc strittu palora palori 
## 	0  ==  palora {} --> pegno {} --> pledge {n}
## 	1  ==  palora {f} --> parola {f} --> word {n}
## 	0  ==  palori {n} --> parole {n} --> words {n}
${$dieli_sc{"palora"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"palora"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"palori"}[0]}{"sc_part"} = '{fpl}';
${$dieli_sc{"palori"}[0]}{"it_part"} = '{fpl}';
${$dieli_sc{"palori"}[0]}{"en_part"} = '{npl}';

## $ ./query-dieli.pl sc strittu pazzia 
## 	0  ==  pazzia {f} --> <br> {f} --> insanity {n}
## 	1  ==  pazzia {} --> <br> {} --> lunacy {}
## 	2  ==  pazzia {} --> <br> {} --> madness {}
${$dieli_sc{"pazzia"}[0]}{"it_word"} = 'pazzia';
${$dieli_sc{"pazzia"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"pazzia"}[1]}{"en_part"} = '{n}';
${$dieli_sc{"pazzia"}[2]}{"sc_part"} = '{f}';
${$dieli_sc{"pazzia"}[2]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu pazzu
## 	0  ==  pazzu {adj} --> pazzo {adj} --> crazy {adj}
## 	1  ==  pazzu {m} --> <br> {m} --> fool {n}
## 	2  ==  pazzu {adj} --> <br> {adj} --> foolish {adj}
## 	3  ==  pazzu {adj} --> <br> {adj} --> insane {adj}
${$dieli_sc{"pazzia"}[1]}{"it_word"} = 'pazzo';

## $ ./query-dieli.pl sc strittu petra
## 	0  ==  petra {n} --> pietra {n} --> stone {n}
${$dieli_sc{"petra"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"petra"}[0]}{"it_part"} = '{f}';

## $ ./query-dieli.pl sc strittu pettu
## 	0  ==  pettu {m} --> petto {m} --> bosom {n}
## 	1  ==  pettu {f} --> petto {m} --> breast {n}
## 	2  ==  pettu {} --> torace {} --> chest {}
## 	3  ==  pettu {m} --> petto {m} --> chest (body) {n}
${$dieli_sc{"pettu"}[2]}{"sc_part"} = '{m}';
${$dieli_sc{"pettu"}[2]}{"it_part"} = '{m}';
${$dieli_sc{"pettu"}[2]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu pezza
## 	0  ==  pezza {} --> panno {} --> cloth {}
## 	1  ==  pezza {f} --> pezze {f} --> rag {n}
${$dieli_sc{"pezza"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"pezza"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"pezza"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu piaciri
## 	0  ==  piaciri {f} --> <br> {f} --> enjoyment {n}
## 	1  ==  piaciri {v} --> <br> {v} --> like {v}
## 	2  ==  piaciri {m} --> piacere {} --> pleasure {n}
${$dieli_sc{"piaciri"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"piaciri"}[0]}{"it_word"} = 'piacere';
${$dieli_sc{"piaciri"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"piaciri"}[1]}{"it_word"} = 'piacere';
${$dieli_sc{"piaciri"}[2]}{"it_part"} = '{m}';

## $ ./query-dieli.pl sc strittu piatta
## 	0  ==  piatta {p} --> piatti {p} --> plates {n}
${$dieli_sc{"piatta"}[0]}{"sc_part"} = '{mpl}';
${$dieli_sc{"piatta"}[0]}{"it_part"} = '{mpl}';
${$dieli_sc{"piatta"}[0]}{"en_part"} = '{npl}';

## $ ./query-dieli.pl sc strittu piatti
## 	0  ==  piatti {p} --> piatti {p} --> plates {n}
${$dieli_sc{"piatti"}[0]}{"sc_part"} = '{mpl}';
${$dieli_sc{"piatti"}[0]}{"it_part"} = '{mpl}';
${$dieli_sc{"piatti"}[0]}{"en_part"} = '{npl}';

## $ ./query-dieli.pl sc strittu piazza
## 	0  ==  piazza {} --> piazza {} --> plaza {}
${$dieli_sc{"piazza"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"piazza"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"piazza"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu picca
## 	0  ==  picca {adj} --> pochi {adj} --> few {adj}
## 	1  ==  picca {m} --> luccio {} --> lance {}
## 	2  ==  picca {adv} --> poco {adv} --> little {adv}
## 	3  ==  picca {} --> luccio {} --> pike {}
${$dieli_sc{"picca"}[1]}{"it_part"} = '{m}';
${$dieli_sc{"picca"}[1]}{"en_part"} = '{n}';
${$dieli_sc{"picca"}[3]}{"sc_part"} = '{m}';
${$dieli_sc{"picca"}[3]}{"it_part"} = '{m}';
${$dieli_sc{"picca"}[3]}{"en_part"} = '{n}';
##
{ my $search = "picca"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "scarsità" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "scarcity" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "picca"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "pochezza" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "scarcity" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "picca"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "penuria" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "penury"  ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

${$dieli_sc{"picca"}[1]}{"linkto"} = "picca_pike";
${$dieli_sc{"picca"}[3]}{"linkto"} = "picca_pike";
${$dieli_sc{"picca"}[4]}{"linkto"} = "picca_scarcity";
${$dieli_sc{"picca"}[5]}{"linkto"} = "picca_scarcity";
${$dieli_sc{"picca"}[6]}{"linkto"} = "picca_scarcity";

## $ ./query-dieli.pl sc strittu picciridda
## 	0  ==  picciridda {f} --> <br> {f} --> infant {n}
## 	1  ==  picciridda {f} --> <br> {f} --> little girl {n}
${$dieli_sc{"picciridda"}[0]}{"it_word"} = 'neonata';
${$dieli_sc{"picciridda"}[1]}{"it_word"} = 'piccolina';

## $ ./query-dieli.pl sc strittu picciriddi
## 	0  ==  picciriddi {} --> <br> {} --> little children {}
${$dieli_sc{"picciriddi"}[0]}{"sc_part"} = '{mpl}';
${$dieli_sc{"picciriddi"}[0]}{"it_word"} = 'piccolini';
${$dieli_sc{"picciriddi"}[0]}{"it_part"} = '{mpl}';
${$dieli_sc{"picciriddi"}[0]}{"en_part"} = '{npl}';

## $ ./query-dieli.pl sc strittu pìcciuli
## 	0  ==  pìcciuli {p} --> <br> {} --> money {n}
${$dieli_sc{"pìcciuli"}[0]}{"sc_part"} = '{mpl}';
${$dieli_sc{"pìcciuli"}[0]}{"it_word"} = 'spiccioli';
${$dieli_sc{"pìcciuli"}[0]}{"it_part"} = '{mpl}';
${$dieli_sc{"pìcciuli"}[0]}{"en_part"} = '{npl}';

## $ ./query-dieli.pl sc strittu picciuli
## 	0  ==  picciuli {adj} --> <br> {adj} --> small change {adj}
${$dieli_sc{"picciuli"}[0]}{"sc_part"} = '{mpl}';
${$dieli_sc{"picciuli"}[0]}{"it_word"} = 'spiccioli';
${$dieli_sc{"picciuli"}[0]}{"it_part"} = '{mpl}';
${$dieli_sc{"picciuli"}[0]}{"en_part"} = '{npl}';

## $ ./query-dieli.pl sc strittu pioggia
## 	0  ==  pioggia {} --> pioggia {} --> rain {n}
## 	1  ==  pioggia {f} --> precipitazione {f} --> shower {n}
${$dieli_sc{"pioggia"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"pioggia"}[0]}{"it_part"} = '{f}';

## $ ./query-dieli.pl sc strittu pirciali
## 	0  ==  pirciali {f} --> ghiaia {f} --> gravel {n}
${$dieli_sc{"pirciali"}[0]}{"sc_part"} = '{m}';

## $ ./query-dieli.pl sc strittu pitittu
## 	0  ==  pitittu {m} --> appetito {m} --> appetiti {n}
${$dieli_sc{"pitittu"}[0]}{"en_word"} = 'appetite';

## $ ./query-dieli.pl sc strittu pizzu
## 	0  ==  pizzu {m} --> becco {m} --> beak {n}
## 	1  ==  pizzu {m} --> bustarella {f} --> bribe {n}
## 	2  ==  pizzu {f} --> vetta {f} --> peak {n}
${$dieli_sc{"pizzu"}[2]}{"sc_part"} = '{m}';

## $ ./query-dieli.pl sc strittu posta
## 	0  ==  posta {} --> posta {} --> mail {}
${$dieli_sc{"posta"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"posta"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"posta"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu postu
## 	0  ==  postu {m} --> posto {m} --> place {n}
## 	1  ==  postu {m} --> posto {m} --> position {n}
## 	2  ==  postu {m} --> posta {f} --> post {n}
## 	3  ==  postu {m} --> posto {m} --> seat {n}
## 	4  ==  postu {f} --> posizione {f} --> site {n}
## 	5  ==  postu {adj} --> <br> {adj} --> situated {adj}
## 	6  ==  postu {f} --> ubicazione {f} --> situation {n}
## 	7  ==  postu {m} --> posto {m} --> spot {n}
## 	8  ==  postu {m} --> posto {m} --> station {n}
## 	9  ==  postu {m} --> posto libero {m} --> vacancy {n}
${$dieli_sc{"postu"}[2]}{"it_word"} = 'posto';
${$dieli_sc{"postu"}[2]}{"it_part"} = '{m}';
${$dieli_sc{"postu"}[4]}{"sc_part"} = '{m}';
${$dieli_sc{"postu"}[5]}{"it_word"} = 'posto';

## $ ./query-dieli.pl sc strittu prisidenti
## 	0  ==  prisidenti {f} --> <br> {f} --> president {n}
${$dieli_sc{"prisidenti"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"prisidenti"}[0]}{"it_word"} = 'presidente';
${$dieli_sc{"prisidenti"}[0]}{"it_part"} = '{m}';

## $ qdieli sc strittu priputenza
## 	priputenza  not found
{ my $search = "priputenza" ; 
  my %th ;  
  $th{"sc_word"} = $search      ; $th{"sc_part"} = "{f}" ;
  $th{"it_word"} = "prepotenza" ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "arrogance"  ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "priputenza" ; 
  my %th ;  
  $th{"sc_word"} = $search      ; $th{"sc_part"} = "{f}" ;
  $th{"it_word"} = "prepotenza" ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "overbearing action"  ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu putiri
## 	0  ==  putiri {v} --> poter fare {v} --> able {v}
## 	1  ==  putiri {m} --> potere {m} --> authority {n}
## 	2  ==  putiri {v} --> potere {v} --> be able to {v}
## 	3  ==  putiri {v} --> potere {v} --> can {v}
## 	4  ==  putiri {m} --> potere {m} --> faculty {n}
## 	5  ==  putiri {v} --> potere {v} --> may {v}
## 	6  ==  putiri {f} --> potere {f} --> might {n}
## 	7  ==  putiri {v} --> potere {v} --> might {v}
## 	8  ==  putiri {m} --> potere {m} --> power {n}
${$dieli_sc{"putiri"}[6]}{"sc_part"} = '{m}';
${$dieli_sc{"putiri"}[6]}{"it_part"} = '{m}';

## $ ./query-dieli.pl sc strittu quaternu
## 	0  ==  quaternu {} --> quaderno {} --> exercise book {}
## 	1  ==  quaternu {m} --> taccuino {m} --> notebook {n}
${$dieli_sc{"quaternu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"quaternu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"quaternu"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu quattrini
## 	0  ==  quattrini {pl} --> quatrini {pl} --> money {n}
## 	1  ==  quattrini {adj} --> <br> {adj} --> small change {adj}
${$dieli_sc{"quattrini"}[0]}{"sc_part"} = '{mpl}';
${$dieli_sc{"quattrini"}[0]}{"it_part"} = '{mpl}';
${$dieli_sc{"quattrini"}[0]}{"en_part"} = '{n}';
${$dieli_sc{"quattrini"}[1]}{"sc_part"} = '{mpl}';
${$dieli_sc{"quattrini"}[1]}{"it_word"} = 'quatrini';
${$dieli_sc{"quattrini"}[1]}{"it_part"} = '{mpl}';
${$dieli_sc{"quattrini"}[1]}{"en_part"} = '{npl}';

## $ ./query-dieli.pl sc strittu quistioni
## 	2  ==  quistioni {f} --> questione {f} --> issue {n}
## 	4  ==  quistioni {} --> questione {} --> matter {}
## 	6  ==  quistioni {} --> questione {} --> topic {}
#
## 	0  ==  quistioni {} --> argomento {} --> issue {}
## 	1  ==  quistioni {} --> suggetto {} --> issue {}
## 	3  ==  quistioni {} --> argomento {} --> matter {}
## 	5  ==  quistioni {} --> suggetto {} --> matter {}
## 	7  ==  quistioni {} --> suggetto {} --> topic {}
for my $i (4,6) {
    ${$dieli_sc{"quistioni"}[$i]}{"sc_part"} = '{f}';
    ${$dieli_sc{"quistioni"}[$i]}{"it_part"} = '{f}';
    ${$dieli_sc{"quistioni"}[$i]}{"en_part"} = '{n}';
}
for my $i (0,1,3,5,7) {
    ${$dieli_sc{"quistioni"}[$i]}{"sc_part"} = '{f}';
    ${$dieli_sc{"quistioni"}[$i]}{"it_part"} = '{m}';
    ${$dieli_sc{"quistioni"}[$i]}{"en_part"} = '{n}';    
}

## $ ./query-dieli.pl sc strittu raggiu
## 	0  ==  raggiu {m} --> raggio {m} --> beam {n}
## 	1  ==  raggiu {} --> scopo {} --> goal {}
## 	2  ==  raggiu {m} --> <br> {m} --> radius {n}
## 	3  ==  raggiu {m} --> raggio {m} --> ray {n}
## 	4  ==  raggiu {m} --> raggio {m} --> spoke {n}
##  
##  could not find "scopo, goal" in Mortillaro or Nicotra
{ my $index = 1;
  splice( @{$dieli_sc{"raggiu"}}, $index ,1);
}

## $ ./query-dieli.pl sc strittu re reghi riggina
## 	0  ==  re {m} --> re {m} --> king {n}
## 	reghi  not found
## 	riggina  not found
{ my $search = "reghi" ; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "re"       ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "king"     ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "riggina" ; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}" ;
  $th{"it_word"} = "regina"   ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "queen"    ; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu refuggiu
## 	0  ==  refuggiu {m} --> rifugio {m} --> asylum {n}
## 	1  ==  refuggiu {m} --> rifugio {m} --> cover {n}
## 	2  ==  refuggiu {f} --> <br> {f} --> hut {n}
${$dieli_sc{"refuggiu"}[2]}{"sc_part"} = '{m}';

## $ ./query-dieli.pl sc strittu rifiuti
## 	0  ==  rifiuti {f} --> robaccia {f} --> rubbish {n}
${$dieli_sc{"rifiuti"}[0]}{"sc_part"} = '{mpl}';

## $ ./query-dieli.pl sc strittu ritardu
## 	0  ==  ritardu {m} --> indugio {m} --> delay {n}
## 	1  ==  ritardu {m} --> ritardo {m} --> delay {n}
## 	2  ==  ritardu {adj} --> tardi {adj} --> late {adj}
## error -- "ritardu" is a noun  (already have "tardu", the adj.)
{ my $index = 2;
  splice( @{$dieli_sc{"ritardu"}}, $index ,1);
}

## $ ./query-dieli.pl sc strittu robba
## 	0  ==  robba {} --> roba {} --> goods {}
## 	1  ==  robba {} --> roba {} --> property {}
## 	2  ==  robba {f} --> roba {f} --> stuff {n}
## 	3  ==  robba {f} --> roba {f} --> things {v}
for my $i (0,1) {
    my $search = "robba";
    ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
    ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
    ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu rosi
## 	0  ==  rosi {fpl} --> <br> {} --> roses {n}
{ my $i = 0;
  my $search = "rosi";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'rose';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{fpl}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{npl}';
}

## $ ./query-dieli.pl sc strittu rùota
## 	0  ==  rùota {n} --> ruota {n} --> wheel {n}
{ my $i = 0;
  my $search = "rùota";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
}

## $ ./query-dieli.pl sc strittu sapuri 
## 	0  ==  sapuri {f} --> <br> {f} --> flavor {n}
## 	1  ==  sapuri {m} --> sapore {m} --> flavor {n}
## 	2  ==  sapuri {m} --> gusto {m} --> taste {n}
${$dieli_sc{"sapuri"}[0]}{"sc_part"} = '{m}';

## $ ./query-dieli.pl sc strittu scerra
## 	0  ==  scerra {f} --> <br> {f} --> fight {n}
## 	1  ==  scerra {f} --> lite {f} --> quarrel {n}
## 	2  ==  scerra {} --> discordia {} --> squabble {}
${$dieli_sc{"scerra"}[2]}{"sc_part"} = '{f}';
${$dieli_sc{"scerra"}[2]}{"it_part"} = '{f}';
${$dieli_sc{"scerra"}[2]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu scerri
## 	0  ==  scerri {} --> <br> {} --> discord {}
## 	1  ==  scerri {} --> <br> {} --> quarrel {}
for my $i (0,1) {
    ${$dieli_sc{"scerri"}[$i]}{"sc_part"} = '{fpl}';
    ${$dieli_sc{"scerri"}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu scherzu
## 	0  ==  scherzu {m} --> scherzo {m} --> fun {n}
{ my $search = "scherzu" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = '{m}' ;
  $th{"it_word"} = "scherzo" ; $th{"it_part"} = '{m}' ;
  $th{"en_word"} = "joke"    ; $th{"en_part"} = '{n}' ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu sciarra
## 	0  ==  sciarra {f} --> rissa {f} --> fight {n}
## 	1  ==  sciarra {f} --> lite {f} --> row {n}
## 	2  ==  sciarra {f} --> zuffa {f} --> brawl {n}
## 
## $ ./query-dieli.pl sc strittu sciarri
## 	0  ==  sciarri {f} --> <br> {} --> fights {n}
## 	1  ==  sciarri {} --> <br> {} --> quarrels {n}
## 	2  ==  sciarri {} --> <br> {} --> squabbles {n}
for my $i (0..2) {
    ${$dieli_sc{"sciarri"}[$i]}{"sc_part"} = '{fpl}';
    ${$dieli_sc{"sciarri"}[$i]}{"en_part"} = '{npl}';
}

## $ ./query-dieli.pl sc strittu scontu
## 	0  ==  scontu {m} --> sconto {m} --> rebate {n}
## 
## $ ./query-dieli.pl sc strittu sconto
## 	0  ==  sconto {} --> sconto {} --> discount {}
delete( $dieli_sc{"sconto"} );
{ my $search = "scontu" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = '{m}' ;
  $th{"it_word"} = "sconto"  ; $th{"it_part"} = '{m}' ;
  $th{"en_word"} = "discount"; $th{"en_part"} = '{n}' ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu scrusciu
## 	0  ==  scrusciu {} --> <br> {} --> rustle {}
## 	1  ==  scrusciu {} --> <br> {} --> scraping noise {}
for my $i (0,1) {
    ${$dieli_sc{"scrusciu"}[$i]}{"sc_part"} = '{m}';
    ${$dieli_sc{"scrusciu"}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu scupa
## 	0  ==  scupa {f} --> <br> {} --> broom {n}
## 	1  ==  scupa {f} --> erica {f} --> heather {n}
${$dieli_sc{"scupa"}[1]}{"it_word"} = 'scopa';
${$dieli_sc{"scupa"}[1]}{"it_part"} = '{f}';
##  that's "erica, heather" the plant used to make brooms

## $ ./query-dieli.pl sc strittu scupetta
## 	0  ==  scupetta {f} --> schioppo {f} --> gun {n}
## 	1  ==  scupetta {m} --> fucile da caccia {m} --> hunting rifle {n}
${$dieli_sc{"scupetta"}[1]}{"it_part"} = '{f}';

## $ ./query-dieli.pl sc strittu scuti
## 	0  ==  scuti {p} --> <br> {} --> money {n}
${$dieli_sc{"scuti"}[0]}{"sc_part"} = '{mpl}';
${$dieli_sc{"scuti"}[0]}{"it_word"} = 'scudi';
${$dieli_sc{"scuti"}[0]}{"it_part"} = '{mpl}';
${$dieli_sc{"scuti"}[0]}{"en_part"} = '{npl}';

## $ ./query-dieli.pl sc strittu sfurtna
## 	0  ==  sfurtna {f} --> sfortuna {f} --> misfortune {n}
## 
## $ ./query-dieli.pl sc strittu sfurtuna
## 	0  ==  sfurtuna {f} --> sfortuna {f} --> bad luck {n}
## 	1  ==  sfurtuna {m} --> disastro {m} --> calamity {n}
delete( $dieli_sc{"sfurtna"} ) ;
{ my $search = "sfurtuna" ; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{f}" ;
  $th{"it_word"} = "sfortuna"  ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "misfortune"; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu sfunnu
## 	0  ==  sfunnu {f} --> istruzione {f} --> background {n}
## 	1  ==  sfunnu {m} --> <br> {m} --> ground {n}
## 	2  ==  sfunnu {m} --> <br> {m} --> setting {n}
${$dieli_sc{"sfunnu"}[0]}{"sc_part"} = '{m}';

## $ ./query-dieli.pl sc strittu sicaretta
## 	0  ==  sicaretta {} --> sigaretta {} --> cigarette {}
{ my $i = 0;
  my $search = "sicaretta"; 
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu signurìa
## 	0  ==  signurìa {} --> <br> {} --> arrogance {}
## 	1  ==  signurìa {} --> <br> {} --> elegance {}
## 	2  ==  signurìa {f} --> nobiltà {f} --> nobility {n}
## 	3  ==  signurìa {f} --> <br> {} --> power {n}
for my $i (0,1) {
    my $search = "signurìa"; 
    ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
    ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu sòggira
## 	0  ==  sòggira {f} --> suocera {f} --> mother-in-law {n}
## 
## $ ./query-dieli.pl sc strittu "sòggira e sòggiru"
## 	0  ==  sòggira e sòggiru {mpl} --> suoceri {mpl} --> parents-in-law {pl}  
{ my $i = 0;
  my $search = "sòggira e sòggiru";
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{npl}';
}
{ my $search = "sòggiru"; 
  my %th ;  
  $th{"sc_word"} = $search        ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "suocero"      ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "father-in-law"; $th{"en_part"} = "{n}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu sordi
## 	0  ==  sordi {p} --> <br> {} --> money {n}
{ my $i = 0;
  my $search = "sordi";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{mpl}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'soldi';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{mpl}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{npl}';
}

## $ ./query-dieli.pl sc strittu spagu
## 	0  ==  spagu {m} --> spago {m} --> cord {n}
## 	1  ==  spagu {} --> spago {} --> string {}
## 	2  ==  spagu {m} --> spago {m} --> string {n}
${$dieli_sc{"spagu"}[1]}{"sc_part"} = '{m}';
${$dieli_sc{"spagu"}[1]}{"it_part"} = '{m}';
${$dieli_sc{"spagu"}[1]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu staggiuni
## 	0  ==  staggiuni {f} --> <br> {} --> season {n}
## 	1  ==  staggiuni {f} --> estate {f} --> summer {n}
{ my $i = 0;
  my $search = "staggiuni";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'stagione';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
}

## $ ./query-dieli.pl sc strittu stiddi
## 	0  ==  stiddi {f} --> <br> {} --> stars {n}
{ my $i = 0;
  my $search = "stiddi";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{fpl}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'stelle';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{fpl}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{npl}';
}

## $ ./query-dieli.pl sc strittu stoffa
## 	0  ==  stoffa {f} --> stoffa {f} --> cloth {n}
## 	1  ==  stoffa {f} --> stoffa {f} --> fabric {n}
## 	2  ==  stoffa {} --> stoffa {} --> material {}
## 	3  ==  stoffa {f} --> stoffa {f} --> stuff {n}
{ my $i = 2;
  my $search = "stoffa";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu surci
## 	0  ==  surci {} --> <br> {} --> mice {}
## 	1  ==  surci {} --> topi {} --> mice {}
## 	2  ==  surci {m} --> topo {m} --> mouse {n}
## 	3  ==  surci {m} --> ratto {m} --> rat {n}
for my $i (0,1) {
    my $search = "surci";
    ${$dieli_sc{$search}[$i]}{"sc_part"} = '{mpl}';
    ${$dieli_sc{$search}[$i]}{"it_word"} = 'topi';
    ${$dieli_sc{$search}[$i]}{"it_part"} = '{mpl}';
    ${$dieli_sc{$search}[$i]}{"en_part"} = '{npl}';
}

## $ ./query-dieli.pl sc strittu tabbaccaru
## 	0  ==  tabbaccaru {f} --> tabaccheria {f} --> cigar shop {n}
${$dieli_sc{"tabbaccaru"}[0]}{"sc_part"} = '{m}';

## $ ./query-dieli.pl sc strittu televisioni
## 	0  ==  televisioni {f} --> <br> {f} --> television {n}
{ my $i = 0;
  my $search = "televisioni";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'televisione';
} 

## $ ./query-dieli.pl sc strittu tenna
## 	0  ==  tenna {f} --> tenda {f} --> awning {n}
## 	1  ==  tenna {f} --> tenda {f} --> curtain {n}
## 	2  ==  tenna {f} --> <br> {f} --> shade (window) {n}
## 	3  ==  tenna {m} --> <br> {m} --> sunshade {n}
## 	4  ==  tenna {f} --> <br> {f} --> tent {n}
{ my $i = 3;
  my $search = "tenna";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
} 

## $ ./query-dieli.pl sc strittu terra
## 	0  ==  terra {f} --> terra {f} --> country {n}
## 	1  ==  terra {f} --> terra {f} --> earth {n}
## 	2  ==  terra {f} --> terra {f} --> ground {n}
## 	3  ==  terra {} --> terra {} --> land {}
## 	4  ==  terra {f} --> terra {f} --> soil {n}
{ my $i = 3;
  my $search = "terra";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
} 

## $ ./query-dieli.pl sc strittu tigri
## 	0  ==  tigri {f} --> <br> {f} --> tiger {n}
{ my $i = 0;
  my $search = "tigri";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'tigre';
}

## $ ./query-dieli.pl sc strittu tradizioni
## 	0  ==  tradizioni {f} --> <br> {f} --> tradition {n}
{ my $i = 0;
  my $search = "tradizioni";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'tradizione';
}

## $ ./query-dieli.pl sc strittu traduzzioni
## 	0  ==  traduzzioni {f} --> traduzione {f} --> version {n}
{ my $search = "traduzzioni" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{f}" ;
  $th{"it_word"} = "traduzione"  ; $th{"it_part"} = "{f}" ;
  $th{"en_word"} = "translation" ; $th{"en_part"} = "{n}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu tranquilità
## 	0  ==  tranquilità {f} --> <br> {f} --> tranquility {n}
{ my $i = 0;
  my $search = "tranquilità";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'tranquillità';
}
## $ ./query-dieli.pl sc strittu tranquillità
## 	0  ==  tranquillità {f} --> <br> {f} --> calm {n}
## 	1  ==  tranquillità {f} --> <br> {f} --> still {n}
{ my $i = 0;
  my $search = "tranquillità";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'tranquillità';
}

## $ ./query-dieli.pl sc strittu travagghiu
## 	0  ==  travagghiu {m} --> <br> {m} --> job {n}
## 	1  ==  travagghiu {} --> <br> {} --> labor {}
## 	2  ==  travagghiu {m} --> lavoro {m} --> work {n}
## 	3  ==  travagghiu {} --> posto (di lavoro) {} --> workplace {}
for my $i (1,3) {
    my $search = "travagghiu";
    ${$dieli_sc{$search}[$i]}{"sc_part"} = '{m}';
    ${$dieli_sc{$search}[$i]}{"it_part"} = '{m}';
    ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu tuvagghia
## 	0  ==  tuvagghia {} --> asciugamano {} --> hand towel {}
## 	1  ==  tuvagghia {f} --> tovaglia {f} --> tablecloth {n}
{ my $i = 0;
  my $search = "tuvagghia";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{m}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu ugna
## 	0  ==  ugna {} --> unghia {} --> nail (as in finger or toe) {}
{ my $i = 0;
  my $search = "ugna";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{mpl}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'unghie';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{mpl}';
  ${$dieli_sc{$search}[$i]}{"en_word"} = 'nails (as in finger or toe)';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{npl}';
}
{ my $search = "ugnu" ; 
  my %th ;  
  $th{"sc_word"} = $search      ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "unghia   "  ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "fingernail" ; $th{"en_part"} = "{n}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "ugnu" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{m}" ;
  $th{"it_word"} = "unghia"  ; $th{"it_part"} = "{m}" ;
  $th{"en_word"} = "toenail" ; $th{"en_part"} = "{n}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu valanza
## 	0  ==  valanza {n} --> bilancia {n} --> balance {n}
## 	1  ==  valanza {n} --> bilancia {n} --> scale {n}
## 	2  ==  valanza {n} --> bilancia {n} --> scales {n}
${$dieli_sc{"valanza"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"valanza"}[1]}{"sc_part"} = '{f}';
${$dieli_sc{"valanza"}[2]}{"sc_part"} = '{f}';
${$dieli_sc{"valanza"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"valanza"}[1]}{"it_part"} = '{f}';
${$dieli_sc{"valanza"}[2]}{"it_part"} = '{f}';

## $ ./query-dieli.pl sc strittu vampa
## 	0  ==  vampa {f} --> <br> {} --> blaze {n}
## 	1  ==  vampa {} --> <br> {} --> flame {n}
## 	2  ==  vampa {} --> <br> {} --> flash {n}
for my $i (1,2) {
    my $search = "vampa";
    ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
}

## $ ./query-dieli.pl sc strittu vasata
## 	0  ==  vasata {} --> <br> {} --> kiss {n}
${$dieli_sc{"vasata"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"vasata"}[0]}{"it_word"} = 'bacio';
${$dieli_sc{"vasata"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"vasata"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu vastuneddu
## 	0  ==  vastuneddu {} --> <br> {} --> stick {}
${$dieli_sc{"vastuneddu"}[0]}{"sc_part"} = '{m}';
${$dieli_sc{"vastuneddu"}[0]}{"it_word"} = 'bastoncello';
${$dieli_sc{"vastuneddu"}[0]}{"it_part"} = '{m}';
${$dieli_sc{"vastuneddu"}[0]}{"en_part"} = '{n}';
{ my $search = "vastuneddu"; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "bastoncello" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "little cane" ; $th{"en_part"} = "{n}"; 
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu vasuni
## 	0  ==  vasuni {m} --> bacio {m} --> kiss {n}
## 	1  ==  vasuni {f} --> <br> {f} --> smack (kiss) {n}
${$dieli_sc{"vasuni"}[1]}{"sc_part"} = '{m}';

## $ ./query-dieli.pl sc strittu vicchiaja
## 	0  ==  vicchiaja {adj} --> <br> {adj} --> old age {adj}
${$dieli_sc{"vicchiaja"}[0]}{"sc_part"} = '{f}';
${$dieli_sc{"vicchiaja"}[0]}{"it_word"} = 'vecchiaia';
${$dieli_sc{"vicchiaja"}[0]}{"it_part"} = '{f}';
${$dieli_sc{"vicchiaja"}[0]}{"en_part"} = '{n}';

## $ ./query-dieli.pl sc strittu vicina
## 	0  ==  vicina {f} --> <br> {f} --> neighbor {n}
${$dieli_sc{"vicina"}[0]}{"it_word"} = 'vicina';

## $ ./query-dieli.pl sc strittu vicini
## 	0  ==  vicini {pl} --> <br> {} --> neighbors {n}
{ my $i = 0;
  my $search = "vicini";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{mpl}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'vicini';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{mpl}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{npl}';
}

## $ ./query-dieli.pl sc strittu viddanu
## 	0  ==  viddanu {m} --> villano {m} --> farm laborer {n}
## 	5  ==  viddanu {m} --> villano {m} --> peasant {n}
## 	7  ==  viddanu {m} --> villano {m} --> yokel {n}
## 	2  ==  viddanu {} --> <br> {} --> hired hand {}
## 	1  ==  viddanu {m} --> contadino {m} --> farmer {n}
## 	3  ==  viddanu {} --> <br> {} --> ill mannered {}
## 	4  ==  viddanu {adj} --> <br> {adj} --> mean (humble) {adj}
## 	6  ==  viddanu {adj} --> <br> {adj} --> rude {adj}
{ my $i = 2;
  my $search = "viddanu";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{m}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}
{ my $i = 3;
  my $search = "viddanu";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{adj}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{adj}';
}
{ my $i = 6;
  my $search = "viddanu";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'villano';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{adj}';
}

## $ ./query-dieli.pl sc strittu viduva
## 	0  ==  viduva {} --> <br> {} --> widow {}
{ my $i = 0;
  my $search = "viduva";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'vedova';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu minnitta
## 	0  ==  minnitta {f} --> spreco {m} --> waste {n}
## 	1  ==  minnitta {f} --> vendetta {f} --> revenge {n}
## 
## $ ./query-dieli.pl sc strittu vinnitta
## 	0  ==  vinnitta {f} --> vendetta {f} --> revenge {n}
## 
## $ ./query-dieli.pl sc strittu vinnitai
## 	0  ==  vinnitai {f} --> vendetta {f} --> vendetta {n}
delete( $dieli_sc{"vinnitai"} );
{ my $search = "vinnitta"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "vendetta" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "vendetta" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "vinnitta"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "vendetta" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "vengeance"; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu vinticeddu
## 	0  ==  vinticeddu {v} --> <br> {v} --> breeze {v}
{ my $i = 0;
  my $search = "vinticeddu";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{m}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'venticello';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{m}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu vintura
## 	0  ==  vintura {} --> <br> {} --> chance {}
## 	1  ==  vintura {f} --> <br> {} --> destiny {n}
## 	2  ==  vintura {f} --> <br> {f} --> fate {n}
## 	3  ==  vintura {f} --> fortuna {f} --> fortune {n}
## 	4  ==  vintura {} --> <br> {} --> luck {}
## 	5  ==  vintura {} --> ventura {} --> luck {}
## 	6  ==  vintura {f} --> <br> {} --> risk {n}
for my $i (0..6) {
  my $search = "vintura";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu virdura
## 	0  ==  virdura {f} --> verdura {f} --> greens {pl}
## 	1  ==  virdura {p} --> verdura {p} --> vegetables (green) {n}
for my $i (0,1) {
  my $search = "virdura";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{npl}';
}

## $ ./query-dieli.pl sc strittu virità
## 	0  ==  virità {f} --> <br> {f} --> truth {n}
{ my $i = 0;
  my $search = "virità";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'verità';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
}

## $ ./query-dieli.pl sc strittu vistiti
## 	0  ==  vistiti {mpl} --> vestiti {mpl} --> clothes {pl}
{ my $i = 0;
  my $search = "vistiti";
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{npl}';
}

## $ ./query-dieli.pl sc strittu viti
## 	0  ==  viti {} --> <br> {} --> grapevine {}
## 	1  ==  viti {f} --> vite {f} --> screw {n}
## 	2  ==  viti {f} --> vite {f} --> vine {n}
{ my $i = 0 ;
  my $search = "viti";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu vizziu
## 	0  ==  vizziu {m} --> <br> {} --> defect (moral) {n}
## 	1  ==  vizziu {} --> <br> {} --> depravity {}
## 	2  ==  vizziu {m} --> <br> {} --> vice {}
for my $i (0..2) {
  my $search = "vizziu";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{m}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'vizio';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{m}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu voscu
## 	0  ==  voscu {m} --> bosco {m} --> forest {n}
## 	1  ==  voscu {m} --> parco {m} --> park {n}
## 	2  ==  voscu {m} --> bosco {m} --> wood {n}
## 	3  ==  voscu {p} --> <br> {} --> woods {n}
${$dieli_sc{"voscu"}[3]}{"sc_part"} = '{m}';

## $ ./query-dieli.pl sc strittu vrancu 
## 	0  ==  vrancu {} --> ramo {} --> branch {}
## 	1  ==  vrancu {adj} --> bianco {adj} --> white {adj}
##  the adjective "vrancu" = "biancu (white)"
##  the noun should be "la vranca"
delete( $dieli_sc{"vrancu"} ) ;
{ my $search = "vranca" ; my $index = 0 ; 
  ${$dieli_sc{$search}[$index]}{"sc_word"} = $search;
  ${$dieli_sc{$search}[$index]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$index]}{"it_word"} = 'ramo';
  ${$dieli_sc{$search}[$index]}{"it_part"} = '{m}';
  ${$dieli_sc{$search}[$index]}{"en_word"} = 'branch';
  ${$dieli_sc{$search}[$index]}{"en_part"} = '{n}';
}
{ my $search = "vrancu" ; my $index = 0 ; 
  ${$dieli_sc{$search}[$index]}{"sc_word"} = $search;
  ${$dieli_sc{$search}[$index]}{"sc_part"} = '{adj}';
  ${$dieli_sc{$search}[$index]}{"it_word"} = 'bianco';
  ${$dieli_sc{$search}[$index]}{"it_part"} = '{adj}';
  ${$dieli_sc{$search}[$index]}{"en_word"} = 'white';
  ${$dieli_sc{$search}[$index]}{"en_part"} = '{adj}';
}

## $ ./query-dieli.pl sc strittu vriogna
## 	0  ==  vriogna {f} --> onta {f} --> shame {n}
## 	1  ==  vriogna {f} --> disonore {f} --> disonoor {n}
## 	2  ==  vriogna {f} --> vergogna {f} --> disgrace {n}
{ my $i = 1;
  my $search = "vriogna";
  ${$dieli_sc{$search}[$i]}{"en_word"} = 'dishonor';
}

## $ ./query-dieli.pl sc strittu zappuni
## 	0  ==  zappuni {} --> zappa {} --> hoe {}
## 	1  ==  zappuni {f} --> <br> {} --> mattock {n}
for my $i (0,1) {
    my $search = "zappuni";
    ${$dieli_sc{$search}[$i]}{"sc_part"} = '{m}';
    ${$dieli_sc{$search}[$i]}{"it_word"} = 'zappa';
    ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
    ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu zefiru
## 	0  ==  zefiru {v} --> <br> {v} --> breeze {v}
{ my $i = 0;
  my $search = "zefiru";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{m}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'zeffiro';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{m}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu zita
## 	0  ==  zita {} --> <br> {} --> bride {}
## 	1  ==  zita {f} --> sposa {f} --> bride {n}
## 	2  ==  zita {} --> fidanzata {f} --> fiancée {n}
## 	3  ==  zita {f} --> innamorata {f} --> sweetheart {n}
{ my $i = 0;
  my $search = "zita";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}
{ my $i = 2;
  my $search = "zita";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
}


##  { my $i = 0;
##    my $search = "";
##    ${$dieli_sc{$search}[$i]}{"sc_part"} = '{m}';
##    ${$dieli_sc{$search}[$i]}{"it_word"} = '';
##    ${$dieli_sc{$search}[$i]}{"it_part"} = '{m}';
##    ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
##  }
##  STOPPED HERE


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  La TALIA
##  == =====

{ my $search = "Abbruzzu"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Abbruzzo" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Abbruzzo" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Lucania"; 
  my %th ;  
  $th{"sc_word"} = $search      ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Basilicata" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Basilicata" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Calabbria"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Calabria" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Calabria" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Campania"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Campania" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Campania" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Emilia"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Emilia" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Emilia" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Rumagna"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Romagna" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Romagna" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Friuli"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Friuli" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Friuli" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Venezzia Giulia"; 
  my %th ;  
  $th{"sc_word"} = $search          ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Venezia Giulia" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Venezia Giulia" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Lazziu"; 
  my %th ;  
  $th{"sc_word"} = $search ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Lazio" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Lazio" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Liguria"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Liguria" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Liguria" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Lummardìa"; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Lombardia" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Lombardy"  ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Marchi"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{fpl}";
  $th{"it_word"} = "Marche" ; $th{"it_part"} = "{fpl}";
  $th{"en_word"} = "Marche" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Mulisi"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Molise" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Molise" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Piemunti"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Piemonte" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Piedmont" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Pugghia"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Puglia" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Apulia" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu Sicilia
## 	0  ==  Sicilia {f} --> <br> {} --> Sicily {n}
{ my $i = 0;
  my $search = "Sicilia";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'Sicilia';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
}

{ my $search = "Sardigna"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Sardegna" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Sardinia" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Tuscana"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Toscana" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Tuscany" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Trentinu"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Trentino" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Trentino" ; $th{"en_part"} = "{n}"; 
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Autu Adici"; 
  my %th ;  
  $th{"sc_word"} = $search      ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Alto Adige" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Alto Adige" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Suttu Tirolu"; 
  my %th ;  
  $th{"sc_word"} = $search      ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Sud Tirolo" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "South Tyrol"; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Umbria"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Umbria" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Umbria" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Vaddi d'Aosta"; 
  my %th ;  
  $th{"sc_word"} = $search         ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Valle d'Aosta" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Aosta Valley"  ; $th{"en_part"} = "{n}";
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Vènitu"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Veneto" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Veneto" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "L'Aquila"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "L'Aquila" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "L'Aquila" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Putenza"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Potenza" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Potenza" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Pizzu"; 
  my %th ;  
  $th{"sc_word"} = $search         ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Pizzo"         ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Pizzo Calabro" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Vibbu Valenzia"; 
  my %th ;  
  $th{"sc_word"} = $search          ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Vibo Valentia"  ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Vibo Valentia"  ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Riggiu Calabbria"; 
  my %th ;  
  $th{"sc_word"} = $search           ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Reggio Calabria" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Reggio Calabria" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Catanzaru"; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Catanzaro" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Catanzaro" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Cusenza"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Cosenza" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Cosenza" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Cutroni"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Crotone" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Crotone" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Nàpuli"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Napoli" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Naples" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Bulogna"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Bologna" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Bologna" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Triesti"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Trieste" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Trieste" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Roma"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Roma"   ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Rome"   ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Gènuva"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Genova"  ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Genoa"   ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Milanu"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Milano"   ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Milan"    ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Ancona"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Ancona" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Ancona" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Campubbassu"; 
  my %th ;  
  $th{"sc_word"} = $search      ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Campobasso" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Campobasso" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Turinu"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Torino" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Turin"  ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Lecci"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Lecce"   ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Lecce"   ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Bari"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Bari"   ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Bari"   ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Barletta"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Barletta" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Barletta" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Andria"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Andria"  ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Andria"  ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Trani"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Trani"   ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Trani"   ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Foggia"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Foggia"  ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Foggia"  ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Brìndisi"; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Brindisi"  ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Brindisi"  ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Tàrantu"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Taranto"  ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Taranto"  ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Càgliari"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Cagliari" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Cagliari" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu Palermu
##      0  ==  Palermu {n} --> <br> {} --> Palermo {}
{ my $i = 0;
  my $search = "Palermu";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{m}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'Palermo';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{m}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

## $ ./query-dieli.pl sc strittu Missina
## 	0  ==  Missina {} --> <br> {} --> Messina {}
{ my $i = 0;
  my $search = "Missina"; 
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'Messina';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

{ my $search = "Carini"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Carini" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Carini" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Casteddammari"; 
  my %th ;  
  $th{"sc_word"} = $search                   ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Castellammare del Golfo" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Castellammare del Golfo" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Sarausa"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Siracusa" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Syracuse" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Tràpani"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Trapani"  ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Trapani"  ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Girgenti"; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Agrigento" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Agrigento" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Nissa"; 
  my %th ;  
  $th{"sc_word"} = $search         ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Caltanissetta" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Caltanissetta" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Enna"; 
  my %th ;  
  $th{"sc_word"} = $search ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Enna"  ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Enna"  ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu Catania
## 	0  ==  Catania {} --> Catania {} --> Catania {}
{ my $i = 0;
  my $search = "Catania";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{f}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{n}';
}

{ my $search = "Rausa"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Ragusa" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Ragusa" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
    
{ my $search = "Firenzi"; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Firenze"  ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Florence" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Trentu"; 
  my %th ;  
  $th{"sc_word"} = $search  ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Trento" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Trent"  ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Buzzanu"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{m}";
  $th{"it_word"} = "Bolzano" ; $th{"it_part"} = "{m}";
  $th{"en_word"} = "Bolzano" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Perugia"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Perugia" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Perugia" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Aosta"; 
  my %th ;  
  $th{"sc_word"} = $search ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Aosta" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Aosta" ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

{ my $search = "Vinezzia"; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{f}";
  $th{"it_word"} = "Venezia" ; $th{"it_part"} = "{f}";
  $th{"en_word"} = "Venice"  ; $th{"en_part"} = "{n}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  EXAMPLES of VERBS
##  ======== == =====

## $ ./query-dieli.pl sc strittu càncianu
## 	0  ==  càncianu {v} --> <br> {} --> change {}
${$dieli_sc{"càncianu"}[0]}{"en_part"} = '{v}';

## $ ./query-dieli.pl sc strittu chianci
## 	0  ==  chianci {} --> piange {} --> cry {}
${$dieli_sc{"chianci"}[0]}{"sc_part"} = '{v}';
${$dieli_sc{"chianci"}[0]}{"it_part"} = '{v}';
${$dieli_sc{"chianci"}[0]}{"en_part"} = '{v}';

## $ ./query-dieli.pl sc strittu havi
## 	0  ==  havi {v} --> <br> {v} --> he has {v}
## 	1  ==  havi {} --> deve {} --> must {}
## 	2  ==  havi {} --> deve {} --> must {}
{ my $search = "havi" ;
  ${$dieli_sc{$search}[0]}{"it_word"} = 'ha';
  foreach my $index (1,2) {
      $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
  }
}

## $ ./query-dieli.pl sc strittu mittillu
## 	0  ==  mittillu {v} --> <br> {v} --> put it {v}
${$dieli_sc{"mittillu"}[0]}{"it_word"} = "mettilo" ;

##  $ ./query-dieli.pl sc strittu natu
##  	0  ==  natu {adj} --> nato {adj} --> born {adj}
##  	1  ==  natu {v} --> <br> {} --> is born {v}
${$dieli_sc{"natu"}[0]}{"linkto"} = "nasciri" ;
${$dieli_sc{"natu"}[1]}{"linkto"} = "nasciri" ;

##  $ ./query-dieli.pl sc pari
##  	0  ==  pari {} --> manifesta {} --> be revealed {}
##  	1  ==  pari {v} --> <br> {v} --> seem {v}
##  	2  ==  pari {} --> <br> {} --> show {}
##  
{ my $search = "pari" ; 
  foreach my $index (0..2) {
      $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
      ${$dieli_sc{$search}[$index]}{"linkto"} = "pàriri" ;
  }
}

## $ ./query-dieli.pl sc strittu rùmpinu
## 	0  ==  rùmpinu {} --> <br> {} --> break (they) {}
${$dieli_sc{"rùmpinu"}[0]}{"sc_part"} = '{v}';
${$dieli_sc{"rùmpinu"}[0]}{"en_part"} = '{v}';

## $ ./query-dieli.pl sc strittu spenni
## 	0  ==  spenni {} --> <br> {} --> spends {}
${$dieli_sc{"spenni"}[0]}{"sc_part"} = '{v}';
${$dieli_sc{"spenni"}[0]}{"en_part"} = '{v}';

## $ ./query-dieli.pl sc strittu spera
## 	0  ==  spera {f} --> <br> {} --> hope {n}
## 	1  ==  spera {} --> <br> {} --> hopes {}
${$dieli_sc{"spera"}[0]}{"sc_part"} = '{v}';
${$dieli_sc{"spera"}[0]}{"en_part"} = '{v}';
${$dieli_sc{"spera"}[1]}{"sc_part"} = '{v}';
${$dieli_sc{"spera"}[1]}{"en_part"} = '{v}';

## $ ./query-dieli.pl sc strittu succedi
## 	0  ==  succedi {} --> <br> {} --> happen {}
{ my $i = 0;
  my $search = "succedi";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{v}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{v}';  
}


##  $ ./query-dieli.pl sc vèstiti 
##  	0  ==  vèstiti {v} --> <br> {v} --> dress {v}
##  	1  ==  vèstiti {} --> <br> {} --> dress up {}
##  	2  ==  vèstiti {v} --> <br> {} --> put on clothing {v}
##  
{ my $search = "vèstiti" ; 
  foreach my $index (0..2) {
      $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
      ${$dieli_sc{$search}[$index]}{"linkto"} = "vistirisi" ;
  }
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  VERBS
##  =====

##  $ ./query-dieli.pl sc allungari
##  	0  ==  allungari {} --> allongare {} --> defer {}
##  	1  ==  allungari {} --> farsene {} --> defer {}
##  	3  ==  allungari {} --> allongare {} --> lengthen {}
##  	4  ==  allungari {} --> farsene {} --> lengthen {}
##  	5  ==  allungari {} --> allungare {} --> prolong {}
##  
foreach my $index (0,1,3,4,5) { 
    my $search = "allungari" ; 
    $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu rinfriscari
## 	0  ==  rinfriscari {v} --> rinfrescare {v} --> refresh {v}
## 
## $ qdieli sc strittu arrifriscari rifriscari 
## 	arrifriscari  not found
## 	rifriscari  not found
{ my $search = "arrifriscari" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "rinfrescare" ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "refresh"     ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "rifriscari" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "rinfrescare" ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "refresh"     ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu "aviri a"
## 	0  ==  aviri a {v} --> dovere {v} --> have to {v}
## 	1  ==  aviri a {} --> dovere {} --> must {}
{ my $search = "aviri a" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc chiùdiri 
##  	0  ==  chiùdiri {} --> chiudere {} --> close {}
##  
{ my $search = "chiùdiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc perdiri
##  	0  ==  perdiri {} --> perdere {} --> lose {}
##  
{ my $search = "perdiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc veniri
##  	0  ==  veniri {} --> <br> {} --> arrive {}
## 
{ my $search = "veniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc viviri
##  	1  ==  viviri {} --> vivere {} --> live {}
##  
{ my $search = "viviri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc vuliri
##  	0  ==  vuliri {} --> volere {} --> want {}
##  
{ my $search = "vuliri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  


##  $ ./query-dieli.pl sc abbagnari
##  	0  ==  abbagnari {} --> pucciare {} --> wet {}
##  
{ my $search = "abbagnari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc abbasiliscari
##  	0  ==  abbasiliscari {} --> trasecolare {} --> be dumbfounded {}
##  
{ my $search = "abbasiliscari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc abbastari
##  	0  ==  abbastari {} --> bastare {} --> be enough {}
##  
{ my $search = "abbastari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc abbianchiari
##  	0  ==  abbianchiari {} --> imbiancare {} --> whiten {}
##  
{ my $search = "abbianchiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc abbijari
##  	0  ==  abbijari {} --> avviare {} --> lead {}
##  
{ my $search = "abbijari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc abbinnari
##  	0  ==  abbinnari {vf} --> bendare {v} --> blindfold {v}
##  
{ my $search = "abbinnari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc abbuffuniari
##  	0  ==  abbuffuniari {} --> prendere in giro {} --> make fun of {}
##  
{ my $search = "abbuffuniari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc abbuffuniari
##  	1  ==  abbuffuniari {} --> prendere in giro {} --> string along {}
##  
{ my $search = "abbuffuniari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc abbàttiri
##  	0  ==  abbàttiri {} --> abbattere {} --> defeat {}
##  
{ my $search = "abbàttiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc abbàttiri
##  	1  ==  abbàttiri {} --> sconfiggere {} --> defeat {}
##  
{ my $search = "abbàttiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc abbàttiri
##  	2  ==  abbàttiri {} --> abbattere {} --> knock down {}
##  
{ my $search = "abbàttiri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc abbàttiri
##  	3  ==  abbàttiri {} --> sconfiggere {} --> knock down {}
##  
{ my $search = "abbàttiri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accalari
##  	0  ==  accalari {} --> abbassare {} --> lower {}
##  
{ my $search = "accalari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accalarisi
##  	0  ==  accalarisi {} --> abbassarsi {} --> lower oneself {}
##  
{ my $search = "accalarisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accalarisi
##  	1  ==  accalarisi {} --> abbassarsi {} --> stoop {}
##  
{ my $search = "accalarisi" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accanzari
##  	2  ==  accanzari {} --> ottenere {} --> obtain {}
##  
{ my $search = "accanzari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accapari
##  	1  ==  accapari {} --> finire {} --> finish {v}
##  
{ my $search = "accapari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accapari
##  	2  ==  accapari {} --> terminare {} --> finish {v}
##  
{ my $search = "accapari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accaparrari
##  	0  ==  accaparrari {} --> abbrancare {} --> grasp {}
##  
{ my $search = "accaparrari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accaparrari
##  	1  ==  accaparrari {} --> afferrare {} --> grasp {}
##  
{ my $search = "accaparrari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accaparrari
##  	2  ==  accaparrari {} --> abbrancare {} --> seize {}
##  
{ my $search = "accaparrari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accucchiari
##  	0  ==  accucchiari {} --> abbinare {} --> bring together {}
##  
{ my $search = "accucchiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accucchiari
##  	1  ==  accucchiari {} --> accoppiare {} --> bring together {}
##  
{ my $search = "accucchiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accucchiari
##  	2  ==  accucchiari {} --> accoppiare {} --> match {}
##  
{ my $search = "accucchiari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accuminciari
##  	0  ==  accuminciari {} --> cominciare {} --> begin {}
##  
{ my $search = "accuminciari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accuminzari
##  	0  ==  accuminzari {} --> cominciare {v} --> begin {v}
##  
{ my $search = "accuminzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accuminzari
##  	1  ==  accuminzari {} --> <br> {} --> commence {}
##  
{ my $search = "accuminzari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accurdari
##  	3  ==  accurdari {} --> <br> {} --> pacify {}
##  
{ my $search = "accurdari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accurdari
##  	6  ==  accurdari {} --> accordare {} --> tune an instrument {}
##  
{ my $search = "accurdari" ; my $index = 6 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accurdunari
##  	0  ==  accurdunari {} --> cingere {} --> encircle {}
##  
{ my $search = "accurdunari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc accurdunari
##  	2  ==  accurdunari {} --> cingere {} --> surround {}
##  
{ my $search = "accurdunari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addicchiarari
##  	0  ==  addicchiarari {} --> richiedere {} --> appoint {}
##  
{ my $search = "addicchiarari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addicchiarari
##  	1  ==  addicchiarari {} --> dichiarare {} --> certify {}
##  
{ my $search = "addicchiarari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addicchiarari
##  	2  ==  addicchiarari {} --> dichiarare {} --> declare {}
##  
{ my $search = "addicchiarari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addicchiarari
##  	3  ==  addicchiarari {} --> dichiarare {} --> profess {}
##  
{ my $search = "addicchiarari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addifènniri
##  	0  ==  addifènniri {} --> difendere {} --> defend {}
##  
{ my $search = "addifènniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addifènniri
##  	1  ==  addifènniri {} --> difendere {} --> protect {}
##  
{ my $search = "addifènniri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addifènniri
##  	2  ==  addifènniri {} --> difendere {} --> stand up for {}
##  
{ my $search = "addifènniri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addimurari
##  	0  ==  addimurari {} --> ritardare {} --> be late {}
##  
{ my $search = "addimurari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addipìnciri
##  	0  ==  addipìnciri {n} --> dipingere {} --> depict {}
##  
{ my $search = "addipìnciri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addipìnciri
##  	1  ==  addipìnciri {} --> dipingere {} --> paint {}
##  
{ my $search = "addipìnciri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addiscìnniri
##  	0  ==  addiscìnniri {} --> discendere {} --> descend {}
##  
{ my $search = "addiscìnniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addisiari
##  	1  ==  addisiari {} --> <br> {} --> want {}
##  
{ my $search = "addisiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addisiari
##  	3  ==  addisiari {} --> <br> {} --> yearn {}
##  
{ my $search = "addisiari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addivirtirisi
##  	2  ==  addivirtirisi {} --> divertirsi {} --> have fun {}
##  
{ my $search = "addivirtirisi" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc addumari
##  	1  ==  addumari {} --> accendere {} --> light (turn on a) {}
##  
{ my $search = "addumari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc affrigiri
##  	0  ==  affrigiri <br> --> affliggersi {v} --> grieve {v}
##  
{ my $search = "affrigiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc aggarrari
##  	0  ==  aggarrari {} --> acciuffare {} --> catch {}
##  
{ my $search = "aggarrari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc aggarrari
##  	1  ==  aggarrari {} --> afferrare {} --> catch {}
##  
{ my $search = "aggarrari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc aggarrari
##  	2  ==  aggarrari {} --> acciuffare {} --> grasp {}
##  
{ my $search = "aggarrari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc aggarrari
##  	3  ==  aggarrari {} --> afferrare {} --> grasp {}
##  
{ my $search = "aggarrari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc aggarrari
##  	4  ==  aggarrari {} --> acciuffare {} --> seize {}
##  
{ my $search = "aggarrari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc aggarrari
##  	5  ==  aggarrari {} --> afferrare {} --> seize {}
##  
{ my $search = "aggarrari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc agghiuriscari
##  	0  ==  agghiuriscari {} --> domare {} --> subdue {}
##  
{ my $search = "agghiuriscari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc aggiri
##  	1  ==  aggiri {vi} --> agire {vi} --> behave {vi}
##  
{ my $search = "aggiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc agguantari
##  	2  ==  agguantari {} --> stringere con la mano {} --> squeeze with the hands {}
##  
{ my $search = "agguantari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu agghiuttiri
## 	0  ==  agghiuttiri {v} --> inghiottire {v} --> swallow {v}
## 
## $ ./query-dieli.pl sc strittu aghhiùttiri
## 	0  ==  aghhiùttiri {v} --> inghiottire {v} --> swallow {v}
delete( $dieli_sc{"aghhiùttiri"} );
{ my $search = "agghiùttiri"; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{v}";
  $th{"it_word"} = "inghiottire" ; $th{"it_part"} = "{v}";
  $th{"en_word"} = "swallow"     ; $th{"en_part"} = "{v}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  $ ./query-dieli.pl sc agnunari
##  	0  ==  agnunari {} --> accantonare {} --> corner {}
##  
{ my $search = "agnunari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc agnunari
##  	1  ==  agnunari {} --> mettere in un angolo {} --> corner {}
##  
{ my $search = "agnunari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc allavancari
##  	0  ==  allavancari {} --> crollare {} --> break down {}
##  
{ my $search = "allavancari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc allavancari
##  	1  ==  allavancari {} --> rovinare {} --> cave in {}
##  
{ my $search = "allavancari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc allazzari
##  	0  ==  allazzari {} --> allacciare {} --> fasten {}
##  
{ my $search = "allazzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc allazzari
##  	1  ==  allazzari {} --> allacciare {} --> tie {}
##  
{ my $search = "allazzari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc allisciari
##  	0  ==  allisciari {} --> accarezzare {} --> caress {}
##  
{ my $search = "allisciari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc allisciari
##  	1  ==  allisciari {} --> accarezzare {} --> pet {v}
##  
{ my $search = "allisciari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc alluntanari
##  	0  ==  alluntanari {} --> <br> {} --> move away from {}
##  
{ my $search = "alluntanari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc amari
##  	0  ==  amari {} --> amare {} --> love {v}
##  
{ my $search = "amari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc amari
##  	1  ==  amari {} --> <br> {} --> prefer {}
##  
{ my $search = "amari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ambintarisi
##  	0  ==  ambintarisi {} --> ambientarsi {} --> calm down {}
##  
{ my $search = "ambintarisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ambintarisi
##  	1  ==  ambintarisi {} --> calmarsi {} --> calm down {}
##  
{ my $search = "ambintarisi" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ambintarisi
##  	2  ==  ambintarisi {} --> riposare {} --> calm down {}
##  
{ my $search = "ambintarisi" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammaccari
##  	0  ==  ammaccari {} --> ammaccare {} --> bruise {}
##  
{ my $search = "ammaccari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammaccari
##  	1  ==  ammaccari {} --> premere {} --> bruise {}
##  
{ my $search = "ammaccari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammaistrari
##  	1  ==  ammaistrari {} --> istruire {} --> teach {}
##  
{ my $search = "ammaistrari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammaistrari
##  	2  ==  ammaistrari {} --> istruire {} --> train {}
##  
{ my $search = "ammaistrari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammarazzari
##  	4  ==  ammarazzari {} --> iingombrare {} --> obstruct {}
##  
{ my $search = "ammarazzari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammarazzari
##  	5  ==  ammarazzari {} --> imbarazzare {} --> obstruct {}
##  
{ my $search = "ammarazzari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammazzari
##  	1  ==  ammazzari {} --> uccidere {} --> murder {}
##  
{ my $search = "ammazzari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammisurari
##  	0  ==  ammisurari {} --> misurare {} --> measure {v}
##  
{ my $search = "ammisurari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammuccarisi
##  	0  ==  ammuccarisi {} --> mangiarsi {} --> eat one's words {}
##  
{ my $search = "ammuccarisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammuccarisi
##  	1  ==  ammuccarisi {} --> mangiarsi {} --> mumble {}
##  
{ my $search = "ammuccarisi" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammugghiari
##  	0  ==  ammugghiari {} --> avvolgere {} --> cover {}
##  
{ my $search = "ammugghiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammuntuari
##  	0  ==  ammuntuari {} --> citare {} --> cite {}
##  
{ my $search = "ammuntuari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammuntuari
##  	1  ==  ammuntuari {} --> nominare {} --> mention {}
##  
{ my $search = "ammuntuari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammurrari
##  	1  ==  ammurrari {} --> Imbronciarsi {} --> cloud over {}
##  
{ my $search = "ammurrari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammurrari
##  	2  ==  ammurrari {} --> esaurire {} --> exhaust (a mine) {}
##  
{ my $search = "ammurrari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammurrari
##  	3  ==  ammurrari {} --> ostruire {} --> obstruct {}
##  
{ my $search = "ammurrari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammurrari
##  	4  ==  ammurrari {} --> arenarsi {} --> run aground {}
##  
{ my $search = "ammurrari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammurrari
##  	5  ==  ammurrari {} --> Imbronciarsi {} --> sulk {}
##  
{ my $search = "ammurrari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
  ${$dieli_sc{$search}[$index]}{"it_word"} = "imbronciarsi";
}

##  $ ./query-dieli.pl sc ammustrari
##  	2  ==  ammustrari {} --> mostrare {} --> point out {}
##  
{ my $search = "ammustrari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammuttunari
##  	0  ==  ammuttunari {} --> imbottire {} --> pad {}
##  
{ my $search = "ammuttunari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ammuttunari
##  	1  ==  ammuttunari {} --> imbottire {} --> stuff {}
##  
{ my $search = "ammuttunari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc annagghiari
##  	0  ==  annagghiari {} --> afferrare {} --> catch {}
##  
{ my $search = "annagghiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc annagghiari
##  	2  ==  annagghiari {} --> afferrare {} --> seize {}
##  
{ my $search = "annagghiari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc annari
##  	0  ==  annari {} --> partire {} --> leave {}
##  
{ my $search = "annari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc annijari
##  	0  ==  annijari {} --> annegare {} --> be drowned {}
##  
{ my $search = "annijari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc anniminari
##  	1  ==  anniminari {} --> indovinare {} --> predict {}
##  
{ my $search = "anniminari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc anniscari
##  	0  ==  anniscari {} --> adescare {} --> catch {}
##  
{ my $search = "anniscari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc anniscari
##  	1  ==  anniscari {} --> adescare {} --> lure {}
##  
{ my $search = "anniscari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc annunziari
##  	0  ==  annunziari {} --> preannunciare {} --> foretell {}
##  
{ my $search = "annunziari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc appartèniri
##  	0  ==  appartèniri {} --> appartenere {} --> belong (to) {}
##  
{ my $search = "appartèniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc apprittari
##  	0  ==  apprittari {} --> insistere {} --> insist {}
##  
{ my $search = "apprittari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc apprittari
##  	1  ==  apprittari {} --> insistere {} --> persist {}
##  
{ my $search = "apprittari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc appuiari
##  	1  ==  appuiari {} --> appoggiare {} --> lay {}
##  
{ my $search = "appuiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc appuiari
##  	2  ==  appuiari {} --> appoggiare {} --> lean {}
##  
{ my $search = "appuiari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc appuiari
##  	3  ==  appuiari {} --> appoggiare {} --> lean on {}
##  
{ my $search = "appuiari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu arraggiàrisi
## 	0  ==  arraggiàrisi {} --> arrabbiarsi {} --> fly into a rage {}
## 	1  ==  arraggiàrisi {} --> arrabbiarsi {} --> get angry {}
for my $index (0,1) { my $search = "arraggiàrisi" ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}


##  $ ./query-dieli.pl sc arraggiunari
##  	1  ==  arraggiunari {} --> discutere con calma {} --> reason {v}
##  
{ my $search = "arraggiunari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arribbummari
##  	1  ==  arribbummari {} --> rimbombare {} --> rumble {}
##  
{ my $search = "arribbummari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arribbummari
##  	2  ==  arribbummari {} --> rimbombare {} --> thunder {}
##  
{ my $search = "arribbummari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arribbuttari
##  	0  ==  arribbuttari {} --> rigettare {} --> reject {}
##  
{ my $search = "arribbuttari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arribbuttari
##  	1  ==  arribbuttari {} --> rigettare {} --> turn down {}
##  
{ my $search = "arribbuttari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arribbuttari
##  	2  ==  arribbuttari {} --> rigettare {} --> turn down {}
##  
{ my $search = "arribbuttari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arricchiri
##  	2  ==  arricchiri {} --> arricchire {} --> make rich {}
##  
{ my $search = "arricchiri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arricintari
##  	1  ==  arricintari {} --> sciacquare {} --> wash {}
##  
{ my $search = "arricintari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arricriarisi
##  	1  ==  arricriarisi {} --> divertire {} --> have fun {}
##  
{ my $search = "arricriarisi" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arricriarisi
##  	2  ==  arricriarisi {} --> provare piacere {} --> have fun {}
##  
{ my $search = "arricriarisi" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arricriarisi
##  	3  ==  arricriarisi {} --> divertire {} --> have pleasure {}
##  
{ my $search = "arricriarisi" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arricriarisi
##  	4  ==  arricriarisi {} --> provare piacere {} --> have pleasure {}
##  
{ my $search = "arricriarisi" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arricògghiri
##  	0  ==  arricògghiri {} --> raccogliere {} --> assemble {}
##  
{ my $search = "arricògghiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu arricurdàrisi
## 	0  ==  arricurdàrisi {v} --> ricordare {v} --> remember {v}
${$dieli_sc{"arricurdàrisi"}[0]}{"it_word"} = 'ricordarsi';

##  $ ./query-dieli.pl sc arrifriddari
##  	0  ==  arrifriddari {} --> raffreddare {} --> cool {}
##  
{ my $search = "arrifriddari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrignari
##  	0  ==  arrignari {} --> regnare {} --> reign {}
##  
{ my $search = "arrignari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arripassari
##  	0  ==  arripassari {} --> ripassare {} --> check {}
##  
{ my $search = "arripassari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arripassari
##  	1  ==  arripassari {} --> ripassare {} --> go over again {}
##  
{ my $search = "arripassari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arripizzari
##  	1  ==  arripizzari {} --> rammendare {} --> mend {v}
##  
{ my $search = "arripizzari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arripizzari
##  	2  ==  arripizzari {} --> rappacificare {} --> mend {v}
##  
{ my $search = "arripizzari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arripizzari
##  	3  ==  arripizzari {} --> rattoppare {} --> mend {v}
##  
{ my $search = "arripizzari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arriscèdiri
##  	1  ==  arriscèdiri {} --> frugare {} --> rummage through {}
##  
{ my $search = "arriscèdiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arriscèdiri
##  	2  ==  arriscèdiri {} --> perquisire {} --> search {}
##  
{ my $search = "arriscèdiri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrisittari
##  	0  ==  arrisittari {} --> riordinare {} --> arrange {}
##  
{ my $search = "arrisittari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrisittari
##  	1  ==  arrisittari {} --> riordinare {} --> tidy up {}
##  
{ my $search = "arrisittari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrunchiari
##  	0  ==  arrunchiari {} --> radunare {} --> assemble {}
##  
{ my $search = "arrunchiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrunzari
##  	0  ==  arrunzari {} --> radunare {} --> assemble {}
##  
{ my $search = "arrunzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrunzari
##  	1  ==  arrunzari {} --> <br> {} --> heap {}
##  
{ my $search = "arrunzari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrunzari
##  	2  ==  arrunzari {} --> ammonticchiare {} --> heap up {}
##  
{ my $search = "arrunzari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrunzari
##  	3  ==  arrunzari {} --> lavorare male {} --> heap up {}
##  
{ my $search = "arrunzari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrunzari
##  	4  ==  arrunzari {} --> <br> {} --> pile {}
##  
{ my $search = "arrunzari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrunzari
##  	5  ==  arrunzari {} --> ammonticchiare {} --> pile {}
##  
{ my $search = "arrunzari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrunzari
##  	6  ==  arrunzari {} --> lavorare male {} --> pile {}
##  
{ my $search = "arrunzari" ; my $index = 6 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrunzari
##  	7  ==  arrunzari {} --> ammonticchiare {} --> push {}
##  
{ my $search = "arrunzari" ; my $index = 7 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrunzari
##  	8  ==  arrunzari {} --> lavorare male {} --> push {}
##  
{ my $search = "arrunzari" ; my $index = 8 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrunzari
##  	9  ==  arrunzari {} --> spingere {} --> push {}
##  
{ my $search = "arrunzari" ; my $index = 9 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrusicari
##  	2  ==  arrusicari {} --> rodere {} --> nibble {}
##  
{ my $search = "arrusicari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arruspigghiari
##  	0  ==  arruspigghiari {} --> svegliare {} --> awaken {}
##  
{ my $search = "arruspigghiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrùstiri
##  	0  ==  arrùstiri {} --> arrostire {} --> grill {}
##  
{ my $search = "arrùstiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc arrùstiri
##  	2  ==  arrùstiri {} --> arrostire {} --> toast {}
##  
{ my $search = "arrùstiri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ascutari
##  	0  ==  ascutari {} --> <br> {} --> listen {}
##  
{ my $search = "ascutari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ascutari
##  	1  ==  ascutari {} --> ascoltare {} --> listen to {}
##  
{ my $search = "ascutari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ascutari
##  	2  ==  ascutari {} --> seguire il consiglio {} --> listen to {}
##  
{ my $search = "ascutari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assaggiari
##  	1  ==  assaggiari {} --> assaggiare {} --> try (sample) {}
##  
{ my $search = "assaggiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assapurari
##  	1  ==  assapurari {} --> assaggiare {} --> test {}
##  
{ my $search = "assapurari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assapurari
##  	2  ==  assapurari {} --> gustare {} --> test {}
##  
{ my $search = "assapurari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assapurari
##  	3  ==  assapurari {} --> gustare {} --> try {}
##  
{ my $search = "assapurari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assapurari
##  	4  ==  assapurari {} --> assaggiare {} --> try (sample) {}
##  
{ my $search = "assapurari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assicunnari
##  	2  ==  assicunnari {} --> replicare {} --> repeat {}
##  
{ my $search = "assicunnari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assicunnari
##  	3  ==  assicunnari {} --> ripetere {} --> repeat {}
##  
{ my $search = "assicunnari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assicurari
##  	1  ==  assicurari {} --> assicurare {} --> ensure {}
##  
{ my $search = "assicurari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assicurari
##  	3  ==  assicurari {} --> assicurare {} --> make safe {}
##  
{ my $search = "assicurari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assicurari
##  	4  ==  assicurari {} --> rendere sicuro {} --> make safe {}
##  
{ my $search = "assicurari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assintari
##  	0  ==  assintari {} --> assestare {} --> balance (ledger) {}
##  
{ my $search = "assintari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assintumari
##  	1  ==  assintumari {} --> svenire {} --> pass out {}
##  
{ my $search = "assintumari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assuggittari
##  	0  ==  assuggittari {} --> assoggettare {} --> subject (submit to) {}
##  
{ my $search = "assuggittari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assumigghiari
##  	1  ==  assumigghiari {} --> assomigliare {} --> make similar (to) {}
##  
{ my $search = "assumigghiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assuttigghiari
##  	6  ==  assuttigghiari {} --> assottigliare {} --> summarize {}
##  
{ my $search = "assuttigghiari" ; my $index = 6 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assuttigghiari
##  	7  ==  assuttigghiari {} --> riassumere {} --> summarize {}
##  
{ my $search = "assuttigghiari" ; my $index = 7 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assuzzari
##  	0  ==  assuzzari {} --> pareggiare {} --> balance {}
##  
{ my $search = "assuzzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assuzzari
##  	2  ==  assuzzari {} --> pareggiare {} --> level {}
##  
{ my $search = "assuzzari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc assuzzari
##  	3  ==  assuzzari {} --> pareggiare {} --> make equal {}
##  
{ my $search = "assuzzari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc attigghiari
##  	0  ==  attigghiari {m} --> solleticare {m} --> tickle {n}
##  
{ my $search = "attigghiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc attigghiari
##  	1  ==  attigghiari {m} --> solleticare {m} --> whet {n}
##  
{ my $search = "attigghiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc attruvari
##  	0  ==  attruvari {} --> trovare {} --> find {}
##  
{ my $search = "attruvari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc attuari
##  	0  ==  attuari {} --> rializzari {} --> carry out {v}
##  
{ my $search = "attuari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc atturrari
##  	0  ==  atturrari {} --> tostare {} --> roast coffee {}
##  
{ my $search = "atturrari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc atturrari
##  	1  ==  atturrari {} --> tostare {} --> toast bread {v}
##  
{ my $search = "atturrari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc aumintari
##  	2  ==  aumintari {} --> aumentare {} --> raise {}
##  
{ my $search = "aumintari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc avantari
##  	0  ==  avantari {vr} --> vantarsi {vr} --> swagger {vr}
##  
{ my $search = "avantari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc avantari
##  	1  ==  avantari {vr} --> vantarsi {vr} --> vaunt {vr}
##  
{ my $search = "avantari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc avantari
##  	2  ==  avantari {vr} --> vantarsi {vr} --> brag {vr}
##  
{ my $search = "avantari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc aviri
##  	1  ==  aviri {} --> <br> {} --> own (property) {}
##  
{ my $search = "aviri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc avvicinarisi
##  	0  ==  avvicinarisi {m} --> avvicinarsi {m} --> approach {n}
##  
{ my $search = "avvicinarisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc azziccari
##  	0  ==  azziccari {} --> infilzari {} --> pierce {}
##  
{ my $search = "azziccari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc azziccari
##  	1  ==  azziccari {} --> infilzari {} --> spear {}
##  
{ my $search = "azziccari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc azziccari
##  	2  ==  azziccari {} --> infilzari {} --> stick {}
##  
{ my $search = "azziccari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc azziccari
##  	3  ==  azziccari {} --> infilzari {} --> string {}
##  
{ my $search = "azziccari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc babÏari
##  	0  ==  babÏari {} --> scherzare {} --> joke {}
##  
delete( $dieli_sc{"babÏari"} );
{ my $search = "babìari" ; my $index = 0 ; 
  ${$dieli_sc{$search}[$index]}{"sc_word"} = "babìari";
  ${$dieli_sc{$search}[$index]}{"it_word"} = "scherzare";
  ${$dieli_sc{$search}[$index]}{"en_word"} = "joke";
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}
## 
## $ ./query-dieli.pl sc strittu babIari
## 	0  ==  babIari {} --> scherzare {} --> joke {}
##
delete( $dieli_sc{"babIari"} );

##  $ ./query-dieli.pl sc bazzicari
##  	0  ==  bazzicari {} --> bazzicare {} --> attend {}
##  
{ my $search = "bazzicari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc bazzicari
##  	2  ==  bazzicari {} --> bazzicare {} --> hang about {}
##  
{ my $search = "bazzicari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc bazzicari
##  	3  ==  bazzicari {} --> bazzicare {} --> see (regularly) {}
##  
{ my $search = "bazzicari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc bazzicari
##  	4  ==  bazzicari {} --> frequentare {} --> see (regularly) {}
##  
{ my $search = "bazzicari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cafuddari
##  	0  ==  cafuddari {} --> picchiare {} --> beat {}
##  
{ my $search = "cafuddari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc calari
##  	0  ==  calari {} --> abbassare {} --> diminish {}
##  
{ my $search = "calari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc calari
##  	1  ==  calari {} --> calare {} --> diminish {}
##  
{ my $search = "calari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc calari
##  	2  ==  calari {} --> abbassare {} --> lower {}
##  
{ my $search = "calari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc calari
##  	3  ==  calari {} --> calare {} --> lower {}
##  
{ my $search = "calari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc campari
##  	0  ==  campari {} --> <br> {} --> be alive {}
##  
{ my $search = "campari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}
## 
##  $ ./query-dieli.pl sc campari
##  	1  ==  campari {} --> <br> {} --> live {}
##  
{ my $search = "campari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}
## 
## $ ./query-dieli.pl sc strittu campari
## 	0  ==  campari {v} --> <br> {} --> be alive {v}
## 	1  ==  campari {v} --> <br> {} --> live {v}
${$dieli_sc{"campari"}[0]}{"it_word"} = 'vivere';
${$dieli_sc{"campari"}[0]}{"it_part"} = '{v}';
${$dieli_sc{"campari"}[1]}{"it_word"} = 'vivere';
${$dieli_sc{"campari"}[1]}{"it_part"} = '{v}';

##  $ ./query-dieli.pl sc canciari
##  	4  ==  canciari {} --> cambiare {} --> modify {}
##  
{ my $search = "canciari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc capiri
##  	0  ==  capiri {} --> entrarci {} --> be relevant {}
##  
{ my $search = "capiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc capiri
##  	1  ==  capiri {} --> starci {} --> be relevant {}
##  
{ my $search = "capiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc capiri
##  	4  ==  capiri {} --> entrarci {} --> matter {}
##  
{ my $search = "capiri" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc capiri
##  	5  ==  capiri {} --> starci {} --> matter {}
##  
{ my $search = "capiri" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc carculari
##  	2  ==  carculari {} --> valutare {} --> evaluate {}
##  
{ my $search = "carculari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc carruzziari
##  	0  ==  carruzziari {} --> portare in giro in macchina {} --> tour {}
##  
{ my $search = "carruzziari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cascari
##  	1  ==  cascari {} --> <br> {} --> fall {}
##  
{ my $search = "cascari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cascari
##  	2  ==  cascari {} --> cadere {} --> fall (down) {}
##  
{ my $search = "cascari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cascari
##  	3  ==  cascari {} --> cadere {} --> flop {}
##  
{ my $search = "cascari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc chianciri
##  	0  ==  chianciri {} --> <br> {} --> cry {}
##  
{ my $search = "chianciri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc chianciri
##  	1  ==  chianciri {} --> <br> {} --> mourn for {}
##  
{ my $search = "chianciri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc chiànciri
##  	1  ==  chiànciri {} --> piangere {v} --> grieve {v}
##  
{ my $search = "chiànciri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ciaccari
##  	5  ==  ciaccari {} --> dissodare {} --> till {v}
##  
{ my $search = "ciaccari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc citari
##  	0  ==  citari {} --> citare {} --> cite {}
##  
{ my $search = "citari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cogghiri
##  	0  ==  cogghiri {} --> cogliere {} --> collect {}
##  
{ my $search = "cogghiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc confinari
##  	0  ==  confinari {} --> confinare {} --> bound {v}
##  
{ my $search = "confinari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc confinari
##  	1  ==  confinari {} --> confinare {} --> confine {}
##  
{ my $search = "confinari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc confinari
##  	2  ==  confinari {} --> confinare {} --> limit {}
##  
{ my $search = "confinari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cuariari
##  	0  ==  cuariari {} --> riscaldare {} --> heat {}
##  
{ my $search = "cuariari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cuariari
##  	1  ==  cuariari {} --> riscaldare {} --> warm {}
##  
{ my $search = "cuariari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cuincìdiri
##  	1  ==  cuincìdiri {} --> coincidere {} --> fall on (a date) {}
##  
{ my $search = "cuincìdiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cullabburari
##  	0  ==  cullabburari {} --> collaborare {} --> collaborate {}
##  
{ my $search = "cullabburari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cullabburari
##  	1  ==  cullabburari {} --> collaborare {} --> contribute {}
##  
{ my $search = "cullabburari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cullabburari
##  	2  ==  cullabburari {} --> collaborare {} --> cooperate {}
##  
{ my $search = "cullabburari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cummattiri
##  	0  ==  cummattiri {} --> combattere {} --> annoy {}
##  
{ my $search = "cummattiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cummattiri
##  	1  ==  cummattiri {} --> <br> {} --> assault {}
##  
{ my $search = "cummattiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cummattiri
##  	3  ==  cummattiri {} --> avere a che fare {} --> be busy {}
##  
{ my $search = "cummattiri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cummattiri
##  	6  ==  cummattiri {} --> <br> {} --> deal {}
##  
{ my $search = "cummattiri" ; my $index = 6 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cummèttiri
##  	0  ==  cummèttiri {} --> commettere {} --> assemble {}
##  
{ my $search = "cummèttiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cumprumìntiri
##  	0  ==  cumprumìntiri {} --> rischiare {} --> compromise {v}
##  
{ my $search = "cumprumìntiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cumprumìntiri
##  	1  ==  cumprumìntiri {} --> compromettere {} --> make a compromise {}
##  
{ my $search = "cumprumìntiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cumprumìntiri
##  	2  ==  cumprumìntiri {} --> rischiare {} --> make a compromise {}
##  
{ my $search = "cumprumìntiri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cumpurtarisi
##  	0  ==  cumpurtarisi {vi} --> comportarsi {vi} --> behave {vi}
##  
{ my $search = "cumpurtarisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cumpòniri
##  	0  ==  cumpòniri {} --> comporre {} --> arrange {}
##  
{ my $search = "cumpòniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cumpòniri
##  	2  ==  cumpòniri {} --> comporre {} --> put together {}
##  
{ my $search = "cumpòniri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cumunicari
##  	2  ==  cumunicari {} --> comunicare {} --> participate {}
##  
{ my $search = "cumunicari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cunchiùdiri
##  	0  ==  cunchiùdiri {} --> concludere {} --> conclude {}
##  
{ my $search = "cunchiùdiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cuncèdiri
##  	1  ==  cuncèdiri {} --> concedere {} --> concede {}
##  
{ my $search = "cuncèdiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cundùciri
##  	0  ==  cundùciri {} --> condurre  {} --> drive  {v}
##  
{ my $search = "cundùciri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cunfunniri
##  	4  ==  cunfunniri {} --> confondere {} --> mix up {}
##  
{ my $search = "cunfunniri" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cunnannari
##  	0  ==  cunnannari {} --> condannare {} --> condemn {}
##  
{ my $search = "cunnannari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cunnannari
##  	2  ==  cunnannari {} --> condannare {} --> sentence {}
##  
{ my $search = "cunnannari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cunnùciri
##  	1  ==  cunnùciri {} --> condurre {} --> conduct {}
##  
{ my $search = "cunnùciri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cunnùciri
##  	2  ==  cunnùciri {} --> condurre  {} --> drive  {v}
##  
{ my $search = "cunnùciri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cunnùciri
##  	3  ==  cunnùciri {} --> condurre {} --> lead {}
##  
{ my $search = "cunnùciri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cunsumari
##  	0  ==  cunsumari {} --> consumare {} --> consume {}
##  
{ my $search = "cunsumari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cuntari
##  	0  ==  cuntari v{} --> contare {v} --> count {v}
##  
{ my $search = "cuntari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cuntrastari
##  	2  ==  cuntrastari {} --> <br> {} --> contest {}
##  
{ my $search = "cuntrastari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cuntèniri
##  	1  ==  cuntèniri {} --> contenere {} --> curb {}
##  
{ my $search = "cuntèniri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cuntèniri
##  	2  ==  cuntèniri {} --> contenere {} --> curb {}
##  
{ my $search = "cuntèniri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cuntèniri
##  	3  ==  cuntèniri {} --> contenere {} --> hold back {}
##  
{ my $search = "cuntèniri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cunzigghiari
##  	1  ==  cunzigghiari {} --> consigliare {} --> cousel {}
##  
{ my $search = "cunzigghiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
  ${$dieli_sc{$search}[$index]}{"en_word"} = "counsel";
}

##  $ ./query-dieli.pl sc cupunari
##  	1  ==  cupunari {} --> coperchiare {} --> put a lid on {}
##  
{ my $search = "cupunari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc curari
##  	2  ==  curari {} --> <br> {} --> mind {v}
##  
{ my $search = "curari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc curarisi
##  	0  ==  curarisi {} --> preoccuparti {} --> worry oneself {}
##  
{ my $search = "curarisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc curcarisi
##  	0  ==  curcarisi {} --> addormentarsi {} --> go to sleep {}
##  
{ my $search = "curcarisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc curreggiri
##  	0  ==  curreggiri {} --> correggere {} --> grade (an exam) {}
##  
{ my $search = "curreggiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc curreggiri
##  	2  ==  curreggiri {} --> correggere {} --> rectify {}
##  
{ my $search = "curreggiri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc currispùnniri
##  	0  ==  currispùnniri {} --> correspondere {} --> coincide {}
##  
{ my $search = "currispùnniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc currispùnniri
##  	1  ==  currispùnniri {} --> correspondere {} --> correspond {}
##  
{ my $search = "currispùnniri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cutturiari
##  	0  ==  cutturiari {} --> assillare {} --> harass {}
##  
{ my $search = "cutturiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cutturiari
##  	1  ==  cutturiari {} --> tampinare {} --> harass {}
##  
{ my $search = "cutturiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cutturiari
##  	2  ==  cutturiari {} --> assillare {} --> pester {}
##  
{ my $search = "cutturiari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cutturiari
##  	3  ==  cutturiari {} --> tampinare {} --> pester {}
##  
{ my $search = "cutturiari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu cuvirnari
## 	0  ==  cuvirnari {v} --> governare {} --> govern {v}
## 	1  ==  cuvirnari {v} --> governare {v} --> rule {v}
## 	2  ==  cuvirnari {v} --> di animali averne cura {v} --> of animals being treated {v}
${$dieli_sc{"cuvirnari"}[0]}{"it_part"} = "{v}" ;

##  $ ./query-dieli.pl sc càriri
##  	0  ==  càriri {} --> cadere {} --> fall {}
##  
{ my $search = "càriri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cèdiri
##  	0  ==  cèdiri {} --> cedere {} --> concede {}
##  
{ my $search = "cèdiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc cèdiri
##  	1  ==  cèdiri {} --> cedere {} --> transfer an entitlement {}
##  
{ my $search = "cèdiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc dicìdiri
##  	0  ==  dicìdiri {} --> decidere {} --> choose {}
##  
{ my $search = "dicìdiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc dicìdiri
##  	1  ==  dicìdiri {} --> decidere {} --> decide {}
##  
{ my $search = "dicìdiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc difùnniri
##  	0  ==  difùnniri {} --> disseminare {} --> circulate {}
##  
{ my $search = "difùnniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc difùnniri
##  	1  ==  difùnniri {} --> diffondere {} --> diffuse {}
##  
{ my $search = "difùnniri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc difùnniri
##  	2  ==  difùnniri {} --> disseminare {} --> disseminate {}
##  
{ my $search = "difùnniri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc diminuiri
##  	0  ==  diminuiri {} --> abbassare {} --> diminish {}
##  
{ my $search = "diminuiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc diminuiri
##  	1  ==  diminuiri {} --> calare {} --> diminish {}
##  
{ my $search = "diminuiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc dipusitari
##  	2  ==  dipusitari {} --> deporre {} --> store {}
##  
{ my $search = "dipusitari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc dipusitari
##  	3  ==  dipusitari {} --> depositare {} --> store {}
##  
{ my $search = "dipusitari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc diriggiri
##  	0  ==  diriggiri {} --> dirigere {} --> direct {}
##  
{ my $search = "diriggiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc diriggiri
##  	3  ==  diriggiri {} --> menare {} --> lead {v}
##  
{ my $search = "diriggiri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc discrìviri
##  	2  ==  discrìviri {} --> descrivere {} --> trace {}
##  
{ my $search = "discrìviri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc discùrriri
##  	0  ==  discùrriri {} --> discutere {} --> argue {}
##  
{ my $search = "discùrriri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu distrudiri
## 	0  ==  distrudiri {v} --> distruggere {v} --> wreck {v}
## 
## $ ./query-dieli.pl sc strittu distrùdiri
## 	0  ==  distrùdiri {v} --> distruggere {v} --> destroy {v}
## 	1  ==  distrùdiri {v} --> distruggire {} --> ruin {}
${$dieli_sc{"distrùdiri"}[1]}{"it_word"} = 'distruggere';
${$dieli_sc{"distrùdiri"}[1]}{"it_part"} = '{v}';
${$dieli_sc{"distrùdiri"}[1]}{"en_part"} = '{v}';

##  $ ./query-dieli.pl sc divirtirisi
##  	0  ==  divirtirisi {} --> divertirsi {} --> enjoy {}
##  
{ my $search = "divirtirisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc divirtirisi
##  	3  ==  divirtirisi {} --> divertirsi {} --> have fun {}
##  
{ my $search = "divirtirisi" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc duviri
##  	4  ==  duviri {} --> dovere qc {} --> owe {}
##  
{ my $search = "duviri" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu finciri
## 	0  ==  finciri {v} --> <br> {v} --> simulate {v}
${$dieli_sc{"finciri"}[0]}{"it_word"} = 'fingere';
## 
##  $ ./query-dieli.pl sc fìnciri
##  	0  ==  fìnciri {} --> fingere {} --> feign {}
##  
{ my $search = "fìnciri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc firari
##  	0  ==  firari {} --> fidare {} --> trust {}
##  
{ my $search = "firari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc firriari
##  	1  ==  firriari {} --> circondare {} --> encircle {}
##  
{ my $search = "firriari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc firriari
##  	2  ==  firriari {} --> girare {} --> encircle {}
##  
{ my $search = "firriari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc firriari
##  	3  ==  firriari {} --> circondare {} --> revolve {}
##  
{ my $search = "firriari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc firriari
##  	4  ==  firriari {} --> girare {} --> revolve {}
##  
{ my $search = "firriari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc firriari
##  	5  ==  firriari {} --> circondare {} --> turn {}
##  
{ my $search = "firriari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc firriari
##  	6  ==  firriari {} --> girare {} --> turn {}
##  
{ my $search = "firriari" ; my $index = 6 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc frequentari
##  	1  ==  frequentari {} --> frequentare {} --> hang about {}
##  
{ my $search = "frequentari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc fequentari
##  	0  ==  fequentari {} --> frequentare {} --> attend {}
##  
{ delete( $dieli_sc{"fequentari"} ) ;
  my $search = "frequentari" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "frequentare" ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "attend"      ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  $ ./query-dieli.pl sc fruttari
##  	0  ==  fruttari {} --> generare {} --> be fruitful {}
##  
{ my $search = "fruttari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc fruttari
##  	1  ==  fruttari {} --> produrre frutta {} --> be fruitful {}
##  
{ my $search = "fruttari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc fruttari
##  	4  ==  fruttari {} --> generare {} --> generate {}
##  
{ my $search = "fruttari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc fruttari
##  	5  ==  fruttari {} --> produrre frutta {} --> generate {}
##  
{ my $search = "fruttari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc funiculari
##  	0  ==  funiculari {f} --> <br> {f} --> cable car {n}
##  
{ my $search = "funiculari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu ghisari 
## 	0  ==  ghisari {v} --> alzare {} --> get up {v}
{ delete( $dieli_sc{"ghisari"} ) ;
  my $search = "ghisarisi" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "alzarsi" ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "get up"  ; $th{"en_part"} = "{v}" ; 
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  $ ./query-dieli.pl sc gianniari
##  	0  ==  gianniari {vi} --> ingiallire {vi} --> yellow (to) {vi}
##  
{ my $search = "gianniari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu girari ggirari
## 	0  ==  girari {v} --> <br> {v} --> gyrate {v}
## 	1  ==  girari {v} --> <br> {v} --> hinge {v}
## 	2  ==  girari {v} --> <br> {v} --> tour {v}
## 	0  ==  ggirari {v} --> girare {v} --> endorse {v}
for my $index (0..2) {
    ${$dieli_sc{"girari"}[$index]}{"it_word"} = 'girare';
}
{ delete( $dieli_sc{"ggirari"} ) ;
  my $search = "girari" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "girare"  ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "endorse" ; $th{"en_part"} = "{v}" ; 
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  $ ./query-dieli.pl sc giudicari
##  	0  ==  giudicari {} --> <br> {} --> judge {v}
##  
{ my $search = "giudicari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc guadagnari
##  	3  ==  guadagnari {} --> guadagnare {} --> obtain {}
##  
{ my $search = "guadagnari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc guardari
##  	3  ==  guardari {} --> <br> {} --> regard {}
##  
{ my $search = "guardari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc guardari
##  	5  ==  guardari {} --> <br> {} --> watch {}
##  
{ my $search = "guardari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu guarda
## 	0  ==  guarda {v} --> guarda {v} --> protect {v}
## 	1  ==  guarda {} --> <br> {} --> regard {}
## 	2  ==  guarda {} --> <br> {} --> save {}
{ my $search = "guarda" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}
{ my $search = "guarda" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc guidari
##  	0  ==  guidari {} --> guidare {} --> conduct {}
##  
{ my $search = "guidari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc guidari
##  	5  ==  guidari {} --> guidare {} --> lead {}
##  
{ my $search = "guidari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc guidari
##  	7  ==  guidari {} --> guidare {} --> steer {v}
##  
{ my $search = "guidari" ; my $index = 7 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc guirari
##  	0  ==  guirari {} --> guidare {} --> drive {v}
##  
{ my $search = "guirari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc gurgari
##  	0  ==  gurgari {} --> sgorgare {} --> gush {}
##  
{ my $search = "gurgari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc gurgari
##  	1  ==  gurgari {} --> sgorgare {} --> spurt out {}
##  
{ my $search = "gurgari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc imbriacari
##  	0  ==  imbriacari {} --> <br> {} --> be drunk {}
##  
{ my $search = "imbriacari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}
## $ ./query-dieli.pl sc strittu  imbriacari
## 	0  ==  imbriacari {v} --> <br> {} --> be drunk {v}
${$dieli_sc{"imbriacari"}[0]}{"it_word"} = 'ubriacare';
${$dieli_sc{"imbriacari"}[0]}{"it_part"} = '{v}';

##  $ ./query-dieli.pl sc impijurari
##  	0  ==  impijurari {} --> <br> {} --> worsen {}
##  
{ my $search = "impijurari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc impijurari
##  	1  ==  impijurari {vi} --> peggiorare {vi} --> worsen {vi}
##  
{ my $search = "impijurari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc insirtari
##  	0  ==  insirtari {} --> indovinare {} --> guess {}
##  
{ my $search = "insirtari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc inturciuniari
##  	0  ==  inturciuniari {} --> intrecciare {} --> interweave {}
##  
{ my $search = "inturciuniari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc inviari
##  	1  ==  inviari {} --> <br> {} --> ship {}
##  
{ my $search = "inviari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc iunciri
##  	1  ==  iunciri {} --> aggiungere {} --> join {}
##  
{ my $search = "iunciri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu gastimari
## 	0  ==  gastimari {v} --> imprecare {v} --> curse {v}
## 	1  ==  gastimari {v} --> maledire {v} --> curse {v}
##
## $ qdieli sc strittu jastimari
## 	jastimari  not found
## 
{ my $search = "jastimari" ; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "maledire"  ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "curse"     ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "jastimari" ; 
  my %th ;  
  $th{"sc_word"} = $search      ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "imprecare"  ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "curse"      ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu "jiri (jirisìnni)"
## 	0  ==  jiri (jirisìnni) {v} --> andare (andarsene) {} --> go {}
## 	1  ==  jiri (jirisìnni) {} --> andare (andarsene) {} --> travel {}
## 
for my $index (0,1) {
    my $search = 'jiri (jirisìnni)' ; 
    $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}
## 
## $ ./query-dieli.pl sc strittu vacci
## 	0  ==  vacci {v} --> <br> {} --> go {}
##
{ my $search = "vacci" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}
## 
## $ ./query-dieli.pl sc strittu vai
## 	0  ==  vai {v} --> <br> {} --> go {}
##
{ my $search = "vai" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}
## 
## $ ./query-dieli.pl sc strittu jiri
## 	0  ==  jiri {v} --> <br> {} --> go {}
## 
${$dieli_sc{"jiri"}[0]}{"it_word"} = 'andare';
${$dieli_sc{"jiri"}[0]}{"it_part"} = '{v}';
${$dieli_sc{"jiri"}[0]}{"en_part"} = '{v}';

##  $ ./query-dieli.pl sc jisari
##  	0  ==  jisari {} --> alzare {} --> hoist {}
##  
{ my $search = "jisari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc jisari
##  	1  ==  jisari {} --> alzare {} --> lift {}
##  
{ my $search = "jisari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc jissijari
##  	0  ==  jissijari {} --> gessare {} --> plaster {v}
##  
{ my $search = "jissijari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc jittari
##  	1  ==  jittari {} --> gettare {} --> fling {}
##  
{ my $search = "jittari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc jittari
##  	2  ==  jittari {} --> gettare {} --> gush {}
##  
{ my $search = "jittari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc jittari
##  	3  ==  jittari {} --> gettare {} --> sprout {}
##  
{ my $search = "jittari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc lacerari
##  	0  ==  lacerari {} --> lacerare {} --> lacerate {}
##  
{ my $search = "lacerari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc lamintarisi
##  	0  ==  lamintarisi {} --> <br> {} --> lament {}
##  
{ my $search = "lamintarisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}
## $ ./query-dieli.pl sc strittu lamintàrisi 
## 	0  ==  lamintàrisi {v} --> lagnarsi {v} --> moan {v}
## 	1  ==  lamintàrisi {} --> lagnarsi {} --> whine {}
{ my $search = "lamintàrisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc lampiari
##  	0  ==  lampiari {} --> lampeggiare {} --> flash {}
##  
{ my $search = "lampiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc lampiari
##  	1  ==  lampiari {} --> lampeggiare {} --> flash {}
##  
{ my $search = "lampiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu lampiari lampari
## 	0  ==  lampiari {v} --> lampeggiare {v} --> flash {v}
## 	1  ==  lampiari {v} --> lampeggiare {v} --> flash {v}
## 	2  ==  lampiari {v} --> lampeggiare {v} --> flash {v}
## 	3  ==  lampiari {v} --> <br> {v} --> lighten {v}
## 	0  ==  lampari {v} --> lampeggiare {v} --> sparkle {v}
{ delete( $dieli_sc{"lampari"} ) ;
  my $search = "lampiari" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "lampeggiare" ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "sparkle"     ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  $ ./query-dieli.pl sc lassari
##  	2  ==  lassari {} --> <br> {} --> leave {}
##  
{ my $search = "lassari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc lassari
##  	3  ==  lassari {} --> lasciare {} --> leave {}
##  
{ my $search = "lassari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc lauriari
##  	0  ==  lauriari {} --> laureare {} --> confer a degree {}
##  
{ my $search = "lauriari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc lazzariari
##  	1  ==  lazzariari {} --> ferire {} --> injure {}
##  
{ my $search = "lazzariari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc lazzariari
##  	2  ==  lazzariari {} --> ferire {} --> wound {}
##  
{ my $search = "lazzariari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc limitari
##  	0  ==  limitari {} --> circoscrivere {} --> bound {v}
##  
{ my $search = "limitari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc limitari
##  	1  ==  limitari {} --> limitare {} --> bound {v}
##  
{ my $search = "limitari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc limitari
##  	2  ==  limitari {} --> circoscrivere {} --> limit {}
##  
{ my $search = "limitari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc limitari
##  	3  ==  limitari {} --> limitare {} --> limit {v}
##  
{ my $search = "limitari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc limitari
##  	4  ==  limitari {} --> circoscrivere {} --> mark the bounds of {}
##  
{ my $search = "limitari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc lippiari
##  	0  ==  lippiari {} --> mangiucchiare {} --> nibble {}
##  
{ my $search = "lippiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu livari livarisi
## 	0  ==  livari {v} --> estrarre {v} --> extract {v}
## 	1  ==  livari {v} --> levare {v} --> remove {v}
## 	2  ==  livari {v} --> togliere {v} --> subtract {v}
## 	3  ==  livari {v} --> <br> {v} --> take {v}
## 	4  ==  livari {v} --> <br> {v} --> take away {v}
## 	0  ==  livarisi {v} --> <br> {v} --> rise {v}
## 	1  ==  livarisi {v} --> <br> {v} --> shed {v}
## 	2  ==  livarisi {v} --> <br> {v} --> take off (clothing) {v}
${$dieli_sc{"livarisi"}[0]}{"it_word"} = 'alzarsi';
${$dieli_sc{"livarisi"}[2]}{"it_word"} = 'levarsi';

##  $ ./query-dieli.pl sc mancari
##  	2  ==  mancari {} --> mancare {} --> lack {v}
##  
{ my $search = "mancari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc mannari
##  	1  ==  mannari {} --> mandare {} --> send {}
##  
{ my $search = "mannari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc mannari
##  	2  ==  mannari {} --> spedire {} --> send {}
##  
{ my $search = "mannari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc mantèniri
##  	0  ==  mantèniri {} --> mantenere {} --> keep {}
##  
{ my $search = "mantèniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc mantèniri
##  	1  ==  mantèniri {} --> mantenere {} --> maintain {}
##  
{ my $search = "mantèniri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu marita
## 	0  ==  marita {} --> <br> {} --> marries {}
## 
{ my $i = 0;
  my $search = "marita";
  ${$dieli_sc{$search}[$i]}{"sc_part"} = '{v}';
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'marita';
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{v}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{v}';
}
## $ ./query-dieli.pl sc strittu maritàrisi
## 	0  ==  maritàrisi {v} --> sposarsi {} --> get married {v}
{ my $i = 0;
  my $search = "maritàrisi";
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{v}';
}

##  $ ./query-dieli.pl sc massacrari
##  	0  ==  massacrari {} --> <br> {} --> massacre {}
##  
{ my $search = "massacrari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc massacrari
##  	1  ==  massacrari {} --> <br> {} --> slaughter {v}
##  
{ my $search = "massacrari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc matuciari
##  	0  ==  matuciari {} --> avere rapporti omosessuali {} --> have homosexual relations {}
##  
{ my $search = "matuciari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc migghiurari
##  	1  ==  migghiurari {} --> migliorare {} --> get better {}
##  
{ my $search = "migghiurari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc migghiurari
##  	3  ==  migghiurari {} --> migliorare {} --> make progress {}
##  
{ my $search = "migghiurari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc minuzzari
##  	0  ==  minuzzari {} --> tagliuzzare {} --> mince {}
##  
{ my $search = "minuzzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc misurari
##  	2  ==  misurari {} --> misurare {} --> measure {v}
##  
{ my $search = "misurari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc mmarcari
##  	2  ==  mmarcari {} --> imbarcare {} --> embark {}
##  
{ my $search = "mmarcari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc mmarcari
##  	3  ==  mmarcari {} --> imbarcare {} --> load {}
##  
{ my $search = "mmarcari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc mmintari
##  	0  ==  mmintari {} --> inventare {} --> invent {}
##  
{ my $search = "mmintari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc mmintari
##  	1  ==  mmintari {} --> mentire {} --> invent {}
##  
{ my $search = "mmintari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc mmintari
##  	2  ==  mmintari {} --> inventare {} --> lie (fabricate) {}
##  
{ my $search = "mmintari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc mmintari
##  	3  ==  mmintari {} --> mentire {} --> lie (fabricate) {}
##  
{ my $search = "mmintari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc mmriacari
##  	0  ==  mmriacari {} --> <br> {} --> get drunk {}
##  
{ my $search = "mmriacari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}
## $ ./query-dieli.pl sc strittu  mmriacari 
## 	0  ==  mmriacari {v} --> <br> {} --> get drunk {v}
${$dieli_sc{"mmriacari"}[0]}{"it_word"} = 'ubriacare';
${$dieli_sc{"mmriacari"}[0]}{"it_part"} = '{v}';

##  $ ./query-dieli.pl sc mpidiri
##  	1  ==  mpidiri {} --> impedire {} --> obstruct {}
##  
{ my $search = "mpidiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc mpidiri
##  	2  ==  mpidiri {} --> impedire {} --> prevent (from) {}
##  
{ my $search = "mpidiri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc strittu mpòniri
##  	0  ==  mpòniri {v} --> imporre  {v} --> impose  {v}
##  
{ my $search = "mpòniri" ; my $index = 0 ; 
  ##  need to remove trailing space
  ${$dieli_sc{$search}[$index]}{"it_word"} = "imporre" ;
  ${$dieli_sc{$search}[$index]}{"en_word"} = "impose" ;
}

##  $ ./query-dieli.pl sc munnari
##  	0  ==  munnari {} --> sbucciare {} --> peel {}
##  
{ my $search = "munnari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu mutari
## 	0  ==  mutari {v} --> <br> {} --> change {}
## 	1  ==  mutari {v} --> <br> {v} --> change {v}
${$dieli_sc{"mutari"}[0]}{"it_word"} = "mutare" ;
${$dieli_sc{"mutari"}[0]}{"it_part"} = "{v}" ;
${$dieli_sc{"mutari"}[0]}{"en_word"} = "transform" ;
${$dieli_sc{"mutari"}[0]}{"en_part"} = "{v}" ;
${$dieli_sc{"mutari"}[1]}{"it_word"} = "mutare" ;

##  $ ./query-dieli.pl sc muriri
##  	0  ==  muriri {} --> morire {} --> come an end {}
##  
{ my $search = "muriri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
  ##  ##  "come to an end" ... but let's conserve Dr. Dieli's work
}

##  $ ./query-dieli.pl sc nasciri
##  	0  ==  nasciri {} --> <br> {} --> be born {}
##  
{ my $search = "nasciri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc navicari
##  	0  ==  navicari {} --> navigare {} --> navigate {}
##  
{ my $search = "navicari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc navicari
##  	1  ==  navicari {} --> navigare {} --> sail {}
##  
{ my $search = "navicari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu incasciari
## 	0  ==  incasciari {v} --> incassare {v} --> cash {v}
## 
##   ADD:  "ncasciari" and "ncasciatu"
{ my $search = "ncasciari" ; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "incassare" ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "cash"      ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "incasciatu" ; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{adj}" ;
  $th{"it_word"} = "incassato" ; $th{"it_part"} = "{adj}" ;
  $th{"en_word"} = "cashed"    ; $th{"en_part"} = "{adj}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "ncasciatu" ; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{adj}" ;
  $th{"it_word"} = "incassato" ; $th{"it_part"} = "{adj}" ;
  $th{"en_word"} = "cashed"    ; $th{"en_part"} = "{adj}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "stari cu lu setti mazzi ncasciatu"; 
  my %th ;  
  $th{"sc_word"} = $search               ; $th{"sc_part"} = "{v}";
  $th{"it_word"} = "star sul sicuro"     ; $th{"it_part"} = "{v}";
  $th{"en_word"} = "be on the safe side" ; $th{"en_part"} = "{v}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  $ ./query-dieli.pl sc ncassari
##  	1  ==  ncassari {} --> esigere {} --> collect (taxes) {}
##  
{ my $search = "ncassari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ncassari
##  	2  ==  ncassari {} --> riscuotere {} --> drawdown {}
##  
{ my $search = "ncassari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu nchianari 
## 	0  ==  nchianari {v} --> <br> {v} --> climb {v}
${$dieli_sc{"nchianari"}[0]}{"it_word"} = 'appianare';

##  $ ./query-dieli.pl sc ncucchiari
##  	0  ==  ncucchiari {} --> mettere insieme {} --> bring together {}
##  
{ my $search = "ncucchiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ncucchiari
##  	1  ==  ncucchiari {} --> mettere insieme {} --> match {}
##  
{ my $search = "ncucchiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ncuminzari
##  	0  ==  ncuminzari {} --> cominciare {v} --> begin {v}
##  
{ my $search = "ncuminzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ngianniari
##  	0  ==  ngianniari {vi} --> ingiallire {vi} --> yellow (to) {vi}
##  
{ my $search = "ngianniari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ngranciari
##  	0  ==  ngranciari {} --> soffriggere {} --> fry lightly {}
##  
{ my $search = "ngranciari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ngrifarisi
##  	0  ==  ngrifarisi {r} --> arricciarsi {r} --> wrinkle {r}
##  
{ my $search = "ngrifarisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu nguaggiari
## 	0  ==  nguaggiari {v} --> sposare {v} --> marry {}
## 
{ my $search = "nguaggiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu nguaggiarisi
## 	0  ==  nguaggiarisi {v} --> sposarsi {v} --> marry {}
## 
{ my $search = "nguaggiarisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc niguzziari
##  	0  ==  niguzziari {} --> commerciare {} --> deal {}
##  
{ my $search = "niguzziari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc niguzziari
##  	1  ==  niguzziari {} --> negoziare {} --> deal {}
##  
{ my $search = "niguzziari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc niguzziari
##  	2  ==  niguzziari {} --> negoziare {} --> negotiate {}
##  
{ my $search = "niguzziari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc niguzziari
##  	4  ==  niguzziari {} --> commerciare {} --> trade {}
##  
{ my $search = "niguzziari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc niguzziari
##  	5  ==  niguzziari {} --> negoziare {} --> trade {}
##  
{ my $search = "niguzziari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ntagghiari
##  	0  ==  ntagghiari {} --> incidere {} --> carve {}
##  
{ my $search = "ntagghiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ntagghiari
##  	1  ==  ntagghiari {} --> incidere {} --> cut into {}
##  
{ my $search = "ntagghiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ntraminzari
##  	0  ==  ntraminzari {} --> includere {} --> include {}
##  
{ my $search = "ntraminzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ntraminzari
##  	1  ==  ntraminzari {} --> intramezzare {} --> include {}
##  
{ my $search = "ntraminzari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ntrubbulari
##  	0  ==  ntrubbulari {} --> intorbidire {} --> cloud {}
##  
{ my $search = "ntrubbulari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ntrubbulari
##  	1  ==  ntrubbulari {} --> intorbidire {} --> make turbid {}
##  
{ my $search = "ntrubbulari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc nutari
##  	0  ==  nutari {} --> annotare {} --> annotate {}
##  
{ my $search = "nutari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc nutari
##  	1  ==  nutari {} --> contrassegnare {} --> mark {}
##  
{ my $search = "nutari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc nutari
##  	4  ==  nutari {} --> notare {} --> notice {}
##  
{ my $search = "nutari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu invidiari
## 	0  ==  invidiari {v} --> invidiare {v} --> envy {v}
## 	1  ==  invidiari {v} --> invidiare {v} --> grudge {v}
##
##  ADD:  "nvidiari"
{ my $search = "nvidiari"; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{v}";
  $th{"it_word"} = "invidiare" ; $th{"it_part"} = "{v}";
  $th{"en_word"} = "envy"      ; $th{"en_part"} = "{v}";
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "nvidiari"; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{v}";
  $th{"it_word"} = "invidiare" ; $th{"it_part"} = "{v}";
  $th{"en_word"} = "grudge"    ; $th{"en_part"} = "{v}";
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  $ ./query-dieli.pl sc nzajari
##  	1  ==  nzajari {} --> indossare {} --> try on {}
##  
{ my $search = "nzajari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc nzitari
##  	0  ==  nzitari {} --> innestare {} --> graft {}
##  
{ my $search = "nzitari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc nzitari
##  	1  ==  nzitari {} --> innestare {} --> prune {}
##  
{ my $search = "nzitari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc nzullintari
##  	0  ==  nzullintari {} --> istigare {} --> incite {}
##  
{ my $search = "nzullintari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc nzullintari
##  	1  ==  nzullintari {} --> provocare {} --> provoke {}
##  
{ my $search = "nzullintari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc nzullintari
##  	2  ==  nzullintari {} --> provocare {} --> provoke {}
##  
{ my $search = "nzullintari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ottèniri
##  	1  ==  ottèniri {} --> ottenere {} --> get {}
##  
{ my $search = "ottèniri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu pasciri
## 	0  ==  pasciri {v} --> nutrire {v} --> feed {v}
## 	1  ==  pasciri {v} --> nutrire {} --> graze {v}
## 	2  ==  pasciri {v} --> pascolare {} --> graze {v}
## 	3  ==  pasciri {v} --> nutrire {v} --> nourish {v}
${$dieli_sc{"pasciri"}[1]}{"it_part"} = '{v}';
${$dieli_sc{"pasciri"}[2]}{"it_part"} = '{v}';

##  $ ./query-dieli.pl sc passari
##  	0  ==  passari {n} --> <br> {} --> be worth {}
##  	1  ==  passari {} --> menare {} --> lead {v}
##  	2  ==  passari {v} --> passare {v} --> pass {v}
##  	3  ==  passari {v} --> passare {v} --> pass over to {v}
##  
{ my $search = "passari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
  ##  it seems this should be a verb, right ???
}
{ my $search = "passari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc persuàdiri
##  	0  ==  persuàdiri {} --> persuadere {} --> convince {}
##  
{ my $search = "persuàdiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc persuàdiri
##  	2  ==  persuàdiri {} --> persuadere {} --> talk into {}
##  
{ my $search = "persuàdiri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu piccari
## 	0  ==  piccari {v} --> <br> {v} --> sin {v}
## 	1  ==  piccari {v} --> <br> {v} --> trespass {v}
${$dieli_sc{"piccari"}[0]}{"it_word"} = 'peccare';
${$dieli_sc{"piccari"}[1]}{"it_word"} = 'peccare';

##  $ ./query-dieli.pl sc pigghiari
##  	1  ==  pigghiari {} --> prendere {} --> get {}
##  
{ my $search = "pigghiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pigghiari
##  	4  ==  pigghiari {} --> <br> {} --> seize {}
##  
{ my $search = "pigghiari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc piniari
##  	0  ==  piniari {} --> penare {} --> suffer {}
##  
{ my $search = "piniari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pinnuliari
##  	0  ==  pinnuliari {} --> penzolare {} --> dangle {}
##  
{ my $search = "pinnuliari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pinzari
##  	0  ==  pinzari {} --> pensare {} --> believe {}
##  
{ my $search = "pinzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pinzari
##  	1  ==  pinzari {} --> pensare {} --> imagine {}
##  
{ my $search = "pinzari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc piriculari
##  	1  ==  piriculari {} --> <br> {} --> jeopardize {}
##  
{ my $search = "piriculari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pirnuttari
##  	0  ==  pirnuttari {} --> pernottare {} --> spend the night {}
##  
{ my $search = "pirnuttari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pirsivirari
##  	0  ==  pirsivirari {} --> <br> {} --> persevere {}
##  
{ my $search = "pirsivirari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu pscari
## 	0  ==  pscari {v} --> pescare {v} --> fish {v}
{ my $search = "piscari" ; 
  my %th ;  
  $th{"sc_word"} = $search   ; $th{"sc_part"} = "{v}";
  $th{"it_word"} = "pescare" ; $th{"it_part"} = "{v}";
  $th{"en_word"} = "fish"    ; $th{"en_part"} = "{v}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
delete($dieli_sc{"pscari"});

##  $ ./query-dieli.pl sc pittari
##  	0  ==  pittari {} --> dipingere {} --> paint {}
##  
{ my $search = "pittari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pratticari
##  	0  ==  pratticari {} --> praticare {} --> engage in {}
##  
{ my $search = "pratticari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc premiri
##  	0  ==  premiri {} --> <br> {} --> be concerned with {}
##  
{ my $search = "premiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc presumiri
##  	3  ==  presumiri {} --> <br> {} --> presume {}
##  
{ my $search = "presumiri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc presumiri
##  	4  ==  presumiri {} --> <br> {} --> presume {}
##  
{ my $search = "presumiri" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc prifiriri
##  	0  ==  prifiriri {n} --> preferire {} --> like better {}
##  
{ my $search = "prifiriri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc prifiriri
##  	1  ==  prifiriri {n} --> preferire {} --> prefer {}
##  
{ my $search = "prifiriri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc prilivari
##  	0  ==  prilivari {} --> prelevare {} --> collect {}
##  
{ my $search = "prilivari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc prilivari
##  	2  ==  prilivari {} --> prelevare {} --> withdraw (banking) {}
##  
{ my $search = "prilivari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc prisirvari
##  	0  ==  prisirvari {} --> conservare {} --> conserve {}
##  
{ my $search = "prisirvari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc prisirvari
##  	1  ==  prisirvari {} --> conservare {} --> preserve {}
##  
{ my $search = "prisirvari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pritènniri
##  	0  ==  pritènniri {} --> pretendere {} --> claim {}
##  
{ my $search = "pritènniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pritènniri
##  	1  ==  pritènniri {} --> pretendere {} --> expect {}
##  
{ my $search = "pritènniri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pritènniri
##  	2  ==  pritènniri {} --> pretendere {} --> pretend {}
##  
{ my $search = "pritènniri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc proseguiri
##  	0  ==  proseguiri {} --> proseguire {} --> continue {}
##  
{ my $search = "proseguiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc prudùciri
##  	0  ==  prudùciri {} --> produrre {} --> bear {}
##  
{ my $search = "prudùciri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc prudùciri
##  	2  ==  prudùciri {} --> produrre {} --> yield {}
##  
{ my $search = "prudùciri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc prupòniri
##  	0  ==  prupòniri {} --> proporre  {} --> propose  {v}
##  
{ my $search = "prupòniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
  ##  also need to remove trailing space
  ${$dieli_sc{$search}[$index]}{"it_word"} = "proporre" ;
  ${$dieli_sc{$search}[$index]}{"en_word"} = "propose" ;
}

##  $ ./query-dieli.pl sc pruvari
##  	3  ==  pruvari {} --> provare {} --> try {}
##  
{ my $search = "pruvari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pròjiri
##  	1  ==  pròjiri {} --> porgere {} --> hold out {}
##  
{ my $search = "pròjiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pulizziari
##  	0  ==  pulizziari {} --> pulire {} --> clean {}
##  
{ my $search = "pulizziari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc puntificari
##  	0  ==  puntificari {} --> comandare {} --> pontificate {v}
##  
{ my $search = "puntificari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pàrtiri
##  	0  ==  pàrtiri {} --> partire {} --> leave {}
##  
{ my $search = "pàrtiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pùnciri
##  	0  ==  pùnciri {} --> pungere {} --> prick {}
##  
{ my $search = "pùnciri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pùnciri
##  	2  ==  pùnciri {} --> <br> {} --> puncture {}
##  
{ my $search = "pùnciri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pùnciri
##  	3  ==  pùnciri {} --> <br> {} --> spur {}
##  
{ my $search = "pùnciri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pùnciri
##  	4  ==  pùnciri {} --> pungere {} --> sting {}
##  
{ my $search = "pùnciri" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc pùnciri
##  	5  ==  pùnciri {} --> <br> {} --> urge {}
##  
{ my $search = "pùnciri" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc quagghiari
##  	0  ==  quagghiari {} --> coagulare {} --> clot {}
##  
{ my $search = "quagghiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc quagghiari
##  	1  ==  quagghiari {} --> rapprendersi {} --> coagulate {}
##  
{ my $search = "quagghiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc racumannari
##  	0  ==  racumannari {} --> raccomandare {} --> recommend {}
##  
{ my $search = "racumannari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc radunari
##  	3  ==  radunari {} --> radunare {} --> rally (troops) {}
##  
{ my $search = "radunari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc rallintari
##  	0  ==  rallintari {} --> <br> {} --> ease {}
##  
{ my $search = "rallintari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc raspari o rattari
##  	0  ==  raspari o rattari {} --> grattare {} --> scratch {}
##  
## $ ./query-dieli.pl sc strittu rattari
## 	0  ==  rattari {v} --> grattare {v} --> scratch {v}
{ my $search = "raspari" ; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{v}";
  $th{"it_word"} = "grattare" ; $th{"it_part"} = "{v}";
  $th{"en_word"} = "scratch"  ; $th{"en_part"} = "{v}";  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
delete($dieli_sc{"raspari o rattari"});

##  $ ./query-dieli.pl sc regnari
##  	0  ==  regnari {} --> <br> {} --> prevail {}
##  
{ my $search = "regnari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc regnari
##  	1  ==  regnari {} --> <br> {} --> reign {}
##  
{ my $search = "regnari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc rettificari
##  	0  ==  rettificari {} --> rettificare {} --> rectify {}
##  
{ my $search = "rettificari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ribbàttiri
##  	0  ==  ribbàttiri {} --> ribattere {} --> refute {}
##  
{ my $search = "ribbàttiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ribbàttiri
##  	1  ==  ribbàttiri {} --> rintuzzare {} --> refute {}
##  
{ my $search = "ribbàttiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ricchiri
##  	1  ==  ricchiri {} --> arricchire {} --> make rich {}
##  
{ my $search = "ricchiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ricunzignari
##  	0  ==  ricunzignari {} --> restituire {} --> give back {}
##  
{ my $search = "ricunzignari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ricunzignari
##  	1  ==  ricunzignari {} --> restituire {} --> restore {}
##  
{ my $search = "ricunzignari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu ricurdari
## 	0  ==  ricurdari {v} --> ricordarsi {v} --> recall {v}
## 	1  ==  ricurdari {v} --> ricordarsi {v} --> recollect {v}
${$dieli_sc{"ricurdari"}[0]}{"it_word"} = 'ricordare';
${$dieli_sc{"ricurdari"}[1]}{"it_word"} = 'ricordare';

## $ ./query-dieli.pl sc strittu riurdari
## 	0  ==  riurdari {v} --> ricordare {v} --> remember {v}
{ delete( $dieli_sc{"riurdari"} ) ;
  my $search = "ricurdari" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "ricordare"   ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "remember"    ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
## $ ./query-dieli.pl sc strittu ricudarisi
## 	0  ==  ricudarisi {v} --> <br> {v} --> recollect {v}
{ delete( $dieli_sc{"ricudarisi"} ) ;
  my $search = "ricurdàrisi" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "ricordarsi"  ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "recollect"   ; $th{"en_part"} = "{v}" ;  
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  $ ./query-dieli.pl sc riddùciri
##  	0  ==  riddùciri {} --> ridurre {} --> lessen {}
##  
{ my $search = "riddùciri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc riddùciri
##  	1  ==  riddùciri {} --> ridurre {} --> lower {}
##  
{ my $search = "riddùciri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ridiri
##  	0  ==  ridiri {} --> ridere {} --> laugh {}
##  
{ my $search = "ridiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ringrazziari
##  	0  ==  ringrazziari {} --> <br> {} --> give thanks {}
##  
{ my $search = "ringrazziari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ringrazziari
##  	1  ==  ringrazziari {} --> <br> {} --> show gratitude {}
##  
{ my $search = "ringrazziari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc risbigghiari
##  	0  ==  risbigghiari {} --> svegliare {} --> awaken {}
##  
{ my $search = "risbigghiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ruinari
##  	1  ==  ruinari {} --> rovinare {} --> spoil {}
##  
{ my $search = "ruinari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc runfuliari
##  	2  ==  runfuliari {} --> ronzare {} --> hum {}
##  
{ my $search = "runfuliari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc runfuliari
##  	3  ==  runfuliari {} --> russare {} --> hum {}
##  
{ my $search = "runfuliari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc rènniri
##  	0  ==  rènniri {} --> rendere {} --> give back {}
##  
{ my $search = "rènniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc rènniri
##  	4  ==  rènniri {} --> rendere {} --> yield {}
##  
{ my $search = "rènniri" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc rùmpiri
##  	0  ==  rùmpiri {} --> rompere {} --> break {}
##  
{ my $search = "rùmpiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sbagghiari
##  	0  ==  sbagghiari {} --> sbagliare {} --> err {}
##  
{ my $search = "sbagghiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sbagghiari
##  	1  ==  sbagghiari {} --> sbagliare {} --> make a mistake {}
##  
{ my $search = "sbagghiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sbagliari
##  	0  ==  sbagliari {} --> sbagliare {} --> mistake {}
##  
{ my $search = "sbagliari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sbariari
##  	0  ==  sbariari {} --> diminuire {} --> decrease {}
##  
{ my $search = "sbariari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sbariari
##  	1  ==  sbariari {} --> passare {} --> disappear {}
##  
{ my $search = "sbariari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sbariari
##  	2  ==  sbariari {} --> svanire {} --> disappear {}
##  
{ my $search = "sbariari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sbariari
##  	4  ==  sbariari {} --> passare {} --> vanish {}
##  
{ my $search = "sbariari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sbariari
##  	5  ==  sbariari {} --> svanire {} --> vanish {}
##  
{ my $search = "sbariari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sbrazzari
##  	0  ==  sbrazzari {} --> <br> {} --> bare one's arms {}
##  
{ my $search = "sbrazzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sbrijari
##  	0  ==  sbrijari {} --> sbrigare {} --> bring to a conclusion {}
##  
{ my $search = "sbrijari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sbrucculari
##  	1  ==  sbrucculari {} --> escodellare {} --> dish out {}
##  
{ my $search = "sbrucculari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sbucciari
##  	2  ==  sbucciari {n} --> sbucciare {} --> peel {}
##  
{ my $search = "sbucciari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scadiri
##  	0  ==  scadiri {} --> scadere {} --> become due {}
##  
{ my $search = "scadiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scadiri
##  	1  ==  scadiri {} --> scadere {} --> decline (in value) {}
##  
{ my $search = "scadiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scampaniari
##  	0  ==  scampaniari {} --> squillare {} --> blare {}
##  
{ my $search = "scampaniari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scatinari
##  	0  ==  scatinari {} --> scatenare {} --> let loose {}
##  
{ my $search = "scatinari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scatinari
##  	1  ==  scatinari {} --> scatenare {} --> unchain {}
##  
{ my $search = "scatinari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scattari
##  	0  ==  scattari {} --> sanguinare (del naso) {} --> bloody nose {}
##  
{ my $search = "scattari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scattari
##  	4  ==  scattari {} --> scoppiettare {} --> crackle (fire) {}
##  
{ my $search = "scattari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc schirzari
##  	0  ==  schirzari {} --> scherzare {} --> jest {}
##  
{ my $search = "schirzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc schirzari
##  	1  ==  schirzari {} --> scherzare {} --> joke {}
##  
{ my $search = "schirzari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc schirzari
##  	2  ==  schirzari {} --> scherzare {} --> make fun (of) {}
##  
{ my $search = "schirzari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc schirzari
##  	3  ==  schirzari {} --> scherzare {} --> tease {}
##  
{ my $search = "schirzari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sciddicari
##  	0  ==  sciddicari {} --> scivolare {} --> slide {}
##  
{ my $search = "sciddicari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sciddicari
##  	1  ==  sciddicari {} --> scivolare {} --> slip {}
##  
{ my $search = "sciddicari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sciusciari
##  	1  ==  sciusciari {} --> soffiare {} --> exhale {}
##  
{ my $search = "sciusciari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sciògghiri
##  	1  ==  sciògghiri {} --> svolgere {} --> find a solution {}
##  
{ my $search = "sciògghiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scrìviri
##  	0  ==  scrìviri {} --> scrivere {v} --> attribute (to) {v}
##  
{ my $search = "scrìviri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scucchiari
##  	0  ==  scucchiari {} --> staccare {} --> detach {}
##  
{ my $search = "scucchiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scucchiari
##  	1  ==  scucchiari {} --> staccare {} --> pull off {}
##  
{ my $search = "scucchiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scuitari
##  	0  ==  scuitari {} --> stuzzicare {} --> stir {}
##  
{ my $search = "scuitari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sculari
##  	0  ==  sculari {} --> scolare {} --> drain {}
##  
{ my $search = "sculari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sculari
##  	1  ==  sculari {} --> sgocciolare {} --> drain {}
##  
{ my $search = "sculari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scummigghiari
##  	1  ==  scummigghiari {} --> scoprire {} --> expose {}
##  
{ my $search = "scummigghiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scummèttiri
##  	0  ==  scummèttiri {} --> scommettere {} --> bet {}
##  
{ my $search = "scummèttiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scummèttiri
##  	1  ==  scummèttiri {} --> scommettere {} --> wager {}
##  
{ my $search = "scummèttiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scuncicari
##  	1  ==  scuncicari {} --> stuzzichiari {} --> prick {}
##  
{ my $search = "scuncicari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scuppiari
##  	0  ==  scuppiari {} --> esplodere {} --> blow up {}
##  
{ my $search = "scuppiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scuppiari
##  	1  ==  scuppiari {} --> esplodere {} --> burst {}
##  
{ my $search = "scuppiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scuppiari
##  	2  ==  scuppiari {} --> esplodere {} --> explode {}
##  
{ my $search = "scuppiari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scupriri
##  	3  ==  scupriri {} --> scoprire {} --> find out {}
##  
{ my $search = "scupriri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scuttari
##  	0  ==  scuttari {} --> <br> {} --> discount {}
##  
{ my $search = "scuttari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc scìnniri
##  	1  ==  scìnniri {} --> scendere {} --> descend {}
##  
{ my $search = "scìnniri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sentiri
##  	0  ==  sentiri {} --> ascoltare {} --> listen {}
##  
{ my $search = "sentiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sentu riri
##  	0  ==  sentu riri {} --> io affermo {} --> assert {}
##  
{ my $search = "sentu riri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
  ${dieli_sc{$search}[$index]}{"linkto"} = "sèntiri";
}

##  $ ./query-dieli.pl sc sentu riri
##  	1  ==  sentu riri {} --> io affermo {} --> hearsay {}
##  
{ my $search = "sentu riri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
  ${dieli_sc{$search}[$index]}{"linkto"} = "sèntiri";
}

##  $ ./query-dieli.pl sc serviri
##  	2  ==  serviri {} --> <br> {} --> be useful {}
##  
{ my $search = "serviri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sfardari
##  	0  ==  sfardari {} --> lacerare {} --> tear up {}
##  
{ my $search = "sfardari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sfardari
##  	1  ==  sfardari {} --> stracciare {} --> tear up {}
##  
{ my $search = "sfardari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sfari
##  	0  ==  sfari {} --> <br> {} --> kill {}
##  
{ my $search = "sfari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sfari
##  	2  ==  sfari {} --> <br> {} --> waste {}
##  
{ my $search = "sfari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sfazzari
##  	0  ==  sfazzari {} --> <br> {} --> suffer {}
##  
{ my $search = "sfazzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sfracari
##  	0  ==  sfracari {} --> sprecare {} --> squander {}
##  
{ my $search = "sfracari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sfracari
##  	1  ==  sfracari {} --> sprecare {} --> waste {}
##  
{ my $search = "sfracari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu sfrazziari
## 	0  ==  sfrazziari {v} --> sfarzeggiare {v} --> show off {v}
## 	1  ==  sfrazziari {v} --> sfoggiare {v} --> show off {v}
{ my $search = "sfrazziari" ; 
  my %th ;  
  $th{"sc_word"} = $search       ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "pompeggiare" ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "show off"    ; $th{"en_part"} = "{v}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "sfrazziari" ; 
  my %th ;  
  $th{"sc_word"} = $search         ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "lussureggiare" ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "luxuriate"     ; $th{"en_part"} = "{v}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu sfuiri
## 	0  ==  sfuiri {v} --> fuggire {} --> avoid {v}
## 	1  ==  sfuiri {v} --> sfuggire {v} --> escape {v}
${$dieli_sc{"sfuiri"}[0]}{"it_part"} = '{v}';

##  $ ./query-dieli.pl sc sfunnari
##  	0  ==  sfunnari {} --> sfondare {} --> break through {}
##  
{ my $search = "sfunnari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sghiddari
##  	1  ==  sghiddari {} --> scizzare {} --> slip away {}
##  
{ my $search = "sghiddari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sghiddari
##  	2  ==  sghiddari {} --> sgusciare {} --> slip away {}
##  
{ my $search = "sghiddari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sicutari
##  	0  ==  sicutari {} --> proseguire {} --> carry on {v}
##  
{ my $search = "sicutari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sicutari
##  	1  ==  sicutari {} --> <br> {} --> continue {}
##  
{ my $search = "sicutari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sicutari
##  	2  ==  sicutari {} --> seguitare {} --> continue {}
##  
{ my $search = "sicutari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sicutari
##  	3  ==  sicutari {} --> proseguire {} --> continue with {}
##  
{ my $search = "sicutari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sicutari
##  	5  ==  sicutari {} --> proseguire {} --> go on {}
##  
{ my $search = "sicutari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sicutari
##  	6  ==  sicutari {} --> seguitare {} --> go on {}
##  
{ my $search = "sicutari" ; my $index = 6 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sicutari
##  	7  ==  sicutari {} --> persistere {} --> persist {}
##  
{ my $search = "sicutari" ; my $index = 7 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc siddiarisi
##  	0  ==  siddiarisi {} --> prenderla a male {} --> be annoyed {}
##  
{ my $search = "siddiarisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc siddiarisi
##  	1  ==  siddiarisi {} --> scocciarsi {} --> be bored {}
##  
{ my $search = "siddiarisi" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc siminari
##  	0  ==  siminari {} --> seminare {} --> disseminate {v}
##  
{ my $search = "siminari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc siminari
##  	1  ==  siminari {} --> seminare {} --> inseminate {v}
##  
{ my $search = "siminari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc siminari
##  	3  ==  siminari {} --> seminare {} --> seed {v}
##  
{ my $search = "siminari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu sintirisi
## 	0  ==  sintirisi {v} --> sentire {v} --> feel {v}
${$dieli_sc{"sintirisi"}[0]}{"it_word"} = 'sentirsi';

## $ ./query-dieli.pl sc strittu spugghiari
## 	0  ==  spugghiari {v} --> spogliare {v} --> deprive {v}
## 	1  ==  spugghiari {v} --> spogliarsi {v} --> disrobe {v}
## 	2  ==  spugghiari {v} --> spogliare {v} --> divest (of) {v}
## 	3  ==  spugghiari {v} --> spogliare {v} --> strip {v}
## 
## $ ./query-dieli.pl sc strittu spugghiarisi
## 	0  ==  spugghiarisi {v} --> spogliarsi {} --> undress {}
{ my $i = 1;
  my $search = "spugghiari";
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'spogliare';
}
{ my $i = 0;
  my $search = "spugghiarisi";
  ${$dieli_sc{$search}[$i]}{"it_part"} = '{v}';
  ${$dieli_sc{$search}[$i]}{"en_part"} = '{v}';
}

##  $ ./query-dieli.pl sc siquitari
##  	0  ==  siquitari {} --> <br> {} --> continue {}
##  
{ my $search = "siquitari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc siquitari
##  	2  ==  siquitari {} --> <br> {} --> pursue {}
##  
{ my $search = "siquitari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc smagghiari
##  	0  ==  smagghiari {} --> smagliare (pe una catena) {} --> break (eg a chain) {}
##  
{ my $search = "smagghiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sminittiari
##  	0  ==  sminittiari {} --> rovinare appositamente {} --> destroy on purpose {}
##  
{ my $search = "sminittiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sminittiari
##  	1  ==  sminittiari {} --> rovinare appositamente {} --> ruin on purpose {}
##  
{ my $search = "sminittiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sminnari
##  	1  ==  sminnari {} --> sciupare {} --> spoil {}
##  
{ my $search = "sminnari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sminnari
##  	2  ==  sminnari {} --> rovinare {} --> waste {}
##  
{ my $search = "sminnari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sminnari
##  	3  ==  sminnari {} --> sciupare {} --> waste {}
##  
{ my $search = "sminnari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc smuddicari
##  	0  ==  smuddicari {} --> sbriciolare {} --> break in pieces {}
##  
{ my $search = "smuddicari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc smòviri
##  	0  ==  smòviri {} --> rimuovere {} --> dismiss {}
##  
{ my $search = "smòviri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spaccari
##  	4  ==  spaccari {} --> spaccare {} --> split {}
##  
{ my $search = "spaccari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spacinziari
##  	0  ==  spacinziari {} --> fare perdere la pazienza {} --> lose patience {}
##  
{ my $search = "spacinziari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spagghiari
##  	3  ==  spagghiari {} --> <br> {} --> winnow {}
##  
{ my $search = "spagghiari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spampinari
##  	0  ==  spampinari {} --> togliere le foglie o i fiori {} --> lose leaves {}
##  
{ my $search = "spampinari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sparagnari
##  	0  ==  sparagnari {} --> <br> {} --> conserve {}
##  
{ my $search = "sparagnari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sparagnari
##  	1  ==  sparagnari {} --> <br> {} --> save {}
##  
{ my $search = "sparagnari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu sparagna
## 	0  ==  sparagna {} --> <br> {} --> conserve {}
## 	1  ==  sparagna {} --> <br> {} --> save {}
{ my $search = "sparagna" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}
{ my $search = "sparagna" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spardari
##  	0  ==  spardari {} --> strappare {} --> tear up {}
##  
{ my $search = "spardari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spardari
##  	1  ==  spardari {} --> strappare {} --> wring {}
##  
{ my $search = "spardari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu spartiri
## 	0  ==  spartiri {v} --> <br> {v} --> deal {v}
## 	1  ==  spartiri {v} --> ripartire {v} --> divide {v}
## 
## $ ./query-dieli.pl sc strittu spàrtiri
## 	0  ==  spàrtiri {v} --> dividere {v} --> apportion {v}
## 	1  ==  spàrtiri {v} --> dividere {v} --> divide {v}
## 	2  ==  spàrtiri {v} --> condividere {v} --> share {v}
## 	3  ==  spàrtiri {v} --> dividere {} --> split {}
${$dieli_sc{"spàrtiri"}[3]}{"it_part"} = '{v}';
${$dieli_sc{"spàrtiri"}[3]}{"en_part"} = '{v}';

##  $ ./query-dieli.pl sc spasciari
##  	0  ==  spasciari {} --> spaccare {} --> wreck {}
##  
{ my $search = "spasciari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sperdiri
##  	1  ==  sperdiri {} --> <br> {} --> lose {}
##  
{ my $search = "sperdiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spiacari
##  	0  ==  spiacari {} --> spiegare {} --> make clear {}
##  
{ my $search = "spiacari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spianari
##  	1  ==  spianari {} --> spianare {} --> level {}
##  
{ my $search = "spianari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spiari
##  	1  ==  spiari {} --> interrogare {} --> examine {}
##  
{ my $search = "spiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spidiri
##  	1  ==  spidiri {} --> spedire {} --> mail {}
##  
{ my $search = "spidiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spidiri
##  	2  ==  spidiri {} --> spedire {} --> send {}
##  
{ my $search = "spidiri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spidiri
##  	3  ==  spidiri {} --> spedire {} --> ship {v}
##  
{ my $search = "spidiri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spinniciarisi
##  	0  ==  spinniciarisi {} --> scervellarsi {} --> rack one's brain {}
##  
{ my $search = "spinniciarisi" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spiriri
##  	2  ==  spiriri {vi} --> sparire {vi} --> disappear {vi}
##  
{ my $search = "spiriri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spirlùciri
##  	2  ==  spirlùciri {} --> rilucere {} --> shine brightly {}
##  
{ my $search = "spirlùciri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spirlùciri
##  	3  ==  spirlùciri {} --> risplendere {} --> shine brightly {}
##  
{ my $search = "spirlùciri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spirlùciri
##  	4  ==  spirlùciri {} --> rilucere {} --> sparkle {}
##  
{ my $search = "spirlùciri" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spirlùciri
##  	5  ==  spirlùciri {} --> risplendere {} --> sparkle {}
##  
{ my $search = "spirlùciri" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spriparari
##  	0  ==  spriparari {} --> sparecchiare {} --> clear away {}
##  
{ my $search = "spriparari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sprèmiri
##  	0  ==  sprèmiri {} --> <br> {} --> squeeze {}
##  
{ my $search = "sprèmiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sprèmiri
##  	1  ==  sprèmiri {} --> <br> {} --> wring {}
##  
{ my $search = "sprèmiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spugghiari
##  	0  ==  spugghiari {} --> spogliare {} --> deprive {}
##  
{ my $search = "spugghiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spugghiari
##  	1  ==  spugghiari {} --> spogliarsi {} --> disrobe {}
##  
{ my $search = "spugghiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spugghiari
##  	2  ==  spugghiari {} --> spogliare {} --> divest (of) {}
##  
{ my $search = "spugghiari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spuntari
##  	0  ==  spuntari {} --> spuntare {} --> sprout {}
##  
{ my $search = "spuntari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spusari
##  	1  ==  spusari {} --> <br> {} --> wed {}
##  
{ my $search = "spusari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spustari
##  	1  ==  spustari {} --> spostare {} --> move {}
##  
{ my $search = "spustari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spustari
##  	5  ==  spustari {} --> spostare {} --> shift {}
##  
{ my $search = "spustari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spàrtiri
##  	1  ==  spàrtiri {} --> dividere {} --> divide {}
##  
{ my $search = "spàrtiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spènniri
##  	0  ==  spènniri {} --> spendere {} --> spend {}
##  
{ my $search = "spènniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc spìnciri
##  	1  ==  spìnciri {} --> calpestare {} --> tread on {}
##  
{ my $search = "spìnciri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc squatrari
##  	0  ==  squatrari {} --> guardare attentamente {} --> describe {}
##  
{ my $search = "squatrari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc squatrari
##  	1  ==  squatrari {} --> dividere in riquadri il terreno {} --> divide up land in squares {}
##  
{ my $search = "squatrari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc squatrari
##  	2  ==  squatrari {} --> guardare attentamente {} --> look at closely {}
##  
{ my $search = "squatrari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc squatrari
##  	3  ==  squatrari {} --> scrutare {} --> measure {v}
##  
{ my $search = "squatrari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc squatrari
##  	4  ==  squatrari {} --> squadrare {} --> square {}
##  
{ my $search = "squatrari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc squatriari
##  	0  ==  squatriari {} --> squadrare {} --> square {}
##  
{ my $search = "squatriari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
  ##  ##  do NOT include this "linkto", but keep as a "reminder"
  ##  ##  "reminder" to include in the "dieli" field of the %{$vnotes{"squatrari"}}
  ##  ##  ${$dieli_sc{$search}[$index]}{"linkto"} = "squatrari";
}

##  $ ./query-dieli.pl sc stabbiliri
##  	2  ==  stabbiliri {} --> fissare {} --> stabilize {}
##  
{ my $search = "stabbiliri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc stabbiliri
##  	3  ==  stabbiliri {} --> stabilire {} --> stabilize {}
##  
{ my $search = "stabbiliri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc stancari
##  	0  ==  stancari {vi} --> riposarsi {vi} --> lie down {vi}
##  
{ my $search = "stancari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc statizzari
##  	0  ==  statizzari {vi} --> far estate {vi} --> summer {vi}
##  
{ my $search = "statizzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc stenniri
##  	0  ==  stenniri {} --> stendere {} --> hang out {}
##  
{ my $search = "stenniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc stenniri
##  	1  ==  stenniri {} --> stendere {} --> lay {}
##  
{ my $search = "stenniri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ qdieli sc strittu stinciri
## 	stinciri  not found
{ my $search = "stinciri" ; 
  my %th ;  
  $th{"sc_word"} = $search     ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "stingere"  ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "fade"      ; $th{"en_part"} = "{v}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  $ ./query-dieli.pl sc strammari
##  	1  ==  strammari {} --> sconvolgere {} --> upset {}
##  
{ my $search = "strammari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc strazzari
##  	1  ==  strazzari {} --> lacerare {} --> tear off {}
##  
{ my $search = "strazzari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc strazzari
##  	2  ==  strazzari {} --> stracciare {} --> tear off {}
##  
{ my $search = "strazzari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc strazzari
##  	3  ==  strazzari {} --> strappare {} --> tear off {}
##  
{ my $search = "strazzari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc strazzari
##  	4  ==  strazzari {} --> strappare {} --> tear up {}
##  
{ my $search = "strazzari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc strummintari
##  	0  ==  strummintari {} --> escogitare {} --> devise {}
##  
{ my $search = "strummintari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc strìnciri
##  	0  ==  strìnciri {} --> stringere {} --> squeeze {}
##  
{ my $search = "strìnciri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc strìnciri
##  	1  ==  strìnciri {} --> stringere {} --> tighten {}
##  
{ my $search = "strìnciri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc stuzzicari
##  	0  ==  stuzzicari {n} --> stuzzicare {v} --> poke {v}
##  
{ my $search = "stuzzicari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc stùrciri
##  	0  ==  stùrciri {} --> storcere {} --> twist {}
##  
{ my $search = "stùrciri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc stùrciri
##  	1  ==  stùrciri {} --> torcere {} --> twist {}
##  
{ my $search = "stùrciri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc stùrciri
##  	2  ==  stùrciri {} --> storcere {} --> wring out {}
##  
{ my $search = "stùrciri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc stùrciri
##  	3  ==  stùrciri {} --> torcere {} --> wring out {}
##  
{ my $search = "stùrciri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc succeriri
##  	0  ==  succeriri {} --> avvenire {} --> happen {}
##  
{ my $search = "succeriri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc succèdiri
##  	0  ==  succèdiri {} --> succedere {} --> befall {}
##  
{ my $search = "succèdiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc succèdiri
##  	2  ==  succèdiri {} --> succedere {} --> succeed (throne) {}
##  
{ my $search = "succèdiri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suffriri
##  	0  ==  suffriri {} --> <br> {} --> bear {}
##  
{ my $search = "suffriri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suffriri
##  	1  ==  suffriri {} --> <br> {} --> endure {}
##  
{ my $search = "suffriri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suliri
##  	1  ==  suliri {} --> <br> {} --> be normal {}
##  
{ my $search = "suliri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suliri
##  	2  ==  suliri {} --> <br> {} --> be usual {}
##  
{ my $search = "suliri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc summergiri
##  	0  ==  summergiri {} --> <br> {} --> overwhelm {}
##  
{ my $search = "summergiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc supirari
##  	1  ==  supirari {} --> superare {} --> overtake {}
##  
{ my $search = "supirari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suppòniri
##  	0  ==  suppòniri {} --> presupporre {} --> assume {}
##  
{ my $search = "suppòniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suppòniri
##  	1  ==  suppòniri {} --> presupporre {} --> presuppose {}
##  
{ my $search = "suppòniri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suppòniri
##  	2  ==  suppòniri {} --> presupporre {} --> presuppose {}
##  
{ my $search = "suppòniri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suppòniri
##  	3  ==  suppòniri {} --> presupporre {} --> suppose {}
##  
{ my $search = "suppòniri" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suprafari
##  	1  ==  suprafari {} --> <br> {} --> prevail {}
##  
{ my $search = "suprafari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suprafari
##  	2  ==  suprafari {} --> <br> {} --> win {}
##  
{ my $search = "suprafari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc supraniari
##  	2  ==  supraniari {} --> superare {} --> overcome {}
##  
{ my $search = "supraniari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu susirisi
## 	0  ==  susirisi {v} --> alzarsi {v} --> arise {v}
## 	1  ==  susirisi {v} --> alzarsi {} --> get up {v}
## 	2  ==  susirisi {v} --> alzarsi {v} --> rise {v}
foreach my $index (0..2) {
    my $search = "susirisi" ; 
    $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ qdieli sc strittu susiri susìu 
## 	susiri  not found
## 
## $ ./query-dieli.pl sc strittu susìu
## 	0  ==  susìu {} --> <br> {} --> got up {}
## 	1  ==  susìu {} --> alzò {} --> got up {}
delete( $dieli_sc{'susìu'} );
{ my $search = "susiri" ; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "alzare"   ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "lift"     ; $th{"en_part"} = "{v}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "susiri" ; 
  my %th ;  
  $th{"sc_word"} = $search    ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "alzare"   ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "raise"    ; $th{"en_part"} = "{v}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  $ ./query-dieli.pl sc suspènniri
##  	0  ==  suspènniri {} --> sospendere {} --> defer {}
##  
{ my $search = "suspènniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suspènniri
##  	2  ==  suspènniri {} --> sospendere {} --> interrupt {}
##  
{ my $search = "suspènniri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sustiniri
##  	0  ==  sustiniri {} --> sorreggere {} --> hold up {}
##  
{ my $search = "sustiniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sustiniri
##  	1  ==  sustiniri {} --> sostenere {} --> hold up {}
##  
{ my $search = "sustiniri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sustiniri
##  	5  ==  sustiniri {} --> sorreggere {} --> sustain {}
##  
{ my $search = "sustiniri" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sustiniri
##  	6  ==  sustiniri {} --> sostenere {} --> sustain {}
##  
{ my $search = "sustiniri" ; my $index = 6 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suttaliniari
##  	2  ==  suttaliniari {} --> sottolineare {} --> underline {}
##  
{ my $search = "suttaliniari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suttamèttiri
##  	0  ==  suttamèttiri {} --> sottomettere {} --> subdue {}
##  
{ my $search = "suttamèttiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suttamèttiri
##  	1  ==  suttamèttiri {} --> sottomettere {} --> subject {}
##  
{ my $search = "suttamèttiri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suttamèttiri
##  	2  ==  suttamèttiri {} --> sottomettere {} --> subjugate {}
##  
{ my $search = "suttamèttiri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc suttirrari
##  	0  ==  suttirrari {} --> sotterrare {} --> bury {}
##  
{ my $search = "suttirrari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc svapurari
##  	0  ==  svapurari {} --> esalare {} --> emit an odor {}
##  
{ my $search = "svapurari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc svapurari
##  	1  ==  svapurari {} --> evaporare {} --> emit an odor {}
##  
{ my $search = "svapurari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc svapurari
##  	2  ==  svapurari {} --> esalare {} --> evaporate {}
##  
{ my $search = "svapurari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc svapurari
##  	3  ==  svapurari {} --> evaporare {} --> evaporate {}
##  
{ my $search = "svapurari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc svelari
##  	0  ==  svelari {} --> scoprire {} --> expose {}
##  
{ my $search = "svelari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu svigghiari
## 	0  ==  svigghiari {v} --> svegliarsi {v} --> awake {v}
## 
${$dieli_sc{"svigghiari"}[0]}{"it_word"} = 'svegliare';
## 
## $ ./query-dieli.pl sc strittu svigghiarisi
## 	svigghiarisi  not found
{ my $search = "svigghiarisi" ; 
  my %th ;  
  $th{"sc_word"} = $search      ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "svegliarsi" ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "wake up"    ; $th{"en_part"} = "{v}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  $ ./query-dieli.pl sc sìggiri
##  	0  ==  sìggiri {} --> riscuotere {} --> collect {}
##  
{ my $search = "sìggiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sòffriri
##  	0  ==  sòffriri {} --> <br> {} --> bear {}
##  
{ my $search = "sòffriri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sòffriri
##  	1  ==  sòffriri {} --> <br> {} --> manage {}
##  
{ my $search = "sòffriri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc sòffriri
##  	2  ==  sòffriri {} --> <br> {} --> sustain {}
##  
{ my $search = "sòffriri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tacchiari
##  	0  ==  tacchiari {} --> correre veloce {} --> run fast {}
##  
{ my $search = "tacchiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc taciri
##  	0  ==  taciri {} --> <br> {} --> be silent {}
##  
{ my $search = "taciri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu taciri
## 	0  ==  taciri {v} --> <br> {} --> be silent {v}
## 	1  ==  taciri {v} --> <br> {v} --> silent (be, remain) {v}
for my $i (0,1) {
    my $search = "taciri";
    ${$dieli_sc{$search}[$i]}{"it_word"} = 'tacere';
    ${$dieli_sc{$search}[$i]}{"it_part"} = '{v}';
}

##  $ ./query-dieli.pl sc tampasiari
##  	0  ==  tampasiari {} --> andare in giro a zonzo {} --> waste time {}
##  
{ my $search = "tampasiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tappuliari
##  	0  ==  tappuliari {} --> bussare {} --> knock {}
##  
{ my $search = "tappuliari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tastari
##  	0  ==  tastari {} --> <br> {} --> sample {}
##  
{ my $search = "tastari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tastari
##  	1  ==  tastari {} --> <br> {} --> savor {}
##  
{ my $search = "tastari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tentari
##  	2  ==  tentari {} --> tentare {} --> test {}
##  
{ my $search = "tentari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tentari
##  	3  ==  tentari {} --> tentare {} --> try {}
##  
{ my $search = "tentari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ti curari
##  	0  ==  ti curari {} --> preoccuparti {} --> worry {}
##  
{ my $search = "ti curari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
  ##  ##  do NOT include this "linkto", but keep as a "reminder"
  ##  ##  "reminder" to include in the "dieli" field of %{$vnotes{"curarisi"}}
  ##  ##  ${$dieli_sc{$search}[$index]}{"linkto"} = "curarisi";
}

##  $ ./query-dieli.pl sc tinniri
##  	0  ==  tinniri {} --> mantenere {} --> maintain {}
##  
{ my $search = "tinniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tintari
##  	0  ==  tintari {} --> tentare {} --> attempt {}
##  
{ my $search = "tintari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tintari
##  	2  ==  tintari {} --> tentare {} --> tempt {}
##  
{ my $search = "tintari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tintari
##  	3  ==  tintari {} --> tentare {} --> try {}
##  
{ my $search = "tintari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc togghiri
##  	0  ==  togghiri {} --> togliere {v} --> remove {v}
##  
{ my $search = "togghiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc torciri
##  	1  ==  torciri {} --> piegare {} --> twist {}
##  
{ my $search = "torciri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc torciri
##  	2  ==  torciri {} --> torcere {} --> twist {}
##  
{ my $search = "torciri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tradùciri
##  	0  ==  tradùciri {} --> tradurre {} --> convey {}
##  
{ my $search = "tradùciri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tradùciri
##  	2  ==  tradùciri {} --> tradurre {} --> translate {}
##  
{ my $search = "tradùciri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc traficari
##  	0  ==  traficari {} --> trafficare {v} --> deal {v}
##  
{ my $search = "traficari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc traficari
##  	1  ==  traficari {} --> trafficare {v} --> do {v}
##  
{ my $search = "traficari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tralucari
##  	0  ==  tralucari {} --> trasferire {} --> move {}
##  
{ my $search = "tralucari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tralucari
##  	1  ==  tralucari {} --> traslocare {} --> move {}
##  
{ my $search = "tralucari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tralucari
##  	4  ==  tralucari {} --> trasferire {} --> transfer {}
##  
{ my $search = "tralucari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tralucari
##  	5  ==  tralucari {} --> traslocare {} --> transfer {}
##  
{ my $search = "tralucari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tramiscari
##  	0  ==  tramiscari {} --> mescolare {} --> blend {}
##  
{ my $search = "tramiscari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tramiscari
##  	1  ==  tramiscari {} --> interpolare {} --> interpolate {}
##  
{ my $search = "tramiscari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tramiscari
##  	2  ==  tramiscari {} --> interpolare {} --> mix {}
##  
{ my $search = "tramiscari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tramiscari
##  	3  ==  tramiscari {} --> mescolare {} --> mix {}
##  
{ my $search = "tramiscari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trasmìttiri
##  	2  ==  trasmìttiri {} --> trasmettere {} --> transmit {}
##  
{ my $search = "trasmìttiri" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trattari
##  	2  ==  trattari {} --> trattare {v} --> discuss {v}
##  
{ my $search = "trattari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trattari
##  	3  ==  trattari {} --> negoziare {v} --> negotiate {v}
##  
{ my $search = "trattari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trattari
##  	5  ==  trattari {} --> accogliere {v} --> receive {v}
##  
{ my $search = "trattari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trattari
##  	7  ==  trattari {} --> ospitare {v} --> welcome {v}
##  
{ my $search = "trattari" ; my $index = 7 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trattèniri
##  	0  ==  trattèniri {} --> trattenere {} --> detain {}
##  
{ my $search = "trattèniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trattèniri
##  	1  ==  trattèniri {} --> trattenere {} --> hold back {}
##  
{ my $search = "trattèniri" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trimari
##  	2  ==  trimari {} --> tremare {} --> tremble {}
##  
{ my $search = "trimari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trivuliari
##  	0  ==  trivuliari {vi} --> tribolare {vi} --> be troubled {vi}
##  
{ my $search = "trivuliari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trivuliari
##  	1  ==  trivuliari {vi} --> tribolare {vi} --> worry {vi}
##  
{ my $search = "trivuliari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trivuliari
##  	2  ==  trivuliari {vi} --> tribolare {vi} --> suffer {vi}
##  
{ my $search = "trivuliari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trucidari
##  	0  ==  trucidari {} --> <br> {} --> massacre {}
##  
{ my $search = "trucidari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc trunari
##  	0  ==  trunari {} --> tuonare {} --> thunder {}
##  
{ my $search = "trunari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc truncari
##  	0  ==  truncari {} --> interrompere {} --> break off {}
##  
{ my $search = "truncari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc truncari
##  	2  ==  truncari {} --> interrompere {} --> interrupt {}
##  
{ my $search = "truncari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc truncari
##  	3  ==  truncari {} --> interrompere {} --> terminate {}
##  
{ my $search = "truncari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc truppicari
##  	0  ==  truppicari {} --> <br> {} --> stumble {}
##  
{ my $search = "truppicari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc truppiddiari
##  	1  ==  truppiddiari {} --> camminare saltellando {} --> walk hopping {}
##  
{ my $search = "truppiddiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tuculiari
##  	0  ==  tuculiari {} --> dimenare {} --> rouse {}
##  
{ my $search = "tuculiari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tuculiari
##  	1  ==  tuculiari {} --> muovere {} --> rouse {}
##  
{ my $search = "tuculiari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tuculiari
##  	2  ==  tuculiari {} --> scuotere {} --> rouse {}
##  
{ my $search = "tuculiari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tuculiari
##  	3  ==  tuculiari {} --> dimenare {} --> stir {}
##  
{ my $search = "tuculiari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tuculiari
##  	4  ==  tuculiari {} --> muovere {} --> stir {}
##  
{ my $search = "tuculiari" ; my $index = 4 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tuculiari
##  	5  ==  tuculiari {} --> scuotere {} --> stir {}
##  
{ my $search = "tuculiari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tuculiari
##  	6  ==  tuculiari {} --> dimenare {} --> wag {}
##  
{ my $search = "tuculiari" ; my $index = 6 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tuculiari
##  	7  ==  tuculiari {} --> muovere {} --> wag {}
##  
{ my $search = "tuculiari" ; my $index = 7 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tuculiari
##  	8  ==  tuculiari {} --> scuotere {} --> wag {}
##  
{ my $search = "tuculiari" ; my $index = 8 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc turnari
##  	0  ==  turnari {} --> ritornare {} --> begin again {}
##  
{ my $search = "turnari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc tèniri
##  	0  ==  tèniri {} --> tenere {} --> keep {}
##  
{ my $search = "tèniri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ubbidiri
##  	0  ==  ubbidiri {} --> obbedire {} --> consent {}
##  
{ my $search = "ubbidiri" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc ubblicari
##  	2  ==  ubblicari {} --> obbligare {} --> require {}
##  
{ my $search = "ubblicari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc urvicari
##  	0  ==  urvicari {} --> <br> {} --> bury {}
##  
{ my $search = "urvicari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc vagnari
##  	3  ==  vagnari {} --> bagnare {} --> wet {}
##  
{ my $search = "vagnari" ; my $index = 3 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu valiri
## 	0  ==  valiri {v} --> <br> {v} --> be worth {v}
## 	1  ==  valiri {v} --> <br> {v} --> value {v}
## 	2  ==  valiri {v} --> <br> {v} --> worth (be) {v}
for my $i (0..2) { 
    my $search = "valiri" ; 
    ${$dieli_sc{$search}[$i]}{"it_word"} = 'valere';
}

## $ ./query-dieli.pl sc strittu vanniari
## 	0  ==  vanniari {v} --> <br> {v} --> proclaim {v}
{  my $i = 0;
   my $search = "vanniari" ; 
   ${$dieli_sc{$search}[$i]}{"it_word"} = 'reclamizzare';
}

##  $ ./query-dieli.pl sc vangari
##  	0  ==  vangari {} --> vangare {} --> dig {}
##  
{ my $search = "vangari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc vastari
##  	1  ==  vastari {} --> sciupare {} --> spoil {}
##  
{ my $search = "vastari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu viaggiari
## 	0  ==  viaggiari {v} --> <br> {v} --> travel {v}
{ my $i = 0 ; 
  my $search = "viaggiari" ; 
  ${$dieli_sc{$search}[$i]}{"it_word"} = 'viaggiare';
}

##  $ ./query-dieli.pl sc virgugnari
##  	0  ==  virgugnari {} --> <br> {} --> be_ashamed {}
##  
{ my $search = "virgugnari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
  ${dieli_sc{$search}[$index]}{"en_word"} = "be ashamed";
}

##  $ ./query-dieli.pl sc virificari
##  	0  ==  virificari {} --> verificare {} --> audit {}
##  
{ my $search = "virificari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc virnizzari
##  	0  ==  virnizzari {vi} --> fare inverno {vi} --> be winter {vi}
##  
{ my $search = "virnizzari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc vulari
##  	0  ==  vulari {} --> volare {} --> fly {}
##  
{ my $search = "vulari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc vulari
##  	2  ==  vulari {} --> volare {} --> go by very quickly {}
##  
{ my $search = "vulari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc vurricari
##  	0  ==  vurricari {} --> seppellire {} --> bury {}
##  
{ my $search = "vurricari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc vuscari
##  	1  ==  vuscari {} --> guadagnare {} --> gain {}
##  
{ my $search = "vuscari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc vuscari
##  	2  ==  vuscari {} --> guadagnare {} --> make (money) {}
##  
{ my $search = "vuscari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc vutari
##  	1  ==  vutari {} --> volgere {} --> turn {}
##  
{ my $search = "vutari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc vutari
##  	2  ==  vutari {} --> voltare {} --> turn {}
##  
{ my $search = "vutari" ; my $index = 2 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc vutari
##  	5  ==  vutari {} --> volgere {} --> vote {}
##  
{ my $search = "vutari" ; my $index = 5 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc vutari
##  	6  ==  vutari {} --> voltare {} --> vote {}
##  
{ my $search = "vutari" ; my $index = 6 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu vutari
## 	0  ==  vutari {v} --> <br> {v} --> screw {v}
## 	1  ==  vutari {v} --> volgere {v} --> turn {v}
## 	2  ==  vutari {v} --> voltare {v} --> turn {v}
## 	3  ==  vutari {v} --> girare {v} --> turn {v}
## 	4  ==  vutari {v} --> votare {v} --> turn {v}
## 	5  ==  vutari {v} --> volgere {v} --> vote {v}
## 	6  ==  vutari {v} --> voltare {v} --> vote {v}
## 	7  ==  vutari {v} --> <br> {v} --> vote {v}
## 	8  ==  vutari {v} --> votare {v} --> vote {v}
for my $i (4,5,6) {
    my $search = "vutari";
    splice( @{$dieli_sc{$search}}, $i ,1);
}


##  $ ./query-dieli.pl sc zappari
##  	0  ==  zappari {} --> <br> {} --> hoe {}
##  
{ my $search = "zappari" ; my $index = 0 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

##  $ ./query-dieli.pl sc zappari
##  	1  ==  zappari {} --> zappare {} --> hoe {v}
##  
{ my $search = "zappari" ; my $index = 1 ; 
  $dieli_sc{$search}[$index] = replace_part( $dieli_sc{$search}[$index] , "v" ) ;
}

## $ ./query-dieli.pl sc strittu zittìri(si)
## 	0  ==  zittìri(si) {} --> tacere {} --> be quiet about {}
## 	1  ==  zittìri(si) {} --> tacere {} --> stop talking {}
delete( $dieli_sc{'zittìri(si)'} );
{ my $search = "zittirisi" ; 
  my %th ;  
  $th{"sc_word"} = $search          ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "tacere"         ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "be quiet about" ; $th{"en_part"} = "{v}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "zittirisi" ; 
  my %th ;  
  $th{"sc_word"} = $search          ; $th{"sc_part"} = "{v}" ;
  $th{"it_word"} = "tacere"         ; $th{"it_part"} = "{v}" ;
  $th{"en_word"} = "stop talking"   ; $th{"en_part"} = "{v}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

## $ ./query-dieli.pl sc strittu acidduzzi
##      0  ==  acidduzzi {} --> uccellini {} --> birds {}
##      1  ==  acidduzzi {} --> <br> {} --> little birds {}
delete( $dieli_sc{'acidduzzi'} );
{ my $search = "acidduzzi" ; 
  my %th ;  
  $th{"sc_word"} = $search         ; $th{"sc_part"} = "{mpl}";
  $th{"it_word"} = "uccellini"     ; $th{"it_part"} = "{mpl}";
  $th{"en_word"} = "birds"         ; $th{"en_part"} = "{pl}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}
{ my $search = "acidduzzi" ; 
  my %th ;  
  $th{"sc_word"} = $search         ; $th{"sc_part"} = "{mpl}";
  $th{"it_word"} = "uccellini"     ; $th{"it_part"} = "{mpl}";
  $th{"en_word"} = "little birds"  ; $th{"en_part"} = "{pl}" ;
  push( @{ $dieli_sc{$search} } , \%th ) ;
}

##  ${$dieli_sc{$search}[$i]}{"it_part"} = '{v}';
##  STOPPED HERE


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  make ENglish and ITalian dictionaries
my %dieli_en = make_en_dict( \%dieli_sc ) ;
my %dieli_it = make_it_dict( \%dieli_sc ) ;

##  store it all
nstore( \%dieli_sc , $dieli_sc_dict );
nstore( \%dieli_en , $dieli_en_dict );
nstore( \%dieli_it , $dieli_it_dict );

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  SUBROUTINES
##  ===========

sub replace_part {
    my $hashref = $_[0] ; 
    my $part    = $_[1] ; 
    
    ##  if the "word" field is empty (Dieli uses "<br>"), the part of speech should be empty too
    ##  issue occurs mostly with Italian, 
    ##  issue MUST NOT occur with Sicilian
    ${$hashref}{"sc_part"} = "{" . $part . "}" ; 
    ${$hashref}{"it_part"} = (${$hashref}{"it_word"} eq "<br>") ? "{}" : "{" . $part . "}" ; 
    ${$hashref}{"en_part"} = (${$hashref}{"en_word"} eq "<br>") ? "{}" : "{" . $part . "}" ; 

    return $hashref ;
}

sub make_en_dict {

    my %dieli_sc = %{ $_[0] } ;
    my %dieli_en ; 
    foreach my $sc_word ( sort keys %dieli_sc ) {	
	for my $i (0..$#{ $dieli_sc{$sc_word} }) {
	    if ( ! defined ${ $dieli_sc{$sc_word}}[$i] ) {
		my $blah = "do nothing";
	    } else {
		my %sc_hash = %{ ${ $dieli_sc{$sc_word}}[$i] } ; 
		if ($sc_hash{"en_word"} ne '<br>') {
		    push( @{ $dieli_en{$sc_hash{"en_word"}} } , \%sc_hash ) ; 
		}
	    }
	}
    }
    return %dieli_en ;
}

sub make_it_dict {
    
    my %dieli_sc = %{ $_[0] } ;
    my %dieli_it ; 
    foreach my $sc_word ( sort keys %dieli_sc ) {	
	for my $i (0..$#{ $dieli_sc{$sc_word} }) {
	    if ( ! defined ${ $dieli_sc{$sc_word}}[$i] ) {
		my $blah = "do nothing";
	    } else {
		my %sc_hash = %{ ${ $dieli_sc{$sc_word}}[$i] } ; 
		if ($sc_hash{"it_word"} ne '<br>') {
		    push( @{ $dieli_it{$sc_hash{"it_word"}} } , \%sc_hash ) ; 
		}
	    }
	}
    }
    return %dieli_it ;
}

