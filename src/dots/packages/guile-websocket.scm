(define-module (dots packages guile-websocket)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (gnu packages guile-xyz))

;; guile-websocket 0.3.0 + master HEAD both have a server-side mask bug:
;; wrap-websocket masks server-to-client frames in violation of RFC 6455,
;; browsers reject with "A server must not mask any frames that it sends
;; to the client." The fix landed upstream in commit 58c8708 ("Default to
;; only masking client sockets.", Apr 11 2026), then the very next commit
;; (c5d77e0 "Deprecate #:mask? arg.") accidentally reintroduced the bug
;; by passing #:mask? server-side? instead of #:mask? mask?.
;; Pinning to 58c8708 — the one-commit window where it works.
(define %commit "58c8708b16dd6e0c6d3ced08cf37ae2c44f50c90")
(define %revision "1")

(define-public guile-websocket-fixed
  (package
    (inherit guile-websocket)
    (name "guile-websocket")
    (version (git-version "0.3.0" %revision %commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git.dthompson.us/guile-websocket.git")
             (commit %commit)))
       (file-name (git-file-name "guile-websocket" version))
       (sha256
        (base32 "0v642499qg7ckjhlanjr26hl8pch47sc7n2r10n4ydsbnmna13f5"))))))
