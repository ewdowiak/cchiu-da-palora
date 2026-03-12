#!/usr/bin/env perl

##  "trova-palora.pl" -- queries the samples index
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
#use warnings;

use utf8;

use Storable qw( retrieve ) ;
#{   no warnings;             
    ## $Storable::Deparse = 1;  
    $Storable::Eval    = 1;  
#}

use URI::Escape;

use lib "/home/eryk/perl5/lib/perl5" , "../cgi-lib";
use Mojolicious::Lite -signatures;

# use lib "../cgi-lib";
use Napizia::TextTools;
use Napizia::PosTools;
use Napizia::Utils;
use Napizia::HtmlTrova;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  storables
my $samples_idx = '../cgi-lib/samples-index';
my $vocab_notes = '../cgi-lib/vocab-notes';
my $verb_tools  = '../cgi-lib/verb-tools';

##  retrieve authors, words and subroutines
my $sm_ref  = retrieve( $samples_idx );
my %smword  = %{ $sm_ref->{smword} };
my %smauth  = %{ $sm_ref->{smauth} };
my %smtitle = %{ $sm_ref->{smtitle} };

##  config
my $topnav_html = '../config/eryk2-topnav.html';
my $navbar_html = '../config/eryk2-navbar.html';

##  example to offer
my $example;
$example .= '<p style="margin-top: 0.5em; margin-bottom: 0.25em;"><i>pi esempiu:</i></p>'."\n";
$example .= '<ul style="margin-top: 0.25em;">' ."\n";
$example .= '<li><a href="/cgi-bin/trova-palora.pl?palori=mari"><span class="code">mari</span></a></li>'."\n";
$example .= '<li><a href="/cgi-bin/trova-palora.pl?palori=acqua%20fimmini%20e%20focu"><span class="code">acqua '."\n";
$example .= ' fimmini e focu</span></a></li>' ."\n";
$example .= '</ul>' ."\n";

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

app->mode('production');

get '/' => sub ($c) {
    my $par_palori = $c->param('palori');
    my $par_autori = $c->param('autori');
    my $par_titulu = $c->param('titulu');
    my $output = mk_htmlpage( $par_palori , $par_autori , $par_titulu );
    $c->render(text => $output);
};

post '/' => sub ($c) {
    my $par_palori = $c->param('palori');
    my $par_autori = $c->param('autori');
    my $par_titulu = $c->param('titulu');
    my $output = mk_htmlpage( $par_palori , $par_autori , $par_titulu );
    $c->render(text => $output);
};

app->start;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

sub mk_htmlpage{ 

    ##  in arguments
    my $par_palori = $_[0];
    my $par_autori = $_[1];
    my $par_titulu = $_[2];

    ##  what are we looking for?
    my $in_palori = ( ! defined $par_palori ) ? "" : $par_palori;
    my $in_autori = ( ! defined $par_autori ) ? "" : $par_autori;
    my $in_titulu = ( ! defined $par_titulu ) ? "" : $par_titulu;

    ##  remove accents, make lower case
    my $palori_str = lc( strip_line( $in_palori ));
    my $autori_str = lc( strip_line( $in_autori ));
    my $titulu_str = lc( strip_line( $in_titulu ));

    ##  remove parenthesis and excess spaces
    $palori_str =~ s/[\(\)]//g;  $autori_str =~ s/[\(\)]//g;  $titulu_str =~ s/[\(\)]//g;
    $palori_str =~ s/\s+/ /g;    $autori_str =~ s/\s+/ /g;    $titulu_str =~ s/\s+/ /g;
    $palori_str =~ s/"//g;       $autori_str =~ s/"//g;       $titulu_str =~ s/"//g;
    $palori_str =~ s/,//g;       $autori_str =~ s/,//g;       $titulu_str =~ s/,//g;
    $palori_str =~ s/^ //;       $autori_str =~ s/^ //;       $titulu_str =~ s/^ //;
    $palori_str =~ s/ $//;       $autori_str =~ s/ $//;       $titulu_str =~ s/ $//;

    ##  enforce max length, without any generosity
    $palori_str = substr( $palori_str , 0 , 48 );  ## (48 is form limit)
    $titulu_str = substr( $titulu_str , 0 , 48 );  ## (48 is form limit)
    $autori_str = substr( $autori_str , 0 , 24 );  ## (24 is form limit)
    
    ##  header, form and footer
    my $html_head = mk_header($topnav_html, $palori_str , $autori_str , $titulu_str );
    my $html_form = mk_form( $palori_str , $autori_str , $titulu_str );
    my $html_rcta = mk_ricota();
    my $html_foot = mk_footer($navbar_html);

    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    # ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

    ##  FIND MATCHES
    ##  ==== =======
    
    ##  what to search for
    my @palori_sch;
    my @autori_sch;
    my @titulu_sch;
    
    ##  split word search string at space and push if four or more characters
    my @palori_array = split( ' ', $palori_str );
    foreach my $palora (@palori_array) {
	if ( length($palora) >= 4 ) {
	    push( @palori_sch , $palora );
	}
    }
    
    ##  split author search string at space and push if four or more characters
    $autori_str =~ s/(la )?mattina$/la~mattina/g;
    $autori_str =~ s/(di )?marco$/di~marco/g;
    $autori_str =~ s/(de )?vita$/de~vita/g;
    
    my @autori_array = split( ' ', $autori_str );
    s/la~mattina/la mattina/g for @autori_array;
    s/di~marco/di marco/g for @autori_array;
    s/de~vita/de vita/g for @autori_array;
    
    foreach my $author (@autori_array) {
	if ( length($author) >= 4 ) {
	    push( @autori_sch , $author );
	}
    }
    
    ##  split title search string at space and push if four or more characters
    my @titulu_array = split( ' ', $titulu_str );
    foreach my $word (@titulu_array) {
	if ( length($word) >= 4 ) {
	    push( @titulu_sch , $word );
	}
    }
    
    
    ##  find word matches
    my @palori;
    foreach my $wdkey (sort keys %smword) {
	foreach my $palora (@palori_sch) {
	    if ($palora eq $wdkey) {
		push( @palori , @{ $smword{$wdkey} } );
	    }
	}
    }
    @palori = uniq(@palori);
    
    ##  find author matches
    my @autori;
    foreach my $aukey (sort keys %smauth) {
	foreach my $author (@autori_sch) {
	    if ($author eq $aukey) {
		push( @autori , @{ $smauth{$aukey} } );
	    }
	}
    }
    @autori = uniq(@autori);
    
    ##  find word matches
    my @tituli;
    foreach my $ttkey (sort keys %smtitle) {
	foreach my $word (@titulu_sch) {
	    if ($word eq $ttkey) {
		push( @tituli , @{ $smtitle{$ttkey} } );
	    }
	}
    }
    @tituli = uniq(@tituli);
    
    
    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    
    ##  identify the matches
    my @matches ;
    
    if ( $#autori_sch < 0 && $#palori_sch < 0 && $#titulu_sch < 0 ) {
	##  no author search, no word search, no title search
	@matches = ();
	
    } elsif ( $#palori_sch < 0  &&  $autori_str =~ /nicotra/ ) {
	##  no word search, but author search on "nicotra"
	##  return no matches
	@matches = ();
	
    } elsif ( $#autori_sch < 0 && $#titulu_sch < 0 ) {
	##  no author search, no title search, but word search
	@matches = @palori;
	
    } elsif ( $#autori_sch < 0 && $#palori_sch < 0 ) {
	##  no author search, no word search, but title search
	@matches = @tituli;
	
    } elsif ( $#palori_sch < 0 && $#titulu_sch < 0 ) {
	##  no word search, no title search, but author search
	@matches = @autori;    
	
    } elsif ( $#palori_sch < 0 ) {
	##  no word search, but title and author search
	my %union ;
	my %isect;
	foreach my $key (@tituli, @autori) {
	    $union{$key}++ && $isect{$key}++
	}
	#my @union_keys = keys %union;
	#my @isect_keys = keys %isect;
	
	@matches = keys %isect;    
	
    } elsif ( $#autori_sch < 0 ) {
	##  no author search, but title and word search
	my %union ;
	my %isect;
	foreach my $key (@palori, @tituli) {
	    $union{$key}++ && $isect{$key}++
	}
	#my @union_keys = keys %union;
	#my @isect_keys = keys %isect;
	
	@matches = keys %isect;    
	
    } elsif ( $#titulu_sch < 0 ) {
	##  no title search, but word and author search
	my %union ;
	my %isect;
	foreach my $key (@palori, @autori) {
	    $union{$key}++ && $isect{$key}++
	}
	#my @union_keys = keys %union;
	#my @isect_keys = keys %isect;
	
	@matches = keys %isect;    
	
    } else {
	##  title, word and author search
	
	my %unionA ;
	my %isectA ;
	foreach my $key (@palori, @autori) {
	    $unionA{$key}++ && $isectA{$key}++
	}
	#my @unionA_keys = keys %unionA;
	my @isectA_keys = keys %isectA;
	
	my %unionB ;
	my %isectB ;
	foreach my $key (@isectA_keys, @tituli) {
	    $unionB{$key}++ && $isectB{$key}++
	}
	#my @unionB_keys = keys %unionB;
	#my @isectB_keys = keys %isectB;
	
	@matches = keys %isectB;
    }
    
    ##  make list unique (should already be unique)
    @matches = uniq(@matches);


    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    # ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

    ##  PREPARE HTML
    ##  ======= ====
    
    ##  prepare HTML output
    my $otlines ;
    
    ##  sorry if not found, otherwise return the cosine-similarity
    if ( $#matches < 0 ) {
	
	##  if search came up empty
	
	##  open outer DIV to limit width
	$otlines .= '<div class="transconj">' ."\n";
	##  open row
	$otlines .= '<div class="row">' ."\n";
	
	if ( $autori_str eq "" && $palori_str eq "" && $titulu_str eq "" ) {
	    ##  no author search, no word search
	    $otlines .= '<p>Attrova na palora o na frasi ntra li pruverbi e versi di puisia!</p>' ."\n";
	    $otlines .= '<p>Almenu una palora havi a aviri 4&nbsp;o chiù littri.</p>'."\n";
	    $otlines .= $example;
	    
	} elsif ( $palori_str eq "" && $autori_str =~ /nicotra/ ) {
	    ##  no four-character word search and author search on "nicotra"
	    ##  return no matches
	    $otlines .= '<p>Ci sunnu tanti pruverbi di Nicotra!</p>' ."\n";
	    $otlines .= '<p>Abbisogna junciri na palora o frasi a la ricerca.</p>' ."\n";
	    
	} elsif ( $autori_str eq "" && $titulu_str eq "" ) {
	    ##  no author or title search, but word search
	    $otlines .= '<p>' . "Nun c'è un esempiu " ;
	    if ( $palori_str =~ / / ) {
		$otlines .= ' dâ frasi: &nbsp; ' ;
	    } else {
		$otlines .= ' dâ palora: &nbsp; ' ;
	    }
	    $otlines .= '<b>' . $palori_str .'</b></p>' ."\n";
	    $otlines .= '<p>Prova di novu! Almenu una palora havi a aviri 4&nbsp;o chiù littri.</p>'."\n";
	    $otlines .= $example;
	    
	} elsif ( $autori_str eq "" && $palori_str eq "" ) {
	    ##  no author or word search, but title search
	    $otlines .= '<p>' . "Nun c'è un tìtulu " ;
	    if ( $titulu_str =~ / / ) {
		$otlines .= ' câ frasi: &nbsp; ' ;
	    } else {
		$otlines .= ' câ palora: &nbsp; ' ;
	    }
	    $otlines .= '<b>' . $titulu_str .'</b></p>' ."\n";
	    $otlines .= '<p>Prova di novu! Almenu una palora havi a aviri 4&nbsp;o chiù littri.</p>'."\n";
	    $otlines .= $example;
	    
	    
	} elsif ( $palori_str eq "" && $titulu_str eq "" ) {
	    ##  no word or title search, but author search
	    $otlines .= '<p>' . "Nun c'è un esempiu di l'autori: " ;
	    $otlines .= '<b>' . $autori_str .'</b></p>' ."\n";
	    $otlines .= '<p>Prova di novu! Almenu una palora havi a aviri 4&nbsp;o chiù littri.</p>'."\n";
	    $otlines .= $example;
	    
	} elsif ( $titulu_str eq "" ) {
	    ##  no title search, but word search and author search
	    $otlines .= '<p>' . "Nun c'è un esempiu " ;
	    if ( $palori_str =~ / / ) {
		$otlines .= ' dâ frasi: &nbsp; ' ;
	    } else {
		$otlines .= ' dâ palora: &nbsp; ' ;
	    }
	    $otlines .= '<b>' . $palori_str .'</b>' ."\n";
	    $otlines .= " &nbsp; di l'autori: " .' &nbsp; <b>'.  $autori_str .'</b></p>'."\n";
	    $otlines .= '<p>Prova di novu! Almenu una palora havi a aviri 4&nbsp;o chiù littri.</p>'."\n";
	    $otlines .= $example;
	    
	} elsif ( $autori_str eq "" ) {
	    ##  no author search, but word search and title search
	    $otlines .= '<p>' . "Nun c'è un esempiu " ;
	    if ( $palori_str =~ / / ) {
		$otlines .= ' dâ frasi: &nbsp; ' ;
	    } else {
		$otlines .= ' dâ palora: &nbsp; ' ;
	    }
	    $otlines .= '<b>' . $palori_str .'</b>' ."\n";
	    $otlines .= " &nbsp; e dû tìtulu " .' &nbsp; <b>'.  $titulu_str .'</b></p>'."\n";
	    $otlines .= '<p>Prova di novu! Almenu una palora havi a aviri 4&nbsp;o chiù littri.</p>'."\n";
	    $otlines .= $example;
	    
	} elsif ( $palori_str eq "" ) {
	    ##  no word search, but author and title search
	    $otlines .= '<p>' . "Nun c'è un esempiu di l'autori: " .' &nbsp; ';
	    $otlines .= '<b>' . $autori_str .'</b>' ."\n";
	    $otlines .= " &nbsp; e dû tìtulu " .' &nbsp; <b>'.  $titulu_str .'</b></p>'."\n";
	    $otlines .= '<p>Prova di novu! Almenu una palora havi a aviri 4&nbsp;o chiù littri.</p>'."\n";
	    $otlines .= $example;
	    
	} else {
	    ##  word, title and author search
	    $otlines .= '<p>' . "Nun c'è un esempiu " ;
	    if ( $palori_str =~ / / ) {
		$otlines .= ' dâ frasi: &nbsp; ' ;
	    } else {
		$otlines .= ' dâ palora: &nbsp; ' ;
	    }
	    $otlines .= '<b>' . $palori_str .'</b>' ."\n";
	    $otlines .= " &nbsp; di l'autori: " .' &nbsp; <b>'.  $autori_str .'</b> '."\n";
	    $otlines .= " &nbsp; e dû tìtulu " .' &nbsp; <b>'.  $titulu_str .'</b></p>'."\n";
	    $otlines .= '<p>Prova di novu! Almenu una palora havi a aviri 4&nbsp;o chiù littri.</p>'."\n";
	    $otlines .= $example;
	    
	}
	
	##  close row
	$otlines .= '</div>' ."\n"; 
	##  close outer DIV to limit width
	$otlines .= '</div>' ."\n";
	
	##  close empty search
        
    } else {
	
	##  found matches
	##  store matching text in holder
	my %othash;
	
        ##  retrieve vocab notes
	my $vnhash = retrieve( $vocab_notes );
	my %vnotes = %{ $vnhash } ;
	
	
	##  retrieve vocabulary subroutines
	my $vthash  = retrieve( $verb_tools );
	my $vbconj  =   $vthash->{vbconj} ;
	
	##  loop through the matches to find matching text
	foreach my $palora (@matches) {
	    
	    if ( ! defined $vnotes{$palora} ) {
		my $blah = "ERROR -- no hash key for:  " . $palora . "\n";
		## print $blah;
	    } else {
		
		##  get word header HTML
		my $header = mk_wdheader( $palora , \%vnotes , $vbconj );
		
		##  find matching poetry and make HTML
		my @poem_matches = find_poem_matches( $palora , $autori_str , $palori_str , $titulu_str , "poetry" , \%vnotes ); 
		my $poem_html = mk_notex_list( 'puisìa:' , \@poem_matches ) ;
		
		##  find matching prose and make HTML
		my @prose_matches = find_poem_matches( $palora , $autori_str , $palori_str , $titulu_str , "prose" , \%vnotes ); 
		my $prose_html = mk_notex_list( 'prosa:' , \@prose_matches ) ;
		
		##  find matching proverbs and make HTML
		my @proverb_matches = find_poem_matches( $palora , $autori_str , $palori_str , $titulu_str , "proverb" , \%vnotes ); 
		my $proverbs_num = ($#proverb_matches > 0) ? 'pruverbi:' : 'pruverbiu:' ;
		my $proverb_html = mk_notex_list( $proverbs_num , \@proverb_matches ) ; 
		
		##  store poems and proverbs on the output hash
		if ( $#poem_matches > -1 ) {
		    $othash{$palora}{header} = $header;
		    $othash{$palora}{poetry} = $poem_html;
		}
		
		if ( $#prose_matches > -1 ) {
		    $othash{$palora}{header} = $header;
		    $othash{$palora}{prose} = $prose_html;
		}
		
		if ( $#proverb_matches > -1 ) {
		    $othash{$palora}{header} = $header;
		    $othash{$palora}{proverb} = $proverb_html;
		}
	    }
	}
	##  end loop through the matches
	
	
	##  now prepare their HTML output
	##  making sure that at least one match
	my @othash_keys = sort {lc(rid_accents($a)) cmp lc(rid_accents($b))} keys %othash ;
	
	if ( $#othash_keys < 0 ) {
	    
	    ##  open div for no matches
	    $otlines .= '<div class="transconj">' ."\n";
	    
	    if ( $autori_str eq "" ) {
		##  no author search, but word search
		$otlines .= '<p>' . "Nun c'è un esempiu " ;
		if ( $palori_str =~ / / ) {
		    $otlines .= ' dâ frasi: &nbsp; ' ;
		} else {
		    $otlines .= ' dâ palora: &nbsp; ' ;
		}
		$otlines .= '<b>' . $palori_str .'</b></p>' ."\n";
		$otlines .= '<p>Prova di novu! Almenu una palora havi a aviri 4&nbsp;o chiù littri.</p>'."\n";
		$otlines .= $example;
		
	    } elsif ( $palori_str eq "" ) {
		##  no word search, but author search
		$otlines .= '<p>' . "Nun c'è un esempiu di l'autori: " ;
		$otlines .= '<b>' . $autori_str .'</b></p>' ."\n";
		$otlines .= '<p>Prova di novu! Almenu una palora havi a aviri 4&nbsp;o chiù littri.</p>'."\n";
		$otlines .= $example;
		
	    } else {
		##  word search and author search
		$otlines .= '<p>' . "Nun c'è un esempiu " ;
		if ( $palori_str =~ / / ) {
		    $otlines .= ' dâ frasi: &nbsp; ' ;
		} else {
		    $otlines .= ' dâ palora: &nbsp; ' ;
		}
		$otlines .= '<b>' . $palori_str .'</b>' ."\n";
		$otlines .= "  &nbsp; di l'autori: " .' &nbsp; <b>'.  $autori_str .'</b></p>'."\n";
		$otlines .= '<p>Prova di novu! Almenu una palora havi a aviri 4&nbsp;o chiù littri.</p>'."\n";
		$otlines .= $example;
	    }
	    
	    ##  close div for no matches
	    $otlines .= '</div>' ."\n";
	    
	    
	} else {
	    
	    ##  for each match, open the file
	    foreach my $palora (@othash_keys) {
		
		##  open div for the matche
		$otlines .= '<div class="transconj">' ."\n";
		
		##  poetry and proverbs to add
		my $add_poem    = ( ! defined $othash{$palora}{poetry}  ) ? "" : $othash{$palora}{poetry} ;
		my $add_prose   = ( ! defined $othash{$palora}{prose}   ) ? "" : $othash{$palora}{prose} ;
		my $add_proverb = ( ! defined $othash{$palora}{proverb} ) ? "" : $othash{$palora}{proverb}; 
		
		##  add the header, poetry and proverbs
		$otlines .= $othash{$palora}{header} ;
		$otlines .= $add_poem ;
		$otlines .= $add_prose ;
		$otlines .= $add_proverb ;
		
		##  add horizontal line
		$otlines .= '<hr>' ."\n";
		
		##  close div for the match
		$otlines .= '</div>' ."\n";
		
	    }
	}
    }
    
    ##  remove last horizontal line
    $otlines =~ s/<hr>\n<\/div>\n$/<\/div>\n/;

    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    # ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    
    ##  OUTPUT the HTML
    ##  ====== === ====

    my $htmlpage;
    $htmlpage .= $html_head;
    $htmlpage .= $html_form;
    $htmlpage .= $otlines;
    $htmlpage .= $html_rcta;
    
    ##  print the social media shares
    my $text_url   = 'https://www.napizia.com/cgi-bin/trova-palora.pl';
    my $text_title = fetch_pagetitle($palori_str , $autori_str , $titulu_str );
    
    ##  information (if any) for the shares
    if ( $palori_str !~ /[a-z]/ && $autori_str !~ /[a-z]/ && $titulu_str !~ /[a-z]/ ) {
	my $blah  = 'do nothing';
    } else { 
	
	##  searches to add to the URL
	my $addtourl ;
	$addtourl .= ( $palori_str !~ /[a-z]/ ) ? "" : '&palori='. $palori_str ;
	$addtourl .= ( $autori_str !~ /[a-z]/ ) ? "" : '&autori='. $autori_str ;
	$addtourl .= ( $titulu_str !~ /[a-z]/ ) ? "" : '&titulu='. $titulu_str ;
	$addtourl =~ s/^\&/?/;
	
	##  add them to the URL 
	$text_url .= $addtourl
    }
    
    ##  append to title
    $text_title  .= 'Trova na Palora :: Napizia';
    
    ##  make the shares
    my $url   = uri_escape($text_url);
    my $title = uri_escape($text_title);
    $htmlpage .= mk_share( $url , $title );
    
    ##  print bottom navigation panel
    $htmlpage .= $html_foot;

    
    ##  return the HTML page
    return $htmlpage;
}
    
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  OTHER SUBROUTINES
##  ===== ===========

sub fetch_pagetitle {

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
  
    ##  return title
    return $title_insert;
}

##  subroutine to make social media shares
sub mk_share {

    my $url   = uri_escape($_[0]);
    my $title = uri_escape($_[1]);
    
    my $html ;
    
    $html .= '<div class="message" style="margin: 0em auto; width: 100%;">'."\n";
    $html .= '<p style="text-align: center; margin-top: 0.15em; margin-bottom: 0.25em;">'."\n";
    $html .= '<a href="https://www.facebook.com/sharer/sharer.php?u='. $url .'"'."\n";
    $html .= '   class="fa fa-facebook" style="color:white;"'."\n";
    $html .= '   target="_blank"></a>'."\n";
    $html .= '<a href="https://bsky.app/intent/compose?text='. $title .'%0A'. $url .'"'."\n";
    $html .= '   class="fa fa-bluesky" style="color:white;"'."\n";
    $html .= '   target="_blank"></a>'."\n";
    $html .= '<a href="https://www.linkedin.com/sharing/share-offsite/?url='. $url .'"'."\n";
    $html .= '   class="fa fa-linkedin" style="color:white;"'."\n";
    $html .= '   target="_blank"></a>'."\n";
    $html .= '<a href="mailto:?subject='. $title .'&body=' . $url .'"'."\n";
    $html .= '   class="fa fa-envelope" style="color:white;"'."\n";
    $html .= '   target="_blank"></a>'."\n";
    $html .= '</p>'."\n";
    $html .= '</div>'."\n";

    return $html ;
}

