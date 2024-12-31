(define-module (etc systems arraniz)
  #:use-modules (gnu)
  #:use-modules (guix)
  #:use-modules (etc systems base-system))

(use-modules (gnu)
	     (gnu system nss)
	     (gnu packages wm)
	     (gnu packages admin)
	     (gnu packages pulseaudio)
	     (gnu packages terminals)
	     (gnu packages xdisorg)
	     (gnu packages image)
	     (gnu packages xorg)
	     (gnu packages version-control)
	     (gnu packages emacs)
	     (gnu packages gnome)
	     (gnu services desktop)
	     (gnu services dbus)
	     (nongnu packages linux)
	     (gnu services base))

(use-service-modules desktop dbus networking xorg)
(use-package-modules wm fonts linux)

(operating-system
 (inherit base-system)
 (host-name "arraniz")

 (kernel linux)
 (firmware (list linux-firmware))
 (bootloader (bootloader-configuration
	      (bootloader grub-efi-bootloader)
	      (targets '("/boot/efi"))
	      (keyboard-layout keyboard-layout)))
 (file-systems (append
		(list (file-system
		       (device (file-system-label "root"))
		       (mount-point "/")
		       (type "ext4"))
		      (file-system
		       (device (uuid "D140-4BF5" 'fat))
		       (mount-point "/boot/efi")
		       (type "vfat")))
		%base-file-systems))
 (swap-devices (list (swap-space
		      (target (uuid "a0bca027-0738-4287-933b-42f5960a25ed")))))
 (users (cons (user-account
	       (name "bfh")
	       (comment "some guy")
	       (group "users")
	       (supplementary-groups '("wheel" "netdev" "audio" "video")))
	      %base-user-accounts))

 (packages (append (list
		    sway
		    waybar
		    swaylock
		    swayidle
		    alacritty
		    git
		    network-manager
		    network-manager-applet
		    pulseaudio
		    brightnessctl
		    wlgreet
		    xorg-server-xwayland
		    ;;		     man-pages
		    ;;		     openssh
		    ;;		     pwgen
		    ;;		     unzip
		    ;;		     zip
		    ;;		     aspell
		    ;;		     aspell-dict-en
		    ;;		     mpv
		    ;;		     mpd-mpc
		    ;;		     asla-utils
		    ;;		     curl
		    ;;		     tree
		    ;;		     msmtp
		    ;;		     isync
		    ;;		     git
		    ;;		     make
		    ;;		     gcc-toolchain
		    ;;		     gvfs
		    ;;		     htop
		    ;;		     wget
		    ;;		     curl
		    ;;		     wl-clipboard
		    ;;		     wofi
		    )
		   %base-packages))

 (services
  (append
   (modify-services %base-services
		    (delete console-font-service-type)
		    (delete login-service-type)
		    (delete mingetty-service-type)
		    (delete agetty-service-type)
		    )
   (list
    (service network-manager-service-type)
    (service wpa-supplicant-service-type)
    (service elogind-service-type)
    (service ntp-service-type)
    ;;(service docker-service-type)
    ;;(service tlp-service-type)
    (service upower-service-type)
    (service udisks-service-type)
    (service polkit-service-type)
    (service dbus-root-service-type)
    (udev-rules-service 'brightnessctl brightnessctl)
    (service console-font-service-type
	     (map (lambda (tty)
		    (cons tty (file-append
			       font-terminus
			       "/share/consolefonts/ter-132n")))
		  '("tty1" "tty2" "tty3")))
    (service greetd-service-type
	     (greetd-configuration
	      (greeter-supplementary-groups
	       (list "users" "video" "input"))
	      (terminals
	       (list
		(greetd-terminal-configuration
		 (terminal-vt "1")
		 (terminal-switch #t)
		 (default-session-command (greetd-wlgreet-sway-session)))
		(greetd-terminal-configuration (terminal-vt "2"))
		(greetd-terminal-configuration (terminal-vt "3")))))))))

 ;; Allow resolution of '.local' host names with mDNS.
 (name-service-switch %mdns-host-lookup-nss))
