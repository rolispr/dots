;;; fuzzel (application picker / dmenu) config generated from a <theme>. fuzzel
;;; uses an INI file with RRGGBBAA colours; the palette and mono font are
;;; injected from the theme. Returns home-xdg-configuration-files entries.

(define-module (dots home services fuzzel)
  #:use-module (guix gexp)
  #:use-module (ice-9 format)
  #:use-module (dots theme base)
  #:export (fuzzel-config
            fuzzel-capability))

(define (fuzzel-config theme)
  "Return the fuzzel.ini contents themed from THEME."
  (define (rgba role alpha)
    (string-append (substring (theme-color theme role) 1) alpha))
  (define font (theme-fonts theme))
  (define shape (theme-shape theme))
  (format #f "\
[main]
font=~a:size=~a
prompt=\"  \"
width=32
lines=12
layer=overlay
terminal=alacritty -e

[colors]
background=~a
text=~a
prompt=~a
placeholder=~a
input=~a
match=~a
selection=~a
selection-text=~a
selection-match=~a
counter=~a
border=~a

[border]
width=~a
radius=~a
"
          (fonts-mono font) (fonts-size font)
          (rgba 'bg "e6") (rgba 'fg "ff") (rgba 'accent "ff") (rgba 'fg-dim "ff")
          (rgba 'fg "ff") (rgba 'cyan "ff") (rgba 'accent "ff") (rgba 'accent-fg "ff")
          (rgba 'accent-fg "ff") (rgba 'fg-dim "ff") (rgba 'border "ff")
          (shape-border shape) (shape-radius shape)))

(define (fuzzel-capability theme)
  "Return home-xdg-configuration-files entries for fuzzel themed from THEME."
  `(("fuzzel/fuzzel.ini"
     ,(plain-file "fuzzel.ini" (fuzzel-config theme)))))
