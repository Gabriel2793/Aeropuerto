Aeropuerto Quetzalcóatl

En este proyecto se realizó un sistema para un aeropuerto ficticio nombrado "Aeropuerto Quetzalcóatl", este sistema se desarrollo con el fin de demostrar mis habilidades con Flutter, NodeJS y MySQL.

El software que se utilizó en este sistema se muestra en la siguiente lista:

1. Flutter
2. NodeJS
3. MySQL

Lo primero que se le muestra al usuario es una pantalla que incluye una imagen y un formulario para iniciar sesión, como en la siguiente imagen:

<img src="https://raw.githubusercontent.com/Gabriel2793/Aeropuerto/main/Airport_Imgs/1.jpg" style="zoom:25%;" />

En caso de no tener una cuenta, el usuario utilizaría el menú que se abre dando click en el icono de la parte superior izquierda y posteriormente en Regístrate, el menú que se muestra es el siguiente:

<img src="https://raw.githubusercontent.com/Gabriel2793/Aeropuerto/main/Airport_Imgs/2.jpg" style="zoom:25%;" />

Posteriormente se debe ingresar correo y contraseña en el formulario que aparece:

<img src="https://raw.githubusercontent.com/Gabriel2793/Aeropuerto/main/Airport_Imgs/3.jpg" style="zoom:25%;" />

Ahora que el usuario está registrado puede ingresar al sistema, al ingresar al usuario se le muestra un calendario en el cual se selecciona un día para visualizar los vuelos disponibles, la siguiente imagen muestra el calendario:

<img src="https://raw.githubusercontent.com/Gabriel2793/Aeropuerto/main/Airport_Imgs/4.jpg" style="zoom:25%;" />

También en esta parte del sistema se tiene una barra dividida en dos, una para mostrar el calendario y la otra para visualizar los vuelos comprados. Cuando el usuario da click en vuelos se muestra los siguiente:

<img src="https://raw.githubusercontent.com/Gabriel2793/Aeropuerto/main/Airport_Imgs/5.jpg" style="zoom:25%;" />

Una lista con los diferentes vuelos, al hacer click en una de ellas, se muestra las fechas en las que se compro ese vuelo:

<img src="https://raw.githubusercontent.com/Gabriel2793/Aeropuerto/main/Airport_Imgs/6.jpg" style="zoom:25%;" />

Y si el usuario quiere visualizar los asientos que compro en ese vuelo, solamente tiene que dar click en el botón con el texto "Ver asientos" y posteriormente se mostrara lo siguiente:

<img src="https://raw.githubusercontent.com/Gabriel2793/Aeropuerto/main/Airport_Imgs/7.jpg" style="zoom:25%;" />

En verde se muestran los asientos comprados en ese vuelo.

Cuando el usuario da click en algún día del calendario se le muestran los vuelos disponibles cómo en la siguiente imagen:

<img src="https://raw.githubusercontent.com/Gabriel2793/Aeropuerto/main/Airport_Imgs/11.jpg" style="zoom:25%;" />

Que muestra los viajes, en cada uno se visualizan el destino, el precio por asiento y dos iconos, el primero es para mostrar un mapa de Google Maps donde indica el aeropuerto de destino y el segundo muestra las horas disponibles, por lo que el usuario deberá seleccionar una, cómo en la siguiente imagen: 

<img src="https://raw.githubusercontent.com/Gabriel2793/Aeropuerto/main/Airport_Imgs/13.jpg" style="zoom:25%;" />

Luego se muestra los asientos disponibles de ese vuelo, en gris los disponibles, en negro los ocupados y en azul los seleccionados, la siguiente imagen lo enseña:

<img src="https://raw.githubusercontent.com/Gabriel2793/Aeropuerto/main/Airport_Imgs/15.jpg" style="zoom:25%;" />

Por último el usuario da click en el botón Pagar y se le enseña los datos de su vuelo y un formulario para ingresar los datos de pago, la siguiente imagen lo ilustra:

<img src="https://raw.githubusercontent.com/Gabriel2793/Aeropuerto/main/Airport_Imgs/16.jpg" style="zoom:25%;" />

En este sistema se eligió un nivel de aislamiento de "READ-COMMITTED" el cual nos permitirá que una transacción A visualice los cambios de la transacción B, hasta que B haga commit, además con el SELECT FOR UPDATE se asegura que desde el inicio de una transacción no se podrá leer, ni escribir en los registros involucrados, es decir en los asientos que se desea comprar, y que las otras transacciones estarán en modo de espera, hasta que la primera termine.   