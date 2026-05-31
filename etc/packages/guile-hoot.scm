(define-module (etc packages guile-hoot)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (gnu packages guile-xyz)
  #:use-module (etc packages guile-websocket))

;; Hoot 0.8.0 in upstream Guix master is broken with Guile 3.0.11
;; (match-error on `mutable-bytevector?` in hoot/backend.scm:2039).
;; Upstream fix: cb686c3 "Fix Hoot for Guile 3.0.11" (2026-04-03, Wingo).
;; Pinning to main commit 54b0b68 (2026-04-23) which includes that fix.
;;
;; Rewrites guile-websocket → guile-websocket-fixed (commit 58c8708, the
;; one-commit window where server-side masking is correct upstream).
(define %hoot-commit "54b0b68fa7ec246d538e27384d8f6cd02ce89f80")
(define %hoot-revision "3")

;; package-input-rewriting/spec rewrites every reference to guile-websocket
;; in the input graph (including gexp interpolations like #$guile-websocket
;; in build phases) to point at guile-websocket-fixed.
(define rewrite-websocket
  (package-input-rewriting/spec
   `(("guile-websocket" . ,(const guile-websocket-fixed)))))

(define-public guile-hoot-latest
  (rewrite-websocket
   (package
     (inherit guile-hoot)
     (name "guile-hoot")
     (version (git-version "0.8.0" %hoot-revision %hoot-commit))
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://codeberg.org/spritely/hoot.git")
              (commit %hoot-commit)))
        (file-name (git-file-name "guile-hoot" version))
        (sha256
         (base32 "003ha3nq5sfb346ky61v2zxkca8w7189z8fn0g76l9xw71vs5pw4")))))))
