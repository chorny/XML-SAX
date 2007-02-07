use strict;
use warnings;

use Test;
BEGIN { plan tests => 4 }

use XML::SAX::PurePerl;

my $handler = AttrHandler->new();
ok($handler);

my $parser = XML::SAX::PurePerl->new(Handler => $handler);
ok($parser);

$parser->parse_string('<code amp="&amp;" x3E="&#x3E;" />');
ok(1); # parser didn't die

my $expected = "amp=& x3E=> ";
ok($handler->attributes, $expected);
if($handler->attributes ne $expected) {
    print "# expected: '$expected'\n";
    print "# got:      '" . $handler->attributes . "'\n";
}

exit;


package AttrHandler;

use base 'XML::SAX::Base';

sub start_document { shift->{_buf} = '';             }
sub attributes     { shift->{_buf};                  }

sub start_element {
    my($self, $data) = @_;
    my $attr = $data->{Attributes};
    foreach (sort keys %$attr) {
        $self->{_buf} .= "$attr->{$_}->{LocalName}=$attr->{$_}->{Value} ";
    }
}
