package App::cpanminus::script::Patch::RunShcompgen;

# DATE
# VERSION

use 5.010001;
use strict;
no warnings;

use Module::Patch 0.270 qw();
use base qw(Module::Patch);

use File::Which;

my $p_install = sub {
    my $ctx = shift;
    my $orig = $ctx->{orig};

    my $res = $orig->(@_);

    {
        warn __PACKAGE__.": Running install() ...\n" if $ENV{DEBUG};
        unless ($res) {
            # installation failed
            warn "  Returning, installation failed\n" if $ENV{DEBUG};
            last;
        }

        unless (which("shcompgen")) {
            warn __PACKAGE__.": Skipped, shcompgen not found\n" if $ENV{DEBUG};
            last;
        }

        # list the exes that got installed
        my @exes;
        for (glob("blib/bin/*"), glob("blib/script/*")) {
            s!.+/!!;
            push @exes, $_;
        }

        unless (@exes) {
            warn __PACKAGE__.": Skipped, no exes found\n" if $ENV{DEBUG};
            last;
        }

        warn __PACKAGE__.": Running shcompgen generate --replace ".join(" ", @exes)."\n" if $ENV{DEBUG};
        system "shcompgen", "generate", "--replace", @exes;
    }

    $res; # return original result
};

sub patch_data {
    return {
        v => 3,
        patches => [
            {
                action      => 'wrap',
                sub_name    => 'install',
                code        => $p_install,
            },
        ],
   };
}

1;
# ABSTRACT: Run shcompgen after distribution installation

=for Pod::Coverage ^(patch_data)$

=head1 SYNOPSIS

In the command-line:

 % perl -MModule::Load::In::INIT=App::cpanminus::script::Patch::RunShcompgen `which cpanm` ...


=head1 DESCRIPTION

This patch makes L<cpanm> run L<shcompgen> after a distribution installation so
when there are scripts that are installed, the shell completion for those
scripts can be activated immediately for use.


=head1 SEE ALSO

L<shcompgen>

=cut
