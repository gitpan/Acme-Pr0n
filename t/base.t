#!/usr/bin/perl -w

BEGIN {
	chdir 't' if -d 't';
	unshift @INC, '../blib/lib', '../lib';
}

use Test::More tests => 10;
require_ok( 'Acme::Pr0n' );

can_ok( 'Acme::Pr0n', 'import' );

package Foo;
$INC{'Foo.pm'} = 1;

use vars qw( @EXPORT @EXPORT_OK $VERSION );

$VERSION = 1.0;
@EXPORT = qw( allowed );
@EXPORT_OK = qw( okay );

sub allowed {}
sub okay {}
sub disallowed {}

package Bar;

use vars '$VERSION';
$VERSION = 0.17;

package Baz;

$INC{'Baz.pm'} = 1;
use vars qw( $VERSION @EXPORT );
$VERSION = 0.18;

package main;

for (qw( allowed okay disallowed )) {
	ok( ! __PACKAGE__->can( $_ ),
		"main should not be able to $_() before importing" );
}

Acme::Pr0n::import( 'Foo' );
ok( ! __PACKAGE__->can( 'allowed' ),
	'normally exported items should be ignored' );
ok( ! __PACKAGE__->can( 'okay' ), '... and so should be allowed exports' );
ok( __PACKAGE__->can( 'disallowed' ),
	'... but non-exported should be imported!' );

eval { Acme::Pr0n::import( 'Bar' ) };
isnt( $@, '', 'import() should die when confronted with non-loaded module' );

$INC{ 'Bar.pm' } = 1;

local *Carp::carp;
*Carp::carp = sub {
	die $_[0];
};

eval { Acme::Pr0n::import( 'Bar' ) };
like( $@, qr/Module 'Bar' too young!/,
	'... or when confronted with too young a module' );
