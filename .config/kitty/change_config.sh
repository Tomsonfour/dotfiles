
function find_option() {
    # Find the option in the configuration file
    num_line=`cut ~/.config/kitty/kitty.conf -d' ' -f1 | grep -n "^$1$" | cut -d: -f1`
    if [ -z $num_line ]; then 
      echo 'there is no option' $1
      return
    fi
    sed -i "${num_line}s/.*/$1 $2/" ~/.config/kitty/kitty.conf
}


function get_kitty_pid() {
    kitty_pid=`pstree -spn $$ | awk -F'[()]' '{for (i=1; i<NF; i++) if ($i ~ /kitty$/) print $(i+1)}'`
    echo $kitty_pid
}
function reload_config() {
    # Reload the configuration
    kill -s usr1  $1
}
find_option $1 $2

# Specify the log file


# Redirect stdout (1) and stderr (2) to the log file

if [[ $3 == 'reload' ]]; then
    kitty_pid=$(get_kitty_pid)

    if [ -z $kitty_pid ]; then
        kitty_pid=$KITTY_PID
    fi
    reload_config $kitty_pid
fi
