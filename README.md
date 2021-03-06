# Facile

Facile is a convention-based template engine that can be executed
either in the browser (using jQuery or zepto) or on the server
(using cheerio). While other template systems like Mustache give the
developer syntax for explicit conditionals, enumerations and data 
bindings, Facile uses simple conventions to achieve the same goals 
with less code.

## Installation

If you want to use Facile with Node.js, install it using `npm`:

```bash
npm install facile
```

To use Facile in the browser, either copy the `facile.coffee` file
or the compiled `test/public/javascripts/facile.js` file into your
project.

## Usage

The facile package is a single function that accepts a `template` string
and a `data` object:

```javascript
var facile = require("facile"), // only needed in Node.js
    template = "...",
    data = {...},
    output = facile(template, data);
```

### Data Binding by Ids and Classes

Facile will look for DOM ids and classes that match the keys in your
data object and set the DOM elements' text to the data values:

```javascript
var template = '<div id="dog"></div><div class="cat"></div>',
    data = {dog: "woof", cat: "meow"};
facile(template, data);
// returns '<div id="dog">woof</div><div class="cat">meow</div>'
```

### Looping Over Collections

When a value in the data object is an array, Facile will find the
container DOM element that matches the data key and render its
contents for each item in the array.

```javascript
var template = '<ul id="users"><li class="name"></li></ul>',
    data = {users: [
      {name: "Moe"}, 
      {name: "Larry"},
      {name: "Curly"}
    ]};
facile(template, data);
// returns:
// <ul id="users">
//   <li class="name">Moe</li>
//   <li class="name">Larry</li>
//   <li class="name">Curly</li>
// </ul>
```

If you are binding an array of data to a `<table>` element, Facile will
expect there to be a single `<tr>` inside the table's `<tbody>` and
will repeat that `<tr>` for each item in the array.

```javascript
var template = '<table id="users">' +
               '  <thead>' +
               '    <tr><th>Name</th></tr>' +
               '  </thead>' +
               '  <tbody>' +
               '    <tr><td class="name"></td></tr>' +
               '  </tbody>' +
               '</table>',
    data = {users: [
      {name: "Moe"}, 
      {name: "Larry"},
      {name: "Curly"}
    ]};
facile(template, data);
// returns:
// <table id="users">
//   <thead>
//     <tr><th>Name</th></tr>
//   </thead>
//   <tbody>
//     <tr><td class="name">Moe</td></tr>
//     <tr><td class="name">Larry</td></tr>
//     <tr><td class="name">Curly</td></tr>
//   </tbody>
// </table>
```

### Removing Elements

If the data object has a `null` value, the corresponding DOM element
will be removed.

```javascript
var template = '<p>Hello!</p><p class="impolite">Take a hike, guy.</p>',
    data = {impolite: null};
facile(template, data);
// returns "<p>Hello!</p>"
```

### Setting DOM Attributes

There are two ways to set DOM attributes on elements using Facile.
First, if a value in the data object is an object, Facile will treat
the keys as attribute names for the matching DOM element. *NOTE:*
the `content` key is special in that it updates the content of the
element rather than setting a `content` attribute.

```javascript
var template = '<div id="dog" />',
    data = {dog: {content: 'woof', 'data-age': 3} };
facile(template, data);
// returns '<div id="dog" data-age="3">woof</div>'
```

The second way is to name a key in the data object using the convention
`id-or-class@attribute`.

```javascript
var template = '<div id="dog" />',
    data = {dog: 'woof', 'dog@data-age': 3};
facile(template, data);
// returns '<div id="dog" data-age="3">woof</div>'
```

### Deferred Values

Any functions that are used in your data objects will be treated as deferred
values and will be run at render time to produce a value. For example:

```javascript
var template = '<div id="startup" /><div id="now" />',
    data = {
      startup: "" + new Date(),
      now: function() { return "" + new Date(); }
    };
setTimeout(function() {
  facile(template, data);
}, 3000);
// 'now' will be 3 seconds after 'startup' because it was calculated at render time
```

### Asyncronous Deferred Values

There may be times when your deferred value functions need to access
asynchronous resources to calculate the final value (using XHR in the browser,
or IO libraries in Node). In these cases, Facile can be passed a Node-style
callback where the first param is an error and the second is the rendered
markup. Asynchronous value functions should accept a callback function
with the same Node-style signature.

In this example, we need to fetch the `name` from the server before we can
render the template. The `name` is fetched asynchronously with a jQuery
`ajax` call, and the resulting error or value is passed into the callback
so that Facile can complete rendering.

```javascript
var template = '<div id="name" />',
    data = {
      name: function(cb) {
        // cb is called like: cb(err, value)
        $.ajax({
          url: "/get-name",
          type: "GET",
          dataType: "json",
          error: function(err) {
            cb(err); // bubble error up to the facile callback
          },
          success: function(name) {
            cb(null, name);
          }
        });
      }
    };

facile(template, data, function(err, markup) {
  if (err) {
    console.log("ERROR:", err);
  } else {
    $("#some-container").html(markup);
  }
});
```

### Using Facile with Express

Facile works out of the box as a render engine in the Express framework 
in Node.js. If you are suffixing your view files with `.facile` then you
simply need to add this line to your Express app:

```javascript
app.set("view engine", "facile");
```

If you would rather name your view files with a `.html` suffix, add these
lines instead:

```javascript
app.set("view engine", "html");
app.register(".html", require(facile));
```

## Running the Tests

1. Install `node` and `npm`.
2. Run `npm install` to the dependencies
3. Run `npm test` to run the specs in Node.js
4. Run `./coffee` to watch/compile the CoffeeScripts
5. Run `node test` to run Jasmine test server
6. Visit [http://localhost:5000](http://localhost:5000) to see the tests run in the browser.

