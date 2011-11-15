
<pre style="font-family:courier">
 _   _           _        ______           _     
| \ | |         | |      |  ____|         | |    
|  \| | ___   __| | ___  | |__   __ _  ___| |__  
| . ` |/ _ \ / _` |/ _ \ |  __| / _` |/ __| '_ \ 
| |\  | (_) | (_| |  __/ | |___| (_| | (__| | | |
|_| \_|\___/ \__,_|\___| |______\__,_|\___|_| |_| New BSD License
</pre>

Node Each is a single elegant function to iterate asynchronously over elements 
both in `sequential`, `parallel` and `concurrent` mode.

The `each` function signature is: `each(subject, mode=boolean)`. 

-   `subject`   
    The first argument is the subject to iterate. It can be an array, an object or 
    any other types in which case the behavior is similar to the one of an array.

-   `mode`   
    The second argument is optional and indicate wether or not you want the 
    iteration to run in `sequential`, `parallel` or `concurrent` mode. See below
    for more details about the different modes.

The return object is an instance of `EventEmitter`. The following events are send:

-   `data`   
    Called for each iterated element. The number of arguments depends on the 
    subject type.
    The first argument is a function to call at the end of your callback. It may
    be called with an error instance to trigger the `error` event.
    For objects, the second and third arguments are the key and value 
    of each elements. For anything else, the second and thirds argument are the 
    value and the index (starting at 0) of each elements.
-   `error`   
    Called only if an error occured. The iteration will be stoped on error.
-   `end`   
    Called only if no error occured once all the data has been handled.

If no `end_callback` is provided, the `iterator_callback` will be called one more 
time with the `next` argument set to null.

Defining a mode
---------------

-   `sequential`   
    Mode is `false`, default if no mode is defined.
    Callbacks are chained meaning each callback is called once the previous 
    callback is completed (after calling the `next` argument).
-   `parallel`
    Mode is `true`.
    All the callbacks are called at the same time and run in parallel.
-   `concurrent`
    Mode is an integer.
    Only the defined number of callbacks is run in parallel.

Dealing with errors
-------------------

Error are declared to each by calling `next` with an error object as its first
argument. An event `error` will be triggered and the iteration will be stoped. Note
that in case of parallel and concurrent mode, the current callbacks are not 
canceled but no new element will be send to the `data` event.

The first element send to the `error` event is an error instance. In 
`sequential` mode, it is the event sent in the previous data `callback`. In 
`parallel` and `concurrent` modes, the second argument is an array will all 
the error sent since multiple errors may be thrown at the same time.

Traversing an array
-------------------

In `sequential` mode:

```javascript
    var each = require('each');
    each( [{id: 1}, {id: 2}, {id: 3}] )
    .on('data', function(next, id) {
        console.log('id: ', id);
        setTimeout(next, 500);
    })
    .on('error', function(err) {
        console.log(err.message);
    })
    .on('end', function() {
        console.log('Done');
    });
```

In `parallel` mode:

```javascript
    var each = require('each');
    each( [{id: 1}, {id: 2}, {id: 3}], true )
    .on('data', function(next, id) {
        console.log('id: ', id);
        setTimeout(next, 500);
    })
    .on('error', function(err, errors){
        console.log(err.message);
        errors.forEach(function(error){
            console.log('  '+error.message);
        });
    })
    .on('end', function(){
        console.log('Done');
    });
```

Traversing an object
--------------------

Without an `end_callback` in `sequential` mode:

```javascript
    var each = require('each');
    each( {id_1: 1, id_2: 2, id_3: 3} )
    .on('data', function(next, key, value) {
        console.log('key: ', key);
        console.log('value: ', value);
        setTimeout(next, 500);
    })
    .on('error', function(err) {
        console.log(err.message);
    })
    .on('end', function() {
        console.log('Done');
    });
```

In `parallel` mode:

```javascript
    var each = require('each');
    each( {id_1: 1, id_2: 2, id_3: 3}, true )
    .on('data', function(next, key, value) {
        console.log('key: ', key);
        console.log('value: ', value);
        setTimeout(next, 500);
    })
    .on('error', function(err, errors){
        console.log(err.message);
        errors.forEach(function(error){
            console.log('  '+error.message);
        });
    })
    .on('end', function(){
        console.log('Done');
    });
```

Installing
----------

Via git (or downloaded tarball):

```bash
    git clone http://github.com/wdavidw/node-each.git
```

Then, simply copy or link the project inside a discoverable Node directory (node_modules).

Via [npm](http://github.com/isaacs/npm):

```bash
    $ npm install each
```

Testing
-------

Install `expresso` and run
```bash
    $ expresso -s test
```

    

