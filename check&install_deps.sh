
# install needed dependencies
file="to_install"

while IFS=' ' read -r bin_name package_name; do 
    which $bin_name> /dev/null 2>&1

    if [ ! $? -eq 0 ]; then
        echo "installing: $package_name"
        yay -S --noconfirm $package_name
    fi
done < "$file"

# config

zsh_paths=$(which -a zsh)

for path in $zsh_paths; do
    if ! grep -Fxq "$path" /etc/shells; then
        echo "$path" | sudo tee -a /etc/shells > /dev/null
    fi 
done
# ensure shell is zsh
chsh -s $(which zsh)

