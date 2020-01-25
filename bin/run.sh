#!/bin/sh

PSGI_SERVER=$(awk -F '=' '$1~/^psgi_server$/ {print $2}'<config)
SECURE_COOKIE=$(awk -F '=' '$1~/^secure_cookie$/ {print $2}'<config)
SESSION_TTL=$(awk -F '=' '$1~/^session_ttl$/ {print $2}'<config)
APP_ROOT=$(awk -F '=' '$1~/^app_root$/ {print $2}'<config)
SQLITE_FILE=$(awk -F '=' '$1~/^sqlite_file$/ {print $2}'<config)
CACHE_ROOT=$(awk -F '=' '$1~/^cache_root$/ {print $2}'<config)

plackup -s $PSGI_SERVER \
  -M Plack::App::File \
  -M Plack::Builder \
  -e "

use lib 'lib';
use Quickroute;

do './routes.pl';

my \$sqlite_file = '$SQLITE_FILE';
die 'must set SQLite file path in config' unless \$sqlite_file;

my \$app_root = '$APP_ROOT';
die 'must set application root dir in config' unless \$app_root;

my \$cache_root = '$CACHE_ROOT';
die 'must set cache root dir in config' unless \$cache_root;

my \$app = sub { 
  my \$env = shift;
  \$env->{'sqlite.file'}='$SQLITE_FILE';
  (our \$q = Quickroute->new(\$env))->go()
};

my \$pub = Plack::App::File->new(root => '$APP_ROOT' . '/pub')->to_app; #config

builder {
  mount '/' => builder {
    enable 'Session',
      store => Quickroute::Session::cache('$CACHE_ROOT', $SESSION_TTL); # sessions inactive for specified TTL will be flushed from cache
      state => Quickroute::Session::cookie('$SECURE_COOKIE'); 
    enable sub {
      my \$app = shift;
      sub {
        my \$env = shift;
        Quickroute::Session::perm_cookie(\$env, '$CACHE_ROOT'); # set a 'permanent' cookie (1yr) on the client if 'persist' field set in session data. Invalidated upon logout.
        my \$res = \$app->(\$env);
        return \$res;
      };
    };
    \$app;
  };
  mount '/pub' => \$pub;
};

"
