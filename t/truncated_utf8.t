BEGIN {
    if ($ENV{'PERL_CORE'}) {
        chdir 't';
        unshift @INC, '../lib';
    }
    require Config; import Config;
    if ($Config{'extensions'} !~ /\bEncode\b/) {
      print "1..0 # Skip: Encode was not built\n";
      exit 0;
    }
    if (ord("A") == 193) {
      print "1..0 # Skip: EBCDIC\n";
      exit 0;
    }
    $| = 1;
}

use strict;
use warnings;

use Encode;
use PerlIO::encoding;
$PerlIO::encoding::fallback &= ~(Encode::WARN_ON_ERR|Encode::PERLQQ);

use Test::More tests => 6;

is(decode("UTF-8", "\xfd\xfe"), "\x{fffd}" x 2);
is(decode("UTF-8", "\xfd\xfe\xff"), "\x{fffd}" x 3);
is(decode("UTF-8", "\xfd\xfe\xff\xe0"), "\x{fffd}" x 4);
is(decode("UTF-8", "\xfd\xfe\xff\xe0\xe1"), "\x{fffd}" x 5);

my $str = ("x" x 1023) . "\xfd\xfe\xffx";
open my $fh, '<:encoding(UTF-8)', \$str;
my $str2 = <$fh>;
close $fh;
is($str2, ("x" x 1023) . ("\x{fffd}" x 3) . "x");

TODO: {
    local $TODO = "bug in perlio";
    my $str = ("x" x 1023) . "\xfd\xfe\xff";
    open my $fh, '<:encoding(UTF-8)', \$str;
    my $str2 = <$fh>;
    close $fh;
    is($str2, ("x" x 1023) . ("\x{fffd}" x 3));
}
