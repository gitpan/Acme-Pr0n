#!/usr/bin/perl -w

BEGIN {
	chdir 't' if -d 't';
	unshift @INC, '../blib/lib', '../lib';
}

use Test::More tests => 8;
require_ok( 'Acme::Pr0n' );

package Foo;
$INC{'Foo.pm'} = 1;
$VERSION = 0.20;

use vars qw( @EXPORT @EXPORT_OK $allowed $forbidden @array %hash $VERSION );

@EXPORT = qw( $allowed hash );
@EXPORT_OK = qw( array );

sub allowed { 14 }
$allowed = 11;
$forbidden = 12;
sub array {}
@array = ( 1 .. 4 );
%hash = ( foo => 'bar' );
sub hash { 'hash' }

package main;

Acme::Pr0n::import( 'Foo' );

isnt( $main::allowed, 11, 'import() should not import exported scalars' );
is( allowed(), 14, '... but should import subs of the same name' );
is( $main::forbidden, 12, '... and should import nonexported scalars' );
is( @main::array, 4, '... importing nonexported arrays' );
ok( ! __PACKAGE__->can( 'array'), '... but not exported subs of the same name');
is( $main::hash{foo}, 'bar', '... importing nonexported hashes' );
ok( ! __PACKAGE__->can( 'hash'), '... but not exported subs of the same name');

# now silence 'used only once' errors
$main::allowed = $main::forbidden;
@main::array = %main::hash = ();
