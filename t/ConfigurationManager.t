#!/usr/bin/perl

use Modern::Perl;
use Test::More;
use File::Slurp;

use t::lib::LXC;
use ConMan::ConfigurationManager;

my $lxcName = 'testlxc';
t::lib::LXC::Clone($lxcName);


my $cm = ConMan::ConfigurationManager->new();
$cm->reconfigure();

#Test we got the desired changes
my $newConfig = File::Slurp::read_file( ConMan::Context->getLxcConfigPath() );
like(  $newConfig, qr/lxc.utsname = testlxc/s, 'testlxc');
unlike($newConfig, qr/lxc.utsname = lxcBase/s, 'lxcBase overloaded');
like(  $newConfig, qr/lxc.network.ipv4 = 10.0.3.23\/24/s, '10.0.3.23/24');
unlike($newConfig, qr/lxc.network.ipv4 = 10.0.3.22\/24/s, '10.0.3.22/24 overloaded');

#Test we got the desired changes
my $newResolvConf = File::Slurp::read_file( ConMan::Context->getLxcRootfsMount()."/rootfs/etc/resolvconf/resolv.conf.d/base" );
like(  $newResolvConf, qr/nameserver 10.0.3.1/, 'new resolv.conf copied');
unlike($newResolvConf, qr/nameserver Bogus.Bill/, 'old resolv.conf replaced');

#Test we got the desired changes
my $newKohaInstallLog = File::Slurp::read_file( ConMan::Context->getLxcRootfsMount()."/rootfs/home/koha/koha-dev/misc/koha-install-log" );
like(  $newKohaInstallLog, qr/DB_PASS=love/, 'new koha-install-log copied');
unlike($newKohaInstallLog, qr/DB_PASS=wqfvuvrtpbj813/, 'old koha-install-log replaced');


done_testing();
