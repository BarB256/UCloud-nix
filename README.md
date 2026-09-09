# UCloud-nix - workaround the docker hell

<p align="center"><img width="1200" height="508" alt="hero-conversation" src="https://github.com/user-attachments/assets/9bb00c0c-fcad-493c-81ff-ab919152e43a" /></p>

## The problem
UCloud (and plenty of other locked-down HPC and cloud platforms) won't let you install Docker, touch the container config, or reboot the machine your job runs on. The usual fallback is a shell script full of apt install calls... **(this is what i call no ideal)**

The issue with this approach is simple. Pip version of a package changes, or your beloved npm package just got hit with a supply chain attack *We all know how it is these days*. Its much better to keep things working even when you run it on a different machine.

The usual solution would be docker **since this is what most people are used to**. But this does not always work so here is a Nix workaround.


## How to use it
```shell
curl -O https://raw.githubusercontent.com/BarB256/UCloud-nix/main/nixinstall.sh
chmod +x nixinstall.sh 
source nixinstall.sh
```

> [!TIP]
> If you cannot curl the script just copy and paste it to a file and run from there. (it will require internet connection)

## Do i need to edit my project
Simply include a nix flake in your project/experiment and pull it onto the server. More info about flakes can be found in NixOs documentation
