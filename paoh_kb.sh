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
    if sudo cp "pao" "$kb_path"; then
        echo "- Copied keyboard layout!"
        cd "$rules_dir"

        # Backup evdev.xml
        if [ ! -f $bak ]; then
            sudo cp $org $bak && echo "- Backup success ✅" || echo "- Backup failed ❌"
        else
            # Check installed
            if grep -q paoh "$org"; then
                # Exist
                sudo rm -f "$org" && sudo cp "$bak" "$org"
            fi
        fi
        echo "- Edit $org ✅"
        # Add config to evdev.xml
        sudo sed -i "s/$search/$replace/g" $org && {
            echo "- Installed ✅"
            add_2_input_source
            echo ""
            echo "ℹ️  Now you can change keyboard layout by pressing (Super + Space) ℹ️"
            echo ""
        } || echo "Failed ❌"
    else
        usage
        exit 1
    fi
}

uninstall() {
    cd "$rules_dir"
    if [ ! -f $kb_path ] || [ ! -f $bak ]; then
        echo "You need to install first ℹ️"
        usage
        exit 1
    fi

    sudo rm -f "$kb_path" && {
        sudo mv -f "$bak" "$org" && {
            echo "- Uninstalled ✅"
            remove_input_source
        } || echo "Uninstall failed ❌"
    } || {
        usage
        exit 1
    }
}

# Ref => https://askubuntu.com/a/805207
add_2_input_source(){
    cur="$(gsettings get org.gnome.desktop.input-sources sources)"
    if [[ ! $cur == *"pao"* ]]; then
        # Append pao to array
        cur=${cur/]/, (\'xkb\', \'pao\')]}
        gsettings set org.gnome.desktop.input-sources sources "$cur" && echo "- Add to input source ✅" || echo "- Add to input source ❌"
    fi
}

remove_input_source(){
    cur="$(gsettings get org.gnome.desktop.input-sources sources)"
    cur=${cur:1:-1}
    cur=${cur// /HtetzSpace}
    cur=${cur//),/), }
    cur=($cur)
    for i in "${cur[@]}"; do
        if [[ ! $i == *"pao"* ]]; then
            out+="${i//HtetzSpace/ }"
        fi
    done
    if [[ $out == *, ]]; then
      out=${out:0:-1}
    fi
    cur="[${out}]"
    gsettings set org.gnome.desktop.input-sources sources "$cur" && echo "- Remove input source ✅" || echo "- Remove input source ❌"
}

usage(){
    echo "Usage: ./paoh_kb.sh install|uninstall"
}

case $1 in
install)
    install
    ;;

uninstall)
    uninstall
    ;;
*)
    usage
    ;;
esac