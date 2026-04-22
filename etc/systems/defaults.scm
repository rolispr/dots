;;; System defaults. Every knob the single operating-system form reads
;;; has a default-<key> here. Hosts override via (system-overrides) in
;;; per-host/<host>/system.scm.

(define-module (etc systems defaults)
  #:use-module (gnu)
  #:use-module (gnu packages)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (etc packages stumpwm)
  #:export (default-hostname
            default-locale
            default-timezone
            default-keyboard-layout
            default-kernel
            default-initrd
            default-firmware
            default-bootloader
            default-file-systems
            default-swap-devices
            default-users
            default-extra-packages
            default-extra-services))

(define default-hostname "guix")
(define default-locale   "en_US.utf8")
(define default-timezone "America/New_York")

(define default-keyboard-layout
  (keyboard-layout "us" #:options '("ctrl:swapcaps")))

(define default-kernel   linux)
(define default-initrd   microcode-initrd)
(define default-firmware (list iwlwifi-firmware sof-firmware linux-firmware))

(define default-bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (targets '("/boot/efi"))
   (keyboard-layout default-keyboard-layout)))

(define default-file-systems '())
(define default-swap-devices '())

(define default-users '())

(define default-extra-packages
  (append (map specification->package
               '("openssh"
                 "sway" "waybar" "swaylock" "swayidle" "wlgreet"
                 "xorg-server-xwayland" "alacritty"
                 "pipewire" "wireplumber" "pavucontrol"
                 "wofi" "wl-clipboard" "mako"
                 "network-manager" "network-manager-applet"
                 "brightnessctl" "git"))
          %stumpwm-packages))

(define default-extra-services '())
