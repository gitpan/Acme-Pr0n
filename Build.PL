use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Acme::Pr0n',
    license             => 'perl',
    dist_author         => 'chromatic <chromatic@wgz.org>',
    dist_version_from   => 'lib/Acme/Pr0n.pm',
	requires            =>
	{
	},
    build_requires      =>
	{
		'Test::Simple'  => '0.45',
    },
    add_to_cleanup      => [ 'Acme-Pr0n-*' ],
	create_makefile_pl  => 'traditional',
	sign                => 1,
);

$builder->create_build_script();
