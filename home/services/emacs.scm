
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
  (list emacs-next-pgtk
	emacs-geiser
	;; UI Enhancements
        emacs-ef-themes
	emacs-doom-themes
	emacs-catppuccin-theme
        emacs-which-key
        emacs-which-key-posframe
        emacs-posframe
        emacs-doom-modeline
        emacs-mini-echo
        emacs-kind-icon
        emacs-nerd-icons
;;        emacs-nerd-icons-completion
;;        emacs-vscode-icon
;;        emacs-ligature
;;        emacs-breadcrumb
;;        emacs-ultra-scroll
        ;; Completion
;;        emacs-vertico 
;;        emacs-orderless
;;        emacs-consult
;;        emacs-marginalia
;;        emacs-corfu
;;        emacs-cape
	;; Evil & Window Management
        emacs-evil
        emacs-evil-collection
        emacs-undo-fu
        emacs-undo-fu-session
        emacs-vundo
	;; Dashboard & File Management
;;        emacs-grid not in guix
        emacs-enlight
        emacs-dirvish
	;;        emacs-dired-subtree
	;; Development Tools
        emacs-magit
        emacs-transient
        emacs-git-gutter
        emacs-git-gutter-fringe
;;        emacs-tree-sitter-langs
        emacs-dtrt-indent
        emacs-suggest
        emacs-eros
	emacs-dash
	emacs-guix
	emacs-eat
	emacs-geiser-guile
	emacs-lispy
	emacs-lispyville
	emacs-keycast
	emacs-gptel
	emacs-git-gutter
	emacs-git-gutter-fringe
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
;;        emacs-python
        emacs-flymake-collection
;;	emacs-tabspaces
	emacs-rainbow-delimiters
	emacs-ligature
	emacs-highlight
	emacs-highlight-symbol
	emacs-highlight-sexp
	emacs-highlight-numbers
	emacs-highlight-escape-sequences
	emacs-sly
	emacs-sly-asdf
	emacs-ansible
	emacs-org
	emacs-emms
	emacs-dirvish
;;	emacs-dired-subtree
	emacs-magit
	))
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
