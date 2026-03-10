package Napizia::HtmlTraina;

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

sub scn_ucfirst { Napizia::TextTools::scn_ucfirst( $_[0] );}
sub scn_ucfirst_trim { Napizia::TextTools::scn_ucfirst_trim( $_[0] );}
sub scn_lowercase { Napizia::TextTools::scn_lowercase( $_[0] );}
sub scn_lowercase_trim { Napizia::TextTools::scn_lowercase_trim( $_[0] );}
sub rid_accents { Napizia::TextTools::rid_accents( $_[0] );}
sub fix_accents { Napizia::TextTools::fix_accents( $_[0] );}

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ("make_link","make_alfa_index","make_alfa_welcome",
    "make_alfa_coll","mk_amkcontent","print_traina",
    "mk_foothtml","mk_amtophtml");

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  SUBROUTINES  for  TRAINA LIST
##  ===========  ===  ====== ====

##  make link with part of speech
sub make_link {
    
    my $palora   = $_[0] ; ##  hash key
    my $display  = $_[1] ; ##  what to display
    # my $partsp   = $_[2] ; ##  part of speech

    ##  link with part of speech
    my $othtml ;
    $othtml .= '<a href="/cgi-bin/traina.pl?';
    $othtml .= 'palora=' . $palora ;
    $othtml .= '">' . $display ; 
    $othtml .= '</a>'; ## ."\n";
    ## $othtml .= '</a> <small>{'. $partsp .'}</small>' ."\n";
    
    return $othtml ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  for welcome page -- make list of lists of words 
sub make_alfa_index {
    
    ##  list of words and list of subs
    my @amlist   = @{$_[0]}; 
    my $nupages  =   $_[1] ; ## NUmber of pages -- divisible by four
    
    my @amkeys = sort { lc(rid_accents($a)) cmp lc(rid_accents($b)) } (@amlist) ;

    ##  calculate keys per page
    my $keysperpage = int( $#amkeys / $nupages ) + 1 ; 

    ##  output to a hash with array of keys and with scalar of html
    my %othash ;

    for my $i (0..$nupages-1) {

	##  index where we start and end
	my $bgn = $i * $keysperpage ;
	my $end = $bgn + $keysperpage - 1 ; 
	if ( $end > $#amkeys ) { 
	    $end = $#amkeys ; 
	}
	
	##  get the first and last hash keys on this page
	my $first = lc(rid_accents($amkeys[$bgn]));
	my $last  = lc(rid_accents($amkeys[$end]));
	
	##  just give me the first four characters
	$first = substr( $first , 0 , 4 ) ; 
	$last  = substr( $last  , 0 , 4 ) ; 

	##  index info
	my $pagenum = sprintf( "%03d" , $i ) ; 
	my $collname = 'alfa_p'. $pagenum ; 
	my $title = $first . ' &ndash; '  . $last ; 
	
	my $othtml ;
	$othtml .= '<p class="cchiu" style="text-align: center;">'; 
	$othtml .= '<a href="/cgi-bin/traina.pl?coll=' . $collname .'">';
	$othtml .= $title .'</a></p>'."\n";

	##  send it to the hash
	@{$othash{$collname}{listkeys}} = @amkeys[$bgn..$end] ;
	$othash{$collname}{html}        = $othtml  ;
	$othash{$collname}{title}       = $title   ;
	$othash{$collname}{pagenum}     = $pagenum ;
    }
    ##  return the othash
    return %othash ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  for welcome page -- make html for list of lists on landing page
sub make_alfa_welcome {

    ##  list of words and list of subs
    my $amlsrf     =    $_[0]   ; 
    my $nupages    =    $_[1]   ; ## NUmber of pages -- divisible by four

    ##  make the lists
    my %lists = make_alfa_index( $amlsrf , $nupages ) ;

    ##  divide them into columns
    my @collkeys = sort( keys %lists ); 
    my $nupercol = int(($#collkeys + 1)/4);
    
    ## output to html
    my $othtml ;
    $othtml .= '<div><h3>';
    $othtml .= 'Nuovo vocabolario siciliano-italiano (1868)';
    $othtml .= '</h3></div>'."\n"; 

    $othtml .= '<div class="listall">'."\n"; 
    $othtml .= '<div class="row">'."\n"; 

    $othtml .= '<div class="rolltb">'."\n"; 
    $othtml .= '<div class="rolldk">'."\n"; 
    { 	my $colnum = 0 ;
	my $bgn = $colnum * $nupercol ;
	my $end = $bgn + $nupercol - 1 ;
	for my $i ($bgn..$end) {
	    $othtml .= $lists{$collkeys[$i]}{html} ; 
	}
    }
    $othtml .= '</div>'."\n"; 
    $othtml .= '<div class="rolldk">'."\n"; 
    { 	my $colnum = 1 ;
	my $bgn = $colnum * $nupercol ;
	my $end = $bgn + $nupercol - 1 ;
	for my $i ($bgn..$end) {
	    $othtml .= $lists{$collkeys[$i]}{html} ; 
	}
    }
    $othtml .= '</div>'."\n"; 
    $othtml .= '</div>'."\n"; 

    $othtml .= '<div class="rolltb">'."\n"; 
    $othtml .= '<div class="rolldk">'."\n"; 
    { 	my $colnum = 2 ;
	my $bgn = $colnum * $nupercol ;
	my $end = $bgn + $nupercol - 1 ;
	for my $i ($bgn..$end) {
	    $othtml .= $lists{$collkeys[$i]}{html} ; 
	}
    }
    $othtml .= '</div>'."\n"; 
    $othtml .= '<div class="rolldk">'."\n"; 
    { 	my $colnum = 3 ;
	my $bgn = $colnum * $nupercol ;
	my $end = $#collkeys ;
	for my $i ($bgn..$end) {
	    $othtml .= $lists{$collkeys[$i]}{html} ; 
	}
    }
    $othtml .= '</div>'."\n"; 
    $othtml .= '</div>'."\n"; 

    $othtml .= '</div>'."\n"; 
    $othtml .= '</div>'."\n"; 
 
    return $othtml ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  make one page of an alphabetical collection
sub make_alfa_coll {
    
    my $coll     =   $_[0];
    my $amlsrf   =   $_[1];
    my $nupages  =   $_[2];
    
    ##  make the lists
    my %lists = make_alfa_index( $amlsrf , $nupages );
    
    ##  let's split the print over four columns
    ##  keep words together by first two letters
    my @amkeys = sort( {lc(rid_accents($a)) cmp lc(rid_accents($b))} @{$lists{$coll}{listkeys}});
    my $amkqtr = int( $#amkeys / 4 ) ; 

    ##  first column
    my $amstart = 0 ; 
    my $amkidx = $amkqtr ; 
    my @amkone = @amkeys[$amstart..$amkidx] ; 

    ##  second column
    $amstart = $amkidx+1 ; 
    $amkidx += $amkqtr ; 
    my @amktwo = @amkeys[$amstart..$amkidx] ; 

    ##  third column
    $amstart = $amkidx+1 ; 
    $amkidx += $amkqtr ; 
    my @amktre = @amkeys[$amstart..$amkidx] ; 
    
    ##  fourth column
    $amstart = $amkidx+1 ; 
    my @amkqtt = @amkeys[$amstart..$#amkeys] ; 
      
    ##  create navigation tools
    ( my $prev_page  =  $coll ) =~ s/alfa_p//  ;                     ##  subtract nothing
    ( my $next_page  =  $coll ) =~ s/alfa_p//  ;  $next_page +=  1 ; ##  add one 
    $prev_page = ( $prev_page eq "00" ) ? undef : 'alfa_p' . sprintf( "%03d" , $prev_page - 1 ); ##  subtract one
    $next_page = ( $next_page eq $nupages ) ? undef : 'alfa_p' . sprintf( "%03d" , $next_page ); ##  add nothing

    ##  create navigation
    my $navigation ;
    $navigation .= '  <!-- begin row div -->' . "\n";
    $navigation .= '  <div class="row">' . "\n";
    $navigation .= "\n";
    $navigation .= '    <div class="col-4 col-m-4 vanish">' . "\n";
    if ( ! defined $prev_page ) { my $blah = "do nothing"; } else { 
	my $prev_title = $lists{$prev_page}{title} ;
	$navigation .= '<p class="zero" style="text-align: left;">&lt;&lt;&nbsp;' ;
	$navigation .= '<a href="/cgi-bin/traina.pl?coll=' . $prev_page . '">' . $prev_title . '</a>'; 
	$navigation .= '</p>' . "\n";
    }
    $navigation .= '    </div>' . "\n";
    $navigation .= "\n";
    $navigation .= '    <div class="col-4 col-m-4">' . "\n";
    $navigation .= '      <p class="zero" style="text-align: center;">' . "\n";
    $navigation .= '	    <a href="/cgi-bin/traina.pl">ìnnici</a>' . "\n";
    $navigation .= '      </p>' . "\n";
    $navigation .= '    </div>' . "\n";
    $navigation .= "\n";
    $navigation .= '    <div class="col-4 col-m-4 vanish">' . "\n";
    if ( ! defined $next_page ) { my $blah = "do nothing"; } else { 
	my $next_title = $lists{$next_page}{title} ;
	$navigation .= '<p class="zero" style="text-align: right;">' . "\n";
	$navigation .= '<a href="/cgi-bin/traina.pl?coll=' . $next_page . '">' . $next_title . '</a>';
	$navigation .= '&nbsp;&gt;&gt;</p>' . "\n";
    }
    $navigation .= '    </div>' . "\n";
    $navigation .= '    ' . "\n";
    $navigation .= '  </div>' . "\n";
    $navigation .= '  <!-- end row div -->' . "\n";

    
    ##  create the HTML output
    my $othtml ;
    $othtml .= '<div><h3 style="margin-top: 0em;">'; 
    $othtml .= 'Nuovo vocabolario siciliano-italiano (1868)';
    $othtml .= '</h3></div>'."\n"; 
    ##  start with navigation
    $othtml .= $navigation ; 
    ##  open the div
    $othtml .= '<div class="listall">'."\n"; 
    $othtml .= '<div class="row">'."\n"; 
    ##  open columns
    $othtml .= '<div class="rolltb">'."\n"; 
    $othtml .= '<div class="rolldk">'."\n"; 
    $othtml .= mk_amkcontent( \@amkone );
    $othtml .= '</div>'."\n";
    $othtml .= '<div class="rolldk">'."\n"; 
    $othtml .= mk_amkcontent( \@amktwo );
    $othtml .= '</div>'."\n";
    $othtml .= '</div>'."\n";
    $othtml .= '<div class="rolltb">'."\n"; 
    $othtml .= '<div class="rolldk">'."\n"; 
    $othtml .= mk_amkcontent( \@amktre );
    $othtml .= '</div>'."\n";
    $othtml .= '<div class="rolldk">'."\n"; 
    $othtml .= mk_amkcontent( \@amkqtt );
    $othtml .= '</div>'."\n";
    $othtml .= '</div>'."\n";
    ##  close columns
    $othtml .= '</div>'."\n"; 
    $othtml .= '</div>'."\n"; 
    ##  close the div
    $othtml .= $navigation ; 
    ##  end with navigation

    return $othtml ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  make columns for part of speech list
sub mk_amkcontent {

    my @amkargs = @{ $_[0] } ;
    
    ##  create the HTML
    my $hold_letter = "" ; 
    my $othtml ;
    
    ##  make each entry
    foreach my $palora (@amkargs) {
	##  prepare output
	my $link = make_link( $palora , $palora ); ## , $partsp );
	$othtml .= '<p class="cchiu">'. $link .'</p>'."\n"; 
    }
    
    return $othtml ; 
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  sub to print Traina definitions
sub print_traina {

    ##  pass in the hash key and vocabulary notes
    my $palora   =   $_[0];
    my @lineidxs = @{$_[1]};
    my %lt_hash  = %{$_[2]};

    ##  prepare output
    my $othtml;
    
    ##  begin DIV to limit width
    $othtml .= '<div class="transconj">'."\n";
    
    foreach my $lineidx (@lineidxs) {

	my $traina_entry = $lt_hash{$lineidx};
	
	##  print Traina entry
	if ( $traina_entry !~ /\|\|/ ) {

	    ##  edit Traina internal links
	    my $edited = $traina_entry;
	    if ( $edited !~ /<a href="\#">/ ) {
		$edited =~ s/<a href="\#/<a href="\/cgi-bin\/traina.pl\?palora=/g;
	    }
	    ##  add definition
	    $othtml .= $edited;
	    
	} else {

	    ##  multiple paragraphs
	    $traina_entry =~ s/(^.*<\/b>\.?)/$1 _SPLIT_ /;
	    my @entry_parts = split( /_SPLIT_/ , $traina_entry );

	    ##  get heading
	    my $heading = $entry_parts[0];

	    ##  get paragraphs
	    my $alldefs = $entry_parts[1];
	    $alldefs =~ s/^\s+\|\|//;
	    $alldefs =~ s/<\/p>$//;

	    ##  split paragraphs
	    my @list_defs = split( /\|\|/ , $alldefs );

	    ##  print heading and list of paragraphs    
	    $othtml .= '<p style="margin-bottom: 0.25em;">'. $heading .'</p>'."\n";
	    $othtml .= '<ul style="margin-top: 0.25em;">'."\n";
	    foreach my $def (@list_defs) {

		##  edit Traina internal links
		my $edited = $def;
		if ( $edited !~ /<a href="\#">/ ) {
		    $edited =~ s/<a href="\#/<a href="\/cgi-bin\/traina.pl\?palora=/g;
		}

		##  add to list
		$othtml .= '<li>'. $edited .'</li>'."\n";
	    }
	    $othtml .= '</ul>'."\n";
	}
    }

    ##  end DIV to limit width
    $othtml .= '</div>'."\n";
    
    ##  create navigation
    my $navigation ;
    $navigation .= '  <!-- begin row div -->' . "\n";
    $navigation .= '  <div class="row">' . "\n";

    $navigation .= '    <div class="col-4 col-m-4 vanish">' . "\n";
    $navigation .= '    </div>' . "\n";

    $navigation .= '    <div class="col-4 col-m-4">' . "\n";
    $navigation .= '      <p class="zero" style="text-align: center;">' . "\n";
    $navigation .= '	    <a href="/cgi-bin/traina.pl">ìnnici</a>' . "\n";
    $navigation .= '      </p>' . "\n";
    $navigation .= '    </div>' . "\n";

    $navigation .= '    <div class="col-4 col-m-4 vanish">' . "\n";
    $navigation .= '    </div>' . "\n";

    $navigation .= '  </div>' . "\n";
    $navigation .= '  <!-- end row div -->' . "\n";

    ##  append navigation
    $othtml .= $navigation;

    ##  return it all!
    return $othtml;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  navigation footer
sub mk_foothtml {

    ##  footer navigation
    my $footnav = $_[0] ; 

    ##  prepare output
    my $othtml ;

    open( my $fh_footnav , "<:encoding(utf-8)" , $footnav ); ## || die "could not read:  $footnav";
    while(<$fh_footnav>){ chomp;  $othtml .= $_ ."\n";};
    close $fh_footnav ;
    
    $othtml .= "  </body>"."\n";
    $othtml .= "</html>"."\n";

    return $othtml ;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub mk_amtophtml {

    my $topnav = $_[0] ;
    my $headword = $_[1] ;
    my $title_insert = $headword ;
    $title_insert = ( $title_insert ne "" ) ? $title_insert .' :: ' : "" ;

    my $ottxt ;
    ## $ottxt .= "Content-type: text/html\n\n";
    $ottxt .= '<!DOCTYPE html>'."\n";
    $ottxt .= '<html>'."\n";
    $ottxt .= '  <head>'."\n";

    my $title_concat = $title_insert . 'Dizziunariu Traina :: Napizia';
    $ottxt .= '    <title>'. $title_concat .'</title>'."\n";
    $ottxt .= '    <meta property="og:title" content="'. $title_concat .'">'."\n";
    $ottxt .= '    <meta name="twitter:title" content="'. $title_concat .'">'."\n";

    my $descrip ;
    if ( ! defined $headword || $headword eq "" ) {
	$descrip .= 'lu dizziunariu di Antonio Traina.';
    } elsif ( $headword =~ /^ìnnici p/ ) {
	$descrip .= $headword ." ";
	$descrip .= 'dû dizziunariu di Antonio Traina.';
    } else {
	$descrip .= $headword ." ";
	$descrip .= 'ntô dizziunariu di Antonio Traina.';
    }

    $ottxt .= '    <meta name="DESCRIPTION" content="'. $descrip .'">'."\n";
    $ottxt .= '    <meta property="og:description" content="'. $descrip .'">'."\n";
    $ottxt .= '    <meta name="twitter:description" content="'. $descrip .'">'."\n";

    ##  continue header
    $ottxt .= '    <meta name="KEYWORDS" content="Sicilian, language, dictionary">'."\n";

    ##  search information to add to URL
    if ( ! defined $headword || $headword eq "" ) {
	my $urlref = 'https://www.napizia.com/cgi-bin/traina.pl';
	$ottxt .= '    <meta property="og:url" content="'. $urlref .'">'."\n";
	$ottxt .= '    <meta name="twitter:url" content="'. $urlref .'">'."\n";

    } elsif ( $headword =~ /^ìnnici p/ ) {

	##  form collection key
	my $collection = $headword ;
	$headword =~ s/^ìnnici p/alfa_p/;
	
	##  search to add to the URL
	my $addtourl = '?coll='. $headword ;

	##  add it to the URL
	my $urlref = 'https://www.napizia.com/cgi-bin/traina.pl';
	$urlref .= $addtourl ;

	##  append to the HTML
	$ottxt .= '    <meta property="og:url" content="'. $urlref .'">'."\n";
	$ottxt .= '    <meta name="twitter:url" content="'. $urlref .'">'."\n";

    } else {
	##  search to add to the URL
	my $addtourl = '?palora='. $headword ;

	##  add it to the URL
	my $urlref = 'https://www.napizia.com/cgi-bin/traina.pl';
	$urlref .= $addtourl ;

	##  append to the HTML
	$ottxt .= '    <meta property="og:url" content="'. $urlref .'">'."\n";
	$ottxt .= '    <meta name="twitter:url" content="'. $urlref .'">'."\n";
    }

    ##  image, og:type and twitter card
    # my $logopic = 'https://www.napizia.com/config/napizia_logo-w-descrip.jpg';
    my $logopic = 'https://www.napizia.com/pics/antonino-traina.jpg';
    $ottxt .= '    <meta property="og:image" content="'. $logopic .'">'."\n";
    $ottxt .= '    <meta name="twitter:image" content="'. $logopic .'">'."\n";
    $ottxt .= '    <meta property="og:type" content="website">'."\n";
    $ottxt .= '    <meta name="twitter:site" content="@ProjectNapizia">'."\n";
    $ottxt .= '    <meta name="twitter:card" content="summary_large_image">'."\n";

    ##  continue header
    $ottxt .= '    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">'."\n";
    $ottxt .= '    <meta name="Author" content="Eryk Wdowiak">'."\n";
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/eryk.css">'."\n";
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/eryk_theme-blue.css">'."\n";
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/eryk_widenme.css">'."\n";
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/cchiu_forms.css">'."\n";

    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/font-awesome.min.css">'."\n";
    $ottxt .= '    <link rel="stylesheet" type="text/css" href="/css/w3-fa-styles.css">'."\n";

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
    $ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    $ottxt .= '          title="Trova na Palora"'."\n";
    $ottxt .= '          href="https://www.napizia.com/pages/sicilian/search/trova-palora.xml">'."\n";
    #$ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    #$ottxt .= '          title="Cosine Sim Skipgram"'."\n";
    #$ottxt .= '          href="https://www.napizia.com/pages/sicilian/search/cosine-sim_skip.xml">'."\n";
    #$ottxt .= '    <link rel="search" type="application/opensearchdescription+xml"'."\n";
    #$ottxt .= '          title="Cosine Sim CBOW"'."\n";
    #$ottxt .= '          href="https://www.napizia.com/pages/sicilian/search/cosine-sim_cbow.xml">'."\n";
    $ottxt .= '    <link rel="icon" type="image/png" href="/config/napizia-icon.png">'."\n";
    $ottxt .= '    <meta name="viewport" content="width=device-width, initial-scale=1">'."\n";

    ##  extra CSS
    $ottxt .= '    <style>'."\n";
    
    ##  DIV -- for top and bottom borders
    $ottxt .= '      div.btop { background-color: rgb(255, 255, 204);'."\n"; 
    $ottxt .= '                 width: 80%;  margin: 0em auto 0em auto;'."\n";
    $ottxt .= '                 padding: 7px 0px 7px 0px;'."\n";
    $ottxt .= '                 border-top: 1px solid rgb(2, 2, 102);}'."\n";

    $ottxt .= '      @media only screen and (max-width: 500px) { '."\n";
    $ottxt .= '          div.btop { width: 95%; }'."\n";
    $ottxt .= '      }'."\n";
    $ottxt .= '      div.bbot { border-bottom: 1px solid rgb(2, 2, 102); }'."\n";
    $ottxt .= '      div.bside { border-left: 1px solid rgb(2, 2, 102);'."\n";
    $ottxt .= '                  border-right: 1px solid rgb(2, 2, 102); }'."\n";
    
    ## ##  zero and half paragraph spacing
    ## ##  now handled by "eryk_widenme.css"
    ## $ottxt .= '      p.zero { margin-top: 0em; margin-bottom: 0em; }'."\n";
    ## $ottxt .= '      p.half { margin-top: 0.5em; margin-bottom: 0.5em; }'."\n";

    ##  form text -- larger, different font
    $ottxt .= '      p.formtext { font-size: 1.05em; font-family: Arial, "Liberation Sans", sans-serif; }'."\n";

    ##  DIV -- "tbleft", "tbright" and center them on small screens
    $ottxt .= '      @media only screen and (min-width: 480px) { '."\n";
    $ottxt .= '          div.tbright { text-align: right; }'."\n";
    $ottxt .= '      }'."\n";
    $ottxt .= '      @media only screen and (min-width: 480px) { '."\n";
    $ottxt .= '          div.tbleft { text-align: left; }'."\n";
    $ottxt .= '      }'."\n";
    $ottxt .= '      @media only screen and (max-width: 479px) { '."\n";
    $ottxt .= '          div.tbright, div.tbleft { text-align: center; }'."\n";
    $ottxt .= '      }'."\n";

    ##  DIV -- translations and conjugations
    $ottxt .= '      div.transconj { position: static; margin: auto; width: 50%;}'."\n";
    $ottxt .= '      @media only screen and (max-width: 835px) { '."\n";
    $ottxt .= '          div.transconj { position: relative; margin: auto; width: 90%;}'."\n";
    $ottxt .= '      }'."\n";

    ##  for the lists of words
    $ottxt .= '      p.cchiu { margin-top: 0.1em; margin-bottom: 0.1em; }'."\n";
    $ottxt .= '      @media only screen and (max-width: 600px) {'."\n";
    $ottxt .= '          p.cchiu { margin-top: 0.5em; margin-bottom: 0.5em; }'."\n";
    $ottxt .= '      }'."\n";
    
    ## ##  DIV -- suggestions
    ## ##  now handled by "eryk_widenme.css"
    ## $ottxt .= '      div.cunzigghiu { position: relative; margin: auto; width: 50%;}'."\n";
    ## $ottxt .= '      @media only screen and (max-width: 835px) { '."\n";
    ## $ottxt .= '          div.cunzigghiu { position: relative; margin: auto; width: 90%;}'."\n";
    ## $ottxt .= '      }'."\n";

    ## ##  spacing for second column of Dieli collections
    ## ##  now handled by "eryk_widenme.css"
    ## $ottxt .= '    ul.ddcoltwo { margin-top: 0em; }'."\n";
    ## $ottxt .= '    @media only screen and (min-width: 600px) { '."\n";
    ## $ottxt .= '        ul.ddcoltwo { margin-top: 2.25em; }'."\n";
    ## $ottxt .= '    }'."\n";

    ##  close CSS -- close head
    $ottxt .= '    </style>'."\n";
    $ottxt .= '  </head>'."\n";
    $ottxt .= '  <body>'."\n";

    open( my $fh_topnav , "<:encoding(utf-8)" , $topnav ); ## || die "could not read:  $topnav";
    while(<$fh_topnav>){ chomp;  $ottxt .= $_ ."\n"; };
    close $fh_topnav ;

    $ottxt .= '  <!-- begin row div -->'."\n";
    $ottxt .= '  <div class="row">'."\n";
    $ottxt .= '    <div class="col-m-12 col-12">'."\n";
    $ottxt .= '      <h1 style="margin-bottom: 0.5em;">Dizziunariu Traina</h1>'."\n";
    ## $ottxt .= '      <h2>di Eryk Wdowiak</h2>'."\n";
    $ottxt .= '    </div>'."\n";
    $ottxt .= '  </div>'."\n";
    $ottxt .= '  <!-- end row div -->'."\n";
    $ottxt .= '  '."\n";
    $ottxt .= '  <!-- begin row div -->'."\n";
    $ottxt .= '  <div class="row">'."\n";
    
    return $ottxt ;
}


1;
