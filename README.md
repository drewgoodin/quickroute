**Quickroute** is a small PSGI web router/framework.

##Ignore all this, things are changing!

### Quickstart

---

```
git clone https://github.com/goodind1/quickroute
cd quickroute
plackup
```

Required Modules:

- Plack
- HTML::Mason

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
Within ```routes.pl```, you have access to the Quickroute object created in app.psgi (one object is created per request). You can use this to call a few methods in your routing subs:

#### Object methods (that you care about)

```perl
$q->env()                        # Plack environment hash reference

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

### Templates

HTML::Mason is the templating engine for Quickroute. If you've never used it, check out this [eBook](https://masonbook.houseabsolute.com/book/) and ignore all the stuff about Apache/mod_perl. In our case, we are using it purely as a template processor via [HTML::Mason::Interp](https://metacpan.org/pod/HTML::Mason::Interp).

Your Mason components must be kept in the included ```templates``` directory for the ```template()``` function to process them.
