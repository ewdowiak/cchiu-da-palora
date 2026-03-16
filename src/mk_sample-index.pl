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

use lib "../lib";
use Napizia::TextTools;
use Napizia::Utils;
use Napizia::HtmlTrova;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  input file -- retrieve the vocabulary hash
my $vnhash = retrieve('../lib/stor/vocab-notes' );
my %vnotes = %{ $vnhash } ;

##  output file -- store the samples index
my $otfile = "../lib/stor/samples-index" ;

##  hashes to store authors, words, titles and subroutines
my %smword ;
my %smauth ;
my %smtitle ;

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
