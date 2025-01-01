;; -*- mode: scheme; -*-

(define-module (home users bfh)
  #:use-module (guix gexp)
  #:use-module (guix files)
  #:use-module (guix modules)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services pm)
  #:use-module (gnu home services sound)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services xdg)
  #:use-module (gnu packages)
  #:use-module (gnu packages glib)
  #:use-module (gnu services)
  #:use-module (home services bash)
  #:use-module (home services emacs))

(define config-dir (string-append (getenv "HOME") "/dots/home/config"))

(home-environment
 (packages
  (specifications->packages
   (list "guile"
	 ;;	 "emacs-treesitter-langs"
	 ;;	 "emacs-shr-tag-pre-highlight"
;;	 "dot"
	 "wofi"
	 "git"
	 "ripgrep"
	 "fd"
	 "jq"
	 "awscliv2"
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

 (services
  (list
   (service home-xdg-configuration-files-service-type
	    `(("sway/config"
	       ,(local-file (string-append config-dir "/sway/config")))
              ("alacritty/alacritty.yml"
               ,(local-file (string-append config-dir "/alacritty/.config/alacritty/alacritty.yml")))
              ("wezterm/wezterm.lua"
               ,(local-file (string-append config-dir "/wezterm/.config/wezterm/wezterm.lua")))
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

   (home-bash-service #:config-dir config-dir)
   (service home-emacs-config-service-type)
   (service home-pipewire-service-type)
   (service home-ssh-agent-service-type)
   (service home-openssh-service-type
            (home-openssh-configuration
             (add-keys-to-agent "yes")))
   )))
