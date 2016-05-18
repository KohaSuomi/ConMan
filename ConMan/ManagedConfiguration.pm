package ConMan::ManagedConfiguration;

use Modern::Perl;
use ConMan::Context;

use ConMan::Logger;
my $logger = ConMan::Logger->get_logger(__PACKAGE__);

sub new {
  my ($class, $section, $operation, $source, $mapping) = @_;
  $logger->trace(@_);

  my $self = {source => ConMan::Context->getManagedConfigurationsDir().'/'.ConMan::Context->getLxcContainerName().'/'.$source,
              destination => ConMan::Context->getLxcRootfsMount().'/'.$mapping->{destination},
              mapping => $mapping};
  bless($self, $class);
  $self->{_conf} = $self->_loadManagedConfig($section, $operation);
  return $self;
}

sub _loadManagedConfig {
  my ($self, $section, $operation) = @_;

  open(my $FH, '<', $self->source()) or
    $logger->logdie("$! ".$self->source());

  my %conf;
  while(my $row = <$FH>){
    if ($row =~ /^\s*(.+?)\s*=\s*(.+?)\s*$/) {
      $conf{$1} = $2;
    }
  }
  close($FH);
  return \%conf;
}

sub deploy {
  my ($self) = @_;
  my $operation = lc($self->mapping()->{operation});
  $self->$operation();
  return $self;
}

sub overlay {
  my ($self) = @_;
  $logger->info('source '.$self->source().', destination '.$self->destination());

  open(my $FH, '<', $self->destination()) or
    $logger->logdie("$! ".$self->destination());

  my @conf = <$FH>;
  my $conf = join("", @conf);
  close($FH);

  while (my ($k, $v) = each(%{$self->conf()})) {
    $logger->trace("substitutin $k = $v");
    my $ok = $conf =~ s/^\s*\Q$k\E\s+=\s+.+?$/$k = $v/m;
    unless ($ok) {
      $conf .= "$k = $v\n";
      $logger->trace("not found");
    }
    else {
      $logger->trace("substituted");
    }
  }

  open($FH, '>', $self->destination()) or
    $logger->logdie("$! ".$self->destination());
  print $FH $conf;
  close($FH);

  $self->_chown();
}

sub copy {
  my ($self) = @_;
  $logger->info('source '.$self->source().', destination '.$self->destination());

  my $cmd = 'cp '.$self->source().' '.$self->destination();
  $logger->trace("$cmd");
  `$cmd`;

  $self->_chown();
}

sub _chown {
  my ($self) = @_;
  my $m = $self->mapping();
  my $cmd = 'chown '.$m->{uid}.':'.$m->{gid}.' '.$self->destination(); #chmod koha:koha filepath
  $logger->trace("$cmd");
  `$cmd`;
}

sub conf {
  my ($self, $key, $val) = @_;
  return $self->{_conf} unless $key;
  return $self->{_conf}->{$key} = $val if defined($val);
  return $self->{_conf}->{$key};
}
sub mapping {
  return shift->{mapping};
}
sub source {
  return shift->{source};
}
sub destination {
  return shift->{destination};
}

return 1;
