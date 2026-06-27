;;; wofi (application picker) style generated from a <theme>: GTK CSS with
;;; the window's translucency preserved. Returns home-xdg-configuration-files
;;; entries.

(define-module (home services wofi)
  #:use-module (guix gexp)
  #:use-module (ice-9 format)
  #:use-module (home theme base)
  #:export (wofi-style
            wofi-capability))

(define (wofi-style theme)
  "Return the wofi style.css contents themed from THEME."
  (define (c role) (theme-color theme role))
  (define radius (shape-radius (theme-shape theme)))
  (format #f "\
window {
    background-color: ~a;
    color: ~a;
    border-radius: ~apx;
}

#input {
    background-color: ~a;
    color: ~a;
    border: ~apx solid ~a;
    padding: 8px;
    margin-bottom: 10px;
}

#inner-box, #outer-box, #scroll {
    background-color: ~a;
}

#text {
    color: ~a;
}

#entry {
    background-color: ~a;
    outline: none;
    border: none;
}

#entry:selected, #text:selected {
    background-color: ~a;
    color: ~a;
}
"
          (hex->rgba (c 'bg) 0.9) (c 'fg) radius
          (c 'bg-alt) (c 'fg) (shape-border (theme-shape theme)) (c 'bg-active)
          (c 'bg)
          (c 'fg)
          (c 'bg-alt)
          (c 'accent) (c 'accent-fg)))

(define (wofi-capability theme)
  "Return home-xdg-configuration-files entries for wofi themed from THEME."
  `(("wofi/style.css"
     ,(plain-file "wofi-style.css" (wofi-style theme)))))
