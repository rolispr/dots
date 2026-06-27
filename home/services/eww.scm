;;; eww (widget system) integrated like the other tools: package in the home
;;; profile, config under ~/.config/eww, launched from the compositor startups.
;;; The style is generated from the theme (palette + mono font); the .yuck
;;; layout and the data feeder scripts are curated files. Returns
;;; home-xdg-configuration-files entries.

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

.launcher { color: ~a; font-size: 18px; padding: 6px 0; }

.workspaces .ws {
  color: ~a;
  background-color: ~a;
  border-radius: ~apx;
  min-width: 26px;
  min-height: 26px;
  margin: 2px 0;
}
.workspaces .ws.current { color: ~a; background-color: ~a; }

.clock { color: ~a; margin: 10px 0; }
.clock .hour { font-size: 16px; font-weight: bold; }
.clock .min { color: ~a; font-size: 16px; }

.control .metric { margin: 3px 0; }
.control .icon { color: ~a; font-size: 14px; }
.control .val { color: ~a; font-size: 11px; }

.lock { color: ~a; font-size: 16px; padding: 6px 0; }
"
          mono
          (c 'bg) (c 'fg)
          (c 'accent)
          (c 'fg-dim) (c 'bg-alt) radius
          (c 'accent-fg) (c 'accent)
          (c 'fg)
          (c 'fg-dim)
          (c 'cyan)
          (c 'fg-dim)
          (c 'red)))

(define (eww-capability theme config-dir)
  "Return home-xdg-configuration-files entries for eww: the themed style, the
curated layout, and the data feeders.  CONFIG-DIR is the dotfiles config root."
  (define (curated name)
    (list (string-append "eww/" name)
          (local-file (string-append config-dir "/eww/" name))))
  `(("eww/eww.scss"
     ,(plain-file "eww.scss" (eww-style theme)))
    ,(curated "eww.yuck")
    ,(curated "niri-workspaces.bb")
    ,(curated "volume")
    ,(curated "brightness")
    ,(curated "battery")))
