mkdir -p ~/coding ~/.bashrc.d
[ -d ~/coding/dotfiles ] || git clone git@github.com:tenstad/dotfiles.git ~/coding/dotfiles

[ -d ~/.fzf ] || git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install
mv ~/.fzf.bash ~/.bashrc.d/fzf
sed -i '/\.fzf\.bash/d' ~/.bashrc

sh ~/coding/dotfiles/sync.sh
