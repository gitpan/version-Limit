package version::Limit;

use 5.008_001;
use strict;
use warnings;
use version 0.41;

require Exporter;

our @ISA = qw(Exporter);

our $VERSION = '0.02';

# Preloaded methods go here.

sub import {
    my $self = shift;
    my $package = (caller())[0];
    $self->SUPER::import(@_);
    $self->export_to_level(1,$self,@_);
    eval "\*$package\::VERSION = \\&_VERSION";
}

sub Scope {
    my $package = (caller())[0];
    my $self;
    if ( scalar(@_) % 2 == 1 ) { # called as class method
    	$self = shift;
    }
    while ( @_ ) {
	my ($range, $reason) = (shift, shift);
	${$package::_INCOMPATIBILITY}{$range} = $reason;
    }
}

sub _VERSION {
#    $DB::single = 1;
    my ($package,$req) = @_;
    $req = version->new($req);
    my $version = version->new(eval("\$$package\::VERSION"));
    if ( $req > $version ) {
	die "$package version $req required--this is only version $version";
    }

    my @ranges = keys %{$package::_INCOMPATIBILITY};
    foreach my $range ( @ranges ) {
	my ($lb,$lower,$upper,$ub) =
		( $range =~ /^\s*(.)([0-9.]+)\s*,\s*([0-9.]+)(.)\s*$/ );
	$lb = '>' . ( $lb eq '[' ? '=' : '');
	$ub = '<' . ( $ub eq ']' ? '=' : '');
	$lower = version->new($lower);
	$upper = version->new($upper);
	my $test = "(\$req $lb \$lower and \$req $ub \$upper)";
	if ( eval $test ) {
	    die "Cannot 'use $package $req': "
	    	. ${$package::_INCOMPATIBILITY}{$range}
		."\n".$test;
	}
    }
    return $version;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

version::Limit - Perl extension for fine control of permitted versions

=head1 SYNOPSIS

  use version::Limit;
  version::Limit::Scope(
    "[0.0.0,1.0.0)" => "constructor syntax has changed",
    "[2.2.4,2.3.1)" => "frobniz method croaks without second argument",
  );


=head1 DESCRIPTION

In a mature, highly structured development environment, it is sometimes
desireable to exert a more fine-grained versioning model than that 
permitted by the default behavior.  With the standard Perl version model,
it is only possible to establish a maximum version (the most recent) for
a given module.  However, this precludes changing the provided interface, 
or specifically excluding certain versions (because of bugs).  Using this
module makes both of those things possible.

In addition, starting with Perl 5.8.0, the support for v-string's was
improved, but it is still difficult to use them for module versions.  The
B<version> compatibility module includes code that is proposed for Perl 
5.10.0, which will provide fully object oriented version objects.  With
version::Limit, it is possible to use bare v-string's to denote version's
without worrying about translation difficulty.

=head1 USAGE

This module is intended to be use'd by a module L</Author> to enforce the
interface restrictions inherent in their module.  From that point onwards,
anyone using B<that> module (L</Consumer>) is restricted from using specific
versions, with a useful error message explaining why.

=head2 Author

A module author who wishes to ensure than any interface changes are 
specified in a consistent way only needs to add a call like this to their
code:

  use version::Limit;
  version::Limit::Scope(
    # see subsequent discussion for what needs to go here
  );

and any L</Consumer> of their module will not accidently run an incompatible
version.
 
For example, if a module changes in a incompatible way at version 1.0.0,
then the following line will prevent any program from calling that module
and requesting any version from 0.0.0 to 1.0.0:

  version::Limit::Scope(
      "[0.0.0, 1.0.0)" => "constructor syntax has changed"
  );

The first term (the range) is coded using standard set notation.  The above
translates to:

  greater than or equal to 0.0.0 and less than 1.0.0

Note that both terminal characters are independent, so "(0.0.0, 1.0.0]" is
also a permitted range.

A module can also have holes in the permitted version values, for example to
account for a bug which was introduced in one version and fixed in a later 
one.  For example:

  version::Limit::Scope(
    "[2.2.4, 2.3.1)" => "frobniz method croaks without second argument"
  );

would signify that starting in version 2.2.4, there was a problem which 
wasn't fixed until 2.3.1.

A module can have as many or as few exclusions defined.  They can be 
initialized either individually or all at once.  The ranges must be
unique and exclusive, i.e. not overlap (although there is currently no
code that checks that).

=head2 Consumer

A consumer of a module restricted with version::Limit doesn't have to do 
anything except:

  use Some::Module 1.3;

and if that module has restrictions set and the requested version is inside
one of the restricted ranges, then the user's module will die with an 
appropriate error (as defined by the L</Author>).

B<NOTE:> if the Consumer doesn't specify a version on the L<use> line, they
will B<not> receive a warning, and the module will continue to load.  There is
no way for the L</Author> to require that the Consumer always specify which 
version they are targeting, but the L</Author> is strongly encouraged to state
this in their module documentation.

=head2 Limitations

Because this module uses cutting edge features of Perl, it is limited to
Perl 5.8.1 and greater, even though the B<version> module provides support
with all Perl versions 5.005_03 and greater.

=head1 EXPORT

None by default.

=head1 SEE ALSO

version

=head1 AUTHOR

John Peacock, E<lt>jpeacock@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by John Peacock

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.

=cut
