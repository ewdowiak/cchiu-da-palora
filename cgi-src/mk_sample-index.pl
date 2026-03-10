#!/usr/bin/env perl

##  Perl script to create storable index of poetry and proverbs
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

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

use strict;
#use warnings;

use utf8;

use Storable qw( retrieve nstore ) ;
#{   no warnings;             
    $Storable::Deparse = 1;  
    ## $Storable::Eval    = 1;  
#}

use lib "../cgi-lib";
use Napizia::TextTools;
use Napizia::Utils;
use Napizia::HtmlTrova;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  input file -- retrieve the vocabulary hash
my $vnhash = retrieve('../cgi-lib/vocab-notes' );
my %vnotes = %{ $vnhash } ;

##  output file -- store the samples index
my $otfile = "../cgi-lib/samples-index" ;

##  hashes to store authors, words, titles and subroutines
my %smword ;
my %smauth ;
my %smtitle ;
# my %smsubs ;
# $smsubs{strip_line}  = \&strip_line;
# $smsubs{rid_accents} = \&rid_accents;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  MAIN LOOP
##  ==== ====

##  for each key, find words and authors to index
foreach my $key (sort keys %vnotes) {

    ##  get list of examples for each hash key
    my @examples ;

    ##  push poetry
    if ( ! defined $vnotes{$key}{poetry} ) { my $blah = "do nothing"; } else {
	push( @examples , @{ $vnotes{$key}{poetry} } );
    }

    ##  push prose
    if ( ! defined $vnotes{$key}{prose} ) { my $blah = "do nothing"; } else {
	push( @examples , @{ $vnotes{$key}{prose} } );
    }

    ##  push proverbs
    if ( ! defined $vnotes{$key}{proverb} ) { my $blah = "do nothing"; } else {
	push( @examples , @{ $vnotes{$key}{proverb} } );
    }

    ## ##  skip examples for right now
    ## if ( ! defined $vnotes{$key}{notex} ) { my $blah = "do nothing"; } else {
    ##	   push( @examples , @{ $vnotes{$key}{notex} } );
    ## }

    ##  find words and authors to index
    foreach my $example (@examples) {
	my $line = $example;
	
	##  strip line to lower case letters and parenthesis
	$line = strip_line( $line );
	
	##  identify words and authors to index
	my ( $words_ref , $authors_ref , $titles_ref ) = find_words_authors( $line );
	
	##  push CDP hash key onto the WORD array
	foreach my $word (@{$words_ref}) {
	    push( @{ $smword{$word} } , $key );
	}

	##  push CDP hash key onto the AUTHOR array
	foreach my $author (@{$authors_ref}) {
	    push( @{ $smauth{$author} } , $key );
	}

	##  push CDP hash key onto the TITLE array
	foreach my $title (@{$titles_ref}) {
	    push( @{ $smtitle{$title} } , $key );
	}

    }
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  MAKE UNIQUE
##  ==== ======

##  make the lists of CDP keys unique
foreach my $word (sort keys %smword) {
    @{ $smword{$word} } = uniq( @{ $smword{$word} } );
}
foreach my $author (sort keys %smauth) {
    @{ $smauth{$author} } = uniq( @{ $smauth{$author} } );
}
foreach my $title (sort keys %smtitle) {
    @{ $smtitle{$title} } = uniq( @{ $smtitle{$title} } );
}


##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  STORE IT ALL
##  ===== == ===

##  store it all
nstore( { smword   => \%smword  , 
	  smauth   => \%smauth  ,
	  smtitle  => \%smtitle } , $otfile ); 

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  SUBROUTINES
##  ===========

# ##  tip of the hat to List::MoreUtils for this sub
# sub uniq { 
#     my %h;  
#     map { $h{$_}++ == 0 ? $_ : () } @_;
# }

##  get lists of words and authors
sub find_words_authors {

    my $line = $_[0];
    
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
    
    ##  make "fake array" with words four chars or more
    my @allwords = split( ' ' , $sample );
    my @words;
    foreach my $word (@allwords) {
	if ( length($word) >= 4 ) {
	    push( @words , $word );
	}
    }

    ##  make a title array
    my @titles;
    if ( $title =~ /[a-z]/ ) {
	my @alltitles = split( ' ' , $title );
	foreach my $ttword (@alltitles) {
	    if ( length($ttword) >= 4 ) {
		push( @titles , $ttword );
	    }
	}
    }
    
    ##  fix "la mattina", "di marco" and "de vita"
    $author =~ s/la mattina/la~mattina/g;
    $author =~ s/di marco/di~marco/g;
    $author =~ s/de vita/de~vita/g;
    
    my @authors = split( / / , $author );
    s/~/ /g for @authors;
    
    return( \@words , \@authors , \@titles );
}


# ##  strip line to (almost) lower-case letters only, removing unicode accents
# ##  but leave parenthesis, double quotes and commas (to identify sources)
# sub strip_line {
# 
#     my $line    =  $_[0];
#     my %smsubs = %{$_[1]};
# 
#     ##  remove stuff
#     $line =~ s/\n/ /g;
#     $line =~ s/<br>/ /g;
#     $line =~ s/<i>/ /g;
#     $line =~ s/<\/i>/ /g;
#     $line =~ s/&nbsp;/ /g;
#     $line =~ s/&lpar;/ /g;
#     $line =~ s/&rpar;/ /g;
#     $line =~ s/[\[\]\{\}\+\=\'\-\*\/\#\|\%\@\$_\;\:\.\!\?]/ /g;
#     $line =~ s/\d+/ /g;
#     $line =~ s/’/ /g;
# 
#     ##  remove accents
#     $line = $smsubs{rid_accents}( $line ) ;
# 
#     ##  and make it all lower case
#     $line = lc($line); 
# 
#     ##  remove anything that is not lower case letter, space or parenthesis, single quote or comma
#     $line =~ s/[^\(\)\"\,a-z]/ /g;
#     
#     ##  remove excess spaces
#     $line =~ s/\s+/ /g;
# 
#     ##  remove spaces from beginning and end
#     $line =~ s/^ //;
#     $line =~ s/ $//;
#     
#     ##  return the stripped line
#     return $line ;
# }


# ##  remove unicode accents
# sub rid_accents {
# 
#     my $line = $_[0]; 
#     
#     ##  rid grave accents
#     $line =~ s/\303\240/a/g; 
#     $line =~ s/\303\250/e/g; 
#     $line =~ s/\303\254/i/g; 
#     $line =~ s/\303\262/o/g; 
#     $line =~ s/\303\271/u/g; 
#     $line =~ s/\303\200/A/g; 
#     $line =~ s/\303\210/E/g; 
#     $line =~ s/\303\214/I/g; 
#     $line =~ s/\303\222/O/g; 
#     $line =~ s/\303\231/U/g; 
#     
#     ##  rid acute accents
#     $line =~ s/\303\241/a/g; 
#     $line =~ s/\303\251/e/g; 
#     $line =~ s/\303\255/i/g; 
#     $line =~ s/\303\263/o/g; 
#     $line =~ s/\303\272/u/g; 
#     $line =~ s/\303\201/A/g; 
#     $line =~ s/\303\211/E/g; 
#     $line =~ s/\303\215/I/g; 
#     $line =~ s/\303\223/O/g; 
#     $line =~ s/\303\232/U/g; 
#     
#     ##  rid circumflex accents
#     $line =~ s/\303\242/a/g; 
#     $line =~ s/\303\252/e/g; 
#     $line =~ s/\303\256/i/g; 
#     $line =~ s/\303\264/o/g; 
#     $line =~ s/\303\273/u/g; 
#     $line =~ s/\303\202/A/g; 
#     $line =~ s/\303\212/E/g; 
#     $line =~ s/\303\216/I/g; 
#     $line =~ s/\303\224/O/g; 
#     $line =~ s/\303\233/U/g; 
# 
#     ##  rid diaeresis accents
#     $line =~ s/\303\244/a/g;
#     $line =~ s/\303\253/e/g;
#     $line =~ s/\303\257/i/g;
#     $line =~ s/\303\266/o/g;
#     $line =~ s/\303\274/u/g;
#     $line =~ s/\303\204/A/g;
#     $line =~ s/\303\213/E/g;
#     $line =~ s/\303\217/I/g;
#     $line =~ s/\303\226/O/g;
#     $line =~ s/\303\234/U/g;
# 
#     ##  Ç = "\303\207"
#     ##  ç = "\303\247"
#     $line =~ s/\303\207/C/g; 
#     $line =~ s/\303\247/c/g; 
# 
#     ##  return the unaccented line
#     return $line ;
# }
