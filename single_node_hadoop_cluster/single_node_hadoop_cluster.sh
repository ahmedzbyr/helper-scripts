#!/usr/bin/env bash

##
## License
## =======
## 
## Copyright (c) 2012. Zubair AHMED.
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy of
## this software and associated documentation files (the "Software"), to deal in
## the Software without restriction, including without limitation the rights to
## use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
## the Software, and to permit persons to whom the Software is furnished to do so,
## subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
## FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
## COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
## IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
## 
##

##
##  Initial Script Verion 0.1a 
##  Basic Initialization script To Install Hadoop as Single Node.   
##  Hadoop 1.1.1 - Java 1.6
##
##
##  Created by - Zubair AHMED
##

#
# Test Log
# Tested on Ubuntu 11.10 - Fresh Install.
# Scripts assumes nothing is installed for Hadoop and installs Required Components for Hadoop to run.
# 

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

usage() {
  echo -e "${BOLD}${RED}
usage: $0 <single-parameter>

  Optional parameters:
     ${BLUE_F}--install-init, -i${NORM}${BOLD}         Initialization script To Install Hadoop as Single Node Cluster.
     ${RED_F}Use the below Options, Once you are logged-in as Hadoop User ${GREEN_F}'hduser' ${NORM}${RED_F}${BOLD}created in the -i init script above. ${NORM} ${BOLD} 
     ${BLUE_F}--install-ssh, -s${NORM}${BOLD}          Install ssh-keygen -t rsa -P ""
     ${BLUE_F}--install-bashrc, -b${NORM}${BOLD}       Updated '.bashrc' with JAVA_HOME, HADOOP_HOME.
     ${BLUE_F}--ipv6-disable, -v${NORM}${BOLD}         IPv6 Support Disable.[ Might Not be required. 
                                Updating ${GREEN_F}'conf/hadoop-env.sh' ${NORM}${BOLD}with${NORM}${RED_F}${BOLD} 'HADOOP_OPTS=-Djava.net.preferIPv4Stack=true'${NORM}${BOLD} option in -e]
     ${BLUE_F}--hostname-update, -u${NORM}${BOLD}      Update Hostname for the system.
     ${BLUE_F}--config-update, -c${NORM}${BOLD}        Update Configuration with default values (Single Node) in core-site.xml, mapred-site.xml, hdfs-site.xml.
     ${BLUE_F}--update-hadoop-env, -e${NORM}${BOLD}    Update Hadoop Env Script with JAVA_HOME.
     ${BLUE_F}--install-pig, -p${NORM}${BOLD}          Install Pig in /usr/local Directory and set .bashrc.
     ${BLUE_F}--install-mahout, -m${NORM}${BOLD}       Install Mahout in /usr/local Directory and set .bashrc.
     ${BLUE_F}--help, -h${NORM}${BOLD}                 Display this Message.
  ${NORM}"
  exit 1
}

update_hadoop_env()
{

    echo -e "${BOLD}${RED_F} We will be updating \${HADOOP_HOME}/conf/hadoop-env.sh with \$JAVA_HOME - ${RED} Run this as Hadoop User ${NORM}"
    echo -n "Do you want to Continue (y/n)"
    read UPDATE_HADOOP_ENV

    if [ $UPDATE_HADOOP_ENV == "y" ]; then
        cp /usr/local/hadoop/conf/hadoop-env.sh /usr/local/hadoop/conf/hadoop-env.sh-init-update.org
        # sed script will look for # export JAVA_HOME and replace this wit our $JAVA_HOME
        if [ ! -n "${JAVA_HOME}" ]; then
            echo -e "${BOLD}${RED_F} \$JAVA_HOME not set - will be setting it as /usr/lib/jvm/java-6-sun ${NORM}"
            echo -n "Do you want to Continue (y/n)"
            read UPDATE
            if [ $UPDATE == "y" ]; then
                sed 's/^\#\ export\ JAVA_HOME.*/export\ JAVA_HOME\=\/usr\/lib\/jvm\/java\-6\-sun/' /usr/local/hadoop/conf/hadoop-env.sh > /tmp/hadoop-env-temp.sh
                sed 's/^\#\ export\ HADOOP_OPTS.*/export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true/' /tmp/hadoop-env-temp.sh > /tmp/hadoop-env.sh
                cp  /tmp/hadoop-env.sh /usr/local/hadoop/conf/hadoop-env.sh
                rm /tmp/hadoop-env.sh
            else
                echo -e "${BOLD}${RED_F} Aborting !! ${NORM}" 
                exit 1
            fi
        else
            # TODO : Need to update this to take information from the $JAVA_HOME - currently hardcoded.
            echo -e "${BOLD}${RED_F} Your JAVA_HOME : $JAVA_HOME ${NORM}"
            JAVA_HOME=`echo $JAVA_HOME`
            sed 's/^\#\ export\ JAVA_HOME.*/export\ JAVA_HOME\=\/usr\/lib\/jvm\/java\-6\-sun/' /usr/local/hadoop/conf/hadoop-env.sh > /tmp/hadoop-env-temp.sh
            sed 's/^\#\ export\ HADOOP_OPTS.*/export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true/' /tmp/hadoop-env-temp.sh > /tmp/hadoop-env.sh
            cp  /tmp/hadoop-env.sh /usr/local/hadoop/conf/hadoop-env.sh
            rm /tmp/hadoop-env.sh
        fi                                        
    fi

}

config_update_hadoop()
{

    CORE_FILE="/usr/local/hadoop/conf/core-site.xml-init-update.org"
    MAPRED_FILE="/usr/local/hadoop/conf/mapred-site.xml-init-update.org"
    HDFS_FILE="/usr/local/hadoop/conf/hdfs-site.xml-init-update.org"

    echo -e "${BOLD}${RED_F} Updating Hadoop Configuration Files: ${NORM}"
    echo -n "Would like to update core-site.xml mapred-site.xml hdfs-site.xml files (y/n)"
    read UPDATE_FILE

    if [ $UPDATE_FILE == "y" ]; then
        if [ -f $CORE_FILE ];
        then
            echo -e "${BOLD}${RED_F} File $CORE_FILE exists${NORM}"
            echo -n "File Already updated by this script, Do you really want to update File. (y/n)"
            read UPDATE_FILE
            if [ $UPDATE_FILE = "y" ]; then
                cp /usr/local/hadoop/conf/core-site.xml /usr/local/hadoop/conf/core-site.xml-init-update.org
                echo "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
            
<!-- Put site-specific property overrides in this file. -->

<configuration>
<!-- In: conf/core-site.xml -->
<property>
<name>hadoop.tmp.dir</name>
<value>/app/hadoop/tmp</value>
<description>A base for other temporary directories.</description>
</property>
<property>
<name>fs.default.name</name>
<value>hdfs://localhost:54310</value>
<description>The name of the default file system.  A URI whose
scheme and authority determine the FileSystem implementation.  The
uri's scheme determines the config property (fs.SCHEME.impl) naming
the FileSystem implementation class.  The uri's authority is used to
determine the host, port, etc. for a filesystem.</description>
</property>
</configuration>" >> /tmp/core-site.xml
                cp /tmp/core-site.xml /usr/local/hadoop/conf/core-site.xml
                rm /tmp/core-site.xml
            fi
        else
            cp /usr/local/hadoop/conf/core-site.xml /usr/local/hadoop/conf/core-site.xml-init-update.org
                echo "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
            
<!-- Put site-specific property overrides in this file. -->

<configuration>
    <!-- In: conf/core-site.xml -->
    <property>
    <name>hadoop.tmp.dir</name>
    <value>/app/hadoop/tmp</value>
    <description>A base for other temporary directories.</description>
    </property>

    <property>
    <name>fs.default.name</name>
    <value>hdfs://localhost:54310</value>
    <description>The name of the default file system.  A URI whose
    scheme and authority determine the FileSystem implementation.  The
    uri's scheme determines the config property (fs.SCHEME.impl) naming
    the FileSystem implementation class.  The uri's authority is used to
    determine the host, port, etc. for a filesystem.</description>
    </property>
</configuration>" >> /tmp/core-site.xml
                cp /tmp/core-site.xml /usr/local/hadoop/conf/core-site.xml
                rm /tmp/core-site.xml

        fi
        if [ -f $MAPRED_FILE ];
        then
            echo -e "${BOLD}${RED_F} File $MAPRED_FILE exists${NORM}"
            echo -n "File Already updated by this script, Do you really want to update File. (y/n)"
            read UPDATE_FILE
            if [ $UPDATE_FILE = "y" ]; then
                cp /usr/local/hadoop/conf/mapred-site.xml /usr/local/hadoop/conf/mapred-site.xml-init-update.org
                echo "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
<!-- In: conf/mapred-site.xml -->
  <property>
    <name>mapred.job.tracker</name>
    <value>localhost:54311</value>
    <description>The host and port that the MapReduce job tracker runs
    at.  If \"local\", then jobs are run in-process as a single map
    and reduce task.
    </description>
  </property>
</configuration>" >> /tmp/mapred-site.xml
                cp /tmp/mapred-site.xml /usr/local/hadoop/conf/mapred-site.xml
                rm /tmp/mapred-site.xml
            fi
        else
            cp /usr/local/hadoop/conf/mapred-site.xml /usr/local/hadoop/conf/mapred-site.xml-init-update.org
                echo "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
<!-- In: conf/mapred-site.xml -->
  <property>
    <name>mapred.job.tracker</name>
    <value>localhost:54311</value>
    <description>The host and port that the MapReduce job tracker runs
    at.  If \"local\", then jobs are run in-process as a single map
    and reduce task.
    </description>
  </property>
</configuration>" >> /tmp/mapred-site.xml
                cp /tmp/mapred-site.xml /usr/local/hadoop/conf/mapred-site.xml
                rm /tmp/mapred-site.xml

        fi
        if [ -f $HDFS_FILE ];
        then
            echo -e "${BOLD}${RED_F} File $HDFS_FILE exists${NORM}"
            echo -n "File Already updated by this script, Do you really want to update File. (y/n)"
            read UPDATE_FILE
            if [ $UPDATE_FILE = "y" ]; then
                cp /usr/local/hadoop/conf/hdfs-site.xml /usr/local/hadoop/conf/hdfs-site.xml-init-update.org
                echo "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
<!-- In: conf/hdfs-site.xml -->
  <property>
    <name>dfs.replication</name>
    <value>1</value>
    <description>Default block replication.
    The actual number of replications can be specified when the file is created.
    The default is used if replication is not specified in create time.
    </description>
  </property>
</configuration>" >> /tmp/hdfs-site.xml
                cp /tmp/hdfs-site.xml /usr/local/hadoop/conf/hdfs-site.xml
                rm /tmp/hdfs-site.xml
            fi
        else
            cp /usr/local/hadoop/conf/hdfs-site.xml /usr/local/hadoop/conf/hdfs-site.xml-init-update.org
                echo "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
<!-- In: conf/hdfs-site.xml -->
  <property>
    <name>dfs.replication</name>
    <value>1</value>
    <description>Default block replication.
    The actual number of replications can be specified when the file is created.
    The default is used if replication is not specified in create time.
    </description>
  </property>
</configuration>" >> /tmp/hdfs-site.xml
                cp /tmp/hdfs-site.xml /usr/local/hadoop/conf/hdfs-site.xml
                rm /tmp/hdfs-site.xml

        fi
    fi

}

install_ssh()
{
    #Creating ssh-key
    echo -e "${BOLD}${RED_F} Creating ssh Key Now... ${NORM}"
    ssh-keygen -t rsa -P ""

    #Copying it to Autorize Login - (Logged in User)
    echo -e "${BOLD}${RED_F} cat it to .. Authorize ... ${NORM}"
    cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

    #Testing Connection - without Passwd
    echo -e "${BOLD}${RED_F} Testing Connection passwordless login -- to Localhost... ${NORM}"
    ssh localhost

}

install_bashrc()
{
   echo -e "${BOLD}${RED_F} .bashrc WILL BE APPENDED WITH BELOW INFORMATION ${NORM}

    # Set Hadoop-related environment variables
    ${BOLD}${RED_F}export HADOOP_HOME=/usr/local/hadoop${NORM}

    # Set JAVA_HOME (we will also configure JAVA_HOME directly for Hadoop later on)
    ${BOLD}${RED_F}export JAVA_HOME=/usr/lib/jvm/java-6-sun${NORM}

    # Some convenient aliases and functions for running Hadoop-related commands
    ${BOLD}${RED_F}unalias fs &> /dev/null
    alias fs=\"hadoop fs\"
    unalias hls &> /dev/null
    alias hls=\"fs -ls\"

    lzohead () {
	hadoop fs -cat \$1 | lzop -dc | head -1000 | less
    }
    ${NORM}
    # Add Hadoop bin/ directory to PATH
    ${BOLD}${RED_F}export PATH=\$PATH:\$HADOOP_HOME/bin${NORM}\n\n"

    echo -n "Would you like update your $HOME/.bashrc ? (y/n)"
    read SET_BASHRC

    if [ "${SET_BASHRC}" == "y" ]; then
        echo -e "${BOLD}${RED_F} .bashrc will be backed-up as $HOME/.bashrc-init-update.org ${NORM}"
        cp $HOME/.bashrc $HOME/.bashrc-init-update.org
    echo "

# Set Hadoop-related environment variables
export HADOOP_HOME=/usr/local/hadoop

# Set JAVA_HOME (we will also configure JAVA_HOME directly for Hadoop later on)
export JAVA_HOME=/usr/lib/jvm/java-6-sun

# Some convenient aliases and functions for running Hadoop-related commands
unalias fs &> /dev/null
alias fs=\"hadoop fs\"
unalias hls &> /dev/null
alias hls=\"fs -ls\"

# If you have LZO compression enabled in your Hadoop cluster and
# compress job outputs with LZOP (not covered in this tutorial):
# Conveniently inspect an LZOP compressed file from the command
# line; run via:
#
# $ lzohead /hdfs/path/to/lzop/compressed/file.lzo
#
# Requires installed 'lzop' command.
#
lzohead () {
    hadoop fs -cat \$1 | lzop -dc | head -1000 | less
}

# Add Hadoop bin/ directory to PATH
export PATH=\$PATH:\$HADOOP_HOME/bin" >> $HOME/.bashrc
    
    #source $HOME/.bashrc 
    #. ~/.bashrc
    exec bash
	    echo -e "${BOLD}${RED_F} Added Information to .bashrc ${NORM}"
    else
	    echo -e "${BOLD}${RED_F} .bashrc Not Updated ${NORM}"
    fi
}

ipv6_disable()
{
    # Checks if you have the right privileges
    if [ "$USER" != "root" ]; then
        echo -e "${BOLD}${RED_F} You need to have ROOT Permission to Execute this. Aborting. ${NORM}"
        exit 1
    fi
    if [ `cat /proc/sys/net/ipv6/conf/all/disable_ipv6` == "1" ]; then
	echo -e "${BOLD}${RED_F} IPv6 is Already disabled - quiting Now${NORM}"
	exit 1
    else
	echo -e "${BOLD}${RED_F} IPv6 is Enable on your system ${NORM}"
    fi    

    echo -n "Would you like to disable IPv6 Support on your System (You need to be 'sudo' to do this) ? (y/n)"
    read SET_DISIPV6

    if [ "${SET_DISIPV6}" == "y" ]; then
    echo "
#disable ipv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf

    echo -e "${BOLD}${RED_F} IPv6 is Disabled${NORM}"
    echo -n "Will take Effect after Reboot. Would you like Reboot NOW (Reboot Recommended)? (y/n)"
    read REBOOT_NOW

	if [ "${REBOOT_NOW}" == "y" ]; then
	    sudo reboot
	    exit 1
	fi
   
    else
	echo -e "${BOLD}${RED_F} IPv6 Not Disabled ${NORM}"
    fi
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

install_pig()
{
    # Code to Come here	
    echo -e "${BOLD}${RED_F} --- Install Pig for Hadoop --- ${SET_JAVA_INSTALL}${NORM}"

    #checking if file exsists 
    if [ -f $HOME/Downloads/pig-0.10.0.tar.gz ];
    then
        echo -e "${BOLD}${RED_F} File Already Downloaded Lets Extract${NORM}"
    else
        echo -e "${BOLD}${RED_F} Downloading Pig from Mirror Now... Saved in $HOME/Downloads ${NORM}"
        wget http://apache.techartifact.com/mirror/pig/pig-0.10.0/pig-0.10.0.tar.gz -P $HOME/Downloads/ 
    fi    

    # Checking if pig is Already Installed in /usr/local 
    # Not checking if pig is installed elsewhere - will include this check later.

    if [ -d /usr/local/pig-0.10.0 ]
    then
        echo -e "${BOLD}${RED_F} Pig Already installed - if you want to reinstall please remove pig from /usr/local and Try Again ... ${NORM}"
        exit 1
    fi

    # Extract pig to /usr/local and Change Owner and create a link for our convinence.
    echo -e "${BOLD}${RED_F} Extract pig to /usr/local and Change Owner and create a link for our convinence.${NORM}"
    sudo tar xvzf $HOME/Downloads/pig-0.10.0.tar.gz -C /usr/local
    
    sudo chown hduser:hadoop -R /usr/local/pig-0.10.0
    sudo ln -s /usr/local/pig-0.10.0 /usr/local/pig

    # Updating .bashrc file
    echo -e "${BOLD}${RED_F} Updating .bashrc file ${NORM}"

    if [ `grep -c "PIG_HOME" $HOME/.bashrc` -ne 0 ]
    then
        echo -e "${BOLD}${RED_F} PIG_HOME Already in $HOME/.bashrc if it has an older configuration then remove it.${NORM}"
        echo -e "${BOLD}${RED_F} Add the below lines to $HOME/.bashrc in the end. Manually.${NORM}

        # Set PIG_HOME environment variables
        export PIG_HOME=/usr/local/pig

        # Add Pig bin/ directory to PATH
        export PATH=\$PATH:\$PIG_HOME/bin"

        exit 1
    fi

    echo -n "Would you like update your $HOME/.bashrc ? (y/n)"
    read SET_BASHRC

    if [ "${SET_BASHRC}" == "y" ]; then
        echo -e "${BOLD}${RED_F} .bashrc will be backed-up as $HOME/.bashrc-init-update.org ${NORM}"
        cp $HOME/.bashrc $HOME/.bashrc-init-update.org
    echo "

# Set PIG_HOME environment variables
export PIG_HOME=/usr/local/pig

# Add Pig bin/ directory to PATH
export PATH=\$PATH:\$PIG_HOME/bin" >> $HOME/.bashrc
    
    #source $HOME/.bashrc 
    #. ~/.bashrc
    exec bash
	    echo -e "${BOLD}${RED_F} Added Information to .bashrc ${NORM}"
    else
	    echo -e "${BOLD}${RED_F} .bashrc Not Updated ${NORM}"
    fi
 
}

install_mahout()
{
    # Code to Come here	
    echo -e "${BOLD}${RED_F} --- Install Mahout for Hadoop --- ${SET_JAVA_INSTALL}${NORM}"

    #checking if file exsists 
    if [ -f $HOME/Downloads/mahout-distribution-0.7.tar.gz ];
    then
        echo -e "${BOLD}${RED_F} File Already Downloaded Lets Extract${NORM}"
    else
        echo -e "${BOLD}${RED_F} Downloading Mahout from Mirror Now... Saved in $HOME/Downloads ${NORM}"
        wget http://apache.techartifact.com/mirror/mahout/0.7/mahout-distribution-0.7.tar.gz -P $HOME/Downloads/ 
    fi    

    # Checking if mahout is Already Installed in /usr/local 
    # Not checking if mahout is installed elsewhere - will include this check later.

    if [ -d /usr/local/mahout-distribution-0.7 ]
    then
        echo -e "${BOLD}${RED_F} Mahout Already installed - if you want to reinstall please remove mahout from /usr/local and Try Again ... ${NORM}"
        exit 1
    fi

    # Extract mahout to /usr/local and Change Owner and create a link for our convinence.
    echo -e "${BOLD}${RED_F} Extract mahout to /usr/local and Change Owner and create a link for our convinence.${NORM}"
    sudo tar xvzf $HOME/Downloads/mahout-distribution-0.7.tar.gz -C /usr/local
    
    sudo chown hduser:hadoop -R /usr/local/mahout-distribution-0.7
    sudo ln -s /usr/local/mahout-distribution-0.7 /usr/local/mahout

    # Updating .bashrc file
    echo -e "${BOLD}${RED_F} Updating .bashrc file ${NORM}"

    if [ `grep -c "MAHOUT_HOME" $HOME/.bashrc` -ne 0 ]
    then
        echo -e "${BOLD}${RED_F} MAHOUT_HOME Already in $HOME/.bashrc if it has an older configuration then remove it.${NORM}"
        echo -e "${BOLD}${RED_F} Add the below lines to $HOME/.bashrc in the end. Manually.${NORM}

        # Set MAHOUT_HOME environment variables
        export MAHOUT_HOME=/usr/local/mahout

        # Add mahout bin/ directory to PATH
        export PATH=\$PATH:\$MAHOUT_HOME/bin"

        exit 1
    fi

    echo -n "Would you like update your $HOME/.bashrc ? (y/n)"
    read SET_BASHRC

    if [ "${SET_BASHRC}" == "y" ]; then
        echo -e "${BOLD}${RED_F} .bashrc will be backed-up as $HOME/.bashrc-init-update.org ${NORM}"
        cp $HOME/.bashrc $HOME/.bashrc-init-update.org
    echo "

# Set MAHOUT_HOME environment variables
export MAHOUT_HOME=/usr/local/mahout

# Add mahout bin/ directory to PATH
export PATH=\$PATH:\$MAHOUT_HOME/bin" >> $HOME/.bashrc
    
    #source $HOME/.bashrc 
    #. ~/.bashrc
    exec bash
	    echo -e "${BOLD}${RED_F} Added Information to .bashrc ${NORM}"
    else
	    echo -e "${BOLD}${RED_F} .bashrc Not Updated ${NORM}"
    fi
 
}



while true ; do
  case "$1" in
    --install-init)
      INSTALL_INIT=1 ; shift ; break
      ;;
    --install-ssh)
      install_ssh
      exit 1
      ;;
    --install-bashrc)
      install_bashrc
      exit 1
      ;;
    --ipv6-disable)
      ipv6_disable
      exit 1
      ;;
    --hostname-update)
      hostname_update
      exit 1
      ;;
    --config-update)
      config_update_hadoop
      exit 1
      ;;
      --update-hadoop-env)
      update_hadoop_env
      exit 1
      ;;
    --help)
      usage
      ;;
    --install-pig)
      install_pig      
      exit 1
      ;;
    --install-mahout)
      install_mahout      
      exit 1
      ;;
    -h)
      usage
      ;;
    -i)
      INSTALL_INIT=1 ; shift ; break
      ;;
    -s)
      install_ssh
      exit 1
      ;;
    -b)
      install_bashrc
      exit 1
      ;;	
    -v)
      ipv6_disable
      exit 1
      ;;	
    -u)
      hostname_update
      exit 1
      ;;	
    -c)
      config_update_hadoop
      exit 1
      ;;
    -e)
      update_hadoop_env
      exit 1
      ;;      
    -p)
      install_pig 
      exit 1
      ;;      
    -m)
      install_mahout 
      exit 1
      ;;      
    *)
      echo "Unknown option: $1"
      usage
      exit 1
  esac
done


if [ "${INSTALL_INIT}" == "1" ]; then
  echo -e "${BOLD}${RED_F} Welcome to Precofiguration For Hadoop single node setup wizard ${NORM}"
  echo
  echo -n "Would you like install Java ? (y/n) "
  read SET_JAVA_INSTALL

#    Setting SET_JAVA_INSTALL_VERSION as "n" Installing Java 1.6 by Default  
#    SET_JAVA_INSTALL_VERSION="n"
#
#    if [ $SET_JAVA_INSTALL == "y" ];
#    then
#        echo -n "Would you like install Java 1.7 (Java 1.6 is default)? (y/n) " 
#        read SET_JAVA_INSTALL_VERSION
#    fi

  echo -n "Would you like to setup user 'hduser' and 'hadoop Group'? (y/n) "
  read SET_HDUSER_HADOOP
#  if [ $SET_HDUSER_HADOOP == "y" ]; then
#    echo -n "Enter Username: "
#    read USERNAME
#    echo -n "Enter Group: "
#    read GROUPNAME
#  fi
  echo -n "Would you like to download Hadoop 1.1.1 and extract to /usr/local? (y/n) "
  read SET_HADOOP_DOWNLOAD
  echo -n "Would you like to make 'hduser' owner /usr/local/hadoop/ directory? (y/n) "
  read SET_HDUSER_OWNER
  echo -n "Would you like to login into 'htuser' once done? (y/n) "
  read SET_LOGIN_HDUSER
  echo
  echo -e "${BOLD}${RED_F} Review your choices:${NORM}"
  echo
  echo -e "${BOLD}${RED_F} Install Java                 : ${SET_JAVA_INSTALL}${NORM}"
  echo -e "${BOLD}${RED_F} Setup 'hduser' user          : ${SET_HDUSER_HADOOP}${NORM}"
  echo -e "${BOLD}${RED_F} Download Hadoop 1.1.1        : ${SET_HADOOP_DOWNLOAD}${NORM}"
  echo -e "${BOLD}${RED_F} Setup 'hduser' as Owner      : ${SET_HDUSER_OWNER}${NORM}"
  echo -e "${BOLD}${RED_F} Login to 'hduser'            : ${SET_LOGIN_HDUSER}${NORM}"
  echo
  echo -n "Proceed with setup? (y/n) "
  read CONFIRM
  if [ "${CONFIRM}" != "y" ]; then
    echo -e "${BOLD}${RED_F} User aborted setup, exiting... ${NORM}"
    exit 1
  fi
else
  SET_JAVA_INSTALL="y"
  SET_HDUSER_HADOOP="y"
  SET_HADOOP_DOWNLOAD="y"
  SET_HDUSER_OWNER="y"
  SET_LOGIN_HDUSER="y"
fi

#Downloading Java Script Now.

if [ "${SET_JAVA_INSTALL}" == "y" ]; then
    echo -e "${BOLD}${RED_F} Install Java 1.6                  : ${SET_JAVA_INSTALL}${NORM}"
    echo -e "${BOLD}${RED_F} Downloading Java Script Now... ${NORM}"
    #
    # Original Path to Script 
    # wget https://raw.github.com/flexiondotorg/oab-java6/master/oab-java.sh
    # Setting Path to MyForked Script in GIT
    wget https://raw.github.com/ahmedzbyr/oab-java6/master/oab-java.sh

    echo -e "${BOLD}${RED_F} Adding Permission to Execute Script... ${NORM}"
    sudo chmod +x oab-java.sh

#    if ["${SET_JAVA_INSTALL_VERSION}" == "n"];
#    then
        echo -e "${BOLD}${RED_F} Executing - Script... ${NORM}"
        sudo ./oab-java.sh

        echo -e "${BOLD}${RED_F} Download Required Packages... ${NORM}"
        sudo apt-get install sun-java6-jdk sun-java6-fonts sun-java6-source ssh
#    else
#        echo -e "${BOLD}${RED_F} Executing - Script. Installing Java 1.7 ${NORM}"
#        sudo ./oab-java.sh -7
#
#        echo -e "${BOLD}${RED_F} Download Required Packages... ${NORM}"
#        sudo apt-get install oracle-java7-jdk oracle-java7-fonts oracle-java7-source ssh
#    fi

    echo -e "${BOLD}${RED_F} Lets See What is the Java Version we Installed... ${NORM}"
    java -version
    
    echo -e "${BOLD}${RED_F} Moving Script to Download Directory... ${NORM}"
    mv oab-java.sh ~/Downloads
    mv oab-java.sh.log /tmp/
    
    if [[ `lsb_release -rs` == "12.04" || `lsb_release -rs` == "12.10" ]]; then
        sudo update-alternatives --config java
    fi
fi


if [ "${SET_HDUSER_HADOOP}" == "y" ]; then
    echo -e "${BOLD}${RED_F} Setup 'hduser' user               : ${SET_HDUSER_HADOOP}${NORM}"
    # Creating User
    echo -e "${BOLD}${RED_F} Creating 'hduser'... ${NORM}"
    sudo addgroup hadoop
    sudo adduser --ingroup hadoop hduser
fi


if [ "${SET_HADOOP_DOWNLOAD}" == "y" ]; then
    echo -e "${BOLD}${RED_F} Download Hadoop 1.1.1             : ${SET_HADOOP_DOWNLOAD}${NORM}"
    
    #Lets Download Hadoop 
    echo -e "${BOLD}${RED_F} Downloading Hadoop 1.0... ${NORM}"
    wget http://apache.techartifact.com/mirror/hadoop/common/hadoop-1.1.1/hadoop-1.1.1-bin.tar.gz

    #Extract and Move it to /usr/local
    echo -e "${BOLD}${RED_F} Extracting Hadoop to /usr/local/... ${NORM}"
    sudo tar -xvzf hadoop-1.1.1-bin.tar.gz -C /usr/local
    echo -e "${BOLD}${RED_F} Creating Symbolic Link Now... ${NORM}"
    cd /usr/local/
    sudo ln -s hadoop-1.1.1 hadoop
    sudo mkdir -p /app/hadoop/tmp
    cd -
    mv hadoop-1.1.1-bin.tar.gz ~/Downloads/.
fi


if [ "${SET_HDUSER_OWNER}" == "y" ]; then
    if [ "${SET_HDUSER_HADOOP}" == "n" ]; then
	    echo -n "Would you like continue as HDUSER creation was not set, do you have a hduser already ? (y/n) "
	    read SET_HDUSER_PRESENT
    fi
    if [[ "${SET_HDUSER_PRESENT}" == "y" || "${SET_HDUSER_HADOOP}" == "y" ]]; then
	    echo -e "${BOLD}${RED_F} Setup 'hduser' as Owner           : ${SET_HDUSER_OWNER}${NORM}"
	    #Lets Create some Permission for hduser
	    echo -e "${BOLD}${RED_F} Creating Permission for 'hduser'... ${NORM}"
	    sudo chown -R hduser:hadoop /usr/local/hadoop-1.1.1
        sudo chown -R hduser:hadoop /app/hadoop/
    else
	    echo -e "'hduser' as Owner Not set - Please do this manually"
	    echo -e "${BOLD}${RED_F} sudo chown -R <username>:<group> hadoop-1.1.1 ${NORM}"
	    echo -e "Example: ${BOLD}${RED_F} sudo chown -R hduser:hadoop hadoop-1.1.1 ${NORM}" 
    fi
fi


if [ "${SET_LOGIN_HDUSER}" == "y" ]; then
    if [ "${SET_HDUSER_HADOOP}" == "n" ]; then
        echo -n "Would you like continue as HDUSER creation was not set, do you have a hduser already ? (y/n) "
        read SET_HDUSER_PRESENT
    fi
    if [[ "${SET_HDUSER_PRESENT}" == "y" || "${SET_HDUSER_HADOOP}" == "y" ]]; then
	    echo -e "${BOLD}${RED_F} Login to 'hduser'                 : ${SET_LOGIN_HDUSER}${NORM}"
        #Entering User Profile
	    echo -e "${BOLD}${RED_F} Login to 'hduser'... ${NORM}"
        echo -e "${BOLD}${RED_F} In 'hduser' Execute script 'sshKeyGenScript.sh'... ${NORM}"
	    su -l hduser
    fi
fi
