use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'XML::Atom::Lifeblog',
    'VERSION_FROM' => 'lib/XML/Atom/Lifeblog.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0.32,
	Image::Info => 0,
	XML::Atom => 0.11,
    },
);
