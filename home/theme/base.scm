;;; <theme> record + accessors. Consumers (niri, waybar, …) take a theme
;;; record and pull semantic colors via (theme-color t 'role).

(define-module (home theme base)
  #:use-module (srfi srfi-9)
  #:export (<theme>
            make-theme theme?
            theme-name theme-dark?
            theme-colors theme-color
            theme-emacs-theme theme-gtk-theme
            theme-icon-theme theme-cursor-theme))

(define-record-type <theme>
  (make-theme name dark? colors emacs-theme gtk-theme icon-theme cursor-theme)
  theme?
  (name         theme-name)
  (dark?        theme-dark?)
  (colors       theme-colors)
  (emacs-theme  theme-emacs-theme)
  (gtk-theme    theme-gtk-theme)
  (icon-theme   theme-icon-theme)
  (cursor-theme theme-cursor-theme))

(define (theme-color t k)
  (or (assq-ref (theme-colors t) k)
      (error "unknown theme color" (theme-name t) k)))
