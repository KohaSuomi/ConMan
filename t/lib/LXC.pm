package t::lib::LXC;

use Modern::Perl;

use ConMan::Context;
use ConMan::Logger;
my $logger = ConMan::Logger->get_logger(__PACKAGE__);

my $baseTempDir = '/tmp/testConMan';

=head2 Clone

Emulates the lxc.hook.clone -call

Sets the environment variables

=cut

sub Clone {
  my ($lxcContainerName) = @_;
  Clean($lxcContainerName);
  my $env = _setEnv($lxcContainerName);

  my $cmd = "cp -r t/lxcBase/ ".$ENV{LXC_ROOTFS_MOUNT};
  $logger->trace("$cmd");
  `$cmd`;

  return $env;
}

sub Clean {
  my ($lxcContainerName) = @_;
  _setEnv($lxcContainerName);
  if (-d $ENV{LXC_ROOTFS_MOUNT}) {
    my $cmd = 'rm -r '.$ENV{LXC_ROOTFS_MOUNT};
    $logger->trace("$cmd");
    `$cmd`;
  }
}

sub _setEnv {
  my ($lxcContainerName) = @_;
  my @ARGV = (
    $lxcContainerName,
    'lxc',
    'clone',
  );
  $ENV{LXC_NAME} = $lxcContainerName;
  $ENV{LXC_SRC_NAME} = 'lxcBase';
  $ENV{LXC_ROOTFS_MOUNT} = "$baseTempDir/$lxcContainerName/";
  $ENV{LXC_CONFIG_FILE} = $ENV{LXC_ROOTFS_MOUNT}.'/config';
  $ENV{LXC_ROOTFS_PATH} = $ENV{LXC_ROOTFS_MOUNT}.'/rootfs/';

  my $cmd = "mkdir -p $baseTempDir";
  $logger->trace("$cmd");
  `$cmd`;

  return ConMan::Context->setLxcHookCloneParams(\@ARGV);
}

sub baseTempDir {
  return $baseTempDir;
}

return 1;
