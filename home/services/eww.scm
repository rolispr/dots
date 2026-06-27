;;; eww (widget system): package in the home profile, config under ~/.config/eww,
;;; launched from the compositor startups. The style is generated from the theme
;;; (palette + mono font); the .yuck layout and the babashka feeders are curated
;;; files. Returns home-xdg-configuration-files entries.

(define-module (home services eww)
  #:use-module (guix gexp)
  #:use-module (ice-9 format)
  #:use-module (home theme base)
  #:export (eww-style
            eww-capability))

(define (eww-style theme)
  "Return the eww eww.scss contents themed from THEME: a global font and the
vertical bar's rules drawn from the palette."
  (define (c role) (theme-color theme role))
  (define radius (shape-radius (theme-shape theme)))
  (define mono (fonts-mono (theme-fonts theme)))
  (format #f "\
* { all: unset; font-family: ~s; font-size: 13px; }

.bar { background-color: ~a; color: ~a; padding: 8px 0; }

.viewer { color: ~a; font-size: 15px; padding: 4px 8px; }
.picker { color: ~a; font-size: 15px; padding: 4px 8px; }

.workspaces .ws {
  color: ~a;
  background-color: ~a;
  border-radius: ~apx;
  padding: 4px 8px;
  margin: 2px 0;
}
.workspaces .ws.current { color: ~a; background-color: ~a; }

.launch { color: ~a; font-size: 16px; padding: 6px 8px; }
.apps .app { color: ~a; font-size: 16px; padding: 5px 8px; }
.apps .app:hover { color: ~a; }

.icon { color: ~a; font-size: 14px; padding: 0 8px; }

.slider trough {
  background-color: ~a;
  min-width: 6px;
  min-height: 70px;
  border-radius: 4px;
}
.slider trough highlight { background-color: ~a; border-radius: 4px; }

.net { color: ~a; font-size: 14px; padding: 4px 8px; }
.net:hover { color: ~a; }

.power-icon { color: ~a; font-size: 14px; padding: 6px 8px; }
.power-box button { color: ~a; font-size: 14px; padding: 4px 8px; }
.power-box button:hover { color: ~a; }

.clock { color: ~a; margin-top: 8px; }
.clock .hour { font-size: 15px; font-weight: bold; }
.clock .min { color: ~a; font-size: 15px; }

.cal-box { background-color: ~a; border-radius: ~apx; padding: 10px; }
calendar { color: ~a; }
calendar:selected { background-color: ~a; color: ~a; }
"
          mono
          (c 'bg) (c 'fg)
          (c 'accent)
          (c 'cyan)
          (c 'fg-dim) (c 'bg-alt) radius
          (c 'accent-fg) (c 'accent)
          (c 'accent)
          (c 'fg-dim) (c 'accent)
          (c 'cyan)
          (c 'bg-alt) (c 'accent)
          (c 'cyan) (c 'accent)
          (c 'red) (c 'fg-dim) (c 'accent)
          (c 'fg) (c 'fg-dim)
          (c 'bg-alt) radius (c 'fg) (c 'accent) (c 'accent-fg)))

(define (eww-capability theme config-dir)
  "Return home-xdg-configuration-files entries for eww: the themed style, the
curated layout, and the babashka feeders/scripts.  CONFIG-DIR is the dotfiles
config root."
  (define (curated name)
    (list (string-append "eww/" name)
          (local-file (string-append config-dir "/eww/" name))))
  `(("eww/eww.scss"
     ,(plain-file "eww.scss" (eww-style theme)))
    ,(curated "eww.yuck")
    ,(curated "niri-workspaces.bb")
    ,(curated "sys.bb")
    ,(curated "niri-window-switch.bb")
    ,(curated "brightness")
    ,(curated "brightness-set")))
