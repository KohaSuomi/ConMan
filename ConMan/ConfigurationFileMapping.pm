package ConMan::ConfigurationFileMapping;

use Modern::Perl;

use ConMan::Logger;
my $logger = ConMan::Logger->get_logger(__PACKAGE__);

sub new {
  my ($class, $mappingString) = @_;
  $logger->trace("using $mappingString");

  my $self = {};
  bless($self, $class);
  $self->_decomposeMapping($mappingString);
  return $self;
}

sub _decomposeMapping {
    my ($self, $mapping) = @_;
    if ($mapping =~ /^(\w+) (\w+):(\w+) (.+)$/) {
        $self->{operation} = $1;
        $self->{uid} = $2;
        $self->{gid} = $3;
        $self->{destination} = $4;
        $logger->debug("decomposed: operation $1, uid $2, gid $3, destination $4");
    }
    else {
        $logger->logdie("couldn't decompose mapping $mapping");
    }
}

return 1;

