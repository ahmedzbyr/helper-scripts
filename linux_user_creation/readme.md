##Simple Script to create a user.

Default passwd is set as username@123

As we are setting the `chage`, user needs to change the passwd on first login.

### Usage :

    [ahmed@localhost ~]$ sh create_user_script.sh 
    Unknown option: 
    
    usage: create.sh <single-parameter>
      Optional parameters:
    
         --sudo-user, -s		Create a sudo User
         --norm-user, -n		Create a Normal User.
         --help,      -h		Display this Message.
      
    [ahmed@localhost ~]$