;;; waybar style generated from a <theme>: palette and mono font. The bar's
;;; config (module layout and icon glyphs) stays a curated file -- it carries
;;; no colours -- and its workspace module is set to match the compositor.
;;; Returns a home-xdg-configuration-files entry for the style.

(define-module (home services waybar)
  #:use-module (guix gexp)
  #:use-module (ice-9 format)
  #:use-module (home theme base)
  #:export (waybar-style
            waybar-capability))

(define (waybar-style theme)
  "Return the waybar style.css contents themed from THEME."
  (define (c role) (theme-color theme role))
  (define radius (shape-radius (theme-shape theme)))
  (format #f "\
* {
    font-family: ~s, monospace;
    font-size: 14px;
}

window#waybar {
    background-color: ~a;
    color: ~a;
    transition: background-color 0.2s;
}

#workspaces button {
    background-color: ~a;
    color: ~a;
    padding: 0 10px;
    margin: 4px 2px;
    border-radius: ~apx;
}

#workspaces button.focused, #workspaces button.active {
    background-color: ~a;
    color: ~a;
}

#workspaces button:hover {
    background-color: ~a;
    color: ~a;
}

#clock, #battery {
    background-color: ~a;
    color: ~a;
    padding: 0 10px;
    border-radius: ~apx;
}

#pulseaudio {
    background-color: ~a;
    color: ~a;
    padding: 0 10px;
    border-radius: ~apx;
}

#network {
    background-color: ~a;
    color: ~a;
    padding: 0 10px;
    border-radius: ~apx;
}

#battery.charging {
    color: ~a;
}

#battery.critical:not(.charging) {
    background-color: ~a;
    color: ~a;
}
"
          (fonts-mono (theme-fonts theme))
          (c 'bg) (c 'fg)
          (c 'bg-alt) (c 'fg) radius
          (c 'accent) (c 'accent-fg)
          (c 'bg-active) (c 'bright-white)
          (c 'bg-alt) (c 'green) radius
          (c 'bg-alt) (c 'yellow) radius
          (c 'bg-alt) (c 'cyan) radius
          (c 'bright-green)
          (c 'red) (c 'bright-white)))

(define (waybar-capability theme)
  "Return a home-xdg-configuration-files entry for the waybar style themed
from THEME."
  `(("waybar/style.css"
     ,(plain-file "waybar-style.css" (waybar-style theme)))))
