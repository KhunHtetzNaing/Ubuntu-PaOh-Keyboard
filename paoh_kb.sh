#!/bin/bash

# Ref https://askubuntu.com/questions/510024/what-are-the-steps-needed-to-create-new-keyboard-layout-on-ubuntu

search="<\/layoutList>"
replace="  <layout>\n      <configItem>\n        <name>pao<\/name>\n        <!-- Keyboard indicator for PaOh (Pa-O, Pa'O, Black Karen) layouts -->\n        <shortDescription>paoh<\/shortDescription>\n        <description>PaOh<\/description>\n        <languageList>\n          <iso639Id>blk<\/iso639Id>\n        <\/languageList>\n      <\/configItem>\n    <\/layout>\n\t<\/layoutList>"

org="evdev.xml"
bak="evdev.xml.bak"
rules_dir="/usr/share/X11/xkb/rules/"
kb_path="/usr/share/X11/xkb/symbols/pao"

install() {
    # copy pao keyboard layout file to system
    if cp "pao" "$kb_path"; then
        echo "- Copied keyboard layout!"
        cd "$rules_dir"

        # Backup evdev.xml
        if [ ! -f $bak ]; then
            cp $org $bak && echo "- Backup success✅" || echo "- Backup failed ❌"
        else
            # Check installed
            if grep -q paoh "$org"; then
                # Exist
                rm -f "$org" && cp "$bak" "$org"
            fi
        fi
        echo "- Edit $org"
        # Add config to evdev.xml
        sed -i "s/$search/$replace/g" $org && echo "- Installed ✅" ; echo "- Now, you need to logout or reboot!" || echo "Failed ❌"
    else
        echo "Run with sudo -_-"
        exit 1
    fi
}

uninstall() {
    cd "$rules_dir"
    rm -f "$kb_path" && mv -f "$bak" "$org" && echo "- Uninstalled ✅" ; echo "- Now, you need to logout or reboot!" || echo "Uninstall failed ❌"
}

case $1 in
install)
    install
    ;;

uninstall)
    uninstall
    ;;
*)
    echo "Usage: sudo sh ./paoh_kb.sh install|uninstall"
    ;;
esac

# install
# uninstall
# logout from command
# gnome-session-quit --no-prompt