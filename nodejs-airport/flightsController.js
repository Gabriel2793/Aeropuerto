const bcrypt = require( 'bcrypt' );
const { response } = require('express');
const jwt = require( 'jsonwebtoken' );

function signUp( req, res ) {
    const { knex } = req.app.locals;
    data = req.body;

    const requiredFields = [ 'password', 'email' ];
    const requiredKeys = Object.keys( data );
    const requiredFieldsExist = requiredFields.every( field => requiredKeys.includes( field ) );
    const saltRound = 10;
    
    if( requiredFieldsExist ) {
        bcrypt.genSalt( saltRound, ( error, salt ) => {
            bcrypt.hash( data.password, salt, ( error, hash ) => {
                knex( 'users' )
                .insert( { ...data, password: hash } )
                .then( response => res.status( 200 ).json( { status: 'success', message:'Client created' } ) )
                .catch( error => res.status( 400 ).json( { status: 'Error', message:error.sqlMessage } ) );
            } );
        } );
    }else{
        res.status( 400 ).json( { text:`The following fields are required: ${ requiredFields }` } );
    }
};

function buyFlight( req, res ) {
    const { knex } = req.app.locals;
    data = null;

    if(req.body.app == 'undefined'){
        data = { ...req.body, file:req.file.buffer };
    }else{
        data = req.body;
        delete data.app;
        data.file = Buffer(data.file, 'base64');
    }
    console.log(data)
    const requiredFields = [ 'title', 'idea', 'file', 'type_file', 'user_id' ];
    const requiredKeys = Object.keys( data );
    const requiredFieldsExist = requiredFields.every( field => requiredKeys.includes( field ) );
    console.log(requiredFieldsExist)
    if( requiredFieldsExist ) {
        knex( 'user_posts' )
        .insert( data )
        .then( response => res.status( 200 ).json( { title: 'Success', text:'Post created' } ) )
        .catch( error => {
            console.log( error.sqlMessage );
            res.status( 400 ).json( { title: 'Error', text:error.sqlMessage } )
        } );
    }else{
        res.status( 400 ).json( { text:`The following fields are required: ${ requiredFields }` } );
    }
};

function signIn( req, res ) {
    const { knex } = req.app.locals;
    const data = req.body;

    knex( 'users' )
    .where('email', data.email)
    .then( response => {
        bcrypt.compare( data.password, response[0].password, ( error, result ) => {
            if( result && ( response.length > 0 ) ) {
                const payload = {
                    username: response[0].username,
                    isAdmin: true
                };
                const secret = 's3cr3t';
                const expiresIn = 60000;
                const token = jwt.sign( payload, secret, { expiresIn });
                res.status( 200 ).json( { status:'success', token, logIn: true, id: response[0].id } );
            }else{
                res.status( 200 ).json( { status:'Error'} );
            }
        } );
    } )
    .catch( error => {
        res.status(500).json( {status:'error', message:'Bad User or password.'} );
    } );
}

function getFlights( req, res ) {
    const { knex } = req.app.locals;
    const data = req.body;

    knex( 'flights' )
    .join('dateflights','flights.id', 'dateflights.flight_id')
    .select('flights.id', 'image', 'to', 'cost',knex.raw('GROUP_CONCAT(dateofflight) as horarios'))
    .whereRaw('date(dateflights.dateofflight)=?',[data.fecha])
    .groupBy('flights.id')
    .then( response => {
        elements = response.map( element => {
            element.image = element.image.toString('base64');
            element.horarios = element.horarios.split(',');
            return element;
        });
        res.status( 200 ).json( elements );
    } )
    .catch((error) => {
        console.log(error)
    });
}

function getSeats( req, res ) {
    const { knex } = req.app.locals;
    const data = req.params;

    knex( 'dateflights' )
    .join('flights_places','dateflights.id','flights_places.dateflight_id')
    .select('dateflights.id',knex.raw('GROUP_CONCAT(ocupado ORDER BY PLACE_ID) AS ocupado'), knex.raw('GROUP_CONCAT(place_id ORDER BY PLACE_ID) AS places'))
    .where('dateflights.dateofflight',data.fecha)
    .where('dateflights.flight_id',data.vueloId)
    .groupBy('dateflights.flight_id')
    .then( response => {
        console.log(response)
        res.status( 200 ).json( response );
    } )
    .catch((error) => {
        console.log(error)
    });
}

function getBoughtSeats( req, res ) {
    const { knex } = req.app.locals;
    const data = req.params;

    console.log(data);

    knex( 'dateflights' )
    .join('flights_places','dateflights.id','flights_places.dateflight_id')
    .select(knex.raw('Group_Concat(place_id ORDER BY place_id) as places'))
    .where('dateflights.flight_id',data.flight_id)
    .where('dateflights.dateofflight',data.horario)
    .where('flights_places.user_id',data.user_id)
    .groupBy('dateflights.id')
    .orderBy('flights_places.place_id') 
    .then( response => {
        console.log(response)
        res.status( 200 ).json( {status:'success', seats:response[0].places} );
    } )
    .catch((error) => {
        console.log(error);
        res.status( 400 ).json( {status:'error', message:error} );
    });
}

function createFlight( req, res ) {
    const { knex } = req.app.locals;
    data = null;

    if(req.body.app == undefined){
        data = { ...req.body, image:req.file.buffer };
    }else{
        data = req.body;
        delete data.app;
        data.file = Buffer(data.image, 'base64');
    }
    const requiredFields = [ 'to', 'cost', 'image' ];
    const requiredKeys = Object.keys( data );
    const requiredFieldsExist = requiredFields.every( field => requiredKeys.includes( field ) );

    if( requiredFieldsExist ) {
        // knex( 'flights' )
        // .insert( data )
        // .then( response => res.status( 200 ).json( { title: 'Success', text:'Post created' } ) )
        // .catch( error => {
        //     console.log( error.sqlMessage );
        //     res.status( 400 ).json( { title: 'Error', text:error.sqlMessage } )
        // } );

        flightPlacesUpdates = [];

        knex.transaction(async trx => {
            var flight = await knex('flights')
            .insert( {image: data.image, to: data.to, cost: data.cost} )
            .transacting(trx);

            var dateflight = await knex('dateflights')
            .insert( {dateofflight: data.dateofflight, flight_id: flight[0]} )
            .transacting(trx);

            for( i = 0; i < 20; i++) {
                await knex('flights_places')
                .insert({
                    place_id: i,
                    dateflight_id: dateflight[0],
                })
                .transacting(trx);
            }
        })
        .then((complete)=> {
            res.status(200).json({status:'success'});
        })
        .catch((error)=>{
            res.status(400).json({status:'error', message:error});
        });
    }else{
        res.status( 400 ).json( { text:`The following fields are required: ${ requiredFields }` } );
    }
}

function buyPlaces( req, res ) {
    const { knex } = req.app.locals;
    data = req.body;
    
    const requiredFields = [ 'dateflight_id', 'places', 'user_id' ];
    const requiredKeys = Object.keys( data );
    const requiredFieldsExist = requiredFields.every( field => requiredKeys.includes( field ) );

    if( requiredFieldsExist ) {
        let mywhere = '';
        let myselect = 'select count(*) as cuantos from ';
        let i;
        let valores = [];
        let tablas ='{';

        for(i=0; i < data.places.length; i++){
            if((i == 0 && i == data.places.length-1) || i == data.places.length-1){
                myselect += 'flights_places as F'+i;
                mywhere += '(F'+i+'.dateflight_id = ? and F'+i+'.place_id = ? and F'+i+'.ocupado = 0)';
                valores.push(data.dateflight_id)
                valores.push(data.places[i])
                tablas += '"F'+i+'":"flights_places"';
            }else{
                myselect += 'flights_places as F'+i+', ';
                mywhere += '(F'+i+'.dateflight_id = ? and F'+i+'.place_id = ? and F'+i+'.ocupado = 0) and ';
                valores.push(data.dateflight_id)
                valores.push(data.places[i])
                tablas += '"F'+i+'":"flights_places",';
            }
        };
        tablas += '}';
        mywhere += ' for update';

        knex.transaction(async trx => {
            cuantos = await knex(JSON.parse(tablas))
            .count('*', {as:'cuantos'})
            .whereRaw(mywhere,valores)
            .transacting(trx);

            if(cuantos[0].cuantos == 1){
                var updates = [];
                for(i = 0; i < data.places.length; i++){
                    updates[i] = await knex('flights_places')
                    .update({
                        ocupado: 1,
                        user_id: data.user_id
                    })
                    .where({
                        dateflight_id: data.dateflight_id,
                        place_id: data.places[i]
                    })
                    .transacting(trx);
                }

                if(updates.reduce((a,b)=>a+b,0) == data.places.length){
                    trx.commit;
                    res.status(200).json({status:'success', message:'Your purchase was a success, thank you.'});
                }else{
                    trx.rollback;
                }
            }else{
                res.status(200).json({status:'sorry', message:'One or all the seats you would buy were bought by other person.'});
            }
        });
        
        
        // knex( 'flights_places' )
        // .update( {
        //     ocupado: 1
        // } )
        // .where('dateflight_id', data.dateflight_id)
        // .whereRaw('')
        // .then( response => res.status( 200 ).json( { title: 'Success', text:'Asientos comprados' } ) )
        // .catch( error => {
        //     console.log( error.sqlMessage );
        //     res.status( 400 ).json( { title: 'Error', text:error.sqlMessage } )
        // } );
    }else{
        res.status( 400 ).json( { text:`The following fields are required: ${ requiredFields }` } );
    }
}

function getUsersFlights( req, res ) {
    const { knex } = req.app.locals;
    const data = req.body;
    console.log(data)

    const requiredFields = [ 'user_id' ];
    const requiredKeys = Object.keys( data );
    const requiredFieldsExist = requiredFields.every( field => requiredKeys.includes( field ) );

    knex( 'flights_places' )
    .join('dateflights','flights_places.dateflight_id', 'dateflights.id')
    .join('flights', 'dateflights.flight_id', 'flights.id')
    .select('flights.id', 'to','dateflights.dateofflight', knex.raw('GROUP_CONCAT(DISTINCT(dateofflight)) as horarios'))
    .whereRaw('flights_places.user_id=?',[data.user_id])
    .groupBy('flights.id')
    .then( response => {
        res.status( 200 ).json( { status: 'success', vuelos: response } );
    } )
    .catch((error) => {
        console.log(error)
    });
}

module.exports = {
    signUp,
    signIn,
    getFlights,
    buyFlight,
    createFlight,
    getSeats,
    buyPlaces,
    getUsersFlights,
    getBoughtSeats
}