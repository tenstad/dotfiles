mkdir -p ~/coding ~/programs ~/.bashrc.d 

[ -d ~/programs/fzf ] || git clone --depth 1 https://github.com/junegunn/fzf.git ~/programs/fzf
~/programs/fzf/install --key-bindings --completion --no-update-rc
mv ~/.fzf.bash ~/.bashrc.d/fzf

sudo rpm --import https://build.opensuse.org/projects/home:manuelschneid3r/public_key
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/home:manuelschneid3r/Fedora_34/home:manuelschneid3r.repo
sudo dnf install -y albert

gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
gsettings set org.gnome.desktop.interface cursor-size 36

[ -d ~/coding/dotfiles ] || git clone git@github.com:tenstad/dotfiles.git ~/coding/dotfiles
sh ~/coding/dotfiles/sync.sh
