#!/usr/bin/perl -w

BEGIN {
	chdir 't' if -d 't';
	unshift @INC, '../blib/lib', '../lib';
}

use Test::More 'no_plan';
require_ok( 'Acme::Pr0n' );

can_ok( 'Acme::Pr0n', 'import' );

package Foo;
$INC{'Foo.pm'} = 1;

use vars qw( @EXPORT @EXPORT_OK );

@EXPORT = qw( allowed );
@EXPORT_OK = qw( okay );

sub allowed {}
sub okay {}
sub disallowed {}

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

