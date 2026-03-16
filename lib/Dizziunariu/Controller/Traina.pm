package Dizziunariu::Controller::Traina;

##  Traina Dictionary
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

use strict;
use warnings;
#no warnings qw( uninitialized );

use utf8;

use Mojo::Base 'Mojolicious::Controller', -signatures;

use Storable qw( retrieve );
#{   no warnings;             
    ## $Storable::Deparse = 1;  
    $Storable::Eval    = 1;  
#}

use URI::Escape;

use Napizia::TextTools;
use Napizia::HtmlTraina;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  HTML FILES
##  ==== =====

##  navigation panels
my $topnav_html = '/home/eryk/website/dizziunariu/public/config/eryk2-topnav.html';
my $navbar_html = '/home/eryk/website/dizziunariu/public/config/eryk2-navbar.html';

##  PARAMETERS
##  ==========

##  number of pages for vocabulary list
##  should be divisible by four
my $nupages = 300 ; 

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  RETRIEVE TOOLS
##  ======== =====

my $amhash = retrieve('/home/eryk/website/dizziunariu/lib/stor/traina-list');
my $amlsrf = $amhash->{amlist} ;

# my $ttspan = retrieve('/home/eryk/website/dizziunariu/lib/stor/traina_span-to-hdword' );
# my %sh_hash = %{ $ttspan };

my $tthead = retrieve('/home/eryk/website/dizziunariu/lib/stor/traina_hdword-to-line' );
my %hl_hash = %{ $tthead };

my $ttline = retrieve('/home/eryk/website/dizziunariu/lib/stor/traina_line-to-traina' );
# my %lt_hash = %{ $ttline };

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  VARIABLES
##  =========

##  what word do we wish to see?
##  which collection are we looking for?

sub welcome ($self) {

    my $par_palora = $self->param('palora') || '';
    my $par_coll   = $self->param('coll')   || '';

    $par_palora = ( $par_palora eq '') ? undef : $par_palora ;
    $par_coll   = ( $par_coll   eq '') ? undef : $par_coll ;

    my $otpage = mk_htmlpage( $par_palora , $par_coll );
    $self->render( htmlpage => $otpage );
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  CREATE  WEBPAGE
##  ======  =======

##  cases:
##    *  landing page -- index of indices
##    *  page or words
##    *  individual word
##

sub mk_htmlpage {

    my $palora = scn_ucfirst_trim($_[0]);
    my $coll   = $_[1];

    my $othtml;
    
    if ( ! defined $palora && ! defined $coll ) {
	##  case where user first arrives
	##     * no "palora" defined
	##     * no "collection" defined
	
	##  landing page with alphabetical list of lists
	$othtml .= mk_amtophtml($topnav_html ,"");
	
	$othtml .= "\n";
	$othtml .= '<img src="/pics/antonino-traina.jpg" style="max-width: 600px;"'."\n";
	$othtml .= '     alt="Nuovo vocabolario siciliano-italiano compilato da Antonino Traina">'."\n";
	$othtml .= "\n";
	
	$othtml .= make_alfa_welcome( $amlsrf , $nupages );
    
	
    } elsif ( ( ! defined $palora || ! defined $hl_hash{$palora} ) &&
	      $coll =~ /^alfa_p[0-2][0-9][0-9]$/ ) {
	
	##  case where user wants to browse a collection
	##     * no "palora" defined
	##     * "collection" is defined
	##  
	##  note:  arriving from the home page
	
	##  browsing words one page of collection     
	my $title_insert = $coll;
	$title_insert =~ s/alfa_/ìnnici /;
	$othtml .= mk_amtophtml($topnav_html , $title_insert );
	$othtml .= make_alfa_coll( $coll , $amlsrf , $nupages );
	
	
    } elsif ( ! defined $hl_hash{$palora} ) {
	
	##  ERRORS, so ...
	##  print landing page with alphabetical list of lists
	$othtml .= mk_amtophtml($topnav_html ,"");
	
	$othtml .= "\n";
	$othtml .= '<img src="/pics/antonino-traina.jpg" style="max-width: 600px;"'."\n";
	$othtml .= '     alt="Nuovo vocabolario siciliano-italiano compilato da Antonino Traina">'."\n";
	$othtml .= "\n";
	
	$othtml .= make_alfa_welcome( $amlsrf , $nupages );
	
    } else {
	
	##  case where
	##     * $hl_hash{$palora} is defined
	##     * "collection" is ambiguous -- we'll obey palora
	
	##  my %lt_hash = %{ $ttline };
	##  my @lineidxs = @{$hl_hash{$uc_disp}} ;
	
	$othtml .= mk_amtophtml($topnav_html , $palora );
	$othtml .= '<div><h3 style="margin-top: 0em;">'; 
	$othtml .= 'Nuovo vocabolario siciliano-italiano (1868)';
	$othtml .= '</h3></div>'."\n"; 
	$othtml .= print_traina( $palora , $hl_hash{$palora}  , $ttline );
	
    } 
    
    
    ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
    
    ##  close webpage
    $othtml .= '<p style="margin: 0.20em auto; text-align: center;"><small>';
    ## $othtml .= 'La vuci di Traina veni dû '."\n";
    ## $othtml .= 'Sta paggina utilizza materiali dâ versioni di '."\n";
    $othtml .= 'Sta paggina utilizza materiali di '."\n";
    $othtml .= '<a href="https://it.wikisource.org/wiki/Nuovo_vocabolario_siciliano-italiano">';
    $othtml .= 'Wikisource Talianu</a>, '."\n";
    $othtml .= 'ca veni pubblicatu sutta la licenza '."\n";
    ## $othtml .= '<a href="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons '."\n";
    ## $othtml .= 'Attribuzioni-SpartiÔStissuModu 4.0 Internaziunali</a>.</small></p>'."\n";
    $othtml .= '<a href="https://creativecommons.org/licenses/by-sa/4.0/">'."\n";
    $othtml .= 'CC BY-SA&nbsp;4.0</a>.</small></p>'."\n";

    $othtml .= "</div>"."\n";


    ##  print the social media shares
    my $text_url   = 'https://dizziunariu.napizia.com/traina/';
    my $text_title;
    
    ##  should we append to URL and title??
    if ( ! defined $palora && ! defined $coll ) {
	my $blah = "do nothing";
	
    } elsif ( ( ! defined $palora || ! defined $hl_hash{$palora} ) && $coll =~ /^alfa_p[0-2][0-9][0-9]$/ ) {
	
	##  append to URL
	$text_url .= '?coll='. $coll ;
	
	##  give the name "index" to the collection
	my $title_insert = $coll;
	$title_insert =~ s/alfa_/ìnnici /;
	
	##  append the index to the title
	$text_title .= $title_insert .' :: ';
	
    } elsif ( ! defined $hl_hash{$palora} ) {
	my $blah = "do nothing";
	
    } else {
	
	##  append to URL
	$text_url .= '?palora='. $palora ;
	
	##  append the word to the title
	$text_title .= $palora .' :: ';
    }
    
    ##  append to text title
    $text_title  .= 'Dizziunariu Traina :: Napizia';
    
    ##  print the social media shares
    my $url   = uri_escape($text_url);
    my $title = uri_escape($text_title);
    $othtml .= mk_share( $url , $title );
    
    ##  print the bottom navigation panel and close
    $othtml .= mk_foothtml($navbar_html);
    
    ##  return the output html
    return $othtml;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
## #  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ## 

##  OTHER SUBROUTINES
##  ===== ===========

##  subroutine to make social media shares
sub mk_share {

    my $url   = uri_escape($_[0]);
    my $title = uri_escape($_[1]);
    
    my $html ;
    
    $html .= '<div class="message" style="margin: 0.10em auto 0em auto; width: 100%;">'."\n";
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

1;
