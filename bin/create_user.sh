#!/bin/sh

SQLITE_FILE=$(awk -F '=' '$1~/^sqlite_file$/ {print $2}'<config)

perl -e "

  use lib 'lib';
  use Quickroute::Auth;
  use DBI;

  my \$sqlite_file = '$SQLITE_FILE';
  die 'must set SQLite file path in config' unless \$sqlite_file;

  my \$dbh = DBI->connect('dbi:SQLite:dbname=$SQLITE_FILE',undef,undef);
  my \$sth = \$dbh->prepare('create table if not exists users(username text primary key, password blob not null, salt blob not null)');
  \$sth->execute;
  my \$match;
  my \$unique;
  my \$password;

  print qq?enter username: ?;
  my \$username = <>;
  chomp \$username;

  \$sth = \$dbh->prepare('select username from users where username = ?');
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

  my (\$salt, \$hash) = Quickroute::Auth::hash_password(\$password);

  \$sth = \$dbh->prepare('insert into users values(?,?,?)');
  \$sth->execute(\$username, \$hash, \$salt) or die 'could not write to DB';

  print qq?user '\$username' created\n?;

  "




