**Quickroute** is a small PSGI web framework. Routes are populated in ```routes.pl``` with the following syntax:

```perl
route [path], [method] => sub {
  ###your code here###
}
```

[path] must be quoted, but [method] need not be if you stick with the 'fat comma' as above.

The subroutine reference shown above must return a single scalar containing the response content. This is most easily accomplished with the template() function below. Call it last and you can avoid an explicit 'return'.

You must include a special route via the function ```noroute``` (below), which defines what happens when you haven't defined a route for a given request (path + method combination). A default one is included already in ```routes.pl```.

Quickroute doesn't care what you claim is an HTTP method, so code thoughtfully. 

It does set the minimum header/status code combination required by PSGI, but you can change/add to this on a per-route basis.

### Globals

app.psgi runs in the main package and introduces a few globals, only one of which you should (optionally) access directly.

- **$env** - The Plack Environment hash. This is available in your route subroutines, so you can do things like parse query strings, etc.

***These are minupulated only by the exported functions of the Quickroute package; you shouldn't touch them directly***

- **%routes**  - A hash of hashes. The key is a url path. The value is a hash with HTTP method keys and subroutine reference values (the action that you take for a given route).
- **$status**  - HTTP response status code
- **%headers** - HTTP response header list

### Exported Functions

**route** path, method => sub {}

**noroute** => sub {}

**status**(http response code)

**set_header**('header' => 'value')

**type**(content type keyword)

**template**(mason component, arguments)

### Content types

Content type defaults to text/html, but you can override this either through set_header(), or in a few cases through type(). Quickroute provides a small hash mapping single-word types to their mime-type. They are: plain, html, css, js, json, and xml. Using type with any of these as arguments is a quick way to set this header without using set_header.

### Example 

```perl
route '/', get => sub {
  status(200);
  type(html);
  template(index);
}

route '/api', get => sub {
  status(201);
  type(json);
  template(my_json_file);
}
```

### Templates

HTML::Mason is the templating engine for Quickroute. If you've never used it, check out this [eBook](https://masonbook.houseabsolute.com/book/) and ignore all the stuff about Apache/mod_perl. In our case, we are using it purely as a template processor via [HTML::Mason::Interp](https://metacpan.org/pod/HTML::Mason::Interp).

Your template components must be kept in the includes ```templates``` directory for the ```template()``` function to process them.

### Required modules

- Plack
- HTML::Mason

Quickroute comes with a small startup script, ```run.sh```, which preloads HTML::Mason and sets the application to reload via Plack's [Shotgun](https://metacpan.org/pod/Plack::Loader::Shotgun).
