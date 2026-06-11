(define-module (etc packages humbleui)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix search-paths)
  #:use-module (guix build-system copy))

(define %commit "c3eb2ec04fcccb40cc4a3da44ccda0ef3ccacc01")
(define %revision "0")

(define-public humbleui
  (package
    (name "humbleui")
    (version (git-version "0.0.0" %revision %commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/HumbleUI/HumbleUI.git")
             (commit %commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0b69dixxjhpsn1msh18yh298908ka5zws1i7p6zgy3l0ly0cqn64"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("src"       "share/humbleui/src")
          ("resources" "share/humbleui/resources")
          ("deps.edn"  "share/humbleui/deps.edn"))))
    (native-search-paths
     (list (search-path-specification
            (variable "HUMBLEUI_SRC")
            (separator #f)
            (files (list "share/humbleui")))))
    (home-page "https://github.com/HumbleUI/HumbleUI")
    (synopsis "Desktop UI framework for Clojure (source)")
    (description
     "Humble UI is a desktop UI framework for Clojure built on Skija (Skia)
and JWM.  This package installs the Clojure source tree at
@file{share/humbleui} and exports @env{HUMBLEUI_SRC} pointing at it.  Skija
and JWM jars are resolved at runtime by @command{clj} from Maven Central.

To consume from a project, point @code{tools.deps} at the source via
@code{-Sdeps}, e.g.
@example
clj -Sdeps \"{:deps {humbleui/humbleui {:local/root \\\"$HUMBLEUI_SRC\\\"}}}\" \\
    -M -m my.app
@end example")
    (license license:asl2.0)))
