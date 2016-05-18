#!/usr/bin/perl

use Modern::Perl;
use Test::More;

use t::lib::LXC;

my $lxcName = 'testlxc';
t::lib::LXC::Clone($lxcName);
ok(-f ConMan::Context->getLxcRootfsMount().'/config', "Config copied");
ok(-d ConMan::Context->getLxcRootfsMount().'/rootfs', "Rootfs copied");

t::lib::LXC::Clean('testlxc');
ok(not(-f ConMan::Context->getLxcRootfsMount().'/config'), "Config cleaned");
ok(not(-d ConMan::Context->getLxcRootfsMount().'/rootfs'), "Rootfs cleaned");

done_testing();

