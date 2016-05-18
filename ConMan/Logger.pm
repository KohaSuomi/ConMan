package ConMan::Logger;

use Modern::Perl;

use Log::Log4perl;

#use base qw(Log::Log4perl);
our @ISA = qw(Log::Log4perl);
Log::Log4perl->wrapper_register(__PACKAGE__);

#use ConMan::Context; #This causes a circular dependency

Log::Log4perl::init(ConMan::Context->getLog4perlConfig()) unless Log::Log4perl->initialized();

return 1;
