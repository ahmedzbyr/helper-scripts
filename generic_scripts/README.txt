NOTE : Latest Script is here.
https://github.com/ahmedzbyr/big_data_learning/tree/master/bigData/installScripts/hadoopSingleNodeClusterScript


License
=======

Copyright (c) 2012. Zubair AHMED.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Credits. 
=================
1. https://github.com/flexiondotorg - For Java 6 Installation scripts.
2. http://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-single-node-cluster
      - This Script was created using the Installation Guide by Micheal Noll.

hadoopscript
============
Please Readme
- hadoop script to setup Single Node Cluster - For Hadoop 1.0.3 Only.
- Tested on Ubuntu 11.10 - Fresh Install.
- Scripts assumes nothing is installed for Hadoop and installs Required Components for Hadoop to run.
   

HOWTO
-------------------

Steps For Executing Script: Currently script only takes single option at a time :(
-----------------------------------------------------------------------
Execute Help
]$ sudo ./initScriptHadoop.sh --help

usage: ./initScriptHadoop.sh <single-parameter>

  Optional parameters:
     --install-init, -i         Initialization script To Install Hadoop as Single Node Cluster.
     Use the below Options, Once you are logged-in as Hadoop User 'hduser' created in the -i init script above.   
     --install-ssh, -s          Install ssh-keygen -t rsa -P 
     --install-bashrc, -b       Updated '.bashrc' with JAVA_HOME, HADOOP_HOME.
     --ipv6-disable, -v         IPv6 Support Disable.[ Might Not be required. 
                                Updating 'conf/hadoop-env.sh' with 'HADOOP_OPTS=-Djava.net.preferIPv4Stack=true' option in -e]
     --hostname-update, -u      Update Hostname for the system.
     --config-update, -c        Update Configuration with default values (Single Node) in core-site.xml, mapred-site.xml, hdfs-site.xml.
     --update-hadoop-env, -e    Update Hadoop Env Script with JAVA_HOME.
     --install-pig, -p          Install Pig in /usr/local Directory and set .bashrc.
     --install-mahout, -m       Install Mahout in /usr/local Directory and set .bashrc.
     --help, -h                 Display this Message.

1. First Install prerequisites using -i Option
     ahmed@ahmed-on-Edge:~$ ./initScriptHadoop.sh -i
      Welcome to Precofiguration For Hadoop single node setup wizard 
     
     Would you like install Java 1.6 ? (y/n) y
     Would you like to setup user 'hduser' and 'hadoop Group'? (y/n) y
     Would you like to download Hadoop 1.0.3 and extract to /usr/local? (y/n) y
     Would you like to make 'hduser' owner /usr/local/hadoop/ directory? (y/n) y
     Would you like to login into 'htuser' once done? (y/n) y
     
      Review your choices:
     
      Install Java 1.6             : y
      Setup 'hduser' user          : y
      Download Hadoop 1.0.3        : y
      Setup 'hduser' as Owner      : y
      Login to 'hduser'            : y
     
     Proceed with setup? (y/n)y

2. Login to 'hduser' which will be created in the -i options.

3. Execute options -s, -b, -c, -e 
   ./initScriptHadoop.sh -s;
   ./initScriptHadoop.sh -b;
   ./initScriptHadoop.sh -c;
   ./initScriptHadoop.sh -e;

3a. Execute below command to Format namenode (First time Namenode needs to be formated)

    hduser@ubuntu:~$ hadoop namenode -format

Now once the hduser is create add the user to sudoer list.

4. To install Pig and Mahout - will required sudo permissions.
   ./initScriptHadoop.sh -p; # Install Pig in /usr/local
   ./initScriptHadoop.sh -m; # Install Mahout in /usr/local



