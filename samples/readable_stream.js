
var fs = require('fs');
var each = require('each');

var eacher = each( {id_1: 1, id_2: 2, id_3: 3} )
.on('item', function(next, key, value) {
    setTimeout(function(){
        eacher.emit('data', key + ',' + value + '\n');
        next();
    }, 1);
})
.on('end', function(){
    console.log('Done');
});

eacher.pipe(
    fs.createWriteStream(__dirname + '/out.csv', { flags: 'w', encoding: null, mode: 0666 })
);
