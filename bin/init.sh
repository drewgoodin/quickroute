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
  Plack::Builder
  Plack::Middleware::Session \ 
  
CSV_DB=$(awk -F '=' '$1~/^csv_db$/ {print $2}'<config)

perl -e "
  use strict;
  use warnings;

  use Data::Entropy::Algorithms qw!rand_bits!;
  use Crypt::Eksblowfish::Bcrypt qw!bcrypt_hash!;
  use DBI;

  my \$username = 'admin';
  my \$password = 'quickroute';
  my \$hash = bcrypt_hash({
      key_nul => 1,
      cost => 6,
      salt => \$salt,
    }, \$password);

  my \$dbh = DBI->connect('dbi:CSV:f_dir=$CSV_DB');
  my \$sth = \$dbh->prepare('insert into users values (?,?)');
  \$sth->execute(\$username, \$hash) or die 'could not write to DB';
"
