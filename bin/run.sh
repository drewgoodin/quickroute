#!/bin/sh

PSGI_SERVER=$(awk -F '=' '$1~/^psgi_server$/ {print $2}'<config)
SECURE_COOKIE=$(awk -F '=' '$1~/^secure_cookie$/ {print $2}'<config)
SESSION_TTL=$(awk -F '=' '$1~/^session_ttl$/ {print $2}'<config)
APP_ROOT=$(awk -F '=' '$1~/^app_root$/ {print $2}'<config)
CSV_DB=$(awk -F '=' '$1~/^csv_db$/ {print $2}'<config)
CACHE_ROOT=$(awk -F '=' '$1~/^cache_root$/ {print $2}'<config)
SECURE_PATH=$(awk -F '=' '$1~/^secure_path$/ {print $2}'<config)

plackup -s $PSGI_SERVER \
  -M Plack::App::File \
  -M Plack::Builder \
  -e "

use lib 'lib';
use Quickroute;

my \$public = sub { 
  do './routes/public.pl';
  my \$env = shift;
  \$env->{'csv.db'}=$CSV_DB;
  (our \$q = Quickroute->new(\$env))->go()
};

my \$auth = sub { 
  do './routes/auth.pl';
  my \$env = shift;
  \$env->{'csv.db'}=$CSV_DB;
  (our \$q = Quickroute->new(\$env))->go()
};

my \$pub = Plack::App::File->new(root => $APP_ROOT . '/pub')->to_app; #config

builder {
  mount '/' => builder {
    enable 'Session',
      store => Quickroute::Session::cache($CACHE_ROOT, $SESSION_TTL),
      state => Quickroute::Session::cookie($SECURE_COOKIE, $SESSION_TTL);
    \$public;
  };
  mount $SECURE_PATH =>  builder {
    enable sub {
      my \$app = shift;
      sub {
        my \$env = shift;
        my \$auth = Quickroute::Auth::auth_session(\$env, $CACHE_ROOT);
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
