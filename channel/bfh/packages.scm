;;; The 'bfh' channel's package surface.
;;;
;;; This module re-exports custom package definitions kept under
;;; ~/dots/etc/packages/ so they're addressable as one entry point.
;;; Cuirass on the builder VM walks this module to emit one job per
;;; re-export (see build-aux/cuirass-jobs.scm).
;;;
;;; Note: re-exporting from (etc packages …) means anyone consuming
;;; this channel via `guix pull` needs the dots load path available.
;;; In practice that's not how it's used today — `guix install -L ~/dots`
;;; on framework/arraniz already finds these packages directly. The
;;; channel exists to give Cuirass a single anchor for substitute builds.

(define-module (bfh packages)
  #:use-module (etc packages stumpwm)
  #:use-module (etc packages guile-hoot)
  #:use-module (etc packages guile-websocket)
  #:use-module (etc packages claude-code)
  #:use-module (etc packages qwen-code)
  #:use-module (etc packages llama-cpp)
  #:use-module (etc packages opentofu)
  #:use-module (etc packages litestream)
  #:use-module (etc packages brogue-ce)
  #:re-export (stumpwm-dev
               stumpwm-dev+servers
               cl-stumpwm-dev
               guile-hoot-latest
               guile-websocket-fixed
               claude-code
               qwen-code
               llama-cpp-latest
               opentofu
               litestream
               brogue-ce))
