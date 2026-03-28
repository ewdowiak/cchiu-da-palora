package Napizia::HtmlTraina;

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

sub scn_ucfirst { Napizia::TextTools::scn_ucfirst( $_[0] );}
sub scn_ucfirst_trim { Napizia::TextTools::scn_ucfirst_trim( $_[0] );}
sub scn_lowercase { Napizia::TextTools::scn_lowercase( $_[0] );}
sub scn_lowercase_trim { Napizia::TextTools::scn_lowercase_trim( $_[0] );}
sub rid_accents { Napizia::TextTools::rid_accents( $_[0] );}
sub fix_accents { Napizia::TextTools::fix_accents( $_[0] );}

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ("make_link","make_alfa_index","make_alfa_welcome",
    "make_alfa_coll","mk_amkcontent","print_traina","mk_topinfo");

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
    $othtml .= '<a href="/traina/?';
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
	$othtml .= '<a href="/traina/?coll=' . $collname .'">';
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
    $prev_page = ( $coll eq "alfa_p000"  )  ? undef : 'alfa_p' . sprintf( "%03d" , $prev_page - 1 ); ## subtract one
    $next_page = ( $next_page eq $nupages ) ? undef : 'alfa_p' . sprintf( "%03d" , $next_page ); ## add nothing

    ##  create navigation
    my $navigation ;
    $navigation .= '  <!-- begin row div -->' . "\n";
    $navigation .= '  <div class="row">' . "\n";
    $navigation .= "\n";
    ## $navigation .= '    <div class="col-4 col-m-4 vanish">' . "\n";
    $navigation .= '    <div class="col-4 col-m-4">' . "\n";
    if ( ! defined $prev_page ) { my $blah = "do nothing"; } else { 
	my $prev_title = $lists{$prev_page}{title} ;
	$navigation .= '<p class="zero" style="text-align: left;">&lt;&lt;&nbsp; ' ;
	$navigation .= '<a href="/traina/?coll=' . $prev_page . '">' . $prev_title . '</a>'; 
	$navigation .= '</p>' . "\n";
    }
    $navigation .= '    </div>' . "\n";
    $navigation .= "\n";
    $navigation .= '    <div class="col-4 col-m-4">' . "\n";
    $navigation .= '      <p class="zero" style="text-align: center;">' . "\n";
    $navigation .= '	    <a href="/traina/">ìnnici</a>' . "\n";
    $navigation .= '      </p>' . "\n";
    $navigation .= '    </div>' . "\n";
    $navigation .= "\n";
    ## $navigation .= '    <div class="col-4 col-m-4 vanish">' . "\n";
    $navigation .= '    <div class="col-4 col-m-4">' . "\n";
    if ( ! defined $next_page ) { my $blah = "do nothing"; } else { 
	my $next_title = $lists{$next_page}{title} ;
	$navigation .= '<p class="zero" style="text-align: right;">' . "\n";
	$navigation .= '<a href="/traina/?coll=' . $next_page . '">' . $next_title . '</a>';
	$navigation .= ' &nbsp;&gt;&gt;</p>' . "\n";
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
    my $before   =   $_[3];
    my $after    =   $_[4];

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
		$edited =~ s/<a href="\#/<a href="\/traina\/\?palora=/g;
	    }
	    ##  add definition
	    $othtml .= $edited;
	    
	} else {

	    ##  multiple paragraphs
	    $traina_entry =~ s/(^.*<\/b>\.?)/$1 _SPLIT_ /;
	    my @entry_parts = split( /_SPLIT_/ , $traina_entry );

	    ##  get heading
	    my $heading = $entry_parts[0];
	    $heading =~ s/^<p>//;

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
		    $edited =~ s/<a href="\#/<a href="\/traina\/\?palora=/g;
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
    $navigation .= '  <!-- begin row div -->'."\n";
    $navigation .= '  <div class="row">'."\n";

    ## $navigation .= '    <div class="col-4 col-m-4 vanish">'."\n";
    $navigation .= '    <div class="col-4 col-m-4">'."\n";
    if ( ! defined $before ) {
	my $blah = "do nothing";
    } else {
	$navigation .= '      <p class="zero" style="text-align: left;">&lt;&lt;&nbsp; ';
	$navigation .= '<a href="/traina/?palora='. $before .'">'. $before .'</a></p>'."\n";
    }
    $navigation .= '    </div>'."\n";

    $navigation .= '    <div class="col-4 col-m-4">'."\n";
    $navigation .= '      <p class="zero" style="text-align: center;">'."\n";
    $navigation .= '	    <a href="/traina/">ìnnici</a>'."\n";
    $navigation .= '      </p>'."\n";
    $navigation .= '    </div>'."\n";

    ## $navigation .= '    <div class="col-4 col-m-4 vanish">'."\n";
    $navigation .= '    <div class="col-4 col-m-4">'."\n";
    if ( ! defined $after ) {
	my $blah = "do nothing";
    } else {
	$navigation .= '      <p class="zero" style="text-align: right;">';
	$navigation .= '<a href="/traina/?palora='. $after .'">'. $after .'</a> &nbsp;&gt;&gt;</p>'."\n";
    }
    $navigation .= '    </div>'."\n";

    $navigation .= '  </div>'."\n";
    $navigation .= '  <!-- end row div -->'."\n";

    ##  append navigation
    $othtml .= $navigation;

    ##  return it all!
    return $othtml;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub mk_topinfo {

    my $headword = $_[0];
    my $collectn = $_[1];

    ##  prepare the description and title
    my $descrip ;
    my $title_concat ;
    
    if ( (! defined $headword || $headword eq "") && (! defined $collectn || $collectn eq "") ) {
	$descrip .= 'lu dizziunariu di Antonio Traina.';
	$title_concat = 'Dizziunariu Traina :: Napizia';
	
    } elsif ( $headword ne "" ) {
	$descrip .= $headword .' ntô dizziunariu di Antonio Traina.';
	$title_concat = $headword .' :: Dizziunariu Traina :: Napizia';

    } elsif ( $collectn =~ /^alfa_p[0-2][0-9][0-9]$/ ) {
	my $pnum = $collectn;
	$pnum =~ s/^alfa_//;
	$descrip .= 'ìnnici '. $pnum .' dû dizziunariu di Antonio Traina.';
	$title_concat = 'ìnnici '. $pnum .' dû Dizziunariu Traina :: Napizia';
	
    } else {
	$descrip .= 'lu dizziunariu di Antonio Traina.';
	$title_concat = 'Dizziunariu Traina :: Napizia';
    }
    
    ##  form the URL
    my $urlref = 'https://dizziunariu.napizia.com/traina/';
    if ( ! defined $headword || $headword eq "" ) {
	my $blah = "do nothing";

    } elsif ( $headword =~ /^ìnnici p/ ) {

	##  form collection key
	my $collection = $headword ;
	$headword =~ s/^ìnnici p/alfa_p/;
	
	##  collection to add to the URL
	my $addtourl = '?coll='. $headword ;
	$urlref .= $addtourl ;

    } else {
	##  search to add to the URL
	my $addtourl = '?palora='. $headword ;
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

1;
