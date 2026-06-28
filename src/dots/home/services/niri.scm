;;; Niri configuration emitted as KDL via a small Lisp DSL.
;;; Adapted from SSS's (sss niri); palette/i18n deps stripped, theme
;;; consumed as a <theme> record.
;;;
;;; Entry point: (niri-capability #:theme … #:keyboard-layout … …)
;;; returns a list of (path plain-file) pairs suitable for splicing
;;; into home-xdg-configuration-files-service-type.

(define-module (dots home services niri)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 format)
  #:use-module (guix gexp)
  #:use-module (dots theme base)
  #:use-module (dots home desktop)
  #:export (niri-capability
            niri-config
            serialize-kdl
            <rule> make-rule rule? rul
            rule-selector rule-declarations
            <declaration> make-declaration declaration? dec
            declaration-property declaration-value
            <declaration-prop> make-declaration-prop declaration-prop? prop
            declaration-prop-props
            bnd serialize-bindings
            default-niri-bindings
            default-niri-startups
            default-niri-xkb-options))


;;; KDL record types

(define-record-type <rule>
  (make-rule selector declarations) rule?
  (selector     rule-selector)
  (declarations rule-declarations))

(define-record-type <declaration>
  (make-declaration property value) declaration?
  (property declaration-property)
  (value    declaration-value))

(define-record-type <declaration-prop>
  (make-declaration-prop props) declaration-prop?
  (props declaration-prop-props))

(define dec  make-declaration)
(define prop make-declaration-prop)

(define (flatten-list xs)
  (cond ((null? xs) '())
        ((pair? xs) (append (flatten-list (car xs))
                            (flatten-list (cdr xs))))
        (else (list xs))))

(define (rul selector . args)
  (make-rule selector (flatten-list args)))


;;; spawn helpers — emit the KDL command literally

(define (spawn-sh cmd)
  (format #f "spawn-sh \"~a\"" cmd))

(define (spawn-sh-at-startup cmd)
  (format #f "spawn-sh-at-startup \"~a\"" cmd))


;;; bindings

(define* (bnd #:key (mod "") bind cmd
              (allow-when-locked? #f)
              (allow-inhibiting? #t))
  `((mod . ,mod) (bind . ,bind) (cmd . ,cmd)
    (allow-when-locked? . ,allow-when-locked?)
    (allow-inhibiting? . ,allow-inhibiting?)))

(define (serialize-bindings xs)
  (string-join
   (map (lambda (b)
          (let ((mod      (assq-ref b 'mod))
                (bind     (assq-ref b 'bind))
                (cmd      (assq-ref b 'cmd))
                (locked?  (assq-ref b 'allow-when-locked?))
                (inhibit? (assq-ref b 'allow-inhibiting?)))
            (format #f "~a~a~a~a{ ~a; }"
                    mod
                    (cond ((not bind) "")
                          ((string=? mod "") bind)
                          (else (string-append "+" bind)))
                    (if locked?  " allow-when-locked=true "  " ")
                    (if (not inhibit?) " allow-inhibiting=false " " ")
                    cmd)))
        xs)
   "\n  "))


;;; default binding set — niri-native (column model)

(define (desktop-launch-bindings desktop)
  "Return the niri keybindings that launch DESKTOP's terminal, picker, and
editor, so the keys agree with the rest of the session."
  (list
   (bnd #:mod "Mod" #:bind "Return" #:cmd (spawn-sh (desktop-launch-terminal desktop)))
   (bnd #:mod "Mod" #:bind "D"      #:cmd (spawn-sh (desktop-launch-picker desktop)))
   (bnd #:mod "Mod" #:bind "E"      #:cmd (spawn-sh (desktop-launch-editor desktop)))))

(define %niri-base-bindings
  (list
   ;; session
   (bnd #:mod "Mod"       #:bind "Q" #:cmd "close-window")
   (bnd #:mod "Mod+Shift" #:bind "E" #:cmd "quit")
   (bnd #:mod "Mod"       #:bind "O" #:cmd "toggle-overview")
   (bnd #:mod "Mod"       #:bind "W"
        #:cmd (spawn-sh "bash ~/.config/rice/wallpaper"))
   (bnd #:mod "Mod+Shift" #:bind "R"
        #:cmd (spawn-sh "niri msg action load-config-file; eww reload; makoctl reload"))

   ;; focus — Mod+H/L between columns, Mod+J/K within a column
   (bnd #:mod "Mod" #:bind "H" #:cmd "focus-column-left")
   (bnd #:mod "Mod" #:bind "L" #:cmd "focus-column-right")
   (bnd #:mod "Mod" #:bind "J" #:cmd "focus-window-down")
   (bnd #:mod "Mod" #:bind "K" #:cmd "focus-window-up")

   ;; move
   (bnd #:mod "Mod+Shift" #:bind "H" #:cmd "move-column-left")
   (bnd #:mod "Mod+Shift" #:bind "L" #:cmd "move-column-right")
   (bnd #:mod "Mod+Shift" #:bind "J" #:cmd "move-window-down")
   (bnd #:mod "Mod+Shift" #:bind "K" #:cmd "move-window-up")

   ;; column composition
   (bnd #:mod "Mod" #:bind "comma"  #:cmd "consume-window-into-column")
   (bnd #:mod "Mod" #:bind "period" #:cmd "expel-window-from-column")
   (bnd #:mod "Mod" #:bind "C"      #:cmd "center-column")

   ;; column width / fullscreen
   (bnd #:mod "Mod"       #:bind "R"     #:cmd "switch-preset-column-width")
   (bnd #:mod "Mod"       #:bind "F"     #:cmd "maximize-column")
   (bnd #:mod "Mod+Shift" #:bind "F"     #:cmd "fullscreen-window")
   (bnd #:mod "Mod"       #:bind "minus" #:cmd "set-column-width \"-10%\"")
   (bnd #:mod "Mod"       #:bind "equal" #:cmd "set-column-width \"+10%\"")

   ;; floating
   (bnd #:mod "Mod"       #:bind "space" #:cmd "toggle-window-floating")
   (bnd #:mod "Mod+Shift" #:bind "space" #:cmd "switch-focus-between-floating-and-tiling")

   ;; workspace cycle
   (bnd #:mod "Mod" #:bind "Page_Down" #:cmd "focus-workspace-down")
   (bnd #:mod "Mod" #:bind "Page_Up"   #:cmd "focus-workspace-up")

   ;; screenshot
   (bnd                   #:bind "Print" #:cmd "screenshot")
   (bnd #:mod "Mod"       #:bind "Print" #:cmd "screenshot-screen")
   (bnd #:mod "Mod+Shift" #:bind "Print" #:cmd "screenshot-window")

   ;; brightness / audio
   (bnd #:bind "XF86MonBrightnessUp"
        #:cmd (spawn-sh "brightnessctl s +10%")
        #:allow-when-locked? #t)
   (bnd #:bind "XF86MonBrightnessDown"
        #:cmd (spawn-sh "brightnessctl s 10%-")
        #:allow-when-locked? #t)
   (bnd #:bind "XF86AudioRaiseVolume"
        #:cmd (spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
        #:allow-when-locked? #t)
   (bnd #:bind "XF86AudioLowerVolume"
        #:cmd (spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
        #:allow-when-locked? #t)
   (bnd #:bind "XF86AudioMute"
        #:cmd (spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        #:allow-when-locked? #t)))

(define (numbered-workspace-bindings)
  (append-map
   (lambda (n)
     (let ((k (if (= n 10) "0" (number->string n))))
       (list
        (bnd #:mod "Mod"       #:bind k
             #:cmd (format #f "focus-workspace ~a" n))
        (bnd #:mod "Mod+Shift" #:bind k
             #:cmd (format #f "move-column-to-workspace ~a" n)))))
   (iota 10 1)))

(define default-niri-bindings
  (append (desktop-launch-bindings default-desktop)
          %niri-base-bindings
          (numbered-workspace-bindings)))


;;; default startup commands and xkb options

(define default-niri-startups
  (list (desktop-launch-bar default-desktop)
        "mako"
        (format #f "dbus-update-activation-environment --systemd \
WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=~a"
                (desktop-xdg-name default-desktop))
        ;; rebind the emacs daemon (a home shepherd service) to THIS session's
        ;; Wayland display -- the persistent shepherd doesn't restart on login,
        ;; and pgtk Emacs needs the live display to make GUI frames.
        "herd restart emacs-daemon"
        "bash ~/.config/rice/wallpaper"))

(define default-niri-xkb-options "ctrl:swapcaps")


;;; config sections

(define* (niri-input-config #:key keyboard-layout xkb-options)
  (rul 'input
       (rul 'keyboard
            (rul 'xkb
                 (dec 'layout  keyboard-layout)
                 (dec 'options (or xkb-options ""))))
       (rul 'touchpad
            (dec 'tap #t))
       (dec 'warp-mouse-to-focus #t)))

(define* (niri-layout-config #:key theme)
  (rul 'layout
       (dec 'background-color "transparent")
       (dec 'gaps (shape-gaps (theme-shape theme)))
       (dec 'center-focused-column "never")
       (rul 'preset-column-widths
            (dec 'proportion 0.333333)
            (dec 'proportion 0.5)
            (dec 'proportion 0.666666))
       (rul 'default-column-width
            (dec 'proportion 0.666666))
       (rul 'focus-ring
            (dec 'width (shape-border (theme-shape theme)))
            (dec 'active-color   (theme-color theme 'accent))
            (dec 'inactive-color (theme-color theme 'bg-active)))
       (rul 'shadow
            (dec 'on #t)
            (dec 'softness 30)
            (dec 'spread 5)
            (dec 'offset (prop '((x 0) (y 5))))
            (dec 'color "#0007"))
       (rul 'struts
            (dec 'left 4) (dec 'right 4)
            (dec 'top 4)  (dec 'bottom 4))))

(define* (niri-overview-config #:key theme)
  ;; The zoomed-out view: a deliberate dark field (bg-dim) behind the
  ;; workspace tiles so the surround reads as chrome, not unstyled gray,
  ;; and a shadow on each tile so the wallpaper'd workspaces float.
  (rul 'overview
       (dec 'zoom 0.5)
       (dec 'backdrop-color (theme-color theme 'bg-dim))
       (rul 'workspace-shadow
            (dec 'softness 40)
            (dec 'spread 10)
            (dec 'offset (prop '((x 0) (y 10))))
            (dec 'color "#00000060"))))

(define (niri-intro)
  "// Niri configuration — generated from (dots home services niri).
// Do not edit by hand; edit src/dots/home/services/niri.scm instead.")

(define (serialized-startups xs)
  (string-join (map spawn-sh-at-startup xs) "\n"))

(define* (niri-config #:key theme
                      keyboard-layout
                      xkb-options
                      (bindings '())
                      (startups '()))
  (list (niri-intro)
        (niri-input-config  #:keyboard-layout keyboard-layout
                            #:xkb-options     xkb-options)
        (niri-layout-config #:theme theme)
        (niri-overview-config #:theme theme)
        (rul 'hotkey-overlay (dec 'skip-at-startup #t))
        (dec 'prefer-no-csd #t)
        (dec 'screenshot-path
             "~/pictures/screenshots/screen-%Y-%m-%d-%H-%M-%S.png")
        (rul 'animations (dec 'slowdown 1.0))
        (rul 'binds (serialize-bindings bindings))
        (rul 'window-rule
             (dec 'geometry-corner-radius (shape-radius (theme-shape theme)))
             (dec 'clip-to-geometry 'true)
             (dec 'draw-border-with-background 'false))
        (serialized-startups startups)))


;;; KDL serializer

(define* (serialize-kdl xs #:key (indent ""))
  (let ((new-indent (string-append indent "  ")))
    (cond
     ((list? xs)
      (map (lambda (x) (serialize-kdl x #:indent new-indent)) xs))
     ((rule? xs)
      (format #f "~a {\n~a~a\n~a}"
              (rule-selector xs)
              indent
              (cond
               ((rule? (rule-declarations xs))
                (serialize-kdl (rule-declarations xs) #:indent new-indent))
               ((list? (rule-declarations xs))
                (string-join
                 (map (lambda (xx)
                        (cond ((rule? xx)
                               (serialize-kdl xx #:indent new-indent))
                              ((declaration? xx)
                               (serialize-declaration xx))
                              (else (format #f "~a" xx))))
                      (rule-declarations xs))
                 (string-append "\n" indent)))
               (else (serialize-declaration (rule-declarations xs))))
              (if (>= (string-length indent) 2)
                  (string-drop indent 2)
                  "")))
     ((declaration? xs)
      (serialize-declaration xs))
     (else (format #f "~a" xs)))))

(define (serialize-declaration xs)
  (format #f "~a ~a"
          (declaration-property xs)
          (cond
           ((eq? #t (declaration-value xs)) "")
           ((declaration-prop? (declaration-value xs))
            (string-join (map (lambda (p)
                                (format #f "~a=~a" (car p) (cadr p)))
                              (declaration-prop-props (declaration-value xs)))
                         " "))
           ((string? (declaration-value xs))
            (format #f "\"~a\"" (declaration-value xs)))
           (else (declaration-value xs)))))


;;; the home-files capability

(define* (niri-capability #:key theme
                          keyboard-layout
                          xkb-options
                          (bindings default-niri-bindings)
                          (startups default-niri-startups))
  `(("niri/config.kdl"
     ,(plain-file
       "config.kdl"
       (string-join
        (serialize-kdl
         (niri-config #:theme           theme
                      #:keyboard-layout keyboard-layout
                      #:xkb-options     xkb-options
                      #:bindings        bindings
                      #:startups        startups))
        "\n")))))
