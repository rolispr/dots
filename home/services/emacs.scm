
(define-module (home services emacs)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (home packages emacs)
  #:export (home-emacs-config-service-type))

(define config-dir (string-append (getenv "HOME") "/dots/home/config"))

(define (home-emacs-config-profile-service config)
  (list emacs-pgtk
        emacs-geiser
        emacs-geiser-guile
        emacs-geiser-hoot
        ;; UI Enhancements
        emacs-ef-themes
        emacs-doom-themes
        emacs-catppuccin-theme
        emacs-which-key
        emacs-which-key-posframe
        emacs-posframe
        emacs-doom-modeline
        emacs-hide-mode-line
        emacs-kind-icon
        emacs-nerd-icons
        emacs-fontaine
        emacs-pulsar
        emacs-colorful-mode
        ;; Completion
        emacs-vertico             ; elpaca HEAD breaks (set-local …); use Guix 2.8
        emacs-consult             ; embark-consult needs consult >= 3.2
        emacs-orderless
        emacs-marginalia
        emacs-corfu               ; elpaca HEAD has same set-local bug as vertico
        emacs-cape
        emacs-vertico-posframe
        emacs-embark              ; bundles embark-consult + embark-org
        ;; Evil & Window Management
        emacs-evil
        emacs-evil-collection
        emacs-undo-fu
        emacs-undo-fu-session
        emacs-vundo
        ;; File Management
        emacs-dirvish
        ;; Development Tools
        emacs-magit
        emacs-transient
        emacs-diff-hl
        emacs-apheleia
        emacs-treesit-auto
        emacs-dtrt-indent
        emacs-suggest
        emacs-eros
        emacs-eval-sexp-fu
        emacs-cider-eval-sexp-fu
        emacs-jinx
        emacs-outli
        emacs-guix
        emacs-eat
        emacs-lispy
        emacs-lispyville
        emacs-keycast
        emacs-gptel
        emacs-mcp
        emacs-arei
        ;; Programming Language Support
        emacs-rustic
        emacs-go-mode
        emacs-lua-mode
        emacs-fennel-mode
        emacs-terraform-mode
        emacs-cider
        emacs-web-mode
        emacs-nix-mode
        emacs-ansible
        emacs-flymake-collection
        emacs-rainbow-delimiters
        emacs-ligature
        emacs-highlight
        emacs-highlight-symbol
        emacs-highlight-sexp
        emacs-highlight-numbers
        emacs-highlight-escape-sequences
        emacs-sly
        emacs-sly-asdf
        emacs-org
        emacs-emms))
;;	emacs-super-save))

(define (home-emacs-config-files-service config)
  `(("emacs/early-init.el"
     ,(local-file (string-append config-dir "/emacs/early-init.el")))
    ("emacs/init.el"
     ,(local-file (string-append config-dir "/emacs/init.el")))))
;;  `(("emacs" 
;;     ,(local-file (string-append (getenv "HOME") "/dots/home/config/emacs/emacs.d")
;;		  #:recursive? #t))))

(define home-emacs-config-service-type
  (service-type 
   (name 'home-emacs-config)
   (description "A service for configuring Emacs.")
   (extensions
    (list (service-extension
	       home-profile-service-type
	       home-emacs-config-profile-service)
	      (service-extension
	       home-xdg-configuration-files-service-type
	       home-emacs-config-files-service)))
   (default-value #t)))
