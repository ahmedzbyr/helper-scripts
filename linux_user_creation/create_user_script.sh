#!/bin/sh

usage() {
  echo -e "
usage: $0 <single-parameter>
  Optional parameters:\n
     --sudo-user, -s\t\tCreate a sudo User
     --norm-user, -n\t\tCreate a Normal User.
     --help,      -h\t\tDisplay this Message.
  "
  exit 1
}

create_normal_user()
{
	USRNAME=$1
	# create user
	useradd $USRNAME
	echo ${USRNAME}@123 | passwd ${USRNAME} --stdin

	# make sure user changes his passwd on first login
	#chage -d 0 ${USRNAME}
}

create_sudo_user()
{
	SUDO_USRNAME=$1
	create_normal_user ${SUDO_USRNAME}
	echo -e "${SUDO_USRNAME}\tALL=(ALL)\tALL" >> /etc/sudoers
}

while true ; do
  case "$1" in
    -s)
      create_sudo_user $2
      exit 1
	  ;;
    -n)
      create_normal_user $2
	  exit 1
      ;;
    --sudo-user)
      create_sudo_user $2
      exit 1
	  ;;
    --norm-user)
      create_normal_user $2
	  exit 1
      ;;
	-h)
	  usage
	  exit 1
	  ;;
	--help)
	  usage
	  exit 1
	  ;;
	*)
      echo "Unknown option: $1"
      usage
      exit 1
	esac
done
