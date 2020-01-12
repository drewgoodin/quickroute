#!/bin/sh

# install Perl dependencies
cpanm \
  Authen::Simple::DBI \
  Crypt::Eksblowfish::Bcrypt \
  Data::Entropy::Algorithms \
  DBD::CSV \
  DBI \
  CHI \
  HTML::Mason \
  Plack \
  Plack::App::File \
  Plack::Builder \
  Plack::Middleware::Session
  
CSV_DB=$(awk -F '=' '$1~/^csv_db$/ {print $2}'<config)

perl -e "
  use strict;
  use warnings;

  use Data::Entropy::Algorithms qw!rand_bits!;
  use Crypt::Eksblowfish::Bcrypt qw!bcrypt_hash!;
  use DBI;

  mkdir '$CSV_DB' unless -e '$CSV_DB';

  open my \$fh, '>', '$CSV_DB/users';
  print \$fh 'username,password,salt' . qq?\n?;
  close \$fh;

  print qq?\nDatabase file initialized. Run 'bin/create_user'!\n?;

"
