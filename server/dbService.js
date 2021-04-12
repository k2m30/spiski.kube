const mysql = require('mysql');
const dotenv = require('dotenv');
let instance = null;
dotenv.config();

const connection = mysql.createConnection({
    host: process.env.MYSQL_HOST,
    user: 'root',
    password: process.env.MYSQL_ROOT_PASSWORD,
    database: process.env.MYSQL_DATABASE,
    port: 3306
});

connection.connect((err) => {
    if (err) {
        console.log(err.message);
        console.log(process.env.MYSQL_HOST);
        console.log(process.env.MYSQL_DATABASE);
        console.log(process.env.MYSQL_ROOT_PASSWORD);
    }
    // console.log('db ' + connection.state);
});


class DbService {
    static getDbServiceInstance() {
        return instance ? instance : new DbService();
    }

    async search(last_name) {
        try {
            const response = await new Promise((resolve, reject) => {
                const query = "SELECT date, last_name, full_info FROM records WHERE last_name = ? ORDER BY date;";

                connection.query(query, [last_name], (err, results) => {
                    if (err) reject(new Error(err.message));
                    resolve(results);
                })
            });

            return response;
        } catch (error) {
            console.log(error);
        }
    }

    async count() {
        try {
            const response = await new Promise((resolve, reject) => {
                const query = "SELECT COUNT(*) FROM records;";

                connection.query(query, [], (err, results) => {
                    if (err) reject(new Error(err.message));
                    resolve(results);
                })
            });

            return response;
        } catch (error) {
            console.log(error);
        }
    }
}

module.exports = DbService;