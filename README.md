# Optimazing Wordpress Docker
Repositorio de Docker para desarrollo en Wordpress

##Instrucciones
Clonar el repositorio del theme [Optimazing](https://github.com/Optimazing/optimazing-theme)

```
$ git clone https://github.com/Optimazing/optimazing-theme
```

En el mismo nivel de directorio, clonar éste repositorio:

```
$ git clone https://github.com/Optimazing/optimazing-wordpress-docker
```

Con [Docker](https://store.docker.com/editions/community/docker-ce-desktop-mac) ya instalado, ejecutar el siguiente comando dentro del directorio de optimazing wordpress docker:

```
$ cd optimazing-wordpress-docker
$ docker-compose up -d
```

Después de 5 min, abrir un navegador y entrar a http://localhost/wp-admin

El usuario de pruebas es: *optimizing*
Password: *Pruebas123*

Para parar el docker, ejecutar el siguiente comando dentro de la carpeta de optimizing wordpress:

```
$ docker-compose down
```

Se pueden hacer cambios directamente a la carpeta de **optimazing-theme** y estos se verán automáticamente.