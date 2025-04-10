FUNCIONES PARA VALIDAR LA CONSISTENCIA DE LOS PERFILES Y SUS LOS HORIZONTES EN UN CONJUNTO DE DATOS PREVIO A SU CARGA AL SISLAC
ELABORÓ: SERGIO DIAZ GUADARRAMA - contacto: sergiodiaz.geo@gmail.com

REQUISITOS: archivo .csv que debe tener cuatro columnas clave (con los nombres como se indica):
1.- profile_Id: corresponde al identificador único del perfil.
2.- layer_Id: corresponde al identificador del horizonte.
3.- top: límite superior del horizonte.
4.- bottom: límite inferior del horizonte.

Las validaciones que se realizan a la descripción de los horizontes y son las siguientes:
1.- Horizontes sin lÍmite superior asignado (I-1).
2.- Horizontes sin lÍmite inferior asignado (I-2).
3.- Horizonte con valores invertidos de los límites (I-3).
4.- Superposición de horizontes (I-4).
5.- Perfiles con horizonte orgánico (I-5), este consisten en que el primer horizonte está descrito de manera inversa y a partir del segundo se inicia la descripción a partir de cero (0).

El resultado se almacena en el dataframe validaPerfil que cuenta con 4 columnas:
1.- profile_Id: indica el perfil con inconsistencia
2.- layer_Id: código del horizonte que presenta inconsistencia
3.- inconsistencia: describe la inconsistencia ocurrida según sea el caso:
	a- Top vacío.
	b- Bottom vacío.
	c- Límites invertidos.
	d- Superposición e horizontes.
	e- Horizonte orgánico.
4.- errorCode: Un código secuencial correspondiente con la validación que se realiza, tal como se muestra en la descripción de las validaciones.

Se recomienda ejecutar las validaciones en el orden indicado y corregirlas antes de continuar con la siguiente.
Para la corrección de las inconsistencias se sugiere las siguientes directrices en caso de no poder validar con la fuente original de los datos:
1.- Horizontes sin lÍmite superior asignado: asignar el valor del límite inferior del horizonte anterior, siempre y cuando este no sea el primer horizonte, en cuyo caso el valor debería ser cero (0)
2.- Horizontes sin lÍmite inferior asignado: asignar el valor del límite superior del siguiente horizonte, si es el último horizonte, se sugiere el valor de su límite superior +10.
3.- Horizonte con valores de los límites invertidos: invertir los valores de top y bottom
4.- SuperposiciÓn de horizontes: verificar con datos originales.
5.- Perfiles con horizonte orgánico: i) invertir los valores del primer horizonte y ii) reescalar los datos con base en el espesor del horizonte orgánico, es decir, sumar ese espesor a cada valor.
