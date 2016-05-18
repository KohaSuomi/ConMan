package ConMan::ConfigurationManager;

use Modern::Perl;

use ConMan::Context;
use ConMan::ManagedConfiguration;
use ConMan::ConfigurationFileMapping;

use ConMan::Logger;
my $logger = ConMan::Logger->get_logger(__PACKAGE__);

sub new {
  my ($class) = @_;
  $logger->trace();

  my $self = {};
  bless($self, $class);
  return $self;
}

sub reconfigure {
  my ($self) = @_;
  $logger->trace();

  my $mappings = ConMan::Context->getConfigurationFileMapping();
  while( my ($source, $mapping) = each(%$mappings) ) {
      $logger->trace("mapping $source $mapping");
      my $managedConf = ConMan::ManagedConfiguration->new('lxc', 'clone', $source, ConMan::ConfigurationFileMapping->new($mapping))
                        ->deploy();
  }
}

return 1;
