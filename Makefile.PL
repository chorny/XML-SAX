use ExtUtils::MakeMaker;
use File::Basename ();
use File::Spec ();


WriteMakefile1(
    'NAME'	=> 'XML::SAX',
    'VERSION_FROM' => 'SAX.pm', # finds $VERSION
    'PREREQ_PM' => { 
        'File::Temp' => 0,
        'XML::NamespaceSupport' => 0.03,
    },
    BUILD_REQUIRES => {
        'Test' => 0,
    },
    LICENSE => 'perl',
    META_MERGE => {
        resources => {
            repository => 'http://github.com/grantm/XML-SAX',
        },
    },
);

sub MY::install {
    package MY;
    my $script = shift->SUPER::install(@_);

    # Only modify existing ParserDetails.ini if user agrees

    my $write_ini_ok = 0;

    eval { require XML::SAX };
    if ($@) {
        $write_ini_ok = 1;
    }
    else {
        my $dir = File::Basename::dirname($INC{'XML/SAX.pm'});
        if (-e File::Spec->catfile($dir, 'SAX', 'ParserDetails.ini')) {
            $write_ini_ok =
                ExtUtils::MakeMaker::prompt(
                    "Do you want XML::SAX to alter ParserDetails.ini?", "Y"
                ) =~ /^y/i;
        }
        else {
            $write_ini_ok = 1;
        }
    }
    
    if ($write_ini_ok) {
        $script =~ s/install :: (.*)$/install :: $1 install_sax_pureperl/m;
        $script .= <<"INSTALL";

install_sax_pureperl :
\t\@\$(PERL) -MXML::SAX -e "XML::SAX->add_parser(q(XML::SAX::PurePerl))->save_parsers()"

INSTALL

    }

    return $script;
}

sub WriteMakefile1 {  #Written by Alexandr Ciornii, version 0.20
    my %params=@_;
    my $eumm_version=$ExtUtils::MakeMaker::VERSION;
    $eumm_version=eval $eumm_version;
    die "EXTRA_META is deprecated" if exists $params{EXTRA_META};
    die "License not specified" if not exists $params{LICENSE};
    if ($params{BUILD_REQUIRES}) { #and $eumm_version < 6.5503
        #Should be modified in future when EUMM will
        #correctly support BUILD_REQUIRES.
        #EUMM 6.5502 has problems with BUILD_REQUIRES
        $params{PREREQ_PM}={ %{$params{PREREQ_PM} || {}} , %{$params{BUILD_REQUIRES}} };
        delete $params{BUILD_REQUIRES};
    }
    delete $params{CONFIGURE_REQUIRES} if $eumm_version < 6.52;
    delete $params{MIN_PERL_VERSION} if $eumm_version < 6.48;
    delete $params{META_MERGE} if $eumm_version < 6.46;
    delete $params{META_ADD} if $eumm_version < 6.46;
    delete $params{LICENSE} if $eumm_version < 6.31;
    delete $params{AUTHOR} if $] < 5.005;
    delete $params{ABSTRACT_FROM} if $] < 5.005;
    delete $params{BINARY_LOCATION} if $] < 5.005;

    WriteMakefile(%params);
}
