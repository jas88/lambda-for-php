#!/usr/bin/perl -w

use strict;

headerv("brotli","deps/brotli/c/common/version.h","BROTLI_VERSION",3);
headerv("curl","deps/curl/include/curl/curlver.h","LIBCURL_VERSION_NUM",2);
headers("php","deps/php-src/main/php_version.h","PHP_VERSION");
headers("zlib","deps/zlib/zlib.h","ZLIB_VERSION");
headers("openssl","deps/openssl/include/openssl/opensslv.h","OPENSSL_VERSION_TEXT");
cmakev("re2c","deps/re2c/CMakeLists.txt","re2c");
simplev("sqlite","deps/sqlite/VERSION");
pov("xz","deps/xz/po4a/de.po","Project-Id-Version: xz");
htmlh3("libxml2","deps/libxml2/doc/xml.html");

exit;

# Grotty hack: get libxml2's from the changelog HTML
sub htmlh3 {
  my $lib=shift;
  my $file=shift;
  open my $fh,'<',$file or die "$file:$!\n";
  while(<$fh>) {
    chomp;
    if (/^<h3>v([^:]+):/) {
      print "$lib:$1\n";
      return;
    }
  }
  die "No version info found in $file\n";
}

# Version file, e.g. SQLite has a file VERSION containing just the release.
sub simplev {
  my $lib=shift;
  my $file=shift;
  open my $fh,'<',$file or die "$file:$!\n";
  my $v=<$fh>;
  die "Could not read version file:$file:$!\n" unless defined $v;
  chomp $v;
  print "$lib:$v\n";
}


# Version in .po string
# e.g.
# xz:"Project-Id-Version: xz 5.2.5\n"
sub pov {
  my $lib=shift;
  my $file=shift;
  my $var=shift;
  open my $fh,'<',$file or die "$file:$!\n";
  while(<$fh>) {
    chomp;
    if (/^"${var}\s+(.+)\\n"$/) {
      print $lib,":",$1,"\n" ;
      return;
    }
  }
  die "No version info found in $file\n";
}

# Simple version string
# e.g.
# PHP: #define PHP_VERSION "7.4.8"
# OpenSSL: # define OPENSSL_VERSION_TEXT    "OpenSSL 1.1.1g  21 Apr 2020"
sub headers {
  my $lib=shift;
  my $file=shift;
  my $var=shift;
  open my $fh,'<',$file or die "$file:$!\n";
  while(<$fh>) {
    chomp;
    if (/^#\s*define\s+${var}\s+"(.+)"$/) {
      if ($1=~/^OpenSSL\s+([^ ]+)\s+.+$/) { # Special case for OpenSSL
        print $lib,":",$1,"\n";
      } else {
        print $lib,":",$1,"\n";
      }
      return;
    }
  }
  die "No version info found in $file\n";
}

# CMake variable
# e.g.
# re2c: project(re2c VERSION 2.0.2 HOMEPAGE_URL "https://re2c.org/")
sub cmakev {
  my $lib=shift;
  my $file=shift;
  my $var=shift;
  open my $fh,'<',$file or die "$file:$!\n";
  while(<$fh>) {
    chomp;
    if (/^project\(${var}\s+VERSION\s+([^ ]+)\s+/) {
      print $lib,":",$1,"\n";
      return;
    }
  }
  die "No version info found in $file\n";
}

# Extract a version from a C hex constant
# e.g.
# brotli BROTLI_VERSION 0xMmmmppp (major, minor, patch)
# curl LIBCURL_VERSION_NUM 0xMMnnpp 
sub headerv {
  my $lib=shift;
  my $file=shift;
  my $var=shift;
  my $chars=shift;
  
  open my $fh,'<',$file or die "$file:$!\n";
  while(<$fh>) {
    chomp;
    if (/^#define\s+${var}\s+0x([0-9a-fA-F]{1,})([0-9a-fA-F]{${chars}})([0-9a-fA-F]{${chars}})$/) {
      print "$lib:",hex($1),".",hex($2),".",hex($3),"\n";
      return;
    }
  }
  die "No matches for ", qr/^#define\s+${var}\s+0x([0-9a-fA-F]{1,})([0-9a-fA-F]{${chars}})([0-9a-fA-F]{${chars}})$/," in ",$file,"\n";
}