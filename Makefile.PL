use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	'NAME'		=> 'Convert::Ethiopic::Lite::Number',
	'DISTNAME'		=> 'Convert-Ethiopic-Lite',
	'VERSION_FROM'	=> 'lib/Convert/Ethiopic/Lite/Number.pm', # finds $VERSION
	'AUTHOR'	=> "Daniel Yacob <Yaocb\@EthiopiaOnline.Net>",
	'ABSTRACT'	=> "Conversion For Ethiopic Numerals and Dates in Perl.",
	dist			=>	{
		COMPRESS        =>	"gzip -9f",
		SUFFIX          =>	"gz",
		POSTOP          =>	'mv $(DISTNAME)-$(VERSION).tar.gz ../'
	}
);
