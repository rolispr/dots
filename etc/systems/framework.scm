(define-module (etc systems framework)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)

  #:use-module (gnu packages certs)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages display-managers)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages image)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages linux) ;; pipewire

  #:use-module (gnu services desktop)
  #:use-module (gnu services dbus)
  #:use-module (gnu services ssh)
  #:use-module (gnu services sddm)
  #:use-module (gnu services xorg)
  #:use-module (gnu services networking)
  #:use-module (gnu services web)
  ;;#:use-module (gnu services base)

  #:use-module (gnu system nss)

  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)

  #:use-module (etc systems base-system)
  #:use-module (etc packages stumpwm))

(define %stumpwm-packages
  (list sbcl
        stumpwm-dev+servers ;; custom package
        sbcl-parse-float ;;|--> gnu packages lisp-xyz
        sbcl-local-time
        sbcl-cl-ppcre
        sbcl-zpng
        sbcl-salza2
        sbcl-clx
        sbcl-zpb-ttf
        sbcl-cl-vectors
        sbcl-cl-store
        sbcl-trivial-features
        sbcl-global-vars
        sbcl-trivial-garbage
        sbcl-bordeaux-threads
        sbcl-cl-fad
        sbcl-clx-truetype
        ;; stumpwm-contrib packages
        sbcl-stumpwm-ttf-fonts ;;|--> gnu packages wm;
        sbcl-stumpwm-kbd-layouts
        sbcl-stumpwm-swm-gaps
        sbcl-stumpwm-globalwindows
        sbcl-stumpwm-cpu
        sbcl-stumpwm-mem
        sbcl-stumpwm-wifi
        sbcl-stumpwm-battery-portable))

(define %guixos-system-packages
  (list openssh
        sway
        waybar
        swaylock
        swayidle
        pipewire
        wireplumber
        network-manager
        network-manager-applet
        brightnessctl
        wlgreet
        xorg-server-xwayland
        ;;xdg-desktop-portal
        ; xdg-desktop-portal-wlr
        ))

(define %guixos-base-packages
  (append %stumpwm-packages
          %guixos-system-packages
          %base-packages))

(operating-system
 ;; (inherit base-system)
 (host-name "arraniz")
 (locale "en_US.utf8")
 (timezone "America/New_York")
 (keyboard-layout (keyboard-layout "us"))

 (kernel linux)
 (initrd microcode-initrd)
 (firmware (list iwlwifi-firmware sof-firmware linux-firmware))
 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets '("/boot/efi"))
              (keyboard-layout base-keyboard-layout)))
 (file-systems (append
                (list (file-system
                       (device (file-system-label "root"))
                       (mount-point "/")
                       (type "ext4"))
                      (file-system
                       (device (uuid "DD8A-2ACD" 'fat))
                       (mount-point "/boot/efi")
                       (type "vfat")))
                %base-file-systems))
 (swap-devices (list (swap-space
                      (target (uuid "008ed7c6-e6cb-4106-99b4-5eee8e5a7eec")))))
 (users (cons* (user-account
                (name "bfh")
                (comment "some guy")
                (group "users")
                (home-directory "/home/bfh")
                (supplementary-groups '("tty" "lp" "wheel" "netdev" "audio" "video")))
               %base-user-accounts))

 (packages (append
            (list (specification->package "openssh")
                  (specification->package "sway")
                  (specification->package "waybar")
                  (specification->package "swaylock")
                  (specification->package "swayidle")
                  (specification->package "pipewire")
                  (specification->package "network-manager")
                  (specification->package "network-manager-applet")
                  (specification->package "brightnessctl")
                  (specification->package "wlgreet")
                  (specification->package "xorg-server-xwayland")
                  ;; (specification->package "xdg-desktop-portal-wlr")
                  ;; (specification->package "xdg-desktop-portal")
                  (specification->package "wireplumber")
                  (specification->package "alacritty")
                  (specification->package "git"))
            %stumpwm-packages
            %base-packages))
 (services
  (cons*
   (service openssh-service-type
            (openssh-configuration
             (port-number 2226)
             (password-authentication? #t)
             (permit-root-login 'prohibit-password)))
   (modify-services (cons (service gnome-desktop-service-type)
                          %desktop-services)
                    ;; Get nonguix substitutes.
                    (guix-service-type config =>
                                       (guix-configuration
                                        (inherit config)
                                        (substitute-urls
                                         (append (list "https://substitutes.nonguix.org")
                                                 %default-substitute-urls))
                                        (authorized-keys
                                         (append (list (local-file "./nonguix-signing-key.pub"))
                                                 %default-authorized-guix-keys)))))))
 
 ;; Allow resolution of '.local' host names with mDNS.
 (name-service-switch %mdns-host-lookup-nss))

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
