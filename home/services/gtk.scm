;;; GTK theming generated from a <theme>. We do not author a full theme; we
;;; override the named colour tokens GTK3 and libadwaita already expose, in the
;;; user gtk.css, plus settings.ini for dark preference, icons, cursor, and
;;; font. One palette skins every GTK app to match the rest of the desktop.

(define-module (home services gtk)
  #:use-module (guix gexp)
  #:use-module (ice-9 format)
  #:use-module (home theme base)
  #:export (gtk-settings
            gtk3-css
            gtk4-css
            gtk-capability))

(define (gtk-settings theme)
  "Return settings.ini contents: dark preference, icon/cursor themes, and the
UI font, from THEME."
  (define f (theme-fonts theme))
  (format #f "\
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=~a
gtk-icon-theme-name=~a
gtk-cursor-theme-name=~a
gtk-font-name=~a ~a
"
          (theme-gtk theme) (theme-icons theme) (theme-cursor theme)
          (fonts-sans f) (fonts-size f)))

(define (gtk3-css theme)
  "Return gtk-3.0/gtk.css: override GTK3's named theme colours from THEME."
  (define (c role) (theme-color theme role))
  (format #f "\
@define-color theme_bg_color ~a;
@define-color theme_base_color ~a;
@define-color theme_fg_color ~a;
@define-color theme_text_color ~a;
@define-color theme_selected_bg_color ~a;
@define-color theme_selected_fg_color ~a;
@define-color insensitive_bg_color ~a;
@define-color insensitive_fg_color ~a;
@define-color borders ~a;
@define-color warning_color ~a;
@define-color error_color ~a;
@define-color success_color ~a;
"
          (c 'bg) (c 'bg-dim) (c 'fg) (c 'fg)
          (c 'accent) (c 'accent-fg)
          (c 'bg-dim) (c 'fg-dim) (c 'border)
          (c 'yellow) (c 'red) (c 'green)))

(define (gtk4-css theme)
  "Return gtk-4.0/gtk.css: override libadwaita's named colours from THEME, so
GTK4 apps follow the palette within libadwaita's structure."
  (define (c role) (theme-color theme role))
  (format #f "\
@define-color window_bg_color ~a;
@define-color window_fg_color ~a;
@define-color view_bg_color ~a;
@define-color view_fg_color ~a;
@define-color headerbar_bg_color ~a;
@define-color headerbar_fg_color ~a;
@define-color sidebar_bg_color ~a;
@define-color sidebar_fg_color ~a;
@define-color card_bg_color ~a;
@define-color card_fg_color ~a;
@define-color popover_bg_color ~a;
@define-color popover_fg_color ~a;
@define-color dialog_bg_color ~a;
@define-color dialog_fg_color ~a;
@define-color accent_bg_color ~a;
@define-color accent_fg_color ~a;
@define-color accent_color ~a;
@define-color destructive_bg_color ~a;
@define-color success_color ~a;
@define-color warning_color ~a;
@define-color error_color ~a;
"
          (c 'bg) (c 'fg)
          (c 'bg-dim) (c 'fg)
          (c 'bg-alt) (c 'fg)
          (c 'bg-dim) (c 'fg)
          (c 'bg-alt) (c 'fg)
          (c 'bg-alt) (c 'fg)
          (c 'bg-alt) (c 'fg)
          (c 'accent) (c 'accent-fg) (c 'fg-alt)
          (c 'red) (c 'green) (c 'yellow) (c 'red)))

(define (gtk-capability theme)
  "Return home-xdg-configuration-files entries that skin GTK3 and GTK4 apps
from THEME."
  (define settings (gtk-settings theme))
  `(("gtk-3.0/settings.ini" ,(plain-file "gtk3-settings.ini" settings))
    ("gtk-3.0/gtk.css"       ,(plain-file "gtk3.css" (gtk3-css theme)))
    ("gtk-4.0/settings.ini"  ,(plain-file "gtk4-settings.ini" settings))
    ("gtk-4.0/gtk.css"       ,(plain-file "gtk4.css" (gtk4-css theme)))))
