;; -*- mode: scheme; -*-

(define-module (home users bfh)
  #:use-modules (gnu)
  #:use-modules (gnu home)
  #:use-modules (home services emacs))

(use-modules (gnu home)
	     (gnu packages)
	     (gnu services)
	     (gnu home services)
	     (gnu home services shells)
	     (gnu home services pm)
	     (gnu home services sound)
	     (gnu home services desktop)
	     (gnu home services xdg)
	     (gnu packages glib)
	     (guix gexp))

(home-environment
 ;; Packages installed to user profile
 (packages
  (specifications->packages
   (list "emacs"
	 "emacs-geiser"
	 "emacs-ef-themes"
	 "emacs-mini-echo"
	 "emacs-guix"
	 "emacs-eat"
	 "guile"
	 "emacs-geiser-guile"
	 "emacs-evil"
	 "emacs-magit"
	 "emacs-company"
	 "wofi"
	 "git"
	 "ripgrep"
	 "fd"
	 "font-jetbrains-mono"
	 "font-liberation"
	 "font-dejavu"
	 "font-google-noto"
	 "adwaita-icon-theme"
	 "gnome-themes-extra"
	 "htop"
	 "google-chrome-stable"
	 "tmux"
	 "curl"
	 "wget")))

 ;; Home services
 (services
  (list
   ;; Sway configuration
   (service home-xdg-configuration-files-service-type
	    `(("sway/config"
	       ,(plain-file "sway-config"
			    "# Sway config
exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
exec waybar
exec mako

# Basic settings
set $mod Mod4
set $left h
set $down j
set $up k
set $right l
set $term alacritty
set $menu wofi --show=drun

# Output configuration
output * bg #000000 solid_color

# Key bindings
bindsym XF86MonBrightnessUp exec brightnessctl s +10%
bindsym XF86MonBrightnessDown exec brightnessctl s 10%-
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'

# Moving around
bindsym $mod+$left focus left
bindsym $mod+$down focus down
bindsym $mod+$up focus up
bindsym $mod+$right focus right

input \"type:keyboard\" {
xkb_layout us
xkb_options ctrl:swapcaps
}

gaps inner 22

# Layout stuff
bindsym $mod+b splith
bindsym $mod+v splitv
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split
bindsym $mod+f fullscreen
bindsym $mod+Shift+space floating toggle"))
	      
	      ;; Alacritty configuration
	      ("alacritty/alacritty.yml"
	       ,(plain-file "alacritty-config"
			    "window:
  padding:
    x: 10
    y: 10
  opacity: 0.95

font:
  normal:
    family: JetBrains Mono
    style: Regular
  size: 11.0

colors:
  primary:
    background: '#282c34'
    foreground: '#abb2bf'"))
	      
	      ;; Waybar configuration
	      ("waybar/config"
	       ,(plain-file "waybar-config"
			    "{
    \"layer\": \"top\",
    \"modules-left\": [\"sway/workspaces\"],
    \"modules-center\": [\"clock\"],
    \"modules-right\": [\"pulseaudio\", \"network\", \"battery\"],
    \"clock\": {
	\"format\": \"{:%H:%M}\"
    }
}"))))

   ;; Shell configuration
   (service home-bash-service-type
	    (home-bash-configuration
	     (aliases '(("ll" . "ls -l")
			("la" . "ls -la")))
	     (bashrc
	      (list (plain-file "bashrc"
				"# Environment variables
export XDG_CURRENT_DESKTOP=sway
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export _JAVA_AWT_WM_NONREPARENTING=1")))
	     (bash-profile
	      (list (plain-file "bash-profile"
				"if [ -z $DISPLAY ] && [ $(tty) = /dev/tty1 ]; then
  exec sway
fi")))))
   
   ;; Sound service (Pipewire)
   ;;(service home-pipewire-service-type)
   ;; requires dbus
   )))
