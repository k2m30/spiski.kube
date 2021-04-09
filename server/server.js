const express = require('express');
const server = express();
const cors = require('cors');
const dotenv = require('dotenv');
dotenv.config();

const dbService = require('./dbService');
const ejsLint = require('ejs-lint');


server.use(cors());
server.use(express.json());
server.set('view engine', 'ejs');
server.use(express.urlencoded({extended: false}));

server.get('/', (request, response) => {
    const q = request.query['q'];
    const db = dbService.getDbServiceInstance();

    const result = db.search(q);

    result.then(search => {
        const count = db.count();
        count.then(size => {
            let data = {};
            data.name = q;
            data.size = size[0]["COUNT(*)"];
            data.results = search;
            response.render('index.ejs', {data: data});
        }).catch(err => console.log(err));
    }).catch(err => console.log(err));
})

server.listen(8080, () => console.log('server is running, port 8080'));