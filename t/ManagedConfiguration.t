#!/usr/bin/perl

use Modern::Perl;
use Test::More;
use File::Slurp;

use ConMan::ManagedConfiguration;
use ConMan::ConfigurationFileMapping;


use t::lib::LXC;
my $lxcName = 'testlxc';
my $uname = 'kivilahtio'; #Verify files are owned by this user.
t::lib::LXC::Clone($lxcName);

subtest "Instantiate", \&instantiate;
sub instantiate {
  my $configurationFileMappingSource      = "lxc/config";
  my $configurationFileMappingDestination = "overlay $uname:$uname config";
  my $mgLxc = ConMan::ManagedConfiguration->new('lxc', 'clone',
                                     $configurationFileMappingSource,
                                     ConMan::ConfigurationFileMapping->new($configurationFileMappingDestination)
  );

  is($mgLxc->conf('lxc.utsname'), 'testlxc', 'lxc.utsname');
  is($mgLxc->conf('lxc.network.ipv4'), '10.0.3.23/24', 'lxc.network.ipv4');
}

subtest "Overlay config", \&overlay;
sub overlay {
  my $configurationFileMappingSource      = "lxc/config";
  my $configurationFileMappingDestination = "overlay $uname:$uname config";
  my $mgLxc = ConMan::ManagedConfiguration->new('lxc', 'clone',
                                     $configurationFileMappingSource,
                                     ConMan::ConfigurationFileMapping->new($configurationFileMappingDestination)
  );

  $mgLxc->deploy();

  #Test we got the desired changes
  my $newConfig = File::Slurp::read_file( ConMan::Context->getLxcConfigPath() );
  like(  $newConfig, qr/lxc.utsname = testlxc/s, 'testlxc');
  unlike($newConfig, qr/lxc.utsname = lxcBase/s, 'lxcBase overloaded');
  like(  $newConfig, qr/lxc.network.ipv4 = 10.0.3.23\/24/s, '10.0.3.23/24');
  unlike($newConfig, qr/lxc.network.ipv4 = 10.0.3.22\/24/s, '10.0.3.22/24 overloaded');

  my @stat = stat(ConMan::Context->getLxcConfigPath());
  is(getpwuid($stat[4]), $uname, "File owner $uname");
  is(getgrgid($stat[5]), $uname, "File group $uname");
}

subtest "Copy config", \&copy;
sub copy {
  my $configurationFileMappingSource      = "lxc/resolv.conf.base";
  my $configurationFileMappingDestination = "copy $uname:$uname rootfs/etc/resolvconf/resolv.conf.d/base";
  my $mgLxc = ConMan::ManagedConfiguration->new('lxc', 'clone',
                                     $configurationFileMappingSource,
                                     ConMan::ConfigurationFileMapping->new($configurationFileMappingDestination)
  );

  $mgLxc->deploy();

  #Test we got the desired changes
  my $newResolvConf = File::Slurp::read_file( ConMan::Context->getLxcRootfsMount()."/rootfs/etc/resolvconf/resolv.conf.d/base" );
  like(  $newResolvConf, qr/nameserver 10.0.3.1/, 'new resolv.conf copied');
  unlike($newResolvConf, qr/nameserver Bogus.Bill/, 'old resolv.conf replaced');

  my @stat = stat(ConMan::Context->getLxcRootfsMount()."/rootfs/etc/resolvconf/resolv.conf.d/base");
  is(getpwuid($stat[4]), $uname, "File owner $uname");
  is(getgrgid($stat[5]), $uname, "File group $uname");
}

done_testing();

