#!/bin/bash
set -e -x
function installJava() {
  echo "======================================================================="
  echo "Begin to install Java"

  sudo yum -y install java-1.8.0-openjdk*
  java_version=`java -version 2>&1 >/dev/null | grep 'version' | awk '{print $3}'`
  echo $java_version
  if [[ $java_version == "\"1.8.0_"* ]] ;
    then
      echo "Install java success."
    else
      echo "Failed to install java."
    fi

  echo "======================================================================="
}


function installZookeeper() {
  echo "========================================================================="
  echo "Begin to install Zookeeper"

  cd ~
  mkdir opt
  cd ~/opt
  mkdir zookeeper
  cd ~/opt/zookeeper/
  mkdir zkdata
  mkdir zkdatalog
  wget http://mirrors.cnnic.cn/apache/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz
  tar -zxvf zookeeper-3.4.10.tar.gz
  cd ~/opt/zookeeper/zookeeper-3.4.10/conf
  cp zoo_sample.cfg zoo.cfg

  echo "zookeeper_client_port:${zookeeper_client_port}"
  echo "zookeeper_internal_port:${zookeeper_internal_port}"
  echo "zookeeper_poll_port:${zookeeper_poll_port}"
  echo "number_of_kafka:${number_of_kafka}"
  echo "displya_name:$1"

  sudo firewall-cmd --zone=public --add-port=${zookeeper_client_port}/tcp --permanent
  sudo firewall-cmd --zone=public --add-port=${zookeeper_internal_port}/tcp --permanent
  sudo firewall-cmd --zone=public --add-port=${zookeeper_poll_port}/tcp --permanent
  sudo firewall-cmd --reload

  chmod 666 zoo.cfg

  sed -i  's/dataDir=\/tmp\/zookeeper/dataDir=\/home\/opc\/opt\/zookeeper\/zkdata/g' zoo.cfg
  sed -i "s/clientPort=2181/clientPort=${zookeeper_client_port}/g" zoo.cfg
  echo 'dataLogDir=/home/opc/opt/zookeeper/zkdatalog' >> zoo.cfg

  for i in `seq ${number_of_kafka}`
    do
      if((i==$1))
      then
        echo "server.$i=0.0.0.0:${zookeeper_internal_port}:${zookeeper_poll_port}" >> zoo.cfg
        continue
      else
        echo "server.$i=$i.$i.$i.$i:${zookeeper_internal_port}:${zookeeper_poll_port}" >> zoo.cfg
        continue
      fi
  done

  sudo echo "$1" > ~/opt/zookeeper/zkdata/myid

}

function installkafka() {
  echo "========================================================================="
  echo "Begin to install Kafka"

  cd ~/opt
  mkdir kafka
  cd kafka
  mkdir kafkalogs
  wget http://ftp.jaist.ac.jp/pub/apache/kafka/1.1.0/kafka_2.12-1.1.0.tgz
  tar -xzf kafka_2.12-1.1.0.tgz
  cd ~/opt/kafka/kafka_2.12-1.1.0/config/

  echo "kafka_client_port:${kafka_client_port}"
  echo "number_of_kafka:${number_of_kafka}"

  sudo firewall-cmd --zone=public --add-port=${kafka_client_port}/tcp --permanent
  sudo firewall-cmd --reload

  chmod 666 server.properties

  sed -i  "s/broker.id=0/broker.id=$1/g" server.properties
  sed -i "s/log.dirs=\/tmp\/kafka-logs/log.dirs=\/home\/opc\/opt\/kafka\/kafkalogs/g" server.properties
  echo '' >>server.properties
  echo "port=${kafka_client_port}" >> server.properties
  echo 'message.max.byte=5242880' >> server.properties
  echo 'default.replication.factor=2' >> server.properties
  echo 'replica.fetch.max.bytes=5242880' >> server.properties

  zookeeperConn=""
  for i in `seq ${number_of_kafka}`
    do
      if((i<${number_of_kafka}))
      then
        zookeeperConn=$zookeeperConn$i.$i.$i.$i:${zookeeper_client_port},
        continue
      else
        zookeeperConn=$zookeeperConn$i.$i.$i.$i:${zookeeper_client_port}
        continue
      fi
  done

  echo "zookeeperConn is $zookeeperConn"
  sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=$zookeeperConn/g" server.properties

}

echo "==================================================================================="
echo "Begin to setup kafka instance"
echo "aaa:$#"
echo "aaa:$*"
echo "aaa:$1"

# Install Java
installJava

#Install Zookeeper
installZookeeper $1

#Install Zookeeper
installkafka $1

echo "End to setup kafka instance"
echo "==================================================================================="
