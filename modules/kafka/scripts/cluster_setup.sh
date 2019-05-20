#!/bin/bash
set -e -x
echo "========================================================================="
echo "Begin to config Kafka"
echo "cluster_ip_list:${cluster_ip_list}"
echo "cluster_display_name_list:${cluster_display_name_list}"
echo "number:${number}"
#OLD_IFS="$IFS"
#IFS=","
#arr=(${cluster_ip_list})
ip_arr=(${cluster_ip_list})
name_arr=(${cluster_display_name_list})
#IFS="$OLD_IFS"
arr_length=${number}
echo "ip_arr:$ip_arr"
echo "name_arr:$name_arr"
echo "arr_length:$arr_length"
for((i=1;i<=$arr_length;i++));
do
  ip=$abc{ip_arr[i-1]abc}
  name=$abc{name_arr[i-1]abc}
  echo "ip:$ip"
  echo "name:$name"
  sudo sed -i "s/server.$name=$name.$name.$name.$name/server.$name=$ip/g" /home/opc/opt/zookeeper/zookeeper-3.4.10/conf/zoo.cfg
  sudo sed -i "s/$name.$name.$name.$name/$ip/g" /home/opc/opt/kafka/kafka_2.12-1.1.0/config/server.properties
done

cd /home/opc/opt/zookeeper
nohup ./zookeeper-3.4.10/bin/zkServer.sh start > /home/opc/zookeeper.out 2>&1 &

sleep 60
nohup /home/opc/opt/kafka/kafka_2.12-1.1.0/bin/kafka-server-start.sh /home/opc/opt/kafka/kafka_2.12-1.1.0/config/server.properties > /home/opc/kafka.out 2>&1 &
sleep 10
echo "End to config Kafka"
echo "========================================================================="

