package ConMan::Context;

use Modern::Perl;
use YAML;

our $CONMAN_CONF = init();
sub init {
  my $conf;
  if ($ENV{CONMAN_CONF}) {
    $conf = YAML::LoadFile( $ENV{CONMAN_CONF} );
  }
  else {
    die "'CONMAN_CONF' environment variable is not set";
  }
  _validateContext($conf);
  return $conf;
}
sub _validateContext {
  my ($conf) = @_;

  foreach my $k (qw(baseDir managedConfigurationDir log4perlConf configurationFileMapping)) {
    die "Conf $k is missing" unless $conf->{$k};
  }
}

require ConMan::Logger;
my $logger = ConMan::Logger->get_logger(__PACKAGE__);

my $lxcHookCloneParams;

sub setLxcHookCloneParams {
  my ($class, $ARGV) = @_;
  $lxcHookCloneParams = {
    containerName       => shift @$ARGV,
    section             => shift @$ARGV, #Typically lxc
    operation           => shift @$ARGV, #Typically clone
    lxcRootfsMount      => $ENV{LXC_ROOTFS_MOUNT},
    lxcConfigPath       => $ENV{LXC_CONFIG_FILE},
    lxcContainerName    => $ENV{LXC_NAME},
    lxcOldContainerName => $ENV{LXC_SRC_NAME},
    lxcRootfsPath       => $ENV{LXC_ROOTFS_PATH},
    ConManConfig        => $ENV{CONMAN_CONF},
    extraParams         => $ARGV,
  };
  $logger->trace("$lxcHookCloneParams");
  return $lxcHookCloneParams;
}

sub getBaseDir {
  return $CONMAN_CONF->{baseDir};
}
sub getConfigurationFileMapping {
  my ($class) = @_;
  my $lxcContainerName = ConMan::Context->getLxcContainerName();
  return $CONMAN_CONF->{configurationFileMapping} unless $lxcContainerName;
  return $CONMAN_CONF->{configurationFileMapping}->{$lxcContainerName} if $CONMAN_CONF->{configurationFileMapping}->{$lxcContainerName};
  return $CONMAN_CONF->{configurationFileMapping};
}
sub getManagedConfigurationsDir {
  return getBaseDir().'/'.$CONMAN_CONF->{managedConfigurationDir};
}
sub getLog4perlConfig {
  return getBaseDir().'/'.$CONMAN_CONF->{log4perlConf} if $CONMAN_CONF->{log4perlConf};
}
sub getLxcConfigPath {
  return $lxcHookCloneParams->{lxcConfigPath};
}
sub getLxcContainerName {
  return $lxcHookCloneParams->{containerName};
}
sub getLxcHookCloneParams {
  return $lxcHookCloneParams;
}
sub getLxcRootfsMount {
  return $lxcHookCloneParams->{lxcRootfsMount};
}

return 1;

