;;; alacritty config generated from a <theme>: the full 16-colour ANSI
;;; palette plus primary background/foreground, cursor, and the theme's
;;; mono font. Returns home-xdg-configuration-files entries.

(define-module (home services alacritty)
  #:use-module (guix gexp)
  #:use-module (ice-9 format)
  #:use-module (home theme base)
  #:export (alacritty-config
            alacritty-capability))

(define (alacritty-config theme)
  "Return the alacritty.toml contents themed from THEME."
  (define (c role) (theme-color theme role))
  (define font (theme-fonts theme))
  (format #f "\
[font]
size = ~a
[font.normal]
family = ~s

[colors.primary]
background = ~s
foreground = ~s

[colors.cursor]
text = ~s
cursor = ~s

[colors.normal]
black = ~s
red = ~s
green = ~s
yellow = ~s
blue = ~s
magenta = ~s
cyan = ~s
white = ~s

[colors.bright]
black = ~s
red = ~s
green = ~s
yellow = ~s
blue = ~s
magenta = ~s
cyan = ~s
white = ~s
"
          (fonts-size font) (fonts-mono font)
          (c 'bg) (c 'fg)
          (c 'bg) (c 'cursor)
          (c 'black) (c 'red) (c 'green) (c 'yellow)
          (c 'blue) (c 'magenta) (c 'cyan) (c 'white)
          (c 'bright-black) (c 'bright-red) (c 'bright-green) (c 'bright-yellow)
          (c 'bright-blue) (c 'bright-magenta) (c 'bright-cyan) (c 'bright-white)))

(define (alacritty-capability theme)
  "Return home-xdg-configuration-files entries for alacritty themed from
THEME."
  `(("alacritty/alacritty.toml"
     ,(plain-file "alacritty.toml" (alacritty-config theme)))))
