package Napizia::TextTools;

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

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ("scn_ucfirst","scn_ucfirst_trim",
	       "scn_lowercase","scn_lowercase_trim",
	       "rid_accents","fix_accents");

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub scn_ucfirst {

    my $word = $_[0];
    $word =~ s/^ //;
    $word =~ s/ $//;
    $word =~ s/^'//;
    $word = ucfirst( $word );
    $word =~ s/^à/À/;
    $word =~ s/^è/È/;
    $word =~ s/^ì/Ì/;
    $word =~ s/^ò/Ò/;
    $word =~ s/^ù/Ù/;
    return $word;
}

sub scn_ucfirst_trim {

    my $word = $_[0];
    $word = scn_ucfirst( $word );
    $word =~ s/ \(.*$//;
    return $word;
}

sub scn_lowercase {

    my $word = $_[0];
    $word =~ s/^ //;
    $word =~ s/ $//;
    $word =~ s/^'//;
    $word = lc( $word );
    $word =~ s/À/à/g;
    $word =~ s/È/è/g;
    $word =~ s/Ì/ì/g;
    $word =~ s/Ò/ò/g;
    $word =~ s/Ù/ù/g;
    return $word;
}

sub scn_lowercase_trim {

    my $word = $_[0];
    $word = scn_lowercase( $word );
    $word =~ s/ \(.*$//;
    return $word;
}

##  remove unicode accents from vowels
sub rid_accents {
    my $str = $_[0] ;
    
    ##  rid grave accents
    $str =~ s/\303\240/a/g; 
    $str =~ s/\303\250/e/g; 
    $str =~ s/\303\254/i/g; 
    $str =~ s/\303\262/o/g; 
    $str =~ s/\303\271/u/g; 
    $str =~ s/\303\200/A/g; 
    $str =~ s/\303\210/E/g; 
    $str =~ s/\303\214/I/g; 
    $str =~ s/\303\222/O/g; 
    $str =~ s/\303\231/U/g; 
    
    ##  rid acute accents
    $str =~ s/\303\241/a/g; 
    $str =~ s/\303\251/e/g; 
    $str =~ s/\303\255/i/g; 
    $str =~ s/\303\263/o/g; 
    $str =~ s/\303\272/u/g; 
    $str =~ s/\303\201/A/g; 
    $str =~ s/\303\211/E/g; 
    $str =~ s/\303\215/I/g; 
    $str =~ s/\303\223/O/g; 
    $str =~ s/\303\232/U/g; 
    
    ##  rid circumflex accents
    $str =~ s/\303\242/a/g; 
    $str =~ s/\303\252/e/g; 
    $str =~ s/\303\256/i/g; 
    $str =~ s/\303\264/o/g; 
    $str =~ s/\303\273/u/g; 
    $str =~ s/\303\202/A/g; 
    $str =~ s/\303\212/E/g; 
    $str =~ s/\303\216/I/g; 
    $str =~ s/\303\224/O/g; 
    $str =~ s/\303\233/U/g; 

    ##  rid diaeresis accents
    $str =~ s/\303\244/a/g;
    $str =~ s/\303\253/e/g;
    $str =~ s/\303\257/i/g;
    $str =~ s/\303\266/o/g;
    $str =~ s/\303\274/u/g;
    $str =~ s/\303\204/A/g;
    $str =~ s/\303\213/E/g;
    $str =~ s/\303\217/I/g;
    $str =~ s/\303\226/O/g;
    $str =~ s/\303\234/U/g;

    ##  Ç = "\303\207"
    ##  ç = "\303\247"
    $str =~ s/\303\207/C/g; 
    $str =~ s/\303\247/c/g; 


    ##  rid grave accents
    $str =~ s/à/a/g; 
    $str =~ s/è/e/g; 
    $str =~ s/ì/i/g; 
    $str =~ s/ò/o/g; 
    $str =~ s/ù/u/g; 
    $str =~ s/À/A/g; 
    $str =~ s/È/E/g; 
    $str =~ s/Ì/I/g; 
    $str =~ s/Ò/O/g; 
    $str =~ s/Ù/U/g; 
    
    ##  rid acute accents
    $str =~ s/á/a/g;
    $str =~ s/é/e/g;
    $str =~ s/í/i/g;
    $str =~ s/ó/o/g;
    $str =~ s/ú/u/g;
    $str =~ s/Á/A/g;
    $str =~ s/É/E/g;
    $str =~ s/Í/I/g;
    $str =~ s/Ó/O/g;
    $str =~ s/Ú/U/g;

    ##  rid circumflex accents
    $str =~ s/â/a/g;
    $str =~ s/ê/e/g;
    $str =~ s/î/i/g;
    $str =~ s/ô/o/g;
    $str =~ s/û/u/g;
    $str =~ s/Â/A/g;
    $str =~ s/Ê/E/g;
    $str =~ s/Î/I/g;
    $str =~ s/Ô/O/g;
    $str =~ s/Û/U/g;

    ##  rid diaeresis accents
    $str =~ s/ä/a/g;
    $str =~ s/ë/e/g;
    $str =~ s/ï/i/g;
    $str =~ s/ö/o/g;
    $str =~ s/ü/u/g;
    $str =~ s/Ä/A/g;
    $str =~ s/Ë/E/g;
    $str =~ s/Ï/I/g;
    $str =~ s/Ö/O/g;
    $str =~ s/Ü/U/g;

    ##  rid cacuminal C
    $str =~ s/Ç/C/g; 
    $str =~ s/ç/c/g; 

    ##  return the unaccented string
    return $str ;
}

##  try to repair unicode accents
sub fix_accents {
    
    my $str = $_[0] ;
    $str =~ s/(\240|\241|\242|\244|\250|\251|\252|\253|\254|\255|\256|\257|\262|\263|\264|\266|\271|\272|\273|\274|\200|\201|\202|\204|\210|\211|\212|\213|\214|\215|\216|\217|\222|\223|\224|\226|\231|\232|\233|\234)\303/\303$1/;
    return $str ;
}

1;
