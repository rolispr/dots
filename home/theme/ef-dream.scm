;;; ef-dream — extracted from Protesilaos's ef-themes 2.1.0
;;; via: emacs --batch --eval "(load \"ef-dream-theme\") (pp ef-dream-palette)"

(define-module (home theme ef-dream)
  #:use-module (home theme base)
  #:export (ef-dream))

(define ef-dream
  (make-theme
   'ef-dream #t
   '((bg-main      . "#232025") (bg-dim       . "#322f34")
     (bg-alt       . "#3b393e") (bg-active    . "#5b595e")
     (bg-inactive  . "#2a272c")
     (fg-main      . "#efd5c5") (fg-dim       . "#8f8886")
     (fg-alt       . "#b0a0cf")
     (border       . "#635850") (cursor       . "#f3c09a")
     (selection    . "#544a50")
     (accent       . "#675072") (accent-2     . "#b0a0cf")
     (red          . "#ff6f6f") (green        . "#51b04f")
     (yellow       . "#c0b24f") (blue         . "#57b0ff")
     (magenta      . "#ffaacf") (cyan         . "#6fb3c0"))
   "ef-dream"
   "Adwaita-dark" "Adwaita" "Adwaita"))
