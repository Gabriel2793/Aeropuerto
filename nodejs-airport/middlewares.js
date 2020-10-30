const jwt = require( 'jsonwebtoken' );

function verifyAthorization( req, res, next ) {
    const { authorization } = req.headers;
    if(authorization != undefined){
        const token = authorization.split(' ')[1];
        jwt.verify( token, 's3cr3t', ( error, decodedToken ) => {
            if( error ) {
                return res.status( 401 ).json( 'Bad token' );
            }else{
                req.token = decodedToken;
                next();
            }
        } );
    }else{
        return res.status( 400 ).json( 'You do not have authorization to use this API' );
    }
    
}

module.exports = {
    verifyAthorization
}