;;; Home defaults. The one home-environment form in home/config.scm
;;; reads every field via (home-setting 'key). Hosts override via
;;; (home-overrides) in per-host/<host>/home.scm.

(define-module (home defaults)
  #:use-module (gnu packages)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services ssh)
  #:use-module (gnu home services sound)
  #:use-module (gnu home services xdg)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (home services bash)
  #:use-module (home services emacs)
  #:use-module (home services niri)
  #:use-module (home theme base)
  #:use-module (home theme ef-dream)
  #:use-module (etc packages claude-code)
  #:use-module (etc packages claude-agent-acp)
  #:use-module (etc packages qwen-code)
  #:export (default-extra-packages default-packages default-services
            default-theme
            default-niri-keyboard-layout
            default-niri-xkb-options)
  #:re-export (default-niri-bindings
               default-niri-startups))

;; Host-specific additions go in (home-overrides). Empty default.
(define default-extra-packages '())

;; Theme — drives focus-ring colors in niri and is available to any
;; future capability that consumes a <theme> record.
(define default-theme ef-dream)

;; Niri inputs. xkb-options matches what your sway uses today.
(define default-niri-keyboard-layout "us")
(define default-niri-xkb-options "ctrl:swapcaps")

;; Niri keybinds and autostart programs are defined alongside the
;; service in (home services niri); these names keep the settings
;; layer uniform with everything else.
;; default-niri-bindings, default-niri-startups — imported above.


;; Always-present home packages for bfh.
(define default-packages
  (append (list claude-code claude-agent-acp qwen-code)
          (specifications->packages
           (list "guile" "guile-colorized" "guile-readline"
                 "coreutils" "alacritty" "nushell" "xz" "make" "ncurses"
                 "pkg-config" "vim" "mako" "libnotify" "slurp" "grimshot"
                 "wl-clipboard" "wofi" "git" "ripgrep" "cl-trial"
                 "sbcl-trial" "fd" "jq" "font-spleen" "font-fira-code"
                 "font-jetbrains-mono" "font-liberation" "font-dejavu"
                 "font-google-noto" "font-terminus" "adwaita-icon-theme"
                 "gnome-themes-extra" "htop" "tmux" "curl" "wget"
                 "llvm@15" "gopls" "ruby-solargraph" "gdb" "zlib" "sbcl"
                 "sbcl-slynk" "bind" "unzip" "zip" "godot" "rust-analyzer"
                 "rust:cargo" "node" "clojure-tools" "clojure"
                 "clj-kondo" "clojure-lsp" "man-db" "vlc" "mosh"
                 "rust" "elixir" "python" "automake" "autoconf" "perl"
                 "openjdk@18.0.2:jdk"
                 "tree-sitter-python" "tree-sitter-markdown"
                 "tree-sitter-scheme" "tree-sitter-typescript"
                 "tree-sitter-javascript" "tree-sitter-rust"
                 "tree-sitter-ruby" "tree-sitter-html" "tree-sitter-php"
                 "tree-sitter-org" "tree-sitter-json" "tree-sitter-java"
                 "tree-sitter-haskell" "tree-sitter-css" "tree-sitter-go"
                 "tree-sitter-dockerfile" "tree-sitter-elixir"
                 "tree-sitter-clojure" "tree-sitter-cpp" "tree-sitter-c"
                 "tree-sitter" "imagemagick" "niri" "gimp"
                 "aspell-dict-en" "hunspell-dict-en-us" "hunspell" "ispell"
                 "aspell" "leiningen" "libvterm" "pavucontrol"
                 "mupen64plus-ui-console" "mupen64plus-core"
                 "mupen64plus-audio-sdl" "mupen64plus-input-sdl"
                 "mupen64plus-video-z64" "book-sicp" "lem" "tiled"
                 "gammastep" "guile-ares-rs" "retroarch-assets"
                 "libretro-mupen64plus-nx" "retroarch" "flatpak"))))

(define default-services
  (let ((config-dir (string-append (getenv "HOME") "/dots/home/config")))
    (list
     (service home-xdg-configuration-files-service-type
              `(("sway/config"
                 ,(local-file (string-append config-dir "/sway/.config/sway")))
                ("eww/eww.yuck"
                 ,(local-file (string-append config-dir "/eww/eww.yuck")))
                ("eww/eww.scss"
                 ,(local-file (string-append config-dir "/eww/eww.scss")))
                ("alacritty/alacritty.toml"
                 ,(local-file (string-append config-dir "/alacritty/.config/alacritty/alacritty.toml")))
                ("wezterm/wezterm.lua"
                 ,(local-file (string-append config-dir "/wezterm/.config/wezterm/wezterm.lua")))
                ("waybar/config"
                 ,(local-file (string-append config-dir "/waybar/waybar")))
                ("wofi/style.css"
                 ,(local-file (string-append config-dir "/wofi/style.css")))
                ("vim/config"
                 ,(local-file (string-append config-dir "/vim/.config/vim")))
                ("waybar/style.css"
                 ,(local-file (string-append config-dir "/waybar/style.css")))
                ("common-lisp/source-registry.conf.d/guix.conf"
                 ,(local-file (string-append config-dir "/common-lisp/source-registry.conf.d/guix.conf")))
                ,@(niri-capability
                   #:theme           default-theme
                   #:keyboard-layout default-niri-keyboard-layout
                   #:xkb-options     default-niri-xkb-options
                   #:bindings        default-niri-bindings
                   #:startups        default-niri-startups)))
     (home-bash-service #:config-dir config-dir)
     (service home-dbus-service-type)
     (service home-emacs-config-service-type)
     (service home-pipewire-service-type)
     (service home-ssh-agent-service-type)
     (service home-openssh-service-type
              (home-openssh-configuration
               (add-keys-to-agent "yes"))))))
