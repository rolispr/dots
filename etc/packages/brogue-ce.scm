(define-module (etc packages brogue-ce)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages sdl))

(define-public brogue-ce
  (package
    (name "brogue-ce")
    (version "1.15.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/tmewett/BrogueCE/archive/refs/tags/v"
             version ".tar.gz"))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "1b5kpyhc4jl28g4clvd7bdypj45bjq8d8ibymnwjqd17adn1ig1a"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:make-flags
      #~(list (string-append "CC=" #$(cc-for-target))
              (string-append "CPPFLAGS=-I"
                             #$(this-package-input "sdl2-image")
                             "/include/SDL2")
              "RELEASE=YES"
              "TERMINAL=YES"
              "GRAPHICS=YES"
              "DATADIR=.")
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (replace 'install
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out      (assoc-ref outputs "out"))
                     (libexec  (string-append out "/libexec/brogue"))
                     (share    (string-append out "/share/brogue"))
                     (bin      (string-append out "/bin"))
                     (apps     (string-append out "/share/applications"))
                     (metainfo (string-append out "/share/metainfo"))
                     (icons    (string-append out "/share/icons/hicolor/256x256/apps"))
                     (bash     (assoc-ref inputs "bash-minimal"))
                     (wrapper  (string-append bin "/brogue")))
                (mkdir-p libexec)
                (install-file "bin/brogue" libexec)
                (mkdir-p share)
                (copy-recursively "bin/assets"
                                  (string-append share "/assets"))
                (install-file "bin/keymap.txt" share)
                (mkdir-p icons)
                (copy-file "bin/assets/icon.png"
                           (string-append icons "/io.github.tmewett.brogue.png"))
                (mkdir-p metainfo)
                (install-file "linux/io.github.tmewett.brogue.metainfo.xml"
                              metainfo)
                (mkdir-p apps)
                (call-with-output-file
                    (string-append apps "/io.github.tmewett.brogue.desktop")
                  (lambda (port)
                    (format port "[Desktop Entry]~%~
                                  Type=Application~%~
                                  Name=Brogue CE~%~
                                  GenericName=Roguelike~%~
                                  Comment=Brave the Dungeons of Doom!~%~
                                  Exec=brogue~%~
                                  Icon=io.github.tmewett.brogue~%~
                                  Terminal=false~%~
                                  Categories=Game;RolePlaying;~%")))
                (mkdir-p bin)
                (call-with-output-file wrapper
                  (lambda (port)
                    (format port "#!~a/bin/bash~%" bash)
                    (format port "set -e~%")
                    (format port "data=\"${XDG_DATA_HOME:-$HOME/.local/share}/brogue\"~%")
                    (format port "mkdir -p \"$data\"~%")
                    (format port "[ -f \"$data/keymap.txt\" ] || \
cp ~a/keymap.txt \"$data/keymap.txt\"~%" share)
                    (format port "cd \"$data\"~%")
                    (format port "exec ~a/brogue --data-dir ~a \"$@\"~%"
                            libexec share)))
                (chmod wrapper #o555)))))))
    (inputs
     (list bash-minimal
           ncurses
           sdl2
           sdl2-image))
    (home-page "https://github.com/tmewett/BrogueCE")
    (synopsis "Brogue Community Edition, a roguelike dungeon crawler")
    (description
     "Brogue is a roguelike game by Brian Walker.  The Community Edition (CE)
is the maintained fork that ships bug fixes, balance changes, and quality of
life improvements.  This package builds the SDL2 graphical client with the
ncurses terminal mode also compiled in (pass @code{--term} to launch in
text mode).  Saves, recordings, scores and your editable @file{keymap.txt}
live under @file{$XDG_DATA_HOME/brogue}; the read-only tile assets are
served from the store via @option{--data-dir}.")
    (license license:agpl3+)))
