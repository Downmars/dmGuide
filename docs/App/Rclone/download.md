
# Why you choose to use rclone?

> Assume that you have already set up Alist.

---

## download rclone  

```
# check if rclone is available in the Pacman repository  
sudo pacman -Ss rclone  
sudo pacman -S rclone  
```

To mount **alist** to the local system, you need to first set up the **reclone remote**. [The rclone documentation](https://rclone.org/webdav/) explains this clearly, or you can follow the commands below:

```
# enter rclone configurations    
rclone config

# choose new remote  
No remotes found, make a new one?
n) New remote
s) Set configuration password
q) Quit config
n/s/q> n # we choose n

# set your remote name  
name> remote
Type of storage to configure.
Choose a number from below, or type in your own value
[snip]
XX / WebDAV
   \ "webdav"
[snip]
Storage> webdav # it will be your remote name  

# set remote url http://your_alist_ip:port/dav
URL of http host to connect to
Choose a number from below, or type in your own value
 1 / Connect to example.com
   \ "https://example.com"
url> http://127.0.0.1:5244/dav # here, set the alist address and port, followed by "dav", as required by alist  

# we choose 6  
Name of the WebDAV site/service/software you are using
Choose a number from below, or type in your own value
 1 / Fastmail Files
   \ (fastmail)
 2 / Nextcloud
   \ (nextcloud)
 3 / Owncloud
   \ (owncloud)
 4 / Sharepoint Online, authenticated by Microsoft account
   \ (sharepoint)
 5 / Sharepoint with NTLM authentication, usually self-hosted or on-premises
   \ (sharepoint-ntlm)
 6 / Other site/service or software
   \ (other)
vendor> 6

# enter your remote account  
User name
user> admin # this is your alist user   

# enter your remote password  
Password.
y) Yes type in my own password
g) Generate random password
n) No leave this optional password blank
y/g/n> y # enter y  
Enter the password: # enter your password, but you cannont see it 
password:
Confirm the password: # enter again
password:

# press enter  
Bearer token instead of user/pass (e.g. a Macaroon)
bearer_token>
Remote config

# choose default  

# your remote message
--------------------
[remote]
type = webdav
url = http://127.0.0.1:5244/dav
vendor = Other
user = admin
pass = *** ENCRYPTED ***
--------------------

# confirm  
y) Yes this is OK
e) Edit this remote
d) Delete this remote
y/e/d> y # enter y  

# enter "q" to exit  
```

## mount to local system  

To check if it's connected, you can use the following command to confirm if `alist` is mounted.

```
# check the alist directory.
rclone lsd alist:

# check the files of alist.
rclone ls alist:
```

```
# Mount the alist directory to the local directory /mnt/Webdev/, this is a foreground command, and it will get stuck after running.
rclone mount alist:/ /webdav  --copy-links --no-gzip-encoding --no-check-certificate --allow-other --allow-non-empty --umask 000 --use-mmap
```

```
# check the local mount location.
df -h  

# the output result wiil be similar to :
Alist:               1.0P     0  1.0P   0% /mnt/Webdev
```

```
# unmount the local mount.
fusermount -qzu /webdav  
```

## set up to start automatically on boot  

You need to run these with root privileges.
```
# edit a server file  
vim /usr/lib/systemd/system/rclone.service

# /usr/lib/systemd/system/rclone.service
[Unit] 
Description=rclone
Before=network.service

[Service] 
User=root 
ExecStart=/usr/bin/rclone mount alist: /mnt/Webdev/  --copy-links --no-gzip-encoding --no-check-certificate --allow-other --allow-non-empty --umask 000 --use-mmap

[Install] 
WantedBy=multi-user.target

```

```
# reload the daemon process  
systemctl daemon-reload

# set up the service file to start automatically  
systemctl enable rclone.service

# start service file  
systemctl start rclone.service

# check ths status of service file  
systemctl status rclone.service  

```  

---
### partial references:
[https://willxup.top/archives/deploy-alist-and-rclone](https://willxup.top/archives/deploy-alist-and-rclone)

