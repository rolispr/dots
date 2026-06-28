;;; Absolute path to the dotfile assets tree (files/ at the repo root),
;;; resolved from the load path so it holds wherever the repo lives -- under
;;; -L src or pulled as a channel. (asset "eww/bar.yuck") -> .../files/eww/bar.yuck.

(define-module (dots assets)
  #:export (asset assets-dir))

(define assets-dir
  (string-append
   (dirname (dirname (dirname (search-path %load-path "dots/assets.scm"))))
   "/files"))

(define (asset rel)
  (string-append assets-dir "/" rel))
