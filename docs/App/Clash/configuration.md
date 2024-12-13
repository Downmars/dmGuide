
# You must need clash!

---

## download clash

```
# download clash, if you use archlinux.
sudo pacman -S clash  
```
if you use other linux system, you can download from [clash](https://github.com/DustinWin/clash_singbox-tools/releases/tag/Clash-Premium).

```
# cp clash to /usr/local/bin.  
sudo cp clash /usr/local/bin/  

# grant executable permissions to clash.  
sudo chmod +x /usr/local/bin/clash  
```

## configure clash  

```
# create default yaml
clash 
```

After starting clash, it will generate a default configuration file in the ~/.config/clash directory, where ~/.config/clash/config.yaml refers to the directory you specify for clash's configuration file, storing your nodes and rules. You can directly overwrite thsi file with your ownn configuration.   
After modifying the configuration file, simply restart clash to enable the proxy.

## set up the system proxy  

```
# edit /etc/environment  
sudo vim /etc/environment

# write network proxy
http_proxy=127.0.0.1:7890
https_proxy=127.0.0.1:7890
socks_proxy=127.0.0.1:7891
```

## set up to start automatically on boot

```
# view the absolute path  
which clash  
```

The default path for Archlinux is /usr/bin/clash.
```
# create a folder to store clash-related files  
sudo mkdir -p /etc/clash
# copy the relevant files  
sudo cp ~/.config/clash/config.yaml /etc/clash/
sudo cp ~/.config/clash/Country.mmdb /etc/clash/

```
```
# edit /etc/systemd/system/clash.service
sudo vim /etc/systemd/system/clash.service

# /usr/lib/systemd/system/clash.service
[Unit]
Description=Clash daemon, A rule-based proxy in Go.
After=network.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/clash -d /etc/clash # /usr/bin/clash, modify according to your actual changes.

[Install]
WantedBy=multi-user.target

```

```
# reload the daemon process  
systemctl daemon-reload

# set up the service file to start automatically
systemctl enable clash.service

# start service file  
systemctl start clash.service

# check ths status of service file  
systemctl status clash.service  

```

---

## partial references:

[https://blog.linioi.com/posts/clash-on-arch/](https://blog.linioi.com/posts/clash-on-arch/)  

