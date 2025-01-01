;; ~/dots/home/services/bash.scm

(define-module (home services bash)
  #:use-module (gnu services)
  #:use-module (gnu home services shells)
  #:use-module (guix gexp)
  #:export (%wayland-environment-vars
            home-bash-service))

(define %wayland-environment-vars
  '(("XDG_CURRENT_DESKTOP" . "sway")
    ("XDG_SESSION_TYPE" . "wayland")
    ("RTC_USE_PIPEWIRE" . "true")
    ("SDL_VIDEODRIVER" . "wayland")
    ("MOZ_ENABLE_WAYLAND" . "1")
    ("CLUTTER_BACKEND" . "wayland")
    ("ELM_ENGINE" . "wayland_egl")
    ("ECORE_EVAS_ENGINE" . "wayland-egl")
    ("QT_QPA_PLATFORM" . "wayland-egl")
    ("_JAVA_AWT_WM_NONREPARENTING" . "1")))

(define* (home-bash-service #:key (config-dir "~/dots/home/config"))
  "Return a home-bash-service-type with standard configuration"
  (service home-bash-service-type
           (home-bash-configuration
            (aliases '(("ll" . "ls -l")
                       ("la" . "ls -la")
		       ("update-system" . "sudo guix system -L ~/dots reconfigure ~/dots/etc/systems/arraniz.scm")
		       ("update-home" . "guix home -L ~/dots reconfigure ~/dots/home/users/bfh.scm")))
            (environment-variables %wayland-environment-vars)
            (bashrc
             (list (local-file (string-append config-dir "/shell/bashrc"))))
            (bash-profile
             (list (plain-file "bash-profile"
                              "if [ -z $DISPLAY ] && [ $(tty) = /dev/tty1 ]; then exec sway fi"))))))
