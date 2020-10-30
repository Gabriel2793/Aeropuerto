const express = require( 'express' );
const app = express();
const router = express.Router();
const { port, database } = require( './settings' );
const routes = require( './routes' );
const middleware = require( './middlewares');
const cors = require('cors');
const multer = require('multer');
const upload=multer()

const knex = require( 'knex' )( {
    client: 'mysql',
    connection: database
} );
app.locals.knex = knex;

app.use(cors({
    "origin":"*",
    "methods":"GET,PATCH,POST,DELETE"
}));

app.use( express.json({limit: '10000mb', extended: true}) );

router.post( '/createFlight', middleware.verifyAthorization, upload.single('image'), routes.flights.createFlight);
router.get('/getSeats/:vueloId/:fecha', middleware.verifyAthorization, routes.flights.getSeats);
router.get('/getBoughtSeats/:user_id/:flight_id/:horario', middleware.verifyAthorization, routes.flights.getBoughtSeats);
router.post('/getUsersFlights', middleware.verifyAthorization,routes.flights.getUsersFlights);
router.post( '/getFlights', middleware.verifyAthorization,routes.flights.getFlights);
router.post( '/buyPlaces', middleware.verifyAthorization, routes.flights.buyPlaces);
router.post( '/signUp', routes.flights.signUp);
router.post( '/signIn', routes.flights.signIn);

app.use( '/api', router );

app.listen( port, ()=> {
    console.log( `Server up on port ${ port }`);
});