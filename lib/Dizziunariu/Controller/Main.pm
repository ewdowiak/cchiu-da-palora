package Dizziunariu::Controller::Main;

##  makes main page
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

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

use strict;
use warnings;
#no warnings qw(uninitialized);

use utf8;

use Mojo::Base 'Mojolicious::Controller', -signatures;

##  navigation panels
my $homepage = '/home/eryk/website/dizziunariu/public/index.html';

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  WELCOME
##  =======

sub welcome ($self) {

    my $otpage = mk_htmlpage( $homepage );
    $self->render( htmlpage => $otpage );
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  CREATE WEBPAGE
##  ====== =======

sub mk_htmlpage { 

    ##  get page
    my $inpage = $_[0];
    
    ##  recreate page
    my $othtml ;

    open( my $fh_inpage , "<:encoding(utf-8)" , $inpage ); ## || die "could not read:  $inpage";
    while(<$fh_inpage>){ chomp;  $othtml .= $_ . "\n" ; };
    close $fh_inpage ;

    ##  return the HTML page
    return ( $othtml );
}

1;
