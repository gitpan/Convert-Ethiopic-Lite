package Convert::Ethiopic::Lite::Number;

use utf8;  # can't find a way to conditionally load this with
           # the scope applying throughout

BEGIN
{
	use strict;
	use vars qw($VERSION @ENumbers %ENumbers);

	$VERSION = '0.13';

	require 5.000;

	@ENumbers =(
		"፩", "፪", "፫", "፬", "፭", "፮", "፯", "፰", "፱",
		"፲", "፳", "፴", "፵", "፶", "፷", "፸", "፹", "፺",
		"፻", "፼"
	);
	%ENumbers =(
		'፩'	=> 1,
		'፪'	=> 2,
		'፫'	=> 3,
		'፬'	=> 4,
		'፭'	=> 5,
		'፮'	=> 6,
		'፯'	=> 7,
		'፰'	=> 8,
		'፱'	=> 9,
		'፲'	=> 10,
		'፳'	=> 20,
		'፴'	=> 30,
		'፵'	=> 40,
		'፶'	=> 50,
		'፷'	=> 60,
		'፸'	=> 70,
		'፹'	=> 80,
		'፺'	=> 90,
		'፻'	=> 100,
		'፼'	=> 10000
	);

}


sub _setArgs
{
my $self = shift;

	if ( $#_ > 1 ) {
		warn (  "to many arguments" );
		return;
	}

	$self->{number} = $_ if ( /^\d+$/ );
1;
}


sub new
{
my $class = shift;
my $self  = {};


	my $blessing = bless $self, $class;

	$self->{number} = undef;

	$self->_setArgs ( @_ ) || return if ( @_ );

	$blessing;
}


sub _fromEthiopic
{

	#
	# just return if its a single char
	#
	return ( $ENumbers{$_[0]->{number}} ) if ( length($_[0]->{number}) == 1);


	$_ = $_[0]->{number};

	#
	#  tack on a ፩ to avoid special condition check
	#
	s/^([፻፼])/፩$1/;
	s/፼፻/፼፩፻/g;

	# what we do now is pad 0s around ፻ and ፼, these regexi try to kill
	# two birds with one stone but could be split and simplified

	#
	# pad 0 around ones and tens
	#
	s/([፻፼])([፩-፱])/$1."0$2"/ge;    # add 0 if tens place empty
	s/([፲-፺])([^፩-፱])/$1."0$2"/ge;  # add 0 if ones place empty
	s/([፲-፺])$/$1."0"/e;            # repeat at end of string

	# print "$_ => ";

	# pad 0s for meto
	#
	#  s/(፻)$/$1."00"/e;  # this is stupid but tricks perl 5.6 into working
	s/፻$/፻00/;

	# pad 0s for ilf
	#
	s/፼$/፼0000/;
	s/፼፼/፼0000፼/g;  # since /g doesn't work the first time..
	s/፼፼/፼0000፼/g;  # ...we do it again!
	s/፻፼/፼00፼/g;
	s/፼0([፩-፱])፼/፼000$1፼/g;
	s/፼0([፩-፱])$/፼000$1/;          # repeat at end of string
	s/፼([፲-፺]0)፼/፼00$1፼/g;
	s/፼([፲-፺]0)$/፼00$1/;           # repeat at end of string
	s/፼([፩-፺]{2})፼/፼00$1፼/g;
	s/፼([፩-፺]{2})$/፼00$1/;         # repeat at end of string


	# s/፼/፻፻/g;
	s/(፻)$/$1."00"/e;  # this is stupid but tricks perl 5.6 into working

	s/[፻፼]//g;

	# fold tens:
	#
	tr/[፲-፺]/[፩-፱]/;

	# translit:
	#
	tr/[፩-፱]/[1-9]/;

	# print "$_ => ";

	$_;
}


sub _toEthiopic
{
my $number = $_[0]->{number};

	my $n = length ( $number ) - 1;

	# map and return a single digit number
	# don't waste time with the loop:
	return ( $ENumbers[$number-1] ) unless ( $n );


	unless ( $n % 2 ) {
		#
		#  Add dummy leading 0 to precondition the number for
		#  the algorithm and reduce one logic test within the
		#  for loop
		#
		$number = "0$number";
		$n++;
	}

	my @aNumberString = split ( //, $number );
	my $eNumberString = "";


	#
	#  read number from most to least significant digits:
	#
	for ( my $place = $n; $place >= 0; $place-- ) {
		#
		#  initialize values to emptiness:
		#
		my ($aTen, $aOne) = ( 0, 0);  #    ascii ten's and one's place
		my ($eTen, $eOne) = ('','');  # ethiopic ten's and one's place


		#
		#  populate our tens and ones places from the number string:
		#
		$aTen = $aNumberString[$n-$place]; $place--;
		$aOne = $aNumberString[$n-$place];
		$eTen = $ENumbers[$aTen-1+9]       if ( $aTen );
		$eOne = $ENumbers[$aOne-1]         if ( $aOne );


		#
		#  pos tracks our 'pos'ition in a sequence of 4 digits
		#  to help determine what separator we need between
		#  a groupings of tens and ones.
		#
		my $pos = ( $place % 4 ) / 2;  # make even/odd 


		#
		#  find a separator, if any, to follow ethiopic ten and one:
		#
		my $sep
		= ( $place )
		  ? ( $pos ) # odd
		    ? ( ($eTen ne '') || ($eOne ne '') )
		      ? '፻'
		      : ''
		    : '፼'
		  : ''
		;


		#
		#  if $eOne is an Ethiopic '፩' we want to clear it under
		#  under special conditions.  These ellision rules could be
		#  combined into a single big test but gets harder to read
		#  and manage:
		#
		# if ( ( $eOne eq '፩' ) && ( $eTen eq '' ) && ( $n > 1 ) ) {
		if ( ( $eOne eq '፩' ) && ( $eTen eq '' ) ) {
			if ( $sep eq '፻' ) {
				#
				#  A superflous implied ፩ before ፻
				#
				$eOne = '';
			}
			elsif ( ($place+1) == $n ) {   # recover from initial $place--
				#
				#  ፩ is the leading digit.
				#
				$eOne = '';
			}
		}


		#
		#  put it all together and append to our output number:
		#
		$eNumberString .= "$eTen$eOne$sep";	
	}

	$eNumberString;
}


sub convert
{
my $self = shift;


	#
	# reset string if we've been passed one:
	#
	$self->number ( @_ ) if ( @_ );

	( $self->number =~ /^[0-9]+$/ )
	  ? $self->_toEthiopic
	  : $self->_fromEthiopic
	;
}


sub number
{
my $self = shift;


	$self->{number} = $_[0] if ( @_ );

	$self->{number};
}


#########################################################
# Do not change this, Do not put anything below this.
# File must return "true" value at termination
1;
##########################################################


__END__


=head1 NAME

Convert::Ethiopic::Lite::Number - Convert Between Western and Ethiopic Numeral Systems

=head1 SYNOPSIS

 #
 #  instantiate with a Western or Ethiopic number (in UTF-8)
 #
 my $n = new Convert::Ethiopic::Lite::Number ( 12345 );
 my $etNumber = $n->convert;

 $n->number ( 54321 );    # reset number handle
 print $n->convert, "\n";

 print "2002 => ", $n->convert ( 2002 ), "\n";  # convert new number


=head1 DESCRIPTION

Implementation of the Ilf-Radix numeral conversion algorithm entirely
in Perl.  Use to convert between Western and Ethiopic numeral systems.

=head1 REQUIRES

Works perfectly with Perl 5.8.0, some what flaky with earlier versions
but could be readily adjusted.

=head1 BUGS

 None known yet.

=head1 AUTHOR

 Daniel Yacob,  Yacob@EthiopiaOnline.Net

=cut
