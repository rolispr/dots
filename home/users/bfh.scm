;; -*- mode: scheme; -*-

(define-module (home users bfh)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services pm)
  #:use-module (gnu home services sound)
  #:use-module (gnu home services desktop)
  #:use-module (gnu packages freedesktop)  ;; For DBus
  #:use-module (gnu home services sound)
  #:use-module (gnu home services xdg)
  #:use-module (gnu home services ssh)
  #:use-module (gnu packages)
  #:use-module (gnu packages glib)
  #:use-module (gnu services)
  #:use-module (home services bash)
  #:use-module (home services emacs)
  #:use-module (home services home-impure-symlinks)
  #:use-module (home services mutable-files)
  )

(define config-dir (string-append (getenv "HOME") "/dots/home/config"))

(home-environment
 (packages
  (specifications->packages
   (list "guile"
         "guile-colorized"
         "guile-readline"
         "coreutils"
         "alacritty"
         ;;"eww" not yet
         "nushell"
         "xz"
         "make"
         "ncurses"
         "pkg-config"
         "vim"
         "mako"
         "libnotify"
         "slurp"
         "grimshot"
         "wl-clipboard"
         "wofi"
         "git"
         "ripgrep"
         "cl-trial"
         "sbcl-trial"
         "fd"
         "jq"
         "awscliv2"
         "font-spleen"
         "font-fira-code"
         "font-jetbrains-mono"
         "font-liberation"
         "font-dejavu"
         "font-google-noto"
         "font-terminus"

         "adwaita-icon-theme"
         "gnome-themes-extra"
         "htop"
         "google-chrome-stable"
         ;;"dot"
         "tmux"
         "curl"
         "wget"

         "llvm@15"
         "gopls"
         "ruby-solargraph"
         "gdb"
         "zlib"
         "sbcl"
         "sbcl-slynk"
         "bind"
         "unzip"
         ;;"wine"
         "zip"
         "godot"
         "rust-analyzer"
         "rust:cargo"
         "node"
         "clojure-tools"
         "clojure"
         "vlc"
         "mosh"
         "rust"
         "elixir"
         "python"
         "automake"
         "autoconf"
         "perl"
         "openjdk@18.0.2:jdk"

         "tree-sitter-python"
         "tree-sitter-markdown"
         "tree-sitter-scheme"
         "tree-sitter-typescript"
         "tree-sitter-javascript"
         "tree-sitter-rust"
         "tree-sitter-ruby"
         "tree-sitter-html"
         "tree-sitter-php"
         "tree-sitter-org"
         "tree-sitter-json"
         "tree-sitter-java"
         "tree-sitter-haskell"
         "tree-sitter-css"
         "tree-sitter-go"
         "tree-sitter-dockerfile"
         "tree-sitter-elixir"
         "tree-sitter-clojure"
         "tree-sitter-cpp"
         "tree-sitter-c"
         "tree-sitter"

         "imagemagick"

         "steam"
         "gimp"
         "aseprite"
         "aspell-dict-en"
         "hunspell-dict-en-us"
         "hunspell"
         "ispell"
         "aspell"
         "leiningen"
         "libvterm"
         "pavucontrol"

         "mupen64plus-ui-console"
         "mupen64plus-core"
         "mupen64plus-audio-sdl"
         "mupen64plus-input-sdl"
         "mupen64plus-video-z64"
         "sicp"
         "sbcl"
	 "lem"
	 "tiled"
         "gammastep"
         "guile-ares-rs"
         "retroarch-assets"
         "libretro-mupen64plus-nx"
         "retroarch"

         "flatpak"

         )))

 (services
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
              ("waybar/style.css"
               ,(local-file (string-append config-dir "/waybar/style.css")))
              ("common-lisp/source-registry.conf.d/guix.conf"
               ,(local-file (string-append config-dir "/common-lisp/source-registry.conf.d/guix.conf")))))

   (service home-mutable-files-service-type)
   (home-bash-service #:config-dir config-dir)
   (service home-dbus-service-type)
   (service home-emacs-config-service-type)
   (service home-pipewire-service-type)
   (service home-ssh-agent-service-type)
   (service home-openssh-service-type
            (home-openssh-configuration
             (add-keys-to-agent "yes")))
   )))
