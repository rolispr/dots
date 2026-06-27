;;; <desktop> -- the single declaration of which tools make up the session
;;; and which theme they share. Every config, env var, keybind, and startup
;;; downstream is a function of this record: change a field here and the
;;; whole desktop follows. The launch-command mapping lives in one place so
;;; a keybind and the env agree on what "the terminal" means.

(define-module (home desktop)
  #:use-module (guix records)
  #:use-module (ice-9 match)
  #:use-module (home theme base)
  #:use-module (home theme ef-dream)
  #:export (desktop desktop?
            desktop-compositor desktop-bar desktop-picker
            desktop-terminal desktop-editor desktop-theme
            desktop-xdg-name
            desktop-launch-terminal desktop-launch-picker
            desktop-launch-editor desktop-launch-bar
            desktop-launch-compositor
            desktop-editor-command
            default-desktop))

(define-record-type* <desktop> desktop make-desktop
  desktop?
  (compositor desktop-compositor (default 'niri))
  (bar        desktop-bar        (default 'waybar))
  (picker     desktop-picker     (default 'wofi))
  (terminal   desktop-terminal   (default 'alacritty))
  (editor     desktop-editor     (default 'emacs))
  (theme      desktop-theme      (default ef-dream)))

(define (desktop-xdg-name d)
  "Return the XDG_CURRENT_DESKTOP value for D's compositor."
  (symbol->string (desktop-compositor d)))

(define (desktop-launch-terminal d)
  "Return the shell command that opens D's terminal."
  (match (desktop-terminal d)
    ('alacritty "alacritty")
    (other (symbol->string other))))

(define (desktop-launch-picker d)
  "Return the shell command that opens D's application picker."
  (match (desktop-picker d)
    ('wofi "wofi --show=drun")
    ('rofi "rofi -show drun")
    (other (symbol->string other))))

(define (desktop-launch-editor d)
  "Return the shell command that opens D's editor as a window."
  (match (desktop-editor d)
    ('emacs "emacsclient -c -a emacs")
    (other (symbol->string other))))

(define (desktop-editor-command d)
  "Return the EDITOR/VISUAL value for D's editor (a terminal-capable
command suitable for tools that spawn $EDITOR)."
  (match (desktop-editor d)
    ('emacs "emacsclient -ca emacs")
    (other (symbol->string other))))

(define (desktop-launch-bar d)
  "Return the shell command that starts D's status bar."
  (symbol->string (desktop-bar d)))

(define (desktop-launch-compositor d)
  "Return the command that starts D's compositor as a login session, used
by the bare-tty1 fallback when no display manager handed off a session."
  (match (desktop-compositor d)
    ('niri "niri --session")
    ('sway "sway")
    (other (symbol->string other))))

(define default-desktop
  (desktop
   (compositor 'niri)
   (bar        'waybar)
   (picker     'wofi)
   (terminal   'alacritty)
   (editor     'emacs)
   (theme      ef-dream)))
