FROM alpine:3.10.2 AS pentaho-base

LABEL maintainer="Nicolai Ernst"

# Pentaho
ARG PENTAHO_VERSION_SHORT="8.3"
ARG PENTAHO_VERSION_FULL="${PENTAHO_VERSION_SHORT}.0.0-317"

ARG PENTAHO_URL="https://downloads.sourceforge.net/project/pentaho/Pentaho%208.3/server/pentaho-server-manual-ce-8.3.0.0-371.zip?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fpentaho%2Ffiles%2FPentaho%25208.3%2Fserver%2Fpentaho-server-manual-ce-8.3.0.0-371.zip%2Fdownload&ts=1568800412"
ARG PENTAHO_SERVER_FOLDER="/pentaho/server/pentaho-server"
ARG PENTAHO_HOME_FOLDER="/.pentaho"

# WildFly
ARG WILDFLY_VERSION="17.0.1.Final"
ARG JBOSS_HOME="/opt/jboss/"

# https://help.pentaho.com/Documentation/8.2/Setup/Installation/Manual/Linux_Environment

# Setup Alpine Linux
RUN echo "Updating repository packages ..." &&\
    apk update &&\
    apk add unzip &&\
    apk add openssl &&\
    apk add curl

# Install Java JDK
RUN echo "Installing Java JRE ..." &&\
    apk add openjdk7-jre

# Install or use Web Application Server
RUN echo "Creating JBoss user ..." &&\
    mkdir -p ${JBOSS_HOME} &&\
    adduser -D -h ${JBOSS_HOME} jboss

USER jboss

RUN echo "Installing JBoss WildFly vers. ${WILDFLY_VERSION} ..." &&\
    cd $HOME &&\
    curl -LO http://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.zip &&\
    unzip -qq wildfly-$WILDFLY_VERSION.zip &&\
    mv $HOME/wildfly-$WILDFLY_VERSION $HOME/wildfly &&\
    rm wildfly-$WILDFLY_VERSION.zip

# EXPOSE 8080 9990
# CMD /opt/jboss/wildfly/bin/standalone.sh --server-config=$STANDALONE.xml -b 0.0.0.0

# ADD your-awesome-app.war /opt/jboss/wildfly/standalone/deployments/

USER root

# Create Linux directory structure
RUN echo "Creating Pentaho directory structure ..." &&\
    mkdir -p ${PENTAHO_HOME_FOLDER} &&\
    mkdir -p ${PENTAHO_SERVER_FOLDER}

# Create Pentaho User
RUN echo "Creating Pentaho user ..." &&\
    adduser -D -h ${PENTAHO_HOME_FOLDER} pentaho

# Use recent created pentaho user
USER pentaho

# Download and Unpack Installation Files
RUN echo "Installing Pentaho vers. ${PENTAHO_VERSION_FULL} ..." &&\
    cd $HOME &&\
    curl ${PENTAHO_URL} > pentaho-${PENTAHO_VERSION_FULL}.zip &&\
    ls -la
#unzip -d ${PENTAHO_SERVER_FOLDER} -qq pentaho-${PENTAHO_VERSION_FULL}.zip
#cd ${PENTAHO_SERVER_FOLDER} &&\
#ls -lrt

USER root

# Install or use Pentaho Repository Host Database
# TODO: Make this optional (via EMBEDDED_DATABASE)
RUN echo "Installing PostgreSQL database ..." &&\
    apk add postgresql
