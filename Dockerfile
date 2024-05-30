FROM jenkins/jenkins:latest-jdk17

USER root

RUN apt update && apt install openssh-client git -y

# añadir al usuario Jenkins al grupo 999, para que, cuando se monte un socket a este 
# contenedor, el usuario Jenkins pueda acceder al socket, evitando que el usuario del 
# contenedor tenga que ser Root
RUN groupadd --gid 999 docker && \
    usermod -aG docker jenkins

# script para la instalacion de las herramientas cliente de Docker
WORKDIR /root
COPY script_instalacion_docker.sh .
RUN chmod u+x script_instalacion_docker.sh
RUN sh -c ./script_instalacion_docker.sh

WORKDIR /var/jenkins_home
USER jenkins

# evitar que el Wizard para la instalación asistida de Jenkins se lance al iniciar el
# contenedor, porque la configuración la aplicamos con JCasC
ENV JAVA_OPTS='-Djenkins.install.runSetupWizard=false'

# indicar la ubicacion del archivo de configuracion para Jenkins
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins-casc.yaml

# archivo con el listado de plugins a instalar automáticamente, entre ellos, los de Docker
COPY plugins.txt /var/home_jenkins/plugins.txt
RUN jenkins-plugin-cli --plugin-file /var/home_jenkins/plugins.txt

COPY jenkins-casc.yaml /var/jenkins_home/jenkins-casc.yaml