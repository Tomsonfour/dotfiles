rotation=$(cat rotate_var)
echo $rotation

if [ "$rotation" = "horizontal" ]; 
then

hyprctl keyword monitor eDP-1,1880x1250@60,0x0,1,transform,1
hyprctl keyword input:touchdevice:transform 1
hyprctl keyword "device[wcom005c:00-2d1f:0066-stylus]:transform" 1
echo vertical > rotate_var
else

hyprctl keyword monitor eDP-1,1880x1250@60,0x0,1,transform,0
hyprctl keyword input:touchdevice:transform 0
hyprctl keyword "device[wcom005c:00-2d1f:0066-stylus]:transform" 0
echo horizontal > rotate_var
fi
