#! perl
# Copyright: 2001-2005 The Perl Foundation.  All Rights Reserved.
# $Id$

use strict;
use warnings;
use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Test;
use Parrot::Config;
use Cwd;

if ($^O =~ m!MSWin32!) {
  plan skip_all => 'win32 implementation missing'
} else {
  plan tests => 1
}

=head1 NAME

t/pmc/os.t - Files and Dirs

=head1 SYNOPSIS

	% prove t/pmc/os.t

=head1 DESCRIPTION

Tests the C<OS> PMC.

=cut

my $cwd = getcwd;

# Ugly hack. I accept suggestions.
$cwd =~ m!([/\\])parrot([/\\]?)$!;
my $upcwd = "$`$2";
my $xpto = "$cwd$1xpto$2";

pir_output_is(<<'CODE', <<"OUT", "cwd");
.sub main :main
        $P1 = new .OS
        $S1 = $P1."cwd"()
        print $S1
        print "\n"

        $S1 = ".."
        $P1."cd"($S1)

        $S1 = $P1."cwd"()
        print $S1
        print "\n"

        $S1 = "parrot"
        $P1."cd"($S1)

        $S1 = $P1."cwd"()
        print $S1
        print "\n"

        $S1 = "xpto"
        $S2 = "0555"
        $P1."mkdir"($S1,$S2)
        $P1."cd"($S1)

        $S1 = $P1."cwd"()
        print $S1
        print "\n"

        end
.end
CODE
$cwd
$upcwd
$cwd
$xpto
OUT

rmdir $xpto if -d $xpto;

