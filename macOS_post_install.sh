#!/bin/bash

## Warning : the script has only been tested on macOS 10.12
cat "misc/art.txt"
# ----------------------------------------------------------------------------------------------------------
# --------------------------     Install Homebrew and XCode command line tools     -------------------------
# ----------------------------------------------------------------------------------------------------------
echo ' + Installing Xcode command line tools'
xcode-select --install
if test ! $(which brew)
    then
    echo 'Installing homebrew'
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# ----------------------------------------------------------------------------------------------------------
# --------------------------------------     Install Cask and Mas     --------------------------------------
# ----------------------------------------------------------------------------------------------------------
echo ' + Installing caskroom'
brew tap caskroom/cask
echo ' + Installing mas'
brew install mas
echo "AppStore account:" 
read COMPTE
echo "Password for '$COMPTE'"
read -s PASSWORD
mas signin $COMPTE "$PASSWORD"

function install () {
    mas list | grep -i "$1" > /dev/null
    if [ "$?" == 0 ]; then
        echo "$1 is already installed"
    else
        echo "Installing $1"
        mas search "$1" | { read app_ident app_name ; mas install $app_ident ; }
    fi
}

# ----------------------------------------------------------------------------------------------------------
# --------------------------------------------     App List     --------------------------------------------
# ----------------------------------------------------------------------------------------------------------

declare -a brew_apps=( wget git zsh emacs ffmpeg node libssh openssh fortune )
declare -a mas_apps=( "BetterSnapTool" "Amphetamine" "Pages" "Keynote" "Numbers" "Xcode"
    "Twitter" "GifGrabber" )
declare -a cask_apps=( flux google-drive appcleaner BetterSnapTool sublime-text3 google-chrome
    firefox transmission selfcontrol spotify spotifree skype onyx vlc spotify-notifications )

for app in "${brew_apps[@]}"
do
    echo " + Installing $app"
    brew app
done

for app in "${mas_apps[@]}"
do
    echo " + Installing $app"
    install app
done

for app in "${cask_apps[@]}"
do
    echo " + Installing $app"
    brew cask install app --appdir=/Applications
done

echo ' + Installing Prezto'
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
chsh -s /bin/zsh

# ----------------------------------------------------------------------------------------------------------
# --------------------------                 macOS system settings                 -------------------------
# ----------------------------------------------------------------------------------------------------------

echo -e "\n Setting custom macOS system settings"

# --------------------------------------           TRACKPAD          ---------------------------------------
echo ' + TRACKPAD'
echo ' +--- Map bottom right corner to right-click'
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

echo ' +--- Disable natural scrolling'
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

echo ' +--- Turn off screensaver password delay'
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# ---------------------------------------           FINDER          ----------------------------------------
echo ' + FINDER'
echo ' +--- Show all filename extensions'
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo ' +--- Always show filepath'
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

echo ' +--- List view as default view'
defaults write com.apple.finder FXPreferredViewStyle -string “Nlsv”

echo ' +--- Set finder default to home'
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

echo ' +--- Search in current folder by default'
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo ' +--- Allow text selection in quick look'
defaults write com.apple.finder QLEnableTextSelection -bool true

echo ' +--- Show hard drive icons on desktop'
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

echo ' +--- Show Library folder'
chflags nohidden ~/Library

echo ' +--- Turn off animations'
defaults write com.apple.finder DisableAllAnimations -bool true

# echo ' +--- Set dock icon size to 36 pixels'
# defaults write com.apple.dock tilesize -int 36

#Not sure if this is what I think it is
# echo ' +--- Enable tab in modal dialogs'
#defaults write NSGlobalDomain AppleKeyboardUIMode -int 3


# ----------------------------------           MISSION CONTROL          ------------------------------------

echo ' + MISSION CONTROL'
echo ' +--- Speed up mission control animations'
defaults write com.apple.dock expose-animation-duration -float 0.1

# ------------------------------------           HOT CORNERS          --------------------------------------

echo ' + HOT CORNERS'
echo ' +--- Top left screen corner to mission control'
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0

echo ' +--- Bottom left screen corner screen saver'
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

echo ' +--- Faster expose animation'
defaults write com.apple.dock expose-animation-duration -float 0.1
echo ' +--- Expose group by app'
defaults write com.apple.dock "expose-group-by-app" -bool true

# ---------------------------------------           DOCK          ------------------------------------------

echo ' + DOCK'
echo ' +--- Automatically hide and show the dock'
defaults write com.apple.dock autohide -bool true

echo ' +--- Remove show/hide dock animation'
defaults write com.apple.dock autohide-time-modifier -float 0

echo ' +--- Removing from dock : Contacts, Calendar, Reminders, Maps, Facetime, iBookds, Notes'
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Contacts/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Calendar/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Reminders/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Maps/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Facetime/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/iBooks/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Notes/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock

# ---------------------------------------          KEYBOARD          ---------------------------------------
echo ' + KEYBOARD'
echo ' +--- Turn off smart quotes'
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

echo ' +--- Super fast key repeat, small delay'
defaults write NSGlobalDomain KeyRepeat -int 0
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# ------------------------------------------          MISC          ----------------------------------------

echo ' + MISC'
echo ' +--- Extend save panel by default'
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

echo ' +--- Turn off dahsboard'
defaults write com.apple.dashboard mcx-disabled -boolean YES

echo ' +--- Settings default screenshot folder to /Pictures/Screenshots'
mkdir $HOME/Pictures/Screenshots
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

echo ' +--- Settings default screenshot format to png'
defaults write com.apple.screencapture type -string "png"

echo ' +--- Turn off fast user switching'
sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool false

echo ' +--- Turn off ambient light sensor'
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false

# ------------------------------------------          MAIL          ----------------------------------------

echo ' + MAIL'
echo ' +--- Disable send and reply animations'
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true

echo ' +--- Copy email address instead of <email address>'
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

echo ' +--- cmd + enter shortcut to send mail'
defaults write com.apple.mail NSUserKeyEquivalents -dict-add “Send” “@U21a9”

# ----------------------------------------          TEXTEDIT          --------------------------------------

echo ' + TEXTEDIT'
echo ' +--- Plain text mode for new documents'
defaults write com.apple.TextEdit RichText -int 0

echo ' +--- Open and save files as UTF-8'
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# ----------------------------------------          SUBLIME          --------------------------------------

echo ' +--- Getting new icon for sublime text 3'
wget -O /Applications/Sublime\ Text\ 2.app/Contents/Resources/Sublime\ Text\ 2.icns https://dribbble.com/shots/1678555-Sublime-Text-3-Replacement-Icon/attachments/265398

# ---------------------------------------           PRINTER          ---------------------------------------
echo ' + PRINTER'
echo ' +--- Quit printer app once print jobs complete'
defaults write com.apple.print.PrintingPrefs “Quit When Finished” -bool true


# -----------------------------------          ACTIVITY MONITOR          -----------------------------------

echo ' + ACTIVITY MONITOR'
echo ' +--- Sort results by CPU usage'
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

# ---------------------------------------           SAFARI          ----------------------------------------

echo ' + SAFARI'
echo ' +--- Disable safari thumbnail cache for history and top sites'
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

echo ' +--- Set safari home page to blank'
defaults write com.apple.Safari HomePage -string "about:blank"

echo ' +--- Do not track'
defaults write com.apple.safari SendDoNotTrackHTTPHeader -int 1

echo ' +--- Safari show url full paths'
defaults write com.apple.safari ShowOverlayStatusBar -int 1
defaults write com.apple.safari ShowFullURLInSmartSearchField -int 1

echo "Don't forget to install browser extensions"
echo "  (Safari) https://github.com/maxfriedrich/quiet-facebook"
echo "  (Safari) https://github.com/ikiPZdU6UP3Gra/osx-safari-ssl-always"
echo "  (Chrome) Https Everywhere"
echo "  (Safari/Chrome) Ghostery"
echo "  (Safari/Chrome) AdBlockPlus"


# ----------------------------------------------------------------------------------------------------------
# ---------------------------------                 Cleaning                 -------------------------------
# ----------------------------------------------------------------------------------------------------------
echo -e "\nRelaunching Dock and Finder"
killall Dock
killall Finder
echo "Brew cleaning, caches cleaning"
brew cleanup
rm -f -r /Library/Caches/Homebrew/*
echo "Installing software updates"
sudo softwareupdate --install -all

echo "Done"