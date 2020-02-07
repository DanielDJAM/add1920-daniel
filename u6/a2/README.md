# 1. Salt-stack

Hay varias herramientas conocidas del tipo gestor de infrastructura como Puppet, Chef y Ansible. En esta actividad vamos a practicar Salt-stack con OpenSUSE.

# 2. Preparativos

| Config   | MV1           | MV2          |
| -------- | ------------- | ------------ |
| Alias    | Master        | Minion       |
| Hostname | master18g     | minion18g    |
| SO       | OpenSUSE      | OpenSUSE     |
| IP       | 172.19.18.31  | 172.19.18.32 |

* Configurar `/etc/hosts` con "IP nombre" de MV1 y MV2.

---
# 3. Master: instalar y configurar.

> Enlaces de interés:
> * [OpenSUSE -Saltstack](https://docs.saltstack.com/en/latest/ref/configuration)

* Ir a la MV1
* `zypper install salt-master`, instalar el software del Máster.

![01](01.png)

* Modificar `/etc/salt/master` para configurar nuestro Máster con:
```
interface: 172.19.18.31
file_roots:
  base:
    - /srv/salt
```

![02](02.png)

* `systemctl enable salt-master.service`, activiar servicio en el arranque del sistema.
* `systemctl start salt-master.service`, iniciar servicio.
* `salt-key -L`, para consultar Minions aceptados por nuestro Máster. Vemos que no hay ninguno todavía.
```
Accepted Keys:
Denied Keys:
Unaccepted Keys:
Rejected Keys:
```

![03](03.png)

---
# 4. Minion

Los Minios son los equipos que van a estar bajo el control del Máster.

## 4.1 Instalación y configuración

* `zypper install salt-minion`, instalar el software del agente (minion).

![04](04.png)

* Modificar `/etc/salt/minion` para definir quien será nuestro Máster:
```
master: 172.19.18.31
```

![05](05.png)

* `systemctl enable salt-minion.service`, activar Minion en el arranque del sistema.
* `systemctl start salt-minion.service`, iniciar el servico del Minion.

![06](06.png)

* Comprobar que  que no tenemos instalado `apache2` en el Minion.

![07](07.png)

## 4.2 Aceptación desde el Master

* Ir a la MV1 Máster.
* Hay que asegurarse de que el cortafuegos permite las conexiones al servicio Salt.
    * Comnsultar URL [Opening the Firewall up for Salt](https://docs.saltstack.com/en/latest/topics/tutorials/firewall.html)

## 4.3 Aceptación desde el Master

Ir a MV1:
* `salt-key -L`, vemos que el Máster recibe petición del Minion.
```
Accepted Keys:
Denied Keys:
Unaccepted Keys:
minion18g
Rejected Keys:
```

![08](08.png)

* `salt-key -a minion18g`, para que el Máster acepte a dicho Minion.
* `salt-key -L`, comprobamos.

![09](09.png)

## 4.4 Comprobamos conectividad

Comprobamos la conectividad desde el Máster a los Minions.
```
# salt '*' test.version
minion18g:
    2019.2.0
# salt '*' test.ping
minion18g:
    True
```

![10](10.png)


> El símbolo `'*'` representa a todos los minions aceptados. Se puede especificar un minion o conjunto de minios concretos.

---
# 5. Salt States

> Enlaces de interés:
> * [Learning SaltStack - top.sls (1 of 2)](https://www.youtube.com/watch?v=UOzmExyAXOM&t=8s)
> * [Learning SaltStack - top.sls (2 of 2)](https://www.youtube.com/watch?v=1KblVBuHP2k)
> * [Repositorio GitHub con estados de ejemplo](https://github.com/AkhterAli/saltstates/)

## 5.1 Preparar el directorio para los estados

Vamos a crear directorios para guardar lo estados de Salt. Los estados de Salt son definiciones de cómo queremos que estén nuestras máquinas.

Ir a la MV Máster:
* Crear directorios `/srv/salt/base` y `/srv/salt/devel`.

![11](11.png)

* Crear archivo `/etc/salt/master.d/roots.conf` con el siguiente contenido:
```
file_roots:
  base:
    - /srv/salt/base
  devel:
    - /srv/salt/devel
```

![12](12.png)

* Reiniciar el servicio del Máster.

![13](13.png)

Hemos creado los directorios para:
* base = para guardar nuestros estados.
* devel = para desarrollo o para hacer pruebas.

## 5.2 Crear un nuevo estado

Los estados de Salt se definen en ficheros SLS.
* Crear fichero `/srv/salt/base/apache/init.sls`:
```
install_apache:
  pkg.installed:
    - pkgs:
      - apache2

apache_service:
  service.running:
    - name: apache2
    - enable: True
```

![14](14.png)

Entendamos las definiciones:
* Nuestro nuevo estado se llama `apache` porque el directorio donde están las definiciones se llama `srv/salt/base/apache`.
* La primera línea es un identificador (ID) del estado. Por ejemplo: `install_apache` o `apache_service`, es un texto que ponemos nosotros libremente, de forma que nos ayude a identificar lo que vamos a hacer.
* `pkg.installed`: Es una orden de salt que asegura que los paquetes estén instalado.
* `service.running`: Es una orden salt que asegura de que los servicios estén iniciado o parados.

## 5.3 Asociar Minions a estados

Ir al Master:
* Crear `/srv/salt/base/top.sls`, donde asociamos a todos los Minions con el estado que acabamos de definir.
```
base:       
  '*':
    - apache
```

![15](15.png)

## 5.4 Comprobar: estados definidos

* `salt '*' state.show_states`, consultar los estados que tenemos definidos para cada Minion:
```
minion18g:
    - apache
```

![16](16.png)

## 5.5 Aplicar el nuevo estado

Ir al Master:
* Consultar los estados en detalle y verificar que no hay errores en las definiciones.
    * `salt '*' state.show_lowstate`

![17](17.png)

    * `salt '*' state.show_highstate`,

![18](18.png)

* `salt '*' state.apply apache`, para aplicar el nuevo estado en todos los minions. OJO: Esta acción puede tardar un tiempo.

```
daniel@master18g:/srv/salt> sudo salt '*' state.apply apache
minion18g:
----------
          ID: install_apache
    Function: pkg.installed
      Result: True
     Comment: The following packages were installed/updated: apache2
     Started: 16:12:23.603334
    Duration: 34613.524 ms
     Changes:   
              ----------
              apache2:
                  ----------
                  new:
                      2.4.33-lp150.2.23.1
                  old:
              apache2-prefork:
                  ----------
                  new:
                      2.4.33-lp150.2.23.1
                  old:
              apache2-utils:
                  ----------
                  new:
                      2.4.33-lp150.2.23.1
                  old:
              git-web:
                  ----------
                  new:
                      2.16.4-lp150.2.9.1
                  old:
              libbrotlicommon1:
                  ----------
                  new:
                      1.0.2-lp150.1.3
                  old:
              libbrotlienc1:
                  ----------
                  new:
                      1.0.2-lp150.1.3
                  old:
              system-user-wwwrun:
                  ----------
                  new:
                      20170617-lp150.3.34
                  old:
----------
          ID: apache_service
    Function: service.running
        Name: apache2
      Result: True
     Comment: Service apache2 has been enabled, and is running
     Started: 16:13:02.493273
    Duration: 372.029 ms
     Changes:   
              ----------
              apache2:
                  True

Summary for minion18g
------------
Succeeded: 2 (changed=2)
Failed:    0
------------
Total states run:     2
Total run time:  34.986 s
daniel@master18g:/srv/salt>
```

> NOTA: Con este comando `salt '*' state.highstate`, también se pueden invocar todos los estados.

---
# 6. Crear más estados

## 6.1 Crear estado "users"

> Enlaces de interés:
>
> * [Create groups](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.group.html)
> * [Create users](https://docs.saltstack.com/en/master/ref/states/all/salt.states.user.html)

Vamos a crear un estado llamado `users` que nos servirá para crear un grupo y usuarios en las máquinas Minions.

* Crear directorio `/srv/salt/base/users`.
* Crear fichero `/srv/salt/base/users/init.sls` con las definiones para crear los siguiente:
    * Grupo `mazingerz`
    * Usuarios `koji18`, `drinfierno18` dentro de dicho grupo.

![20](20.png)

* Aplicar el estado.

```
daniel@master18g:/srv/salt/base/users> sudo salt '*' state.apply users
[sudo] password for root:
minion18g:
----------
          ID: koji18
    Function: user.present
      Result: True
     Comment: New user koji18 created
     Started: 16:33:24.952816
    Duration: 129.561 ms
     Changes:   
              ----------
              fullname:
                  koji18
              gid:
                  100
              groups:
                  - users
              home:
                  /home/koji18
              homephone:
              name:
                  koji18
              other:
              passwd:
                  x
              roomnumber:
              shell:
                  /bin/bash
              uid:
                  2001
              workphone:
----------
          ID: drinfierno18
    Function: user.present
      Result: True
     Comment: New user drinfierno18 created
     Started: 16:33:25.082695
    Duration: 55.389 ms
     Changes:   
              ----------
              fullname:
                  drinfierno18
              gid:
                  100
              groups:
                  - users
              home:
                  /home/drinfierno18
              homephone:
              name:
                  drinfierno18
              other:
              passwd:
                  x
              roomnumber:
              shell:
                  /bin/bash
              uid:
                  2002
              workphone:
----------
          ID: mazingerz
    Function: group.present
      Result: True
     Comment: New group mazingerz created
     Started: 16:33:25.139066
    Duration: 80.966 ms
     Changes:   
              ----------
              gid:
                  2020
              members:
                  - koji18
                  - drinfierno18
              name:
                  mazingerz
              passwd:
                  x

Summary for minion18g
------------
Succeeded: 3 (changed=3)
Failed:    0
------------
Total states run:     3
Total run time: 265.916 ms
daniel@master18g:/srv/salt/base/users>

```

## 6.2 Crear estado "directories"

* Crear estado `drectories` para crear las carpetas `private` (700), `public` (755) y `group` (750) en el home del usuario `koji`.

![22](22.png)

* Aplicar el estado.


```
daniel@master18g:/srv/salt/base/directories> sudo salt '*' state.apply directories
minion18g:
----------
          ID: /home/koji18/private
    Function: file.directory
      Result: True
     Comment: Directory /home/koji18/private updated
     Started: 16:37:00.945341
    Duration: 7.17 ms
     Changes:   
              ----------
              /home/koji18/private:
                  New Dir
----------
          ID: /home/koji18/public
    Function: file.directory
      Result: True
     Comment: Directory /home/koji18/public updated
     Started: 16:37:00.952640
    Duration: 0.95 ms
     Changes:   
              ----------
              /home/koji18/public:
                  New Dir
----------
          ID: /home/koji18/group
    Function: file.directory
      Result: True
     Comment: Directory /home/koji18/group updated
     Started: 16:37:00.953683
    Duration: 0.949 ms
     Changes:   
              ----------
              /home/koji18/group:
                  New Dir

Summary for minion18g
------------
Succeeded: 3 (changed=3)
Failed:    0
------------
Total states run:     3
Total run time:   9.069 ms
daniel@master18g:/srv/salt/base/directories>
```

---
# 7. Añadir Minion de otro SO

* Crear MV3 con SO Windows (minion18w)
* Instalar `salt-minion` en MV3.

![24](24.png)

* Ir a MV1(Máster) y aceptar al minion.

![25](25.png)

![26](26.png)
