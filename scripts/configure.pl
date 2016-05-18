#!/usr/bin/perl

use Modern::Perl;

use ConMan::Context;
use ConMan::ConfigurationManager;
use ConMan::Logger;


ConMan::Context->setLxcHookCloneParams(\@ARGV);

my $logger = ConMan::Logger->get_logger(__PACKAGE__);


my $cm = ConMan::ConfigurationManager->new()->reconfigure();