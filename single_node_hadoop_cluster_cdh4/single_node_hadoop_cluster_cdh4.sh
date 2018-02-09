#!/usr/bin/env bash

#
# Text Formating
#

BOLD="\033[1m";
NORM="\033[0m";

BLACK_F="\033[30m"; BLACK_B="\033[40m"
RED_F="\033[31m"; RED_B="\033[41m"
GREEN_F="\033[32m"; GREEN_B="\033[42m"
YELLOW_F="\033[33m"; YELLOW_B="\033[43m"
BLUE_F="\033[34m"; BLUE_B="\033[44m"
MAGENTA_F="\033[35m"; MAGENTA_B="\033[45m"
CYAN_F="\033[36m"; CYAN_B="\033[46m"
WHITE_F="\033[37m"; WHITE_B="\033[47m"

	
HBASE_UPDATE_FILE_PATH="/etc/hbase/conf/hbase-site.xml.updated.org_$(date +'%d-%m-%Y')"
HBASE_ORG_PATH="/etc/hbase/conf/hbase-site.xml"
HBASE_TEMP_PATH="/tmp/hbase-site.xml"


uninstall_open_java()
{
	# Removing Open JDK from the system.
	sudo apt-get purge openjdk*
	sudo apt-get update
}

installing_oracle_7_java()
{
	# Installing Oracle Java
	cd ~/Downloads
	wget https://github.com/flexiondotorg/oab-java6/raw/0.2.8/oab-java.sh -O oab-java.sh
	chmod 777 oab-java.sh
	sudo ./oab-java.sh -7
	sudo apt-get update
	sudo apt-get install oracle-java7-jdk oracle-java7-fonts oracle-java7-source ssh
}

install_dep_change()
{
    sudo echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" > /etc/apt/sources.list.d/webupd8team-java.list
    sudo echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/apt/sources.list.d/webupd8team-java.list
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
    sudo apt-get update
    sudo apt-get install oracle-java7-installer
}


install_oracle_7_java()
{
	sudo apt-get purge openjdk*
	install_dep_change

	#Now you can install Java 7 by adding the following repository:
	sudo add-apt-repository ppa:webupd8team/java
	sudo apt-get update
	sudo apt-get install oracle-java7-installer
    sudo apt-get install oracle-java7-jdk oracle-java7-fonts oracle-java7-source ssh
}


installing_python_components()
{
	# Installing Python and required components
	sudo apt-get install python
	sudo apt-get install python-date
	sudo apt-get install python-dateutil
	sudo apt-get install python-genfromtxt
	sudo apt-get install genfromtxt
	sudo apt-get install numpy
	sudo apt-get install python-numpy
}

installing_linux_headers()
{
	# Installing Linux header - used for VMWare linux
	sudo apt-get update
	sudo apt-get install linux-headers-$(uname -r)
}

installing_cloudera_precise()
{
	# Installing Clodera Hadoop.
	cd ~/Downloads/
	wget http://archive-primary.cloudera.com/cdh4/one-click-install/lucid/amd64/cdh4-repository_1.0_all.deb
	sudo dpkg -i cdh4-repository_1.0_all.deb
	sudo apt-get update
	sudo apt-get install zookeeper=3.4.5+26-1.cdh4.7.0.p0.17~lucid-cdh4.7.0 hadoop-0.20-conf-pseudo
	sudo apt-get install zookeeper-server
	sudo service zookeeper-server init
	sudo apt-get install hadoop-0.20-conf-pseudo
	sudo apt-get install hbase-master # this will install Hbase as well
	sudo apt-get install hbase-regionserver	 
}




config_hbase()
{

    echo -e "${BOLD}${RED_F} Updating Hbase Configuration Files: ${NORM}"
    echo -e "${RED_F}Would like to update hbase-site.xml files (y/n)${NORM}"
    read UPDATE_FILE
	
	if [ $UPDATE_FILE == "y" ]; then
        if [ -f $HBASE_UPDATE_FILE_PATH ];
        then
            echo -e "${BOLD}${RED_F} File $HBASE_UPDATE_FILE_PATH exists${NORM}"
            echo -e "${RED_F}File Already updated by this script, Do you really want to update File. (y/n)${NORM}"
            read UPDATE_FILE
            if [ $UPDATE_FILE = "y" ]; then
                sudo cp $HBASE_ORG_PATH $HBASE_UPDATE_FILE_PATH
                echo "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
            
<!-- Put site-specific property overrides in this file. -->

<configuration>
<property>
  <name>hbase.cluster.distributed</name>
  <value>true</value>
</property>
<property>
  <name>hbase.rootdir</name>
  <value>hdfs://localhost:8020/hbase</value>
</property>
</configuration>" >> $HBASE_TEMP_PATH
                sudo cp $HBASE_TEMP_PATH $HBASE_ORG_PATH
                rm $HBASE_TEMP_PATH
        fi
        else
            sudo cp $HBASE_ORG_PATH $HBASE_UPDATE_FILE_PATH
            echo "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
            
<!-- Put site-specific property overrides in this file. -->

<configuration>
<property>
  <name>hbase.cluster.distributed</name>
  <value>true</value>
</property>
<property>
  <name>hbase.rootdir</name>
  <value>hdfs://localhost:8020/hbase</value>
</property>
</configuration>" >> $HBASE_TEMP_PATH
                sudo cp $HBASE_TEMP_PATH $HBASE_ORG_PATH
                rm $HBASE_TEMP_PATH

        fi
	fi
}

config_cloudera_hadoop()
{
	# Step 1: Format the NameNode.
	sudo -u hdfs hdfs namenode -format

	# Step 2: Start HDFS
	for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done

	# Step 3: Create the /tmp Directory
	sudo -u hdfs hadoop fs -mkdir /tmp 
	sudo -u hdfs hadoop fs -chmod -R 1777 /tmp
	 
	# 3,1 Create Directory for Hbase
	sudo -u hdfs hadoop fs -mkdir /hbase 
	sudo -u hdfs hadoop fs -chown hbase /hbase
	 
	# Step 4: Create the MapReduce system directories: 
	sudo -u hdfs hadoop fs -mkdir -p /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
	sudo -u hdfs hadoop fs -chmod 1777 /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
	sudo -u hdfs hadoop fs -chown -R mapred /var/lib/hadoop-hdfs/cache/mapred

	# Step 5: Verify the HDFS File Structure
	sudo -u hdfs hadoop fs -ls -R /

	# Step 6: Start MapReduce
	for x in `cd /etc/init.d ; ls hadoop-0.20-mapreduce-*` ; do sudo service $x start ; done

	 
	# Step 7: Create User Directories
	# Create a home directory for each MapReduce user. It is best to do this on the NameNode; for example:

	sudo -u hdfs hadoop fs -mkdir /user/$USER 
	sudo -u hdfs hadoop fs -chown $USER /user/$USER

	# Running some Test Now

	# Make a directory in HDFS called input and copy some XML files into it by running the following commands:
	hadoop fs -mkdir input
	hadoop fs -put /etc/hadoop/conf/*.xml input
	hadoop fs -ls input

	#Run an example Hadoop job to grep with a regular expression in your input data.
	/usr/bin/hadoop jar /usr/lib/hadoop-0.20-mapreduce/hadoop-examples.jar grep input output 'dfs[a-z.]+'

	# List the output files.
	hadoop fs -ls

	# Read the results in the output file; for example:
	hadoop fs -cat output/part-00000 | head
}


hostname_update()
{
    if [ "$USER" != "root" ]; then
        echo -e "${BOLD}${RED_F} You need to have ROOT Permission to Execute this. Aborting. ${NORM}"
        exit 1
    fi


    FILE="/etc/hostname-init-update.org"
    CURRENT_HOSTNAME=`uname -n`
    #FILE="/etc/hostname"

    echo -e "${BOLD}${RED_F} Hostname Currently : $CURRENT_HOSTNAME ${NORM}"
    echo -n "Would like to update /etc/hostname and /etc/hosts files (y/n)"
    read UPDATE_FILE

    if [ $UPDATE_FILE == "y" ]; then
        if [ -f $FILE ];
        then
            echo -e "${BOLD}${RED_F} File $FILE exists${NORM}"
            echo -n "File Already updated by this scrit, Do you really want to update File. (y/n)"
            read UPDATE_FILE
        if [ $UPDATE_FILE = "y" ]; then
            echo -n "Enter Host Name:"
            read HOSTNAME

            if [ $HOSTNAME != "" ]; then
                sudo cp /etc/hostname /etc/hostname-init-update.org
                if [ -f /tmp/hostname ]; then
                    rm /tmp/hostname
                fi
                echo $HOSTNAME >> /tmp/hostname
                sudo cp /tmp/hostname /etc/hostname
                echo -e "${BOLD}${RED_F} File Updated with Hostname:'$HOSTNAME'- Original File is backed-up as $FILE ${NORM}"
                rm /tmp/hostname
                echo -e "${BOLD}${RED_F} Lets updated the /etc/hosts file as well - Original File is backed-up as /etc/hosts-init-update.org ${NORM}"
                sudo cp /etc/hosts /etc/hosts-init-update.org
                sudo sed 's/'$CURRENT_HOSTNAME'/'$HOSTNAME'/g' /etc/hosts > /tmp/hosts
                sudo cp /tmp/hosts /etc/hosts
                sudo rm /tmp/hosts

                echo -n "Will take Effect after Reboot. Would you like Reboot NOW (Reboot Recommended)? (y/n)"
                read REBOOT_NOW

                if [ "${REBOOT_NOW}" == "y" ]; then
                    sudo reboot
                    exit 1
                fi

            else
                echo -e "${BOLD}${RED_F} Please Enter Valid HOSTNAME. Quiting Now...${NORM}"
                exit 1
            fi
        fi
        else
            echo -e "${BOLD}${RED_F} File $FILE does not exists${NORM}"
            echo -n "Enter Host Name:"
            read HOSTNAME

            if [ $HOSTNAME != "" ]; then
                sudo cp /etc/hostname /etc/hostname-init-update.org
                if [ -f /tmp/hostname ]; then
                    rm /tmp/hostname
                fi
                echo $HOSTNAME >> /tmp/hostname
                sudo cp /tmp/hostname /etc/hostname
                echo -e "${BOLD}${RED_F} File Updated with Hostname:'$HOSTNAME'- Original File is backed-up as $FILE ${NORM}"
                rm /tmp/hostname
                echo -e "${BOLD}${RED_F} Lets updated the /etc/hosts file as well - Original File is backed-up as /etc/hosts-init-update.org ${NORM}"
                sudo cp /etc/hosts /etc/hosts-init-update.org
                sudo sed 's/'$CURRENT_HOSTNAME'/'$HOSTNAME'/g' /etc/hosts > /tmp/hosts
                sudo cp /tmp/hosts /etc/hosts
                sudo rm /tmp/hosts

                echo -n "Will take Effect after Reboot. Would you like Reboot NOW (Reboot Recommended)? (y/n)"
                read REBOOT_NOW

                if [ "${REBOOT_NOW}" == "y" ]; then
                    sudo reboot
                    exit 1
                fi

            else
                echo -e "${BOLD}${RED_F} Please Enter Valid HOSTNAME. Quiting Now...${NORM}"
                exit 1
            fi
        fi
    fi

}



echo -e "${BOLD}${RED_F} Welcome to Ubuntu 14.04 Desktop Setup  ${NORM}"
echo


echo -e "${RED_F}Would you like to remove Open Java ? (y/n)${NORM}"
read SET_OPENJAVA_UNINSTALL
if [ "${SET_OPENJAVA_UNINSTALL}" == "y" ]; then
	uninstall_open_java
else
	 echo -e "${RED_F}Open Java Not UnInstalled${NORM}"
fi

echo -e "${RED_F}Would you like to install Oracle Java 7? (y/n)${NORM}"
read SET_JAVA_INSTALL
if [ "${SET_JAVA_INSTALL}" == "y" ]; then
    install_oracle_7_java
else
	 echo -e "${RED_F}Java Not Installed${NORM}"

fi

echo -e "${RED_F}Would you like to install Cloudera for Precise Single Node Cluster? (y/n)${NORM}"
read SET_CLOUDERA_PSEUDO_INSTALL
if [ "${SET_CLOUDERA_PSEUDO_INSTALL}" == "y" ]; then
	installing_cloudera_precise
else
	 echo -e "${RED_F}CLOUDERA_PSEUDO Not Installed${NORM}"

fi


echo -e "${RED_F}Would you like to Configure Cloudera for Precise Single Node Cluster? (y/n)${NORM}"
read SET_CLOUDERA_PSEUDO_CONFIG
if [ "${SET_CLOUDERA_PSEUDO_CONFIG}" == "y" ]; then
	config_cloudera_hadoop
else
	 echo -e "${RED_F}CLOUDERA_CONFIG Not Complete${NORM}"

fi


echo -e "${RED_F}Would you like to Configure Hbase for Precise Single Node Cluster? (y/n)${NORM}"
read SET_HBASE_PSEUDO_CONFIG
	if [ "${SET_HBASE_PSEUDO_CONFIG}" == "y" ]; then		
		if [ -f $HBASE_ORG_PATH ]; then
        	config_hbase
			echo -e "${BOLD}${RED_F} In File '/etc/hosts', UPDATE LINE '127.0.1.1 ubuntu' to '127.0.0.1 ubuntu' and REBOOT system ${NORM}"
		else
			echo -e "${RED_F}No hbase-site.xml present ot update\n${NORM}";
			echo -e "${BOLD}${RED_F} - Please check if Hbase is intalled on the system\n${NORM}";
			exit 1
		fi
	else
        	echo -e "${RED_F}CLOUDERA_HBASE_CONFIG Not Complete${NORM}"
fi