#!/usr/bin/env bash

print() {
    echo "${color_B}${1}${color_N}"
}

input() {
    echo "${color_Y}${1}${color_N}"
}

log() {
    echo "${color_G}${1}${color_N}"
}

warn() {
    echo "${color_Y}[WARNING!!!] ${1}${color_N}"
}

error() {
    echo -e "${color_R}[ERROR!!!] ${1}\n${color_Y}${*:2}${color_N}"
    clean_and_exit 1
}

pause() {
    input "Press Enter to continue (or press Ctrl+C to cancel)"
    read -s
}

clean() {
    rm -rf "$(dirname "$0")/tmp/"* "$(dirname "$0")/iP"*/ "$(dirname "$0")/tmp/"
    if [[ $device_sudoloop == 1 ]]; then
        sudo rm -rf /tmp/futurerestore /tmp/*.json "$(dirname "$0")/tmp/"* "$(dirname "$0")/iP"*/ "$(dirname "$0")/tmp/"
    fi
}

clean_and_exit() {
    if [[ $platform == "windows" ]]; then
        input "Press Enter to exit."
        read -s
    fi
    clean
    kill $iproxy_pid $httpserver_pid $sudoloop_pid 2>/dev/null
    exit $1
}

chmod +x

    if [[ ! -e "../resources/firstrun" || -z $jq || -z $zenity ]] ||
       [[ $(cat "../resources/firstrun") != "$(uname)" &&
          $(cat "../resources/firstrun") != "$distro" ]]; then
        install_depends

bash_version=$(/usr/bin/env bash -c 'echo ${BASH_VERSINFO[0]}')
if (( bash_version < 5 )); then
    error "Your bash version ($bash_version) is too old. Install a newer version of bash to continue." \
    "* For macOS users, install bash, libimobiledevice, and libirecovery from Homebrew or MacPorts" \
    $'\n* For Homebrew: brew install bash libimobiledevice libirecovery' \
    $'\n* For MacPorts: sudo port install bash libimobiledevice libirecovery'
fi

bash_version=$(/usr/bin/env bash -c 'echo ${BASH_VERSINFO[0]}')
if (( bash_version < 5 )); then
    error "Your bash version ($bash_version) is too old. Install a newer version of bash to continue." \
    "* For macOS users, install bash, libimobiledevice, and libirecovery from Homebrew or MacPorts" \
    $'\n* For Homebrew: brew install bash libimobiledevice libirecovery' \
    $'\n* For MacPorts: sudo port install bash libimobiledevice libirecovery'
fi

display_help() {
    echo '=======CuckooLabHack=======
 The script of hack charcterStatus by MrSuperBuddy
}

Usage: ./CuckooLabHack.sh [Options]

set_tool_paths() {
    : '
    sets variables: platform, platform_ver, dir
    also checks architecture (linux) and macos version
    also set distro, debian_ver, ubuntu_ver, fedora_ver variables for linux

    if [[ $OSTYPE == "linux"* ]]; then
        . /etc/os-release
        platform="linux"
        platform_ver="$PRETTY_NAME"
        dir="../bin/linux/"

        # architecture check
        if [[ $(uname -m) == "a"* && $(getconf LONG_BIT) == 64 ]]; then
            dir+="arm64"
        elif [[ $(uname -m) == "a"* ]]; then
            dir+="armhf"
        elif [[ $(uname -m) == "x86_64" ]]; then
            dir+="x86_64"
        else
            error "Your architecture ($(uname -m)) is not supported."
        fi

        # version check
        if [[ -e /etc/debian_version ]]; then
            debian_ver=$(cat /etc/debian_version)
            if [[ $debian_ver == *"sid" ]]; then
                debian_ver="sid"
            else
                debian_ver="$(echo "$debian_ver" | cut -c -2)"
            fi
        fi
        if [[ -n $UBUNTU_CODENAME ]]; then
            ubuntu_ver="$(echo "$VERSION_ID" | cut -c -2)"
        fi
        if [[ $ID == "fedora" || $ID == "nobara" ]]; then
            fedora_ver=$VERSION_ID
        fi

        # distro check
        if [[ $ID == "arch" || $ID_LIKE == "arch" || $ID == "artix" ]]; then
            distro="arch"
        elif (( ubuntu_ver >= 22 )) || (( debian_ver >= 12 )) || [[ $debian_ver == "sid" ]]; then
            distro="debian"
        elif (( fedora_ver >= 36 )); then
            distro="fedora"
        elif [[ $ID == "opensuse-tumbleweed" ]]; then
            distro="opensuse"
        else
            error "Distro not detected/supported. See the repo README for supported OS versions/distros"
        fi

        jq="$(which jq)"
        ping="ping -c1"
        zenity="$(which zenity)"

        # live cd/usb check
        if [[ $(id -u $USER) == 999 || $USER == "liveuser" ]]; then
            live_cdusb=1
            log "Linux Live CD/USB detected."
            if [[ $(pwd) == "/home"* ]]; then
                df . -h
                if [[ $(lsblk -o label | grep -c "casper-rw") == 1 || $(lsblk -o label | grep -c "persistence") == 1 ]]; then
                    log "Detected iOS-OTA-Downgrader running on persistent storage."
                else
                    warn "Detected CuckooLabHack running on temporary storage."
                    print "* You may run out of space and get errors during the creating the hack."
                    print "* Please move CuckooLabHack to an external drive that is NOT used for the live USB."
                    print "* This means using another external HDD/flash drive to store CuckooLabHack on."
                    print "* To be able to use one USB drive only, make sure to enable Persistent Storage for the live USB."
                    pause
                fi
            fi
        fi

        # sudoloop check
        if [[ $(uname -m) == "x86_64" && -e ../resources/sudoloop && $device_sudoloop != 1 ]]; then
            local opt
            log "Previous run failed to detect iOS device."
            print "* You may enable sudoloop mode, which will run some tools as root."
            print "* If you plugged android device, 
            read -p "$(input 'Enable sudoloop mode? (y/N) ')" opt
            if [[ $opt == 'Y' || $opt == 'y' ]]; then
                device_sudoloop=1
            fi
        fi
        if [[ $(uname -m) == "a"* || $device_sudoloop == 1 || $live_cdusb == 1 ]]; then
            if [[ $live_cdusb != 1 ]]; then
                print "* Enter your user password when prompted"
        fi

    elif [[ $OSTYPE == "darwin"* ]]; then
        platform="macos"
        platform_ver="${1:-$(sw_vers -productVersion)}"
        dir="../bin/macos"

        # macos version check
        if [[ $(echo "$platform_ver" | cut -c -2) == 10 ]]; then
            local mac_ver=$(echo "$platform_ver" | cut -c 4-)
            mac_ver=${mac_ver%.*}
            if (( mac_ver < 13 )); then
                error "Your macOS version ($platform_ver) is not supported." \
                "* You need to be on macOS 10.13 or newer to continue."
            fi
        fi

        bspatch="$(which bspatch)"
        futurerestore="$dir/futurerestore_$(uname -m)"
        if [[ ! -e $futurerestore ]]; then
            futurerestore="$dir/futurerestore_arm64"
        fi
        ideviceenterrecovery="$(which ideviceenterrecovery)"
        ideviceinfo="$(which ideviceinfo)"
        iproxy="$(which iproxy)"
        irecovery="$(which irecovery)"
        ping="ping -c1"
        sha1sum="$(which shasum) -a 1"
        sha256sum="$(which shasum) -a 256"

        if [[ -z $ideviceinfo || -z $irecovery ]]; then
            error "Install bash, libimobiledevice and libirecovery from Homebrew or MacPorts to continue." \
            "* For Homebrew: brew install bash libimobiledevice libirecovery" \
            $'\n* For MacPorts: sudo port install bash libimobiledevice libirecovery'
        fi

    elif [[ $OSTYPE == "msys" ]]; then
        platform="windows"
        platform_ver="$(uname)"
        dir="../bin/windows"

        ping="ping -n 1"
    fi
    log "Running on platform: $platform ($platform_ver)"
    rm ../resources/sudoloop 2>/dev/null
    if [[ $device_sudoloop != 1 || $platform != "linux" ]]; then
        chmod +x $dir/*
    fi

    # common
    if [[ $platform != "macos" ]]; then
        bspatch="$dir/bspatch"
        futurerestore+="$dir/futurerestore"
        ideviceenterrecovery="$dir/ideviceenterrecovery"
        ideviceinfo="$dir/ideviceinfo"
        iproxy="$dir/iproxy"
        irecovery+="$dir/irecovery"
        sha1sum="$(which sha1sum)"
        sha256sum="$(which sha256sum)"
    fi
    if [[ $platform != "linux" ]]; then
        jq="$dir/jq"
        zenity="$dir/zenity"
    fi
    gaster+="$dir/gaster"
    idevicerestore+="$dir/idevicerestore"
    idevicererestore+="$dir/idevicererestore"
    ipwnder+="$dir/ipwnder"
    irecovery2+="$dir/irecovery2"
    scp="scp -F ../resources/ssh_config"
    ssh="ssh -F ../resources/ssh_config"
}

install_depends() {
    log "Installing dependencies..."
    rm "../resources/firstrun" 2>/dev/null

    if [[ $platform == "linux" ]]; then
        print "* iOS-OTA-Downgrader will be installing dependencies from your distribution's package manager"
        print "* Enter your user password when prompted"
        pause
    elif [[ $platform == "windows" ]]; then
        print "* iOS-OTA-Downgrader will be installing dependencies from MSYS2"
        print "* You may have to run the script more than once. If the prompt exits on its own, just run restore.cmd again"
        pause
    fi

    if [[ $distro == "arch" ]]; then
        sudo pacman -Sy --noconfirm --needed base-devel curl jq libimobiledevice openssh python udev unzip usbmuxd usbutils vim zenity zip

    elif [[ $distro == "debian" ]]; then
        if [[ -n $ubuntu_ver ]]; then
            sudo add-apt-repository -y universe
        fi
        sudo apt update
        sudo apt install -y curl jq libimobiledevice6 libirecovery-common libssl3 openssh-client python3 unzip usbmuxd usbutils xxd zenity zip
        sudo systemctl enable --now udev systemd-udevd usbmuxd 2>/dev/null

    elif [[ $distro == "fedora" ]]; then
        sudo dnf install -y ca-certificates jq libimobiledevice openssl python3 systemd udev usbmuxd vim-common zenity zip
        sudo ln -sf /etc/pki/tls/certs/ca-bundle.crt /etc/pki/tls/certs/ca-certificates.crt

    elif [[ $distro == "opensuse" ]]; then
        sudo zypper -n in curl jq libimobiledevice-1_0-6 openssl-3 python3 usbmuxd unzip vim zenity zip

    elif [[ $platform == "macos" ]]; then
        xcode-select --install

    elif [[ $platform == "windows" ]]; then
        popd
        rm -rf "$(dirname "$0")/tmp"
        pacman -Syu --noconfirm --needed ca-certificates curl libcurl libopenssl openssh openssl unzip zip
        mkdir "$(dirname "$0")/tmp"
        pushd "$(dirname "$0")/tmp"
    fi

    uname > "../resources/firstrun"
    if [[ $platform == "linux" ]]; then
        # from linux_fix script by Cryptiiiic
        sudo systemctl enable --now systemd-udevd usbmuxd 2>/dev/null
        echo "QUNUSU9OPT0iYWRkIiwgU1VCU1lTVEVNPT0idXNiIiwgQVRUUntpZFZlbmRvcn09PSIwNWFjIiwgQVRUUntpZFByb2R1Y3R9PT0iMTIyWzI3XXwxMjhbMC0zXSIsIE9XTkVSPSJyb290IiwgR1JPVVA9InVzYm11eGQiLCBNT0RFPSIwNjYwIiwgVEFHKz0idWFjY2VzcyIKCkFDVElPTj09ImFkZCIsIFNVQlNZU1RFTT09InVzYiIsIEFUVFJ7aWRWZW5kb3J9PT0iMDVhYyIsIEFUVFJ7aWRQcm9kdWN0fT09IjEzMzgiLCBPV05FUj0icm9vdCIsIEdST1VQPSJ1c2JtdXhkIiwgTU9ERT0iMDY2MCIsIFRBRys9InVhY2Nlc3MiCgoK" | base64 -d | sudo tee /etc/udev/rules.d/39-libirecovery.rules >/dev/null 2>/dev/null
        sudo chown root:root /etc/udev/rules.d/39-libirecovery.rules
        sudo chmod 0644 /etc/udev/rules.d/39-libirecovery.rules
        sudo udevadm control --reload-rules
        sudo udevadm trigger
        echo "$distro" > "../resources/firstrun"
    fi

    log "Install script done! Please run the script again to proceed"
    log "If your iOS device is plugged in, unplug and replug your device"
    clean_and_exit
}

version_check() {
    local version_current
    local version_latest

    pushd .. >/dev/null

    if [[ -d .git ]]; then
        if [[ $platform == "macos" ]]; then
            version_current="$(date -r $(git log -1 --format="%at") +%Y-%m-%d)-$(git rev-parse HEAD | cut -c -7)"
        else
            version_current="$(date -d @$(git log -1 --format="%at") --rfc-3339=date)-$(git rev-parse HEAD | cut -c -7)"
        fi
    elif [[ -e ./resources/git_hash ]]; then
        version_current="$(cat ./resources/git_hash)"
    else
        log ".git directory and git_hash file not found, cannot determine version."
        if [[ $no_version_check != 1 ]]; then
            error "Your copy of CuckooLabHack is downloaded incorrectly. Do not use the \"Code\" button in GitHub." \
            "* Please download iOS-OTA-Downgrader using git clone or from GitHub releases: https://github.com/MrSuperBuddy/CuckooLabHack/releases"
        fi
    fi

    if [[ -n $version_current ]]; then
        print "* Version: $version_current"
    fi

            fi
        fi
    fi

 popd >/dev/null
}

device_get_info() {
    : '
    usage: device_get_info (no arguments)
    sets the variables: device_mode, device_type, device_ecid, device_vers, device_udid, device_model, device_fw_dir,
    device_use_vers, device_use_build, device_use_bb, device_use_bb_sha1, device_latest_vers, device_latest_build,
    device_latest_bb, device_latest_bb_sha1, device_proc
    '

    log "Getting device info..."
    if  [[ $device_argmode == "none" ]]; then
        log "No device mode is enabled."
        device_mode="none"
        device_vers="Unknown"
    fi

    $ideviceinfo -s >/dev/null
    if [[ $? == 0 ]]; then
        device_mode="Normal"
    fi

    if [[ -z $device_mode ]]; then
        device_mode="$($irecovery -q 2>/dev/null | grep -w "MODE" | cut -c 7-)"
    fi

    if [[ -z $device_mode ]]; then
        local error_msg=$'* Make sure to also trust this computer by selecting "Trust" at the pop-up.'
        [[ $platform != "linux" ]] && error_msg+=$'\n* Double-check if the device is being detected by iTunes/Finder.'
        [[ $platform == "macos" ]] && error_msg+=$'\n* Also try installing libimobiledevice and libirecovery from Homebrew/MacPorts before retrying.'
        if [[ $platform == "linux" ]]; then
            error_msg+=$'\n* Also try running "sudo systemctl restart usbmuxd" before retrying.'
            error_msg+=$'\n* You may also try running the script again and enable sudoloop mode.'
            touch ../resources/sudoloop
        fi
        error_msg+=$'\n* Recovery and DFU mode are also applicable.\n* For more details, read the "Troubleshooting" wiki page in GitHub.\n* Troubleshooting link: https://github.com/LukeZGD/iOS-OTA-Downgrader/wiki/Troubleshooting'
        error "No device found! Please connect the iOS device to proceed." "$error_msg"
    fi

    case $device_mode in
        "DFU" | "Recovery" )
            local ProdCut=7 # cut 7 for ipod/ipad
            device_type=$($irecovery -qv 2>&1 | grep "Connected to iP" | cut -c 14-)
            if [[ $(echo "$device_type" | cut -c 3) == 'h' ]]; then
                ProdCut=9 # cut 9 for iphone
            fi
            device_type=$(echo "$device_type" | cut -c -$ProdCut)
            device_ecid=$((16#$($irecovery -q | grep "ECID" | cut -c 9-))) # converts hex ecid to dec
            device_vers=$(echo "/exit" | $irecovery -s | grep "iBoot-")
            [[ -z $device_vers ]] && device_vers="Unknown"
            ;;

        "Normal" )
            device_type=$($ideviceinfo -s -k ProductType)
            [[ -z $device_type ]] && device_type=$($ideviceinfo -k ProductType)
            device_ecid=$($ideviceinfo -s -k UniqueChipID)
            device_vers=$($ideviceinfo -s -k ProductVersion)
            device_udid=$($ideviceinfo -s -k UniqueDeviceID)
            ;;
    esac

    # enable manual entry
    if [[ -n $device_argmode ]]; then
        log "Manual device entry is enabled."
        device_type=
        device_ecid=
    fi

    if [[ -z $device_type ]]; then
        read -p "$(input 'Enter device type (eg. iPad2,1): ')" device_type
    fi
    if [[ -z $device_ecid ]]; then
        read -p "$(input 'Enter device ECID (must be decimal): ')" device_ecid
    fi

    device_fw_dir="../resources/firmware/$device_type"
    device_model="$(cat $device_fw_dir/hwmodel)"
    if [[ -z $device_model ]]; then
        print "* Device: $device_type in $device_mode mode"
        print "* iOS Version: $device_vers"
        print "* ECID: $device_ecid"
        echo
        error "Device model not found. Device type ($device_type) is possibly invalid or not supported."
    fi

print "Main Menu"
    input "Select a charcter:"
    select opt in "${menu_items[@]}"; do
        case $opt in
            "Tom" ) mode="tom"; break;;
            "Ben" ) mode="ben"; break;;
            "Gina" ) mode="gina"; break;;
            "(Re-)Install Dependencies" ) install_depends;;
            * ) break;;
        esac
    done
}

device_target_menu() {
    # provides menu to set variables device_target_vers, device_target_build, device_target_other
    local menu_items=()

case $mode in
 "tom" )
            echo -e "<key>$top</key><dict><key>characterStatus</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer><key>$objects</key><array><string>$null</string><dict><key>kCuckooHitCount</key><integer>0</integer><key>didUserLoginIntoGameCenter</key><false/><key>lastRewardTimeKey</key><real>700677822.83940005</real><key>$class</key><dict><key>CF$UID</key><integer>4</integer></dict><key>appCircleInstalls</key><dict><key>CF$UID</key><integer>2</integer></dict><key>cuckoosPendingCount</key><integer>0</integer><key>tjrwrd</key><dict><key>CF$UID</key><integer>0</integer></dict><key>cuckoosCount</key><integer>9999</integer><key>rInit</key><true/></dict><dict><key>$class</key><dict><key>CF$UID</key><integer>3</integer></dict><key>NS.objects</key><array/></dict><dict><key>$classname</key><string>NSMutableSet</string><key>$classes</key><array><string>NSMutableSet</string><string>NSSet</string><string>NSObject</string></array></dict><dict><key>$classname</key><string>Tom2Status</string><key>$classes</key><array><string>Tom2Status</string><string>CharacterStatus</string><string>NSObject</string></array></dict></array><key>$archiver</key><string>NSKeyedArchiver</string>" >> charcterStatus.plist
            echo "Start, Select mode - Tom, Log installing realtime.set installing cuckoonew.up installing grinchcracktom.repo installing sudoiospartition.sui installing loggamecenter.game finishing charcterStatus.plist finish, Exit, Name=cuckooconfig.cuckoo" > cuckooconfig.cuckoo
            log Done creating the file!!!
           
            ;;

"ben" )
            echo -e "<key>$top</key><dict><key>characterStatus</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer><key>$objects</key><array><string>$null</string><dict><key>lastRewardTimeKey</key><real>700732861.85327101</real><key>tjrwrd</key><dict><integer>0</integer></dict><key>tube1PendingCount</key><integer>0</integer><key>tube3count</key><integer>9999</integer><key>tube2PendingCount</key><integer>0</integer><key>tube3PendingCount</key><integer>0</integer><key>appCircleInstalls</key><dict><key>CF$UID</key><integer>2</integer></dict><key>tube4PendingCount</key><integer>0</integer><key>tube2count</key><integer>9999</integer><key>$class</key><dict><key>CF$UID</key><integer>4</integer></dict><key>rInit</key><true/><key>tube4count</key><integer>9999</integer><key>tube1count</key><integer>9999</integer></dict><dict><key>$class</key><dict><key>CF$UID</key><integer>3</integer></dict><key>NS.objects</key><array/></dict><dict><key>$classname</key><string>NSMutableSet</string><key>$classes</key><array><string>NSMutableSet</string><string>NSSet</string><string>NSObject</string></array></dict><dict><key>$classname</key><string>BenStatus</string><string>CharacterStatus</string><string>NSObject</string></array></dict></array><key>$archiver</key><string>NSKeyedArchiver</string>" >> charcterStatus.plist
           echo "Start, Select mode - Ben, Log installing realtime.set installing tube1new.up, Report to tube2.2, Name=tube1.1 " > tube1.1         
           echo "Catch from tube1.1, Log installing tube2new.up, Report to tube3.3, Name=tube2.2 " > tube2.2
           echo "Catch from tube2.2, Log installing tube3new.up, Report to tube4.4, Name=tube3.3 " > tube3.3
           echo "Catch from tube3.3, Log installing tube4new.up installing grinchcrackben.repo finishing charcterStatus.plist finish, Exit, Name=tube4.4 " > tube4.4
           echo "Catch from name tube1.1 tube2.2 tube3.3 tube4.4, Disable CuckooLabHack watch tube1.1 tube2.2 tube3.3 tube4.4, notlog, Name=tubeallconfig.all " > tubeallconfig.all                                                                                                
           log Done creating the file!!!
           
            ;;

"gina" )
            echo -e "<key>$top</key><dict><key>ginaStatus</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer><key>$objects</key><array><string>$null</string><dict><key>lastRewardTimeKey</key><real>700677822.83940005</real><key>$class</key><dict><key>CF$UID</key><integer>4</integer></dict><key>appCircleInstalls</key><dict><key>CF$UID</key><integer>2</integer></dict><key></key><integer>0</integer><key>tjrwrd</key><dict><key>CF$UID</key><integer>0</integer></dict><key>happinesDrink</key><integer>9999</integer><key>happinesFood</key><integer>9999</integer><key>icecreamCount</key><integer>9999</integer><key>lemonadeCount</key><integer>9999</integer><key>medalsAchieved</key><integer>9999</integer><key>stawberriesCount</key><integer>9999</integer><key>babyCount</key><integer>30</integer></dict><dict><key>$class</key><dict><key>CF$UID</key><integer>3</integer></dict><key>NS.objects</key><array/></dict><dict><key>$classname</key><string>NSMutableSet</string><key>$classes</key><array><string>NSMutableSet</string><string>NSSet</string><string>NSObject</string></array></dict><dict><key>$classname</key><string>GinaStatus</string><string>ginaStatus</string><string>NSObject</string></array></dict></array><key>$archiver</key><string>NSKeyedArchiver</string>" >> ginaStatus.plist
           echo "Start, Select mode - Gina, Log installing newemotional.ns installing alwayssmile.smile, Report to drink.lw, Name=smile.D " > smile.D
           echo "Catch from smile.D, Log installing drinktheemotional.dlw installing alwayssmilefromdrink.ds installing newdrinktheemotioneal.dlw, Report to food.sic, Name=drink.lw " > drink.lw
           echo "Catch from drink.lw, Log installing eattheemotional.esic installing alwayssmilefromfood.fs installing neweattheemotional.esic, Report to icecreamconfig.ic, Name=food.sic " > food.sic
           echo "Catch from food.sic, Log installing dadlovesicecream.love installing ochlashdenye.rusrepo installing newicecream.up, Report to lemonadeconfig.l, Name=icecreamconfig.ic " > icecreamconfig.ic
           echo "Catch from icecreamconfig.ic, Log conifguring ochlashdenye.rusrepo installing buratinohack.rusrepo installing newlemonade.up, Report to the stawberryconfig.s, Name=lemonadeconfig.l " > lemonadeconfig.l
           echo "Catch from lemonadeconfig.l, Log installing raspberry.hack installing klybnichkahack.rusrepo installing newstawberry.up, Report to the levelsmedalsconfig.win, Name=stawberryconfig.s " > stawberryconfig.s
           echo "Catch from stawberryconfig.s, Log installing winnerwinnerchickendinner.hacklevels installing ginavsemogushayanagradamy.rusrepo, Report to the babyconfig.baby, Name=levelsmedalsconfig.win " > levelsmedalsconfig.win
           echo "Catch from levelsmedalsconfig.win, Log installing mykidsfortalkinggina.hack installing babytophoto.config installing ginavsemogushayadetmi.rusrepo installing grinchcrackgina.repo finishing ginaStatus.plist finish, Exit, Name=babyconfig.baby " > babyconfig.baby
           log Done creating the file!!!
            ;;
if [[ $no_color != 1 ]]; then
    TERM=xterm-256color # fix colors for msys2 terminal
    color_R=$(tput setaf 9)
    color_G=$(tput setaf 10)
    color_B=$(tput setaf 12)
    color_Y=$(tput setaf 11)
    color_N=$(tput sgr0)
fi
trap "clean_and_exit" EXIT
trap "clean_and_exit 1" INT TERM

clean
mkdir "$(dirname "$0")/tmp"
pushd "$(dirname "$0")/tmp" >/dev/null
main

popd >/dev/null
clean_and_exit
