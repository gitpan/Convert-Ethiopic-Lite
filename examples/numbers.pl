#!/usr/bin/perl -w

use Convert::Ethiopic::Lite::Number;

use utf8;
if ( $] >= 5.007 ) {
	binmode (STDOUT, ":utf8");
}


my @testNumbers = (
	"1",
	"10",
	"100",
	"1000",
	"10000",
	"100000",
	"1000000",
	"10000000",
	"100000000",
	"100010000",
	"100100000",
	"100200000",
	"100110000",
	"1",
	"11",
	"111",
	"1111",
	"11111",
	"111111",
	"1111111",
	"11111111",
	"111111111",
	"1111111111",
	"11111111111",
	"111111111111",
	"1111111111111",
	"1",
	"12",
	"123",
	"1234",
	"12345",
	"7654321",
	"17654321",
	"51615131",
	"15161513",
	"10101011",
	"101",
	"1001",
	"1010",
	"1011",
	"1100",
	"1101",
	"1111",
	"10001",
	"10010",
	"10100",
	"10101",
	"10110",
	"10111",
	"100001",
	"100010",
	"100011",
	"101010",
	"1000001",
	"1000101",
	"1010000",
	"1010001",
	"1100001",
	"1010101",
	"101010101",
	"3",
	"30",
	"33",
	"303",
	"3003",
	"3030",
	"3033",
	"3300",
	"3303",
	"3333",
	"30003",
	"30303",
	"300003",
	"303030",
	"3000003",
	"3000303",
	"3030003",
	"3300003",
	"3030303",
	"303030303",
	"333333333",
);

my $n = new Convert::Ethiopic::Lite::Number;

foreach ( @testNumbers ) {
	$n->number ( $_ );
	my $number = $n->convert;
	print "$_ => $number => ", $n->convert ( $number ), ".\n";
}

