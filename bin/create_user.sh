#!/bin/sh

CSV_DB=$(awk -F '=' '$1~/^csv_db$/ {print $2}'<config)

perl -e "

  use Data::Entropy::Algorithms qw!rand_bits!;
  use Crypt::Eksblowfish::Bcrypt qw!bcrypt_hash!;
  use DBI;

  my \$dbh = DBI->connect('dbi:CSV:f_dir=$CSV_DB');
  my \$match;
  my \$unique;
  my \$password;

  print qq?enter username: ?;
  my \$username = <>;
  chomp \$username;

  my \$sth = \$dbh->prepare('select username from users where username = ?');
  \$sth->execute(\$username);

  \$unique = 1 unless \$sth->fetchrow_array();

  until (\$unique) {
    print qq?user already exists! try again\n?;
    print qq?enter username: ?;
    \$username = <>;
    chomp \$username;
    \$sth->execute(\$username);
    \$unique = 1 unless \$sth->fetchrow_array();
  }

  print qq?password: ?;
  system('stty -echo');
  my \$pass1 = <>;
  print qq?\n?;
  print qq?confirm password: ?;
  my \$pass2 = <>;
  print qq?\n?;
  system('stty echo');

  \$match = 1 if \$pass1 eq \$pass2;

  until (\$match) {
    print qq?passwords don't match, try again\n?;
    print qq?password: ?;
    system('stty -echo');
    my \$pass1 = <>;
    print qq?\n?;
    print qq?confirm password: ?;
    my \$pass2 = <>;
    print qq?\n?;
    system('stty echo');
    \$match = 1 if \$pass1 eq \$pass2;
  }

  \$password = \$pass1;
  chomp \$password;

  my \$salt = rand_bits(16*8);
  my \$hash = bcrypt_hash({
      key_nul => 1,
      cost => 6,
      salt => \$salt,
    }, \$password);

  \$sth = \$dbh->prepare('insert into users values(?,?,?)');
  \$sth->execute(\$username, \$hash, \$salt) or die 'could not write to DB';

  print qq?user '\$username' created\n?;

  "




