FROM php:7.1-cli
MAINTAINER Exakat, Damien Seguy, dseguy@exakat.io

COPY exakat.sh /usr/src/exakat/
COPY config/exakat.ini /usr/src/exakat/config/
COPY projects /usr/src/exakat/projects
COPY docs/ /docs/

RUN \
    echo "===> php.ini" && \
    echo "memory_limit=-1" >> /usr/local/etc/php/php.ini && \
    \
    echo "===> Java 8"  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get update  && \
    \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default  && \
    \
    apt-get update && apt-get install -y --no-install-recommends \
    git \
    maven \ 
    lsof && \
    \
    export TERM="xterm" && \
    \    
    echo "====> Exakat 0.11.5" && \
    cd /usr/src/exakat && \
    wget --quiet http://dist.exakat.io/index.php?file=exakat-0.11.5.phar -O exakat.phar && \
    chmod a+x /usr/src/exakat/exakat.* && \
    ln -s /src /usr/src/exakat/projects/codacy/code && \
    \
    echo "====> Neo4j" && \
    wget --quiet http://dist.neo4j.org/neo4j-community-2.3.10-unix.tar.gz && \
    tar zxf neo4j-community-2.3.10-unix.tar.gz && \
    mv neo4j-community-2.3.10 neo4j && \
    export NEO4J_HOME=/usr/src/exakat && \
    sed -i.bak s/dbms\.security\.auth_enabled=true/dbms\.security\.auth_enabled=false/ neo4j/conf/neo4j-server.properties && \
    sed -i.bak s%#org.neo4j.server.thirdparty_jaxrs_classes=org.neo4j.examples.server.unmanaged=/examples/unmanaged%org.neo4j.server.thirdparty_jaxrs_classes=com.thinkaurelius.neo4j.plugins=/tp% neo4j/conf/neo4j-server.properties && \
    sed -i.bak s%org.neo4j.server.webserver.port=7474%org.neo4j.server.webserver.port=7777% neo4j/conf/neo4j-server.properties && \
    rm neo4j/conf/neo4j-server.properties.bak && \
    rm -rf neo4j-community-2.3.10-unix.tar.gz && \
    \
    echo "====> Gremlin 3" && \
    git clone https://github.com/thinkaurelius/neo4j-gremlin-plugin && \
    cd neo4j-gremlin-plugin && \
    sed -i.bak s_\<tinkerpop-version\>3.1.0-incubating\</tinkerpop-version\>_\<tinkerpop-version\>3.2.0-incubating\</tinkerpop-version\>_ tinkerpop3/pom.xml && \
    mvn clean package -DskipTests -Dtp.version=3  && \
    unzip target/neo4j-gremlin-plugin-tp3-2.3.1-server-plugin.zip -d ../neo4j/plugins/gremlin-plugin && \
    rm -rf /usr/src/exakat/neo4j-gremlin-plugin && \
    \
    echo "====> Cleanup" && \
    apt-get clean && \
    apt-get remove -y --purge maven && \
    rm -rf /var/cache/oracle-jdk8-installer  && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -u 2004 -ms /bin/bash docker && \
    chown -R docker:docker /docs && \
    chown -R docker:docker /usr/src/exakat 

WORKDIR /usr/src/exakat

ENTRYPOINT [ "/usr/src/exakat/exakat.sh" ]

