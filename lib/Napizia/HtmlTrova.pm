package Napizia::HtmlTrova;

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
no warnings qw(uninitialized numeric void);

use utf8;

sub conjugate { Napizia::PosTools::conjugate($_[0], $_[1], $_[2]);}
sub rid_accents { Napizia::TextTools::rid_accents( $_[0] );}

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ("mk_hdinfo","mk_form","mk_wdheader","get_sample_author",
	       "find_poem_matches","mk_notex_list","strip_line");

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  make HTML header
sub mk_hdinfo {

    ##  the words, title and author searched for
    my $palori_str = ( ! defined $_[0] ) ? "" : $_[0] ;
    my $autori_str = ( ! defined $_[1] ) ? "" : $_[1] ;
    my $titulu_str = ( ! defined $_[2] ) ? "" : $_[2] ;

    $palori_str = ( $palori_str !~ /[a-z]/ ) ? "" : "pa: " . $palori_str . ", ";
    $autori_str = ( $autori_str !~ /[a-z]/ ) ? "" : "au: " . $autori_str . ", ";
    $titulu_str = ( $titulu_str !~ /[a-z]/ ) ? "" : "ti: " . $titulu_str . ", ";

    ##  create search string
    my $search = $palori_str . $titulu_str . $autori_str ;
    $search =~ s/, $//;
    $search =~ s/^ //;
    $search =~ s/ $//;
    
    ##  text to insert into the title
    my $title_insert = ( $search eq "" ) ? "" : $search .' :: ';
  
    ##  and here's the TITLE
    my $title_concat = $title_insert . 'Trova na Palora :: Napizia';

    ##  prepare the description
    my $descrip ;
    if ( $title_insert ne "") {
	$descrip .= 'puisia e pruverbi pi: '. $search .', ';
	$descrip .= 'poetry and proverbs for: '. $search ;
    } else {
	$descrip .= 'Attrova na palora o na frasi ntra li pruverbi e versi di puisia. ';
	$descrip .= 'Find a word or phrase within the proverbs and verses of poetry.';
    }
    
    ##  form the URL
    my $urlref = 'https://dizziunariu.napizia.com/trova/';
    if ( $palori_str !~ /[a-z]/ && $autori_str !~ /[a-z]/ && $titulu_str !~ /[a-z]/ ) {
	my $blah = "do nothing";
    } else {
	##  searches to add to the URL
	my $addtourl ;
	$addtourl .= ( $palori_str !~ /[a-z]/ ) ? "" : '&palori='. $palori_str ;
	$addtourl .= ( $autori_str !~ /[a-z]/ ) ? "" : '&autori='. $autori_str ;
	$addtourl .= ( $titulu_str !~ /[a-z]/ ) ? "" : '&titulu='. $titulu_str ;
	$addtourl =~ s/^\&/?/;
	
	##  add them to the URL
	$urlref .= $addtourl ;
    }
    
    ##  prepare hash to return
    my %otinfo = (
	"card_title"    => $title_concat ,
	"card_descrip"  => $descrip ,
	"card_url"      => $urlref
	);
    
    ##  and return it
    return %otinfo ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  make form
sub mk_form {

    ##  embedding and search
    my $in_palori = $_[0];
    my $in_autori = $_[1];
    my $in_titulu = $_[2]; 
    
    my $ottxt ;
    # $ottxt .= '<form enctype="multipart/form-data" action="/trova/" method="post">' . "\n" ;
    $ottxt .= '<form enctype="multipart/form-data" action="/trova/" method="get">' . "\n" ;
    $ottxt .= '<table style="max-width:500px;"><tbody>' ."\n";
    $ottxt .= '<tr><td><small>palora</small></td>' ."\n";
    $ottxt .= '<td colspan="2">' ."\n";
    $ottxt .= '<input type=text name="palori" value="'. $in_palori .'" size=27 maxlength=48>' ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '<tr><td><small>tìtulu</small></td>' ."\n";
    $ottxt .= '<td colspan="2">' ."\n";
    $ottxt .= '<input type=text name="titulu" value="'. $in_titulu .'" size=27 maxlength=48>' ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '<tr><td><small>autori</small></td>' ."\n";
    $ottxt .= '<td>' ."\n";
    $ottxt .= '<input type=text name="autori" value="'. $in_autori .'" size=15 maxlength=24>' ; 
    $ottxt .= '</td>' . "\n" ;
    $ottxt .= '<td align="right">' . '<input type="submit" value="Attrova">' . "\n" ;
    ## $ottxt .= '<input type=reset value="Clear Form">' . "\n" ; 
    $ottxt .= '</td></tr>' . "\n" ;
    $ottxt .= '</tbody></table>' . "\n" ;
    $ottxt .= '</form>' . "\n" ;
        
    return $ottxt ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  make word header
sub mk_wdheader {

    ##  inputs for word header
    my $palora =   $_[0];
    my %vnotes = %{$_[1]};
    my $vbconj =   $_[2];
    
    ##  are we working with a verb?
    my %wdhash ;
    my $isverb = ( ! defined $vnotes{ $palora }{verb}     && 
		   ! defined $vnotes{ $palora }{reflex}   && 
		   ! defined $vnotes{ $palora }{prepend}  ) ? "false" : "true" ;
    if ( $isverb eq "true" ) {
	%wdhash = conjugate( $palora , \%vnotes , $vbconj ) ; 
    }
    
    ##  which word do we display?
    ( my $display = $palora ) =~ s/_([a-z])+$//;
    $display = ( ! defined $wdhash{inf} ) ? $display : $wdhash{inf} ;
    $display = ( ! defined $vnotes{$palora}{display_as} ) ? $display : $vnotes{$palora}{display_as} ;
    
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
	    
    ##  HEADER
    my $header;
    $header .= '<p><b><a href="/chiu/?' . 'palora=' . $palora . '">' ; 
    $header .= $display . '</a></b>&nbsp;&nbsp;{'. $part_speech .'}</p>'."\n";

    return $header;
}

##  get stripped sample and author
sub get_sample_author {

    my $line = $_[0];
    $line = strip_line( $line );
    
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
    
    ##  return stripped sample, author and title
    return( $sample , $author , $title );
}

##  find poem/proverb matches
sub find_poem_matches {

    my $palora     =   $_[0];
    my $autori_str =   $_[1];
    my $palori_str =   $_[2];
    my $titulu_str =   $_[3];
    my $typeof     =   $_[4];  ## "poetry", "prose", or "proverb"
    my %vnotes     = %{$_[5]};
    
    my @poem_matches;
        
    if ( ! defined $vnotes{$palora}{$typeof} ) {
	my $blah = "do nothing" ;
    } else {
	
	my @poetry  = @{ $vnotes{$palora}{$typeof} };
	foreach my $poem (@poetry) {
	    ##  get stripped sample and author
	    my ( $sample , $author , $title ) = get_sample_author( $poem );
	    
	    ##  fix "la mattina", "di marco" and "de vita"
	    $author =~ s/la mattina/la~mattina/g;
	    $author =~ s/di marco/di~marco/g;
	    $author =~ s/de vita/de~vita/g;

	    ##  add spacing
	    my @au_sch = split(' ',$author);
	    $author = ' ' . join( ' | ' , @au_sch ) . ' ';
	    $sample = ' ' . $sample . ' ';
	    $title  = ' ' . $title  . ' ';
	    
	    ##  create author search string
	    my $autori_new = $autori_str;
	    $autori_new =~ s/la mattina/la~mattina/g;
	    $autori_new =~ s/di marco/di~marco/g;
	    $autori_new =~ s/de vita/de~vita/g;
	    my @autori_list = split(' ',$autori_new );
	    
	    ##  create word search string
	    my $palori_new = ' ' . $palori_str . ' ';

	    ##  create title search string
	    my $titulu_new = ' ' . $titulu_str . ' ';
		    
	    ##  search sample and author
	    if ( $autori_str ne "" && $palori_str ne "" && $titulu_str ne "" ) {
		foreach my $author_new (@autori_list) {
		    my $author_sch = ' ' . $author_new . ' ';
		    if ( $author_sch =~ /$author/ && $sample =~ /$palori_new/ && $title =~ /$titulu_new/ ) {
			push( @poem_matches , $poem );
		    }
		}

	    } elsif ( $autori_str ne "" && $titulu_str ne "" ) {
		foreach my $author_new (@autori_list) {
		    my $author_sch = ' ' . $author_new . ' ';
		    if ( $author_sch =~ /$author/ && $title =~ /$titulu_new/ ) {
			push( @poem_matches , $poem );
		    }
		}

	    } elsif ( $autori_str ne "" && $palori_str ne "" ) {
		foreach my $author_new (@autori_list) {
		    my $author_sch = ' ' . $author_new . ' ';
		    if ( $author_sch =~ /$author/ && $sample =~ /$palori_new/ ) {
			push( @poem_matches , $poem );
		    }
		}

	    } elsif ( $palori_str ne "" && $titulu_str ne "" ) {
		if ( $sample =~ /$palori_new/ && $title =~ /$titulu_new/ ) {
		    push( @poem_matches , $poem );
		}

	    } elsif ( $titulu_str ne "" ) {
		if ( $title =~ /$titulu_new/ ) {
		    push( @poem_matches , $poem );
		}
		
	    } elsif ( $palori_str ne "" ) {
		if ( $sample =~ /$palori_new/ ) {
		    push( @poem_matches , $poem );
		}		       			
	    } elsif ( $autori_str ne "" ) {
		foreach my $author_new (@autori_list) {	
		    my $author_sch = ' ' . $author_new . ' ';
		    if ( $author_sch =~ /$author/ ) {
			push( @poem_matches , $poem );
		    }
		}
	    }
	    
	}
    }

    ##  return matching poems/proverbs
    return @poem_matches ;
}

##  make list of examples
sub mk_notex_list {

    my $typeof =     $_[0] ;
    my @inarray = @{ $_[1] } ;

    my $othtml ;

    ## $othtml .= '<div class="transconj">' ."\n"; 
    $othtml .= '<p style="margin-bottom: 0.25em;"><i>' . $typeof . '</i></p>' ."\n";
    $othtml .= '<ul style="margin-top: 0.25em;">' ."\n";
    foreach my $line (@inarray) {

	##  clean up dashes
	$line =~ s/\-\-/\&ndash;/g;
	    
	##  append the line
	$othtml .= "<li>" . $line . "</li>" ."\n";
    }
    $othtml .= "</ul>" ."\n";
    ## $othtml .= "</div>" ."\n";
    
    return $othtml ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  strip line to (almost) lower-case letters only, removing unicode accents
##  but leave parenthesis, double quotes and commas (to identify sources)
sub strip_line {

    my $line    =  $_[0];

    ##  remove stuff
    $line =~ s/\n/ /g;
    $line =~ s/<br>/ /g;
    $line =~ s/<i>/ /g;
    $line =~ s/<\/i>/ /g;
    $line =~ s/&nbsp;/ /g;
    $line =~ s/&lpar;/ /g;
    $line =~ s/&rpar;/ /g;
    $line =~ s/[\[\]\{\}\+\=\'\-\*\/\#\|\%\@\$_\;\:\.\!\?]/ /g;
    $line =~ s/\d+/ /g;
    $line =~ s/’/ /g;

    ##  remove accents
    $line = rid_accents( $line ) ;

    ##  and make it all lower case
    $line = lc($line); 

    ##  remove anything that is not lower case letter, space or parenthesis, single quote or comma
    $line =~ s/[^\(\)\"\,a-z]/ /g;
    
    ##  remove excess spaces
    $line =~ s/\s+/ /g;

    ##  remove spaces from beginning and end
    $line =~ s/^ //;
    $line =~ s/ $//;
    
    ##  return the stripped line
    return $line ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

1;
