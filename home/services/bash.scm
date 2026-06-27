;; ~/dots/home/services/bash.scm

(define-module (home services bash)
  #:use-module (gnu services)
  #:use-module (gnu home services shells)
  #:use-module (guix gexp)
  #:use-module (ice-9 format)
  #:use-module (home desktop)
  #:export (%wayland-environment-vars
            home-bash-service))

;; Compositor-agnostic Wayland hints, safe in every shell. The session
;; identity (XDG_CURRENT_DESKTOP, XDG_SESSION_TYPE) is deliberately absent:
;; it is owned by whatever started the session -- a GDM .desktop entry, or
;; the tty1 fallback below -- not by the interactive shell.
(define %wayland-environment-vars
  '(("RTC_USE_PIPEWIRE" . "true")
    ("SDL_VIDEODRIVER" . "wayland")
    ("MOZ_ENABLE_WAYLAND" . "1")
    ("CLUTTER_BACKEND" . "wayland")
    ("ELM_ENGINE" . "wayland_egl")
    ("ECORE_EVAS_ENGINE" . "wayland-egl")
    ("QT_QPA_PLATFORM" . "wayland-egl")
    ("_JAVA_AWT_WM_NONREPARENTING" . "1")))

(define (bash-profile-script desktop)
  "Return the bash-profile contents.  On a bare tty1 login -- no display
manager handing off a session -- set the session identity that path lacks
and start DESKTOP's compositor."
  (if desktop
      (format #f "\
if [ -z \"$DISPLAY\" ] && [ \"$(tty)\" = /dev/tty1 ]; then
    export XDG_CURRENT_DESKTOP=~a
    export XDG_SESSION_TYPE=wayland
    exec ~a
fi
"
              (desktop-xdg-name desktop)
              (desktop-launch-compositor desktop))
      ""))

(define* (home-bash-service #:key (config-dir "~/dots/home/config") desktop)
  "Return a home-bash-service-type with standard configuration.  When
DESKTOP is given, export EDITOR, VISUAL, and TERMINAL derived from it."
  (service home-bash-service-type
           (home-bash-configuration
            (aliases '(("ll" . "ls -l")
                       ("la" . "ls -la")
		       ("update-system" . "sudo -E guix system -L ~/dots reconfigure ~/dots/etc/systems/config.scm")
		       ("update-home" . "guix home -L ~/dots reconfigure ~/dots/home/config.scm")))
            (environment-variables
             (append %wayland-environment-vars
                     (if desktop
                         `(("EDITOR"   . ,(desktop-editor-command desktop))
                           ("VISUAL"   . ,(desktop-editor-command desktop))
                           ("TERMINAL" . ,(desktop-launch-terminal desktop)))
                         '())))
            (bashrc
             (list (local-file (string-append config-dir "/shell/bashrc"))))
            (bash-profile
             (list (plain-file "bash-profile"
                               (bash-profile-script desktop)))))))
