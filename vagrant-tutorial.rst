Creación de ambientes virtuales con Vagrant
===========================================

Vagrant_ es una herramienta de línea de comando cuyo objetivo principal es la creación de máquinas virtuales, en forma rápida, flexible y reproducible. Está desarrollada en Ruby, es de código abierto y multiplataforma. Vagrant nos permite crear fácilmente un ambiente con la configuración que necesitemos (Sistema operativo, librerías, aplicaciones, etc).

.. _Vagrant: https://www.vagrantup.com/

Casos de Uso:

- Generar ambientes de prueba para realizar deploys
- Unificar los ambientes de desarrollo de los miembros de un equipo
- Creación de ambientes con diferentes configuraciones para testear el funcionamiento de nuestra aplicación.
- Crear una versión de una aplicación web que corra dentro de una máquina virtual y sea servida en un puerto de mi máquina local

Como instalarlo?
----------------

Descargar__ la versión correspondiente a nuestro sistema operativo y seguir el proceso de instalación normal.
Además, debemos instalar una herramienta de virtualización. En nuestro caso utilizamos VirtualBox_, ya que es gratuita y esta disponible en las plataformas más importantes. 

__ http://www.vagrantup.com/downloads
.. _Virtualbox: https://www.virtualbox.org/

Ejemplo
-------

Mostraremos a continuación un ejemplo básico de como utilizamos Vagrant para crear un ambiente donde testear la instalación de una aplicación web servida desde apache. En nuestro caso estamos trabajando en ubuntu 12.04, utilizando Vagrant en su versión 1.5.4 y Virtualbox 4.3.18.  

Creando nuestra configuración
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Vamos a crear una carpeta donde almacenaremos la configuración requerida para instanciar nuestra máquina virtual. Este será el directorio raiz de nuestra configuración en el cuál debemos ejecutar los comandos de vagrant

.. code-block:: console

    $ mkdir vagrant_prueba
    $ cd vagrant_prueba


La configuración inicial de la máquina virtual que vamos a crear va a estar definida en el archivo Vagrantfile. Para crear un archivo Vagranfile de ejemplo, con comentarios sobre la configuración que podemos definir, ejecutamos el comando:

.. code-block:: console   
    
    $ vagrant init

Una vez ejecutado este comando debemos definir la imagen base (base box) que será utilizada para clonar nuestras máquinas virtuales. Podemos encontrar imágenes base con diferentes configuraciones en los siguientes repositorios:

- Repositorio oficial: https://atlas.hashicorp.com/boxes/search
- Vagrantbox.es: http://www.vagrantbox.es/
- Imagenes Ubuntu: https://cloud-images.ubuntu.com/vagrant/

Si encontramos una con la configuración que necesitemos (principalmente el SO, las demás aplicaciones puede instalarse luego) debemos definirla dentro del archivo Vagrantfile en la línea:

::
 
     config.vm.box = "puphpet/debian75-x64"

En este caso seleccionamos un Debian Server 7.5 de 64bits, que se encuentra en el repositorio oficial de Vagrant (por eso la identificamos con su nombre únicamente). Si seleccionamos una imagen que se encuentre en otro repositorio, debemos especificar la url desde donde descargarla y el nombre con la que la identificaremos:

::

   config.vm.box = "ubuntu-trusty-64bits"
   config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

Una vez definida esta configuración podemos iniciar nuestra máquina virtual con el comando:

.. code-block:: console

    $ vagrant up

Lo primero que hará este comando es chequear si tenemos descargada en nuestro sistema una versión de la imagen que definimos como base. Si no es así, la descargará y la ubicará en un directorio manejado por vagrant (en ubuntu ~/.vagrant.d/boxes). Podemos ver el listado de imágenes descargadas en nuestro sistema con el comando:
  
.. code-block:: console

    $ vagrant box list

    
Luego de descargar la imagen, Vagrant clonará la misma para crear nuestra máquina virtual. Por último iniciará la máquina virtual. Si el comando se ejecutó con éxito, podemos conectarnos a la misma por ssh, ejecutando el comando:

.. code-block:: console

    $ vagrant ssh

Una vez conectados podemos hacer los cambios necesarios para poder instalar nuestra aplicación. Notar que por defecto, el directorio raiz desde donde iniciamos nuestra vm, ha sido compartido dentro de la misma en el directorio /vagrant (esto nos facilita la tarea de copiar archivos desde nuestra máquina hacia la máquina virtual que creamos). Estos directorios se encuentra sincronizados, por lo que cualquier cambio en los archivos o carpetas de los mismos se verá reflejado en ambas máquinas.

Provisioning
------------

Como vimos podemos instalar el sofware que necesitemos para ejecutar nuestra aplicación logueándonos por ssh e instalándolo "a mano". Una mejor forma es utilizar los provisioners de Vagrant que nos permiten automatizar el proceso de instalación y configuración de las aplicaciones necesarias. La forma más simple es proveer un script de shell que se lanzará al realizar el vagrant up.

Por ejemplo, para actualizar el sistema e instalar apache podemos crear el siguiente script bash en la carpeta root del proyecto:

.. code-block:: bash

    #!/usr/bin/env bash

    apt-get update
    apt-get install -y apache2

y configurar sus ejecución dentro de Vagrantfile con la siguiente línea:

::

    config.vm.provision :shell, path: "update_and_install_apache.sh", privileged: true

Si cambiamos esta configuración en una máquina que se encuentra corriendo, podemos reiniciar la máquina tomando esta configuración con:

.. code-block:: console

    $ vagrant reload --provision

Además de shell, podemos utilizar algunas otras herramientas de más alto nivel como por ejemplo: Ansible_, Chef_ o Puppet_

.. _Ansible: http://docs.ansible.com/
.. _Chef: https://www.chef.io/chef/
.. _Puppet: https://puppetlabs.com/puppet/what-is-puppet

Networking
----------

Hasta el momento, tenemos una máquina virtual, con la que podemos interactuar, compartir archivos e instalarle las aplicaciones que necesitemos. Lo último que necesitaríamos para chequear que nuestra aplicación web funcione correctamente es poder acceder a la misma desde nuestra máquina host. 

La forma más simple de realizar esto es mediante Port Forwarding, para conectar y retransmitir los datos que se envían desde un puerto de nuestra máquina host hacia un puerto de nuestra máquina virtual.

Si seguimos trabajando con la máquina que creamos recientemente, veremos que apache se encuentra levantado y corriendo por default en el puerto 80. Podemos conectar este puerto con el puerto 8080 de nuestra máquina host con la siguiente configuración en el Vagranfile:

::

    config.vm.network :forwarded_port, host: 8080, guest: 80

Luego, para que tome esta nueva configuración ejecutar ``vagrant up`` (o ``vagrant reload`` si la vm ya se encuentra levantada). A continuación, podemos acceder en nuestra máquina host a la dirección http://localhost:8080 y veremos la página de ejemplo de apache, que está siendo servida desde la vm.

La configuración completa de la máquina de ejemplo quedaría:

.. code-block:: ruby

    # -*- mode: ruby -*-
    # vi: set ft=ruby :

    # Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
    VAGRANTFILE_API_VERSION = "2"

    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
      config.vm.box = "puphpet/debian75-x64"
      config.vm.network "forwarded_port", guest: 80, host: 8080
      config.vm.provision :shell, path: "update_and_install_apache.sh", privileged: true
    end


Apagado
-------

Finalmente, podemos apagar nuestra máquina virtual, manteniendo los cambios que se hayan realizado en la misma, con el comando: ``vagrant halt``. Para iniciarla nuevamente debemos ejecutar ``vagrant up``.

En el caso de que queramos detener nuestra máquina virtual salvando el estado de ejecución actual de forma que pueda ser resumido más tarde y continuar desde ese punto exacto, utilizaremos los comandos: ``vagrant suspend`` y ``vagrant resume`` (respectivamente)

Por último, si sabemos que no vamos a trabajar más con esta máquina podemos eliminarla con el comando: ``vagrant destroy``. Esto detiene la máquina virtual y destruye todos los cambios que podamos haber hecho, pero no así su archivo de configuración (**Vagrantfile**), permitiendo ejecutar luego un ``vagrant up`` que iniciará una nueva vm a partir de una imagen totalmente limpia.

Podemos chequear el estado en que se encuentra nuestra máquina virtual con el comando: ``vagrant status``.

`Múltiples VMs`__
-----------------

__ http://docs.vagrantup.com/v2/multi-machine/


Es común en el contexto de una aplicación web, que la misma esté integrada por diferentes procesos, deployados en diferentes servidores y comunicandose entre sí, dentro de una red. Vagrant permite fácilmente gestionar y definir una configuracion de este tipo. Analizaremos a continuación un ejemplo con dos máquinas virtuales, una utilizada para ejecutar la aplicación y otra para el servidor de base de datos.

.. code-block:: ruby

    # -*- mode: ruby -*-
    # vi: set ft=ruby :

    # Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
    VAGRANTFILE_API_VERSION = "2"

    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

      config.vm.box = "puphpet/debian75-x64"

      config.vm.define "web" do |web|
        web.vm.provision :shell, path: "update_and_install_apache.sh", privileged: true
        web.vm.network "private_network", ip: "192.168.0.2"
      end

      config.vm.define "db" do |db|
        db.vm.provision :shell, path: "install_mysql.sh", privileged: true
        db.vm.network "private_network", ip: "192.168.0.3"
      end
    end


La opción ``config.vm.define`` nos permite definir una configuración dentro de la configuración general. Este comando toma como parámetro el nombre de una variable (en este caso "web" y "db"). A partir de estas variables podemos definir la configuración particular que aplica a cada máquina.

Las directivas que se encuentran por fuera de la configuración particular de cada máquina es compartida por ambas instancias. En este caso ambas  usarán la imagen base "puphpet/debian75-x64".

Además de la configuración que ya teníamos definida para el servidor web, agregamos a ambas la configuración para crear una red privada entre la maquina host y las dos máquinas virtuales, de forma que puedan comunicarse entre sí. Para hacer una solicitud al servidor apache que está corriendo en la instancia "web" podemos acceder a la url http://192.168.0.2

En este caso podemos realizar todas las acciones que enumeramos anteriormente indicando sobre la instancia que queremos realizarla. Por ejemplo si queremos conectarnos por ssh a la instancia web:

.. code-block:: console

    $ vagrant ssh web

Por default el comando ``vagrant up`` inicia en este caso todas las instancias.



Cómo lo utilizamos?
-------------------

En el proyecto FOP-ARSAT, tuvimos que desarrollar y deployar una aplicación compuesta por diferentes procesos, que se comunican entre sí y que podían estar instalados y corriendo en varios servidores, con diferentes configuraciones. Cada uno de estos procesos requería de diferentes ambientes y aplicaciones para correr. Para probar el correcto funcionamiento de la aplicación, además de los test unitarios y las pruebas de integración, necesitábamos una forma de testear la correcta instalación y comunicación de los diferentes procesos.

Vagrant nos permitió crear rápida y fácilmente, ambientes similares a los utilizados por el cliente para realizar la instalación. Estos ambientes serían de gran utilidad para testear y depurar errores en los scripts de instalación y actualización de nuestra aplicación.

Otro de los requerimientos del proyecto era proveerle al cliente de una máquina virtual, en la que se encuentre corriendo la aplicación y a la cuál podamos conectarnos, de forma tal de poder correr la misma en forma local sin necesidad de acceder internet. Para unificar y automatizar el proceso de creación de estas máquinas virtuales utilizamos Vagrant.

Por último, debido a que el cliente no posee un entorno Unix, para trabajar fácilmente en el desarrollo de la aplicación, le proveímos de una máquina virtual con las herramientas y las aplicaciones necesarias para realizar esta tarea. El proceso de creación de estas máquinas virtuales también fue implementado utilizando Vagrant. 

Links útiles
^^^^^^^^^^^^
 
  - https://docs.vagrantup.com/v2/getting-started/index.html