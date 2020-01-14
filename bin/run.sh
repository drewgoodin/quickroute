#!/bin/sh

PSGI_SERVER=$(awk -F '=' '$1~/^psgi_server$/ {print $2}'<config)
SECURE_COOKIE=$(awk -F '=' '$1~/^secure_cookie$/ {print $2}'<config)
SESSION_TTL=$(awk -F '=' '$1~/^session_ttl$/ {print $2}'<config)
APP_ROOT=$(awk -F '=' '$1~/^app_root$/ {print $2}'<config)
SQLITE_FILE=$(awk -F '=' '$1~/^sqlite_file$/ {print $2}'<config)
CACHE_ROOT=$(awk -F '=' '$1~/^cache_root$/ {print $2}'<config)
SECURE_PATH=$(awk -F '=' '$1~/^secure_path$/ {print $2}'<config)

plackup -s $PSGI_SERVER \
  -M Plack::App::File \
  -M Plack::Builder \
  -e "

use lib 'lib';
use Quickroute;

my \$sqlite_file = '$SQLITE_FILE';
die 'must set SQLite file path in config' unless \$sqlite_file;

my \$app_root = '$APP_ROOT';
die 'must set application root dir in config' unless \$sqlite_file;

my \$cache_root = '$CACHE_ROOT';
die 'must set cache root dir in config' unless \$sqlite_file;

my \$public = sub { 
  do './routes/public.pl';
  my \$env = shift;
  \$env->{'sqlite.file'}='$SQLITE_FILE';
  (our \$q = Quickroute->new(\$env))->go()
};

my \$auth = sub { 
  do './routes/auth.pl';
  my \$env = shift;
  \$env->{'sqlite.file'}='$SQLITE_FILE';
  (our \$q = Quickroute->new(\$env))->go()
};

my \$pub = Plack::App::File->new(root => '$APP_ROOT' . '/pub')->to_app; #config

builder {
  mount '/' => builder {
    enable 'Session',
      store => Quickroute::Session::cache('$CACHE_ROOT', $SESSION_TTL),
      state => Quickroute::Session::cookie('$SECURE_COOKIE', $SESSION_TTL);
    enable sub {
      my \$app = shift;
      sub {
        my \$env = shift;
        Quickroute::Session::expire_cookie(\$env, '$CACHE_ROOT'); #expire cookie if persist field not set in session data
        my \$res = \$app->(\$env);
        return \$res;
      };
    };
    \$public;
  };
  mount '$SECURE_PATH' =>  builder {
    enable sub {
      my \$app = shift;
      sub {
        my \$env = shift;
        my \$auth = Quickroute::Auth::auth_session(\$env, '$CACHE_ROOT'); #check session data for auth field
        return [ 403, ['Content-type' => 'text/plain'], [ 'forbidden' ] ] unless \$auth;
        my \$res = \$app->(\$env);
        return \$res;
      };
    };
    \$auth;
  };
  mount '/pub' => \$pub;
};

"
