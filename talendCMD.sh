# ALWAYS use talenduser for below commands, if modification or deletion or creation of keys is not possible, use ec2-user as an alternative with sudo and mention homedir
# whenever we need to use ec2-user with sudo or root user make sure that the user and group of /home/talenduser/.gnupg/pubring.kbx AND /home/talenduser/.gnupg/private-keys-v1.d is changed back to talenduser and talendgroup since it will be changed to root sometimes
# /home/talenduser/.gnupg/pubring.kbx
# /home/talenduser/.gnupg/private-keys-v1.d
# to change the permissions you have to use ec2-user with sudo or root and run the below commands
chown -R talenduser:talendgroup /home/talenduser/.gnupg/pubring.kbx
chown -R talenduser:talendgroup /home/talenduser/.gnupg/private-keys-v1.d


#sftp conn checks
sftp -vvv -o Port=22 -o IdentityFile=/somewhere/our_server_priv_SSHKEY user@customer_sftp_server
# SFTP Connection

# for creating an sftp connection we need the private key of our server 
# for any new project that is being added to talend perimeter ask Julien to update the Route53 records to allow for the external server to make a connection to our AWS
sftp -vvv -o Port=9684 -o IdentityFile=ourPrivateKey User@Hostname
# NOTE: -vvv is verbose output, only use it when you want to troubleshoot an error, or else no need to use it
# -v gives debug1 logs, -vv gives debug1 & debug2 logs, -vvv gives debug1, debug2, debug3 logs 

# getting param values from param store
aws ssm get-parameters --name "/somewhere/something" --region "eu-west-1" --with-decryption --query "Parameters[*].{Value:Value}" --output text

# to get the public IP of an ec2 server connecting outside of the AWS env
curl https://checkip.amazonaws.com

# homedir paths
/home/talenduser/.ssh       # for SSH
/home/talenduser/.gnuPG     # for GPG
/shared/GnuPG               # for GPG

# LISTING GPG KEYS
# to list all gpg keys
# public GPG keys
gpg --homedir=/home/talenduser/.gnupg --list-keys
# private GPG keys
gpg --homedir=/home/talenduser/.gnupg --list-secret-keys

# NOTE: If this path doesn't have any keys try the homedir as /shared/GnuPG/

# to view all details and subkeys use the below command
gpg --homedir=/shared/GnuPG --list-secret-keys --keyid-format=long # homedir can be any path where the GPG keys are stored


# GPG Agent Troubleshooting
# to check the status of the gpg agent
ps aux | grep gpg-agent
gpgconf --list-dirs agent-socket
gpgconf --launch gpg-agent
# to launch the gpg-agent
gpgconf --launch gpg-agent
# to stop the gpg-agent (only do if you understand what this means)
gpgconf --kill gpg-agent


# IMPORTING GPG KEY
# to import a key
gpg --homedir=/home/talenduser/.gnupg --import GPG_Key
# to import a private key
gpg --homedir=/home/talenduser/.gnupg  --allow-secret-key-import --import --pinentry-mode loopback gpg.priv


# EXPORTING GPG KEY
# to export a public GPG key
gpg --export -a ABCDEF123456 > gpg.pub
# to export a private GPG key with homedir
sudo gpg --homedir=/shared/GnuPG --export-secret-key -a ABCDEF123456 > gpg.priv

# NOTE: .priv and .pub extensions are not necessary, you don't need to use them mandatorily, keys will work even without the extensions.
# When you share the key over email the .pub or .priv extension might not be valid, there you can use .txt format just for sharing


# TESTING ENCRYPTION AND DECRYPTION
# to test encryption/decryption of a key with a test file
mkdir -p /tmp/made/
echo "Talend Tango" > /tmp/made/test.txt
cd /tmp/made/
# encrypt with key ABCD1234 ID
gpg --encrypt -r "ABCD1234" test.txt
# decrypt the file with the key
gpg -d -v -o test.txt.gpg.txt test.txt.gpg


# CREATION OF SSH KEY
# Create an OPENSSH PUBLIC KEY (id_rsa.pub) with the corresponding PRIVATE KEY (id_rsa)
ssh-keygen -y -f id_rsa > id_rsa.pub
# to create a SSH key from its corresponding private key (extensions not necessary)
ssh-keygen -y -f PRIV_KEY > PUB_KEY.pub
# Checking if our server is able to connect to the host with the given DNS and port
ssh-keyscan -H <HostDNS> -p <PortNumber>
# Alternative for above check
curl -k -v <HostDNS>
# Even if the host DNS, Port and public key details are not present in our /home/talenduser/.ssh/known_hosts file, we can still connect to the host server without any issues
 

# LOG SEARCHES
# checking the keywords under all directories
grep -riF "parsing license response" /logs/gomft


# FILE SEARCHES
# finding a file in a specific directory
find /logs/gomft -type f -name '*.log'


# YET TO BE TESTED (for talenduser privileges access)
# edit the sudoers file to let talenduser run sudo commands with the below command
sudo visudo
# add this line at the end of the file
talenduser ALL=(ALL) NOPASSWD: /usr/bin/gpg, /usr/bin/gpg2, /usr/bin/gpg-agent, /usr/bin/gpg-connect-agent, /usr/bin/gpgconf
# this should be able to solve most of the permissions issue we are facing for talend


# Online Resources

# SSH-Keyscan
https://help.salesforce.com/s/articleView?id=001120703&type=1

# Managing SSH and PGP keys in Transfer Family
https://docs.aws.amazon.com/transfer/latest/userguide/key-management.html

# How to display key pairs in GPG and how they work
https://stackoverflow.com/questions/65242815/how-can-i-display-actual-public-private-key-of-key-pair-i-just-generated-with-gp

# During Encryption it is normal for the encryption process to be using the subkey instead of the actual primary key
https://serverfault.com/questions/397973/gpg-why-am-i-encrypting-with-subkey-instead-of-primary-key

# Details related to the sub-keys
https://wiki.debian.org/Subkeys

# Encryption on private keys during export
https://stackoverflow.com/questions/9981099/are-exported-private-keys-in-gpg-still-encrypted

# Difference between export and export-private-key
https://security.stackexchange.com/questions/279735/explaining-output-of-gpg-export-export-private-key-key-id-vs-key-id

# All GPG documentation
https://www.gnupg.org/documentation/manuals/gnupg/

# GPG Documentation related to config files
https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration.html