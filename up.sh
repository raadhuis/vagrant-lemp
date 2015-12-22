#!/bin/bash

function press_enter {
    echo ""
    echo -n "Press Enter to continue"
    read
    clear
}

selection=
until [ "$selection" = "exit" ]; do
    echo ""
    echo "What kind of project would you like to work on?"
    echo "A brand new project:"
    echo " 1 - MODX website"
    echo " 2 - Wordpress Website"
    echo " 3 - Web App"
    echo ""
    echo "An existing project"
    echo " 4 - Use a git repo and figure it out"
    echo ""
    echo "type exit to exit this program"
    echo ""
    echo -n "Enter selection: "
    read selection
    echo ""
    case $selection in
        1 ) provisionscript='provision/modx.sh' vagrant up ; exit ;;
        2 ) provisionscript='provision/wordpress.sh' vagrant up ; exit ;;
        3 ) provisionscript='provision/webapp.sh' vagrant up ; exit ;;
        4 ) free ; press_enter ;;
        exit ) exit ;;
        * ) echo "Please enter a number or type exit"; press_enter
    esac
done
