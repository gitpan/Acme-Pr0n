package Acme::Pr0n;

use strict;

use vars qw( $VERSION );
$VERSION = '0.02';

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
		my %skip;
		@skip{ @{ *{ $glob->{ EXPORT } }{ARRAY} },
			   @{ *{ $glob->{ EXPORT_OK } }{ARRAY} }
		} = ();

		foreach my $symbol ( keys %$glob ) {
			if (defined (my $code = *{ $glob->{ $symbol } }{CODE})) {
				next if exists $skip{ $symbol };
				*{ $caller . "::$symbol" } = $code;
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
little like consent.

=head2 EXPORT

None, by default.  I suppose you could use this module on yourself, but you'll
probably go blind if you do that.

=head1 TODO

=over 4

=item * Respect sigils in @EXPORT and @EXPORT_OK

=item * Handle variables.

=item * Expose SOURCE CODE, you fiend.

=item * Tell your mother what you're doing.

=head1 AUTHOR

chromatic E<lt>chromatic@wgz.orgE<gt>, with substantial thematic help from
Michael G Schwern, Mark-Jason Dominus, Joel Noble, and Norm Nunley.  Yikes.
You really had to be there.

Dave Cross suggested looking in %INC.  Go, Dave.

DJ Adams let me upload the initial version in the hallway at OSCON 2002 from
his laptop.  Now he's tainted too!

=head1 SEE ALSO

L<perl>, a psychiatrist.

=cut
