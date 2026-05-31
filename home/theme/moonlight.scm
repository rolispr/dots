;;; moonlight — derived from the sway palette in
;;; home/config/sway/.config/sway.

(define-module (home theme moonlight)
  #:use-module (home theme base)
  #:export (moonlight))

(define moonlight
  (make-theme
   'moonlight #t
   '((bg-main      . "#212337") (bg-dim       . "#191a2a")
     (bg-alt       . "#222436") (bg-active    . "#2f334d")
     (bg-inactive  . "#1e2030")
     (fg-main      . "#c8d3f5") (fg-dim       . "#828bb8")
     (fg-alt       . "#b4c2f0")
     (border       . "#444a73") (cursor       . "#c8d3f5")
     (selection    . "#2f334d")
     (accent       . "#82aaff") (accent-2     . "#c099ff")
     (red          . "#ff757f") (green        . "#c3e88d")
     (yellow       . "#ffc777") (blue         . "#82aaff")
     (magenta      . "#c099ff") (cyan         . "#b4f9f8"))
   #f
   "Adwaita-dark" "Adwaita" "Adwaita"))
