# FUNCIONES PARA VALIDAR LA CONSISTENCIA DE LOS PERFILES Y SUS LOS HORIZONTES EN UN CONJUNTO DE DATOS
# ELABORO: SERGIO DIAZ GUADARRAMA - contacto: sergiodiaz.geo@gmail.com
# REQUISITOS: El archivo .csv debe tener cuatro columnas clave las cuales son:
## 1- profile_Id: Corresponde al identificador unico del perfil.
## 2- layer_Id: Corresponde al identificador del horizonte.
## 3- top: Limite superior del horizonte.
## 4- bottom: Limite inferior del horizonte.
# Las validaciones que se realizan son:
## 1- Horizontes sin limite superior asignado (I-1).
## 2- Horizontes sin limite inferior asignado (I-2).
## 3- Horizonte con valores de los límites invertidos (I-3).
## 4- Superposicion de horizontes (I-4).
## 5- Perfiles con horizonte organico (I-5).
# El resultado se almacena en el dataframe validaPerfil con el listado de los perfiles con inconsistencia

# Leer csv
ruta_perfiles <- 'ruta de su archivo .csv'
perfiles <- read.csv(file = ruta_perfiles) # Cargar el archivo
listPerfiles <- unique(perfiles$profile_identifier) # Listado de los perfiles
validaPerfil <- data.frame(profile_Id = character(), layer_Id = character(), 
                            inconsistencia = character(), errorCode = character()) # Dataframe de inconsistencias


# VALIDACIONES

# 1-Validar valores vacios en top ## OK
for (i in 1: NROW(listPerfiles)){
  inconsistencia <- 'Top vacio' # Descripcion de la inconsistencia
  errorCode <- 'I-1' # Codigo de la inconsistencia
  perfTemp <- perfiles[perfiles$profile_identifier == listPerfiles[i],] #Dataframe temporal con el perfil a validar
  for (j in 1: NROW(perfTemp)){
    profile_Id <- as.character(perfTemp$profile_identifier[j]) # Obtencion del código del perfil que se valida
    layer_Id <- as.character(perfTemp$layer_identifier[j]) #Obtencion del codigo del horizonte que se valida
    if (j == 1) {
      if ((is.na(perfTemp$top[j])) & (!is.na(perfTemp$bottom[j]))){
        validaPerfil <- rbind(validaPerfil, cbind(profile_Id, layer_Id, inconsistencia, errorCode))
      }
    } else {
      if ((is.na(perfTemp$top[j])) & (!is.na(perfTemp$bottom[j])) & (!is.na(perfTemp$bottom[j-1]))){
        validaPerfil <- rbind(validaPerfil, cbind(profile_Id, layer_Id, inconsistencia, errorCode))
      }
    }
  }
  validaPerfil <- unique(validaPerfil)
  names(validaPerfil) <- c('profile_Id','layer_Id', 'inconsistencia', 'errorCode')
}

# 2-Validar valores vacios en bottom ## OK
for (i in 1: NROW(listPerfiles)){
  inconsistencia <- 'Bottom vacio'
  errorCode <- 'I-2'
  perfTemp <- perfiles[perfiles$profile_identifier == listPerfiles[i],]
  for (j in 1 : (NROW(perfTemp))){
    profile_Id <- as.character(perfTemp$profile_identifier[j])
    layer_Id <- as.character(perfTemp$layer_identifier[j])
    if (!is.na(perfTemp$top[j]) & is.na(perfTemp$bottom[j])){
      validaPerfil <- rbind(validaPerfil, cbind(profile_Id, layer_Id, inconsistencia, errorCode))
    }
  }
  validaPerfil <- unique(validaPerfil)
  names(validaPerfil) <- c('profile_Id','layer_Id', 'inconsistencia', 'errorCode')
}

# 3- Limites invertidos ## OK
for (i in 1: NROW(listPerfiles)){
  inconsistencia <- 'Limites invertidos'
  errorCode <- 'I-3'
  perfTemp <- perfiles[perfiles$profile_identifier == listPerfiles[i],]
  profile_Id <- as.character(perfTemp$profile_identifier[j])
  
  if (NROW(perfTemp) == 1 & (!is.na(perfTemp$top[1]) & !is.na(perfTemp$bottom[1]))){
    layer_Id <- as.character(perfTemp$layer_identifier[1])
    if (perfTemp$top[1] > perfTemp$bottom[1]) {
      validaPerfil <- rbind(validaPerfil, cbind(profile_Id, layer_Id, inconsistencia, errorCode))
    }
  } else {
    for (j in 1: nrow(perfTemp)){
      if (j == 1) {
        layer_Id <- as.character(perfTemp$layer_identifier[1])
        if ((perfTemp$top[1] > perfTemp$bottom[1]) &
            (perfTemp$bottom[1] == 0) & (perfTemp$top[2] != 0) &
            ((!is.na(perfTemp$top[1])) & (!is.na(perfTemp$bottom[1])))) {
          validaPerfil <- rbind(validaPerfil, cbind(profile_Id, layer_Id, inconsistencia, errorCode))
        }
      } else{
        layer_Id <- as.character(perfTemp$layer_identifier[j])
        if ((perfTemp$top[j] > perfTemp$bottom[j]) &
            (perfTemp$bottom[j] >= perfTemp$bottom[j-1]) &
            ((!is.na(perfTemp$top[j])) & (!is.na(perfTemp$bottom[j])))) {
          validaPerfil <- rbind(validaPerfil, cbind(profile_Id, layer_Id, inconsistencia, errorCode))
        }
      }
    }
  }
  validaPerfil <- unique(validaPerfil)
  names(validaPerfil) <- c('profile_Id','layer_Id', 'inconsistencia', 'errorCode')
}

# 4- Superpoosicion de horizontes ## OK
for (i in 1: NROW(listPerfiles)){
  inconsistencia <- 'Superposicion de horizontes'
  errorCode <- 'I-4'
  perfTemp <- perfiles[perfiles$profile_identifier == listPerfiles[i],]
  if (NROW(perfTemp) >= 2) {
    for (j in 2 : NROW(perfTemp)){
      profile_Id <- as.character(perfTemp$profile_identifier[j])
      layer_Id <- as.character(perfTemp$layer_identifier[j])
      if (!is.na(perfTemp$top[j-1]) & !is.na(perfTemp$top[j]) & !is.na(perfTemp$bottom[j-1]) &  !is.na(perfTemp$bottom[j])){
        if ( (perfTemp$top[j-1] < perfTemp$bottom[j-1]) & ( perfTemp$top[j] < perfTemp$bottom[j])){
          if (perfTemp$top[j] < perfTemp$bottom[j-1]) {
            validaPerfil <- rbind(validaPerfil, cbind(profile_Id, layer_Id, inconsistencia, errorCode))
          }
        }
      }
    }
  }
  validaPerfil <- unique(validaPerfil)
  names(validaPerfil) <- c('profile_Id','layer_Id', 'inconsistencia', 'errorCode')
}

# 5- Horizonte organico ## OK
for (i in 1: NROW(listPerfiles)){
  inconsistencia <- 'Horizonte organico'
  errorCode <- 'I-5'
  perfTemp <- perfiles[perfiles$profile_identifier == listPerfiles[i],]
  profile_Id <- as.character(perfTemp$profile_identifier[1])
  layer_Id <- as.character(perfTemp$layer_identifier[1])
  
  if (!is.na(perfTemp$top[1]) & !is.na(perfTemp$bottom[1]) & 
      !is.na(perfTemp$top[2]) & !is.na(perfTemp$bottom[2]) & NROW(perfTemp) > 1){
    if (((perfTemp$top[1] > 0) & perfTemp$bottom[1] == 0) &
        ((perfTemp$top[2] == 0) & perfTemp$bottom[2] > 0)) {
      validaPerfil <- rbind(validaPerfil, cbind(profile_Id, layer_Id, inconsistencia, errorCode))
    }
  }
  validaPerfil <- unique(validaPerfil)
  names(validaPerfil) <- c('profile_Id','layer_Id', 'inconsistencia', 'errorCode')
}


read.cs
