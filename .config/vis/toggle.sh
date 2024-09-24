#!/bin/bash
ps -e | grep -q vis

if (("$?" == "0")); 
then
	$(hyprctl dispatch closewindow "title:^(vis)$")
else
	$(exec foot --title=vis vis)
fi
