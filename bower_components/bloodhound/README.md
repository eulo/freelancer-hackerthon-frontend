# Bloodhound

Bloodhound is a view resolver for a variety of client side template languages.
It has very few dependencies, was built with flexibility and modularity in
mind, and is Dependency Injection-friendly.

## Why Use a View Resolver

Client side templates have freed the browser from requiring a backend just to
transform data into HTML. Most template languages available today give you the
ability to render views inside views, sometimes called sub templates or
partials. The downside is that many template implementations do not automate the
loading of these sub templates. They only render data to HTML.

A view resolver allows you to decouple the rendering of a view from the gritty
details of loading all necessary partials and rendering them.

A view resolver should:

- Provide an easy to use, generic interface for all rendering operations
- Decouple rendering from the template language being used
- Make it easy to add support for additional template languages
- Cache templates for quicker rendering
- Decouple the name of a view from the location of its source code
- Be easy to use with Dependency Injection and Inversion of Control

Bloodhound was built with these ideas in mind.

## Getting Started

It's easy to get started using Bloodhound.

### Acquiring Bloodhound

For those with NodeJS and Bower installed, simply add Bloodhound as a dependency
in your project, then run `bower install`.

In your bower.json file:

```javascript
{
    "dependencies": {
        "bloodhound": "~1.0"
    }
}
```

Otherwise, you can download the source or clone it from GitHub:

- Download: https://github.com/gburghardt/bloodhound/downloads/master.zip
- Clone: `git clone https://github.com/gburghardt/bloodhound.git`

### Viewing the Demo

You can view the demo pages to see it work right out of the box:

1. Download or clone the Bloodhound source code
2. View `demo/mustache_templates/index.html` or `demo/simple_templates/index.html`
   in any browser. No web server required.
3. To view the demo for Dynamic Views, you'll need to point a web server to the
   root directory for this library, and go to
   `http://localhost/path/to/bloodhound/demo/mustache_templates/dynamic.html` or
   `http://localhost/path/to/bloodhound/demo/simple_templates/dynamic.html`

## Embedded Versus Dynamic Views

Bloodhound gives you two ways to resolve views: Embedded and Dynamic.

An Embedded View means the template source code for that view exists on the web
page as a `<script>` tag, e.g.

```html
<script type="text/html" data-template-name="foo">
    <p>Foo: {{foo}}</p>
</script>
```

This is probably the most familiar kind of view for front end developers, and is
the prevailing pattern.

The second pattern, Dynamic Views, allows you to embed template source code just
like Embedded Views, but also download template source code on demand via AJAX.

Advantages of Embedded Views:

- Builds on a pattern already in use by developers
- All Bloodhound method calls are synchronous, since the template code lives on
  the web page already.
- It's easier to implement and maintain
- Rendering views is more responsive because they do not have to be downloaded
  first.
- Easiest to integrate into existing code bases
- Easiest for new developers to grok when they start on the project

Disadvantages of Embedded Views:

- All views must be embedded on the web page in order to be rendered
- Adding a view means remembering to embed it on the web page as well
- The more views you add to a page, the bigger the page weight

Advantages of Dynamic Views:

- Since URLs to template source code can be generated by a convention, you do
  not need to add that view to the web page. You can simply start rendering it
  and Bloodhound takes care of the rest for you.
- You can still use Embedded Views
- You can map the name of a view in JavaScript to a custom URL, making it easier
  to refactor your code, or dynamically generate a template on the server to be
  delivered to the client.
- Template source code is cached, so subsequent calls to render a view are much
  quicker.
- Helps reduce page load times since the template code is not delivered with the
  HTML file to the browser. Can be especially beneficial for mobile sites.

Disadvantages of Dynamic Views:

- Downloading template source code via convention based URLs is one more layer
  of abstraction.
- Many method calls in Bloodhound become asynchronous, requiring additional
  attention by the programmer so the user interface still seems responsive.
- Since view names can be mapped to different URLs, tracking down the template
  file rendered for a certain view can become more difficult.
- The first time a view is rendered will be the slowest, since the template and
  all sub templates must be downloaded asynchronously before rendering.

## Embedded Views

Embedded Views are the easiest to implement, and build on a pattern already in
use by many front end developers. The template source code for a view resides in
the DOM inside `script` tags.

```html
<script type="text/html" data-template-name="blog/post">
    <h2>{{title}}</h2>
    <p>{{date}}</p>
    <div>
        {{{body}}}
    </div>
</script>
```

This example is using Mustache templates. You can render this template by
referring to its name, `blog/post`. Below is the JavaScript required to wire
things together:

```javascript
var provider = new Bloodhound.ViewProviders.MustacheViewProvider(),
    resolver = new Bloodhound.ViewResolvers.EmbeddedViewResolver(document, provider),
    renderingEngine = new Bloodhound.RenderingEngines.EmbeddedRenderingEngine(resolver);

var data = {
    title: "Test",
    date: "2014/02/11",
    body: "<p>Just a blog post</p>"
};
```

```javascript
var html = renderingEngine.render("blog/post", data);
```

The `html` variable holds the rendered Mustache template. You can render
directly to an HTML tag by Id:

```javascript
renderingEngine.render("blog/post", data, "blog_post");
```

The rendered source for `blog/post` will be inserted into an HTML tag whose Id
is `blog_post` by setting the `innerHTML` property. You may also use a reference
to a DOM node:

```javascript
var node = document.getElementById("blog_post");

renderingEngine.render("blog/post", data, node);
```

In each case, the return value of `renderingEngine.render` is the rendered HTML
source:

```javascript
var html = renderingEngine.render("blog/post", data, "blog_post");
```

**Demo: `demo/mustache_templates/index.html`**

If the template language supports it, sub templates (sometimes called partials),
can be rendered as well. We'll use Mustache templates as an example:

```html
<body>
    <div id="blog_post"></div>

    <script type="text/html" data-template-name="blog/post">
        <h2>{{title}}</h2>
        <p>{{date}}</p>
        <div>
            {{{body}}}
        </div>
        <ol class="comments">
            {{> blog/post/comments}}
        </ol>
    </script>

    <script type="text/html" data-template-name="blog/post/comments">
        {{#comments}}
            <li>
                {{text}} &mdash; {{author}}, {{date}}
            </li>
        {{/comments}}
    </script>

    <script type="text/javascript">
        var provider = new Bloodhound.ViewProviders.MustacheViewProvider(),
            resolver = new Bloodhound.ViewResolvers.EmbeddedViewResolver(document, provider),
            renderingEngine = new Bloodhound.RenderingEngines.EmbeddedRenderingEngine(resolver);

        var data = {
            title: "Test",
            date: "2014/02/11",
            body: "<p>Just a blog post</p>",
            comments: [{
                text: "Great info!",
                author: "Concerned Citizen",
                date: "2014/02/04"
            },{
                text: "Trash talk!",
                author: "Anonymous Coward",
                date: "2014/01/28"
            }]
        };

        renderingEngine.render("blog/post", data, "blog_post");
    </script>
</body>
```

Rendering partials in Mustache becomes a lot easier. You don't need to build
your own object of partials before calling `Mustache.render`. Let Bloodhound do
that for you! (good dog)

## Dynamic Views

> **Note:** You will need a web server for this.

The big difference between Dynamic and Embedded Views is that the call to
`renderingEngine.render` becomes an asychronous call that returns a
`Bloodhound.IRenderPromise` object. You can still keep all of your embedded
views the same. Let's take the previous example with embedded views and set it
up for Dynamic Views.

```html
<body>
    <div id="blog_post"></div>

    <script type="text/html" data-template-name="blog/post">
        <!-- same template source code -->
    </script>

    <script type="text/html" data-template-name="blog/post/comments">
        <!-- same template source code -->
    </script>

    <script type="text/javascript">
        var provider = new Bloodhound.ViewProviders.MustacheViewProvider(),
            resolver = new Bloodhound.ViewResolvers.DynamicViewResolver(document, provider),
            renderingEngine = new Bloodhound.RenderingEngines.DynamicRenderingEngine(resolver);

        var data = {
            title: "Test",
            date: "2014/02/11",
            body: "<p>Just a blog post</p>",
            comments: [{
                text: "Great info!",
                author: "Concerned Citizen",
                date: "2014/02/04"
            },{
                text: "Trash talk!",
                author: "Anonymous Coward",
                date: "2014/01/28"
            }]
        };

        renderingEngine.render("blog/post", data, "blog_post");
    </script>
</body>
```

We swap out `EmbeddedViewResolver` for `DynamicViewResolver`, and change
`EmbeddedRenderingEngine` to `DynamicRenderingEngine`. After that, it looks
exactly the same. The `renderingEngine.render` method takes the same exact
arguments. The only difference in behavior is that it returns a
`Bloodhound.IRenderPromise` object. If you do not need to do anything after the
view has been rendered, no code changes are required. If you want to run code
after the asynchronous rendering is complete, simply use this:

```javascript
renderingEngine.render("blog/post", data, "blog_post")
    .done(function(html, template, element, renderingEngine, promise) {
        alert("Rendered!");
    });
```

Now, let's remove the template code from the HTML document and have Bloodhound
fetch the source code from the server.

### Dynamic Views Using the Bloodhound URL Convention

> **Note:** You will need a web server and a site configured to serve static
> files for this demo.

If you request a view that is not an embedded template, Bloodhound will try
downloading the template source code via AJAX by building a URL to a file
containing the template source code, and issuing a GET request. By default, a
template named `blog/post` resolves to the URL `/js/app/views/blog/post.tpl`.

```javascript
viewResolver.find("blog/post", function(template) { ... });
```

If you have a browser debugging tool open, under the Network tab you'll see an
AJAX request to `GET /js/app/views/blog/post.tpl`

Let's refactor the markup in the previous example to take advantage of this.

First, we'll need this directory structure for our web site.

    website_root/
      index.html
      js/
        app/
          views/
            blog/
              post.tpl
              comments.tpl

The `index.html` file is where you will currently have your embedded templates.
We want to move them into files on the server.

1. Copy the contents of the "blog/post" embedded template and save it as a file
   in `website_root/js/app/views/blog/post.tpl`
2. Remove `<script type="text/html" data-template-name="blog/post">...</script>`
3. Copy the contents of the "blog/post/comments" template and save it as a file
   in `website_root/js/app/views/blog/post/comments.tpl`
4. Remove `<script type="text/html" data-template-name="blog/post/comments">...</script>`
5. Open a debugging tool and refresh the page in your browser.

The Network tab in your browser debugging tools should show two AJAX requests:

- GET /js/app/views/blog/post.tpl
- GET /js/app/views/blog/comments.tpl

This default mapping of view names to URLs may work most of the time, but there
are always one-off views that don't fit into this pattern. For those, you can
use a special `script` tag that maps the view name to any URL you want.

### Remapping Dynamic View URLs

We create a `script` tag holding the name of the view we want in the
`data-template-name` attribute, and then we add the `data-template-url`
attribute specifying the exact URL to download the template source:

```html
<script type="text/html" data-template-name="blog/post/comments"
    data-template-url="/blogs/123/comments?foo=bar"></script>
```

The `data-template-url` attribute on the `script` tag will cause Bloodhound to
make a GET request to `/blogs/123/comments?foo=bar` when finding the view named
"blog/post/comments":

```javascript
viewResolver.find("blog/post/comments", function(template) { ... });
```

In the Network tab of your browser debugging tool, you'll see:

- GET /blogs/123/comments?foo=bar

The default URL pattern may work fine for new projects, but you'll need to
customize a few settings for existing web projects, which we will discuss next.

### Options for Dynamic Views

You can customize several options for how Dynamic Views are resolved. A URL can
be generated for you given the name of a view. The basic pattern is:

```javascript
templateURLBase + viewName + templateExtension
```

By default, the `templateURLBase` for DynamiceViewResolver is "/js/app/views",
and the `templateExtension` is ".tpl". You can change these settings on the
view resolver object like this:

```javascript
var viewResolver = new Bloodhound.ViewResolvers.DynamicViewResolver(provider);

viewResolver.templateURLBase = "/javascripts/my_app";
viewResolver.templateExtension = ".mustache";
viewResolver.httpMethod = "post";

viewResolver.find("blog/post", function(template) { ... });
```

With the settings above, the view named "blog/post" gets resolved to this URL:
`/javascripts/my_app/blog/post.mustache`, and the DynamicViewResolver would
issue a POST request to downlod the source code.

You can also override the HTTP method on `script` tags that override the default
URL for a view:

```html
<script type="text/html" data-template-name="foo"
    data-template-url="/foo"
    data-template-method="post"></script>
```

Now running `viewResolver.find("foo")` will issue a POST request to "/foo" to
download the template source.

## Supported Template Languages

Currently, only two template languages are supported:
[Mustache.js Templates](https://github.com/janl/mustache.js/) and
[Simple Templates](https://github.com/gburghardt/template).

### Mustache Templates

In order to use Mustache Templates with Bloodhound, you'll need to include the
following JavaScript files:

1. src/bloodhound.js
2. src/bloodhound/adapters/mustache_template.js
3. src/bloodhound/view_providers/mustache_view_provider.js

Next, you just need to decide whether you want to use Embedded Views or Dynamic
Views.

Embedded Views:

1. src/bloodhound/rendering_engines/embedded_rendering_engine.js
2. src/bloodhound/view_resolvers/embedded_view_resolver.js

**Demo:** demo/mustache_templates/index.html

Dynamic Views:

1. bower_components/concrete-promise/src/promise.js
2. src/bloodhound/rendering_engines/dynamic_rendering_engine.js
3. src/bloodhound/view_resolvers/dynamic_view_resolver.js

**Demo:** demo/mustache_templates/dynamic.html

### Simple Templates

Include these files to use Simple Templates with Bloodhound:

1. src/bloodhound.js
2. src/bloodhound/view_providers/simple_template_view_provider.js

Simple Templates come with a JavaScript class called `Template` which implements
the `Bloodhound.ITemplate` interface (documented in src/interfaces.js). Later
we'll see how you can use these interfaces to write view providers and adapters
for any template language.

Next, you just need to decide whether you want to use Embedded Views or Dynamic
Views.

Embedded Views:

1. src/bloodhound/rendering_engines/embedded_rendering_engine.js
2. src/bloodhound/view_resolvers/embedded_view_resolver.js

**Demo:** demo/simple_templates/index.html

Dynamic Views:

1. bower_components/concrete-promise/src/promise.js
2. src/bloodhound/rendering_engines/dynamic_rendering_engine.js
3. src/bloodhound/view_resolvers/dynamic_view_resolver.js

**Demo:** demo/simple_templates/dynamic.html

### Adding Support For New Template Languages

You can add support for any JavaScript templating language you want. The only
two required components are the View Provider and the Template.

#### View Providers

A View Provider in Bloodhound is responsible for two tasks:

1. Creating a new object implementing the `Bloodhound.ITemplate` interface given
   a view name and template source code
2. And detecting any sub templates or partials inside the template source code
   and looping over them, which allows View Resolvers to fetch those templates.

The interface that all View Providers must implement can be found in
`src/interfaces.js` and is called `Bloodhound.ViewProviders.IViewProvider`.

Bloodhound comes with two implementations already:

- src/bloodhound/view_providers/mustache_view_provider.js
- src/bloodhound/view_providers/simple_template_view_provider.js

Use this as a guide for creating new view providers:

```javascript
function MyViewProvider() {}

MyViewProvider.prototype.createTemplate = function createTemplate(name, source) {
    // return an object supporting Bloodhound.ITemplate
};

MyViewProvider.prototype.forEachSubTemplate = function(source, callback, context) {
    var subTemplateRegex = /\{\{>\s*(\w+)\s*\}\}/g;

    source.replace(subTemplateRegex, function(tag, templateName) {
        callback.call(context, templateName);
    });
};
```

#### Templates

A Template object in Bloodhound contains the name of that view, and the template
source code. It is responsible for rendering the template source code and
returning the rendered string. This is where you make a call to a function
specific to a template language to render the data.

Template objects must implement the `Bloodhound.ITemplate` interface, which can
be found in `src/interfaces.js`.

Not every templating language may need a Template class, but most will. A good
example is Mustache templates. To render a template, you call
`Mustache.render(source, data)`. There is no association between the name of a
view and its template source code, so we created
`Bloodhound.Adapters.MustacheTemplate`, which implements the
`Bloodhound.ITemplate` interface (src/bloodhound/adapters/mustache_template.js).

Use this as a guide for creating new Templates:

```javascript
function MyTemplate(name, source) {
    this.name = name || null;

    if (source) {
        this.setSource(source);
    }
}

MyTemplate.prototype.render = function render(data) {
    // Call method specific to templating language, return a string
    // e.g. return Mustache.render(this.source, data);
};

MyTemplate.prototype.setSource = function setSource(source) {
    this.source = source;
};

MyTemplate.prototype.setViewResolver = function setViewResolver(viewResolver) {
    this.viewResolver = viewResolver;
};
```

Each template object gets a reference to the view resolver, allowing templates
to look up sub templates and render them:

```javascript
MyTemplate.prototype.render = function render(data) {
    var subTemplate = this.viewResolver.find("some_view");
    var html = subTemplate.render(data.something);

    // ...
};
```

When adding support for other template languages, you shouldn't need to create
your own view resolver. The `EmbeddedViewResolver` or `DynamicViewResolver`
should work. Both classes have a method called `find`. When you only pass the
name of a view to the `find` method, you will always get back a template object.
No callback functions are required. By the time the `render` method is called on
a template object, all sub templates and partials have been fetched and cached
in the browser so all calls to `viewResolver.find("view_name")` are
*synchronous* and return a `Bloodhound.ITemplate` object. This makes the call to
`Bloodhound.ITemplate#render` a synchronous call as well, simplifying your
implementation for a template language.

If you roll your own View Provider and Template, the next section describes how
you can get them included in Bloodhound by default.

## Contributing

Did you find a bug? Do you want "Template Language X" supported right out of the
box? You can contribute your own bug fixes and features by following these
guidelines.

### Contributing Bug Fixes

Just fork the [repository on GitHub](https://github.com/gburghardt/bloodhound),
create a branch, make your fix, and issue a Pull Request.

Some things that will expedite a bug fix:

- Describe the bug and steps to reproduce
- Add a Jasmine spec (even though no specs exist yet)
- Describe the impact of the bug
- Open an [Issue on GitHub](https://github.com/gburghardt/bloodhound/issues).
- Make sure the Demos still function

### Contributing New Features

As with bug fixes, fork the
[repository on GitHub](https://github.com/gburghardt/bloodhound), create a
branch, add your feature, and issue a Pull Request.

When adding support for a new template language, use these class and file naming
conventions to keep the code base organized:

- View Providers live in the namespace `Bloodhound.ViewProviders` and must
  implement the `Bloodhound.ViewProviders.IViewProvider` interface.
- View Provider classes should contain the name of the template language, and be
  suffixed with `ViewProvider`. For example, the View Provider for Mustache
  templates is `Bloodhound.ViewProviders.MustacheViewProvider`.
- View Providers must live in `src/bloodhound/view_providers/<template language name>_view_provider.js`
- Template classes are considered Adapters in Bloodhound, and are in the
  namespace `Bloodhound.Adapters`.
- Template classes should follow this naming convention: `Bloodhound.Adapters.<template language name>Template`
- Template class files should live in `src/bloodhound/adapters/<template language name>_template.js`

Only implementations for Open Source template languages will be considered for
inclusion in this class library. You must include a URL to the project web site
for that Template language in the Pull Request.

You are more than welcome to implement closed source template languages using
this class library. They will just never be included by default.

## Finding the Changelog and Information About Releases

View the [CHANGELOG.md](https://github.com/gburghardt/bloodhound/blog/master/CHANGELOG.md)
file for information about all releases. You can also `bower info bloodhound` to
view all available versions.
