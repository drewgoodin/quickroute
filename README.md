**Quickroute** is a small PSGI web router/framework.

### Getting Started

---

Required Modules - use your preferred CPAN client to get them and their dependencies:

- Authen::Simple::DBI
- CHI
- Crypt::Eksblowfish::Bcrypt
- Data::Entropy::Algorithms
- DBD::SQLite
- HTML::Mason
- Plack::Middleware::Session
- URL::Encode

```
git clone https://github.com/goodind1/quickroute
cd quickroute
```

Edit 'config' and add values to the three fields that don't have defaults: app_root, sqlite_file, and cache_root. These are all absolute paths and you should create them first (for sqlite_file, just make sure the directory containing the file exists; Quickroute will make the database file). If desired, set secure_cookie to 1 (session data will only be transmitted over HTTPS), and change PSGI server to another module (such as Starman).

If using builtin authentication, run ```bin/create_user.sh```, which will create your SQLite database (if it doesn't exist) and a single 'users' table (likewise) containing only username and password data, as well as prompt you to create a user. You are free to create any other tables afterward.

Run ```bin/run.sh``` and navigate to localhost:5000. You will get a test page with login.

---

Routes are populated in ```./routes.pl``` with the following syntax:

```perl
route [path], [method] => sub {
  ###your code here###
}
```

[path] must be quoted, but [method] need not be if you stick with the 'fat comma' as above. Brackets shown just to separate parameters. See examples.

Don't use trailing slashes in defining routes ('/' being the exception); they get sawn off.

The subroutine reference shown above must return a single scalar containing the response content. This is most easily accomplished with the template() function (see exports). Call it last and you can avoid an explicit 'return'.

You must include a special route via the function ```noroute```, which defines what happens when you haven't defined a route for a given request (path + method combination). A default one is included already.

Quickroute doesn't care what you claim is an HTTP method, so code thoughtfully. 

It does set the minimum header/status code combination required by PSGI, but you can change/add to this on a per-route basis.

### Global $q
Within routes files, you have access to the Quickroute object created in app.psgi (one object is created per request). You can use this to call a few methods in your routing subs:

#### Object methods (that you care about)

```perl
$q->authen()                     # Authenticates current request against SQLite 'users' table using 'username' and 'password' POST parameters. Populates some session data on success.

$q->env()                        # Plack environment hash reference

$q->is_auth()                     # Checks session data for given request, if applicable, and returns true if 'auth' field is a true value (this field set by $q->authen())

$q->set_header('key' => 'value') # Set any response header

$q->status('some int')           # Set HTTP response code

$q->type('some supported type')  # Quickie for setting content type response header
```

### Exported Functions

```perl
route('path', 'method', sub {})

noroute(sub {})

template('mason component', @args)
```

### Content types

Content type defaults to text/html, but you can override this either through ```$q->set_header()```, or in a few cases through ```$q->type()```. Quickroute provides a small hash that maps single-word types to their mime-type. They are: plain, html, css, js, json, and xml. Using ```$q->type``` with any of these as arguments is a quick way to set this header.

### Examples

```perl
route '/', get => sub {
  template('index');
}

route '/api', get => sub {
  $q->status(201);
  $q->type('json');
  template('my_json_file');
}

noroute sub {
  $q->status(404);
  $q->type('plain);
  template('oops');
}

```

### Sessions

Every request, other than requests to resources under your secure_dir set in the config file, receives a 'Set-Cookie' header as part of the response, so the presence of a valid cookie is not enough to define a user as authenticated. The cookie only contains the session ID and any parameters such as 'secure' and the cookie expiration date. When a user authenticates, session data is set on the server and stored in the environment hash for the request. One of the session data fields is 'auth' and is set to a true value when a user authenticates. This session data persists in the cache and is expired according to you session_ttl in config. session_ttl also defines when the cookie expireson the client side, so these two expirations are in sync. If the session data field 'persist' is set to a true value upon authentication, the cookie will be sent without an expiration date and will therefore expire on the client side after the browser is closed. This is useful for implementing a 'remember me' feature, as is done in the sample site included with the source code. Session data can be accessed via ```$q->env->{'psgix.session'}```. This returns a hash reference.

Requests to resources under your secure_dir are not responded to with a Set-Cookie header. Rather, incoming requests are checked for a cookie that would have been set at the authentication stage above, and the session ID from this cookie is used to look up session data in the cache. The data is checked for the 'auth' field.

You can still restrict access to resources in your public routes file, but you will need to check session data for auth status on a per-route basis, via ```$q->is_auth()```. By populating routes in routes/auth.pl, this check is done for your automatically for any resources under secure_dir.

### Templates

HTML::Mason is the templating engine for Quickroute. If you've never used it, check out this [eBook](https://masonbook.houseabsolute.com/book/) and ignore all the stuff about Apache/mod_perl. In our case, we are using it purely as a template processor via [HTML::Mason::Interp](https://metacpan.org/pod/HTML::Mason::Interp).

Your Mason components must be kept in the included ```templates``` directory for the ```template()``` function to process them.
