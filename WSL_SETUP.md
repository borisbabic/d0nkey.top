# WSL setup instructions
* wsl --install -d Debian
* in wsl add the following to `/etc/wsl.conf`

```
[boot]
systemd=true
```

* restart wsl 
`wsl.exe --shutdown`

do the following in wsl 

```shell
# install dependencies. 
sudo apt install curl git direnv -y

# clone the project
# setup .ssh if you're using ssh
mkdir ~/projects
# only one of the below
git clone git@github.com:borisbabic/d0nkey.top.git ~/projects/hsguru 
git clone https://github.com/borisbabic/d0nkey.top.git ~/projects/hsguru

# setup direnv
cd ~/projects/hsguru
cp .envrc.skel .envrc

# Uncomment the first line to use nix_flake to manage elixir/erlang versions
# Add the required environment variables
# See each sites developer portal for details
nano .direnv

# Enable flakes in nix
mkdir -p ~/.config/nix/
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.confg

# enable direnv
echo "#direnv setup" >> ~/.bashrc
direnv hook bash >> ~/.bashrc

# install nix
# copy/pasted from https://nixos.org/download/
sh <(curl -L https://nixos.org/nix/install) --daemon


# start new shell
bash
# enable direnv
direnv allow # in the project directory
# you should now see downloading going on
# after it finishes you check that it hs worked with
elixir --version

# install docker desktop https://www.docker.com/products/docker-desktop/ 
# ensure the user is added to the docker groups
sudo usermod -aG docker $(whoami)
#
# ensure docker desktop is running in windows whenever you want to run the project
#
```

# Enable vscode
```shell
sudo apt install wget
cd ~/xirprojects/hsguru
code .
```