package App::cpanminus::script::Patch::RunShcompgen;

# DATE
# VERSION

use 5.010001;
use strict;
no warnings;

use Module::Patch 0.12 qw();
use base qw(Module::Patch);

use File::Which;

my $p_install = sub {
    my $ctx = shift;
    my $orig = $ctx->{orig};

    my $res = $orig->(@_);

    {
        last unless $res; # installation failed

        last unless which("shcompgen");

        # list the exes that got installed
        my @exes;
        for (glob("blib/bin/*"), glob("blib/script/*")) {
            s!.+/!!;
            push @exes, $_;
        }

        last unless @exes;

        system "shcompgen", "generate", @exes;
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
