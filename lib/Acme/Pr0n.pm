package Acme::Pr0n;

use strict;

use vars qw( $VERSION );
$VERSION = '0.03';

sub import {
	my $caller  = caller();

	no strict 'refs';

	foreach my $victim (@_) {
		(my $path = $victim) =~ s[::][/]g;
		unless (exists $INC{ $path . '.pm' }) {
			require Carp;
			Carp::croak("Some pervert is looking at unloaded module $victim!");
		}
		my $glob = *{ "main::${victim}::" };

		unless (exists $glob->{ VERSION } and
				${ *{ $glob->{VERSION} }{SCALAR} } >= 0.18) {
			require Carp;
			Carp::carp( "Module '$victim' too young!" );
		}

		my @exportlists = grep { exists $glob->{ $_ } } qw( EXPORT EXPORT_OK );

		my %skip;
		@skip{
			map { @{ *{ $glob->{ $_ } }{ARRAY} } } @exportlists 
		} = ();

		foreach my $symbol ( keys %$glob ) {
			foreach my $slots (
				[ 'CODE', '&', '' ],
				[ 'SCALAR', '$' ],
				[ 'ARRAY', '@' ],
				[ 'HASH', '%' ],
				[ 'IO', '*' ],
			) {
				my $slot = shift @$slots;
				my $skip_slot = 0;
				while (@$slots) {
					$skip_slot = 1, last
						if exists $skip{ shift( @$slots ) . $symbol };
				}
				next if $skip_slot;

				if (defined (my $ref = *{ $glob->{ $symbol } }{$slot})) {
					*{ $caller . "::$symbol" } = $ref;
				}
			}
		}
	}
}

1;

__END__

=head1 NAME

Acme::Pr0n - expose the naughty bits of modules to the world

=head1 SYNOPSIS

  use Acme::Pr0n qw( Regexp::English );

=head1 DESCRIPTION

Acme::Pr0n exposes the naughty bits of other modules.  Simply pass a list of
module names you want to uncover, and everything (well, every function, anyway)
normally hidden will be imported into your namespace.

It looks in @EXPORT and @EXPORT_OK, and ignores those.  You can see those
functions anyway.  Where's the fun in that?

Please note that you must have loaded the module you want to leer at -- it's a
little like consent.  The victim module must also have a version greater than
0.18.  If there's no version, Acme::Pr0n won't bother guessing.  It will
carp(), so be ready for that.

=head2 EXPORT

None, by default.  I suppose you could use this module on yourself, but you'll
probably go blind if you do that.  It's also under the age of consent.

=head1 TODO

=over 4

=item * Expose SOURCE CODE, you fiend.

=item * Tell your mother what you're doing.

=back

=head1 BUGS

Modules with custom import()s are more or less immune.  The author considers
this to be a feature, at least until he writes Glob::Util.  It's a surprisingly
tricky problem.

=head1 AUTHOR

chromatic E<lt>chromatic@wgz.orgE<gt>, with substantial thematic help from
Michael G Schwern, Mark-Jason Dominus, Joel Noble, and Norm Nunley.  Yikes.
You really had to be there.

Dave Cross suggested looking in %INC.  Go, Dave.

DJ Adams let me upload the initial version in the hallway at OSCON 2002 from
his laptop.  Now he's tainted too!

J. Waalboer E<lt>jwaalboer@convolution.nlE<gt> suggested some POD fixes.
Thanks!

=head1 SEE ALSO

L<perl>, a psychiatrist.

=cut
