#!/usr/bin/env perl

##  ./mk_traina.pl -- parses Traina dictionary and creates hashes of:
##    >  line id to Traina definition
##    >  headword to line id
##    >  span id to headword
##  
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
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

use strict;
# use warnings;
# no warnings qw( uninitialized numeric void ) ; 

use utf8;

use Encode qw(decode FB_CROAK);

##  ensure weak references in use
use HTML::TreeBuilder 5 -weak; 

use Storable qw( retrieve nstore ) ;

use lib "../cgi-lib";
use Napizia::TextTools;
use Napizia::Utils;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  base name of input files
my $inpart = "./traina/traina-01c-";

##  output files
my $shfile = "../cgi-lib/traina_span-to-hdword";
my $hlfile = "../cgi-lib/traina_hdword-to-line";
my $ltfile = "../cgi-lib/traina_line-to-traina";

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  dictionary parts -- "main" and "supp"
my @dparts = ("main","supp");

##  retrieve abbrevs
my @abbrevs = get_abbrevs();

##  hash to hold Traina's entries
my %traina;

##  initialize hashes for the output files
my %sh_hash;
my %hl_hash;
my %lt_hash;

##  for each part of Traina's dictionary
foreach my $dpart (@dparts) {

    ##  input and output files
    my $infile = $inpart . $dpart ."-edited.html";

    ##  open the input file and the error file
    open( my $fh_infile , "<:encoding(utf-8)" , $infile  ) || die "could not open $infile";
#    open( my $fh_infile , $infile  ) || die "could not open $infile";
    
    ##  hold the line number
    my $linenum = 0;
    
    ##  read the input file
    while(<$fh_infile>) {
	chomp;
	my $line = $_;

	##  update line number and make line index
	$linenum++;
	my $lineidx = substr( $dpart ,0,1) . sprintf("%05d",$linenum);

	##  get "span id"
	my $spanid ;
	if ( $line =~ /^<p><b><span id="/ ) {
	    $spanid = $line;
	    $spanid =~ s/<\/span>.*$//;
	    $spanid =~ s/">.*$//;
	    $spanid =~ s/^<p><b><span id="//;
	} else {
	    $spanid = "ERRORS";
	}
	
	##  empty tree
	my $tree = HTML::TreeBuilder->new; 
	$tree->parse($line);
	$tree->eof;

	##  array to hold the stuff in <p> tags
	my @parray;

	##  get the stuff in <p> tags
	my $parag = $tree->look_down('_tag','p');

	##  get the headword
	my $hword;
	if ( ! defined $parag ) { my $blah = "do nothing";
	} else {
	    my $hword_look = $parag->look_down('_tag','b');
	    if ( ! defined $hword_look ) { my $blah = "do nothing";
	    } else {
		$hword = $hword_look->as_text;
		$hword =~ s/^ //;
		$hword =~ s/ $//;
		$hword =~ s/^'//;
		$hword = ucfirst( $hword );
		$hword =~ s/^à/À/;
		$hword =~ s/^è/È/;
		$hword =~ s/^ì/Ì/;
		$hword =~ s/^ò/Ò/;
		$hword =~ s/^ù/Ù/;
		$hword =~ s/ \(.*$//;

		foreach my $elem ($parag->content_list) {
		    
		    if ( ! defined $elem || ref($elem) ne 'HTML::Element' ) {
			my $blah = "do nothing";
			
		    } else {
			##  look for words in BOLD
			my $bolds = $elem->look_down('_tag','b');
			if ( ! defined $bolds ) { my $blah = "do nothing";
			} else {
			    foreach my $bold ($bolds->content_list) {
				if ( ! defined $bold ) { my $blah = "do nothing";
				} elsif ( ref($bold) ne 'HTML::Element' ) {
				    push( @parray , $bold );
				} else {
				    push( @parray , $bold->as_text );
				}
			    }
			}
		    }
		}
	    }
	}

	##  print out the line id to Traina definition and
	##  add everything to the hash (or print error)
	##  ##  a-zàèìòù
	if ( $spanid eq "ERRORS" || ! defined $parag ||
	     ! defined $hword || $hword !~ /^[A-ZÀÈÌÒÙ]/ || $hword =~ /\(/ ) {

	    ##  errors -- record them
	    print "error: ". $lineidx ." -- ". $line ."\n";
	    # print $spanid ."\n";
	    # print $hword ."\n";
	    # print "\n";
	    
	} else {

	    ##  line id to Traina definition
	    $lt_hash{$lineidx} = $line ; 

	    ##  add information to the Traina hash
	    my @larray = ( $lineidx , $spanid , \@parray );
	    push( @{$traina{$hword}} , \@larray );
	}
	
    }
    ##  end of line
    
    ##  close the input file
    close $fh_infile;
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  capture the feminine singulars and plurals
##  and create hashes of:
##    *  headword to line id
##    *  span id to headword

##  headword to line id
foreach my $hword ( sort { lc(rid_accents($a)) cmp lc(rid_accents($b)) } keys %traina ) {
    
    my @lineidxs;
    my @spanids;
    my @bolds;
    
    ##  loop through
    for my $lidx (0..$#{$traina{$hword}}) {
	my @larray = @{ $traina{$hword}[$lidx] };
	push( @lineidxs ,   $larray[0]  );
	push( @spanids  ,   $larray[1]  );
	push( @bolds    , @{$larray[2]} );
    }

    ##  make unique
    @lineidxs = uniq(@lineidxs );
    @spanids  = uniq(@spanids);
    @bolds    = uniq(@bolds);

  
    ## capture the feminine singulars and plurals
    my @allforms;
    my $alts = grep {/–/} @bolds;
    
    if ( $alts > 0 && $hword eq "Ingannaturi –tura –trici" ) {
    	push( @allforms , "Ingannaturi","Ingannatura","Ingannatrici","Inganneri" );
	
    } elsif ( $alts > 0 ) {

     	##  because original HTML is inconsistent
     	my $join = join(" ",@bolds);
     	$join =~ s/\s+/ /g;
     	$join =~ s/^ //;
     	$join =~ s/ $//;
     	my @forms = split(/ /, $join);

	##  which are base words?  which are endings?
     	my @bases = grep {!/–/} @forms;
     	my @ends  = grep {/–/} @forms;

	##  push bases to array of all forms
	push( @allforms , @bases );

	##  now make alternates
	foreach my $base (@bases) {
	    foreach my $end (@ends) {
		
		my $new = $base;	

		#   242 –trici
		if ( $end eq "–trici" ) { $new =~ s/turi$/trici/; }

		#   179 –tura
		if ( $end eq "–tura" ) { $new =~ s/turi$/tura/; }

		#     4 –ttrici
		if ( $end eq "–ttrici" ) { $new =~ s/tturi$/ttrici/; }

		#     4 –ra
		if ( $end eq "–ra" ) { $new =~ s/r[iu]$/ra/; }

		#     4 –era
		if ( $end eq "–era" ) { $new =~ s/eri$/era/; }

		#     2 –rera
		if ( $end eq "–rera" ) { $new =~ s/reri$/rera/; }

		#     2 –na
		if ( $end eq "–na" ) { $new =~ s/ni$/na/; }

		#     1 –zza
		if ( $end eq "–zza" ) { $new =~ s/zzu$/zza/; }

		#     1 –ura
		if ( $end eq "–ura" ) { $new =~ s/uri$/ura/; }

		#     1 –turissa
		if ( $end eq "–turissa" ) { $new =~ s/turi$/turissa/; }
		
		#     1 –ttrattrici
		if ( $end eq "–ttrattrici" ) { $new =~ s/ttratturi$/ttrattrici/; }

		#     1 –ssura
		if ( $end eq "–ssura" ) { $new =~ s/ssuri$/ssura/; }

		#     1 –dda
		if ( $end eq "–dda" ) { $new =~ s/ddu$/dda/; }


		##  base and new should be different
		# if ( $base eq $new ) {
		#     print "error -- base is same as new -- ". $base ."\n";
		# }
		
		##  push the new word onto all forms array
		if ( $new !~ /–/ ) {
		    push( @allforms , $new );
		} else {
		    print "skipping: ". $new . " in ". $hword ."\n";
		}
		
	    }
	}
		
	
    } else {
     	push( @allforms , $hword );
    }

    ##  make all forms unique
    @allforms = uniq(@allforms);


    ##  add to hashes of:
    ##    *  headword to line id
    ##    *  span id to headword
    foreach my $allform (@allforms) {

	##  headword to line ids
	push( @{$hl_hash{$allform}} , @lineidxs );

	##  span id to headwords
	foreach my $spanid (@spanids) {
	    push( @{$sh_hash{$spanid}} , $allform );
	}
    }

}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  store line id to Traina definition
nstore( \%lt_hash , $ltfile );

##  store headword to line ids
nstore( \%hl_hash , $hlfile );

##  store span id to headword
nstore( \%sh_hash , $shfile );

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  SUBROUTINES
##  ===========

##  remove bad UTF-8
sub rm_badchars {
    my $intext = $_[0];
    my $in_dup = $intext;
    my $ottext;
    eval { decode("UTF-8", $in_dup, FB_CROAK); };
    if ($@) {
	$ottext = " ";
    } else {
	$ottext = $intext;
    }
    return $ottext;
}

##  sub to make list of abbreviations
sub get_abbrevs {
    my @abbrevs = (
	"a.",
	"A. V. ital.",
	"accr.",
	"add.",
	"An.",
	"An. Cat.",
	"An. M.",
	"ant.",
	"art.",
	"ass.",
	"att.",
	"Aur.",
	"avv.",
	"avvil.",
	"Car. Voc. Met.",
	"cong.",
	"D. B.",
	"dim.",
	"f.",
	"femm.",
	"Fanf.",
	"Fanf. sup.",
	"Fanf. voc. d. u. Tosc.",
	"fig.",
	"Fig.",
	"Fr.",
	"freq.",
	"Gr.",
	"indecl.",
	"intr.",
	"intr. ass.",
	"intr. pass.",
	"intr. pron.",
	"iperb.",
	"Lat.",
	"m.",
	"masc.",
	"Mal.",
	"met.",
	"mod. avv.",
	"mod. prov.",
	"Mort.",
	"Pal. Voc. Met.",
	"p. e.",
	"P. pres.",
	"P. pass.",
	"Part.",
	"Pasq.",
	"pegg.",
	"pl.",
	"post. avv.",
	"prep.",
	"pron.",
	"Prov.",
	"prov.",
	"Rec.",
	"Rifl.",
	"Rifl. a.",
	"Rifl. pass.",
	"Scob.",
	"sim.",
	"sinc.",
	"sing.",
	"s. m.",
	"s. f.",
	"Sp.",
	"Spat.",
	"sup.",
	"sost.",
	"T. agr.",
	"T. agrim.",
	"T. alg.",
	"T. anat.",
	"T. ant.",
	"T. aral.",
	"T. arch.",
	"T. archeol.",
	"T. arg.",
	"T. arit.",
	"T. arm.",
	"T. art.",
	"T. artig.",
	"T. astr.",
	"T. astrol.",
	"T. batt.",
	"T. battil.",
	"T. bot.",
	"T. botti.",
	"T. cacc.",
	"T. cald.",
	"T. calz.",
	"T. capp.",
	"T. carr.",
	"T. cavall.",
	"T. cesell.",
	"T. chim.",
	"T. chir.",
	"T. ciarl.",
	"T. comm.",
	"T. conf.",
	"T. cron.",
	"T. cuc.",
	"T. eban.",
	"T. eccl.",
	"T. fabb.",
	"T. farm.",
	"T. fil.",
	"T. fis.",
	"T. forn.",
	"T. geog.",
	"T. geol.",
	"T. geom.",
	"T. gioj.",
	"T. giuo.",
	"T. giur.",
	"T. gramm.",
	"T. lan.",
	"T. leg.",
	"T. legn.",
	"T. lib.",
	"T. mac.",
	"T. mag.",
	"T. mar.",
	"T. mat.",
	"T. mecc.",
	"T. med.",
	"T. merc.",
	"T. mil.",
	"T. min.",
	"T. mur.",
	"T. mus.",
	"T. nat.",
	"T. oref.",
	"T. orol.",
	"T. parr.",
	"T. past.",
	"T. pastor.",
	"T. pesc.",
	"T. pett.",
	"T. pitt.",
	"T. pol.",
	"T. rett.",
	"T. ric.",
	"T. rileg.",
	"T. sart.",
	"T. scarp.",
	"T. sch.",
	"T. scient.",
	"T. scud.",
	"T. scult.",
	"T. stam.",
	"T. st.",
	"T. st. nat.",
	"T. teol.",
	"T. teat.",
	"T. tess.",
	"T. tint.",
	"T. uccell.",
	"T. valig.",
	"T. vet.",
	"T. zool.",
	"tras.",
	"Tomm. D.",
	"Tomm.",
	"V.",
	"v.",
	"V. A.",
	"v. a.",
	"v. appr.",
	"v. intr.",
	"verb.",
	"vezz.",
	"vilif.",
	# "VINCI",
	"Zan. Voc. Met."
	);
    return @abbrevs;
}
