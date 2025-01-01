(define-module (home services emacs)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu packages emacs)
  #:use-module (home packages emacs)
  #:export (home-emacs-config-service-type))

(define (home-emacs-config-profile-service config)
  (list emacs-next-pgtk       ;; Changed from emacs to emacs-next-pgtk since that's what you use
	emacs-geiser
	emacs-ef-themes
	emacs-doom-themes
	emacs-vertico
	emacs-vertico-posframe
	emacs-corfu
	emacs-orderless
	emacs-embark
	emacs-mini-echo
	emacs-guix
	emacs-eat
	emacs-geiser-guile
	emacs-evil
	emacs-lispy
	emacs-lispyville
	emacs-keycast
	emacs-evil-collection
	emacs-vundo
	emacs-vim-tab-bar
	emacs-cape
	emacs-marginalia
	emacs-git-gutter
	emacs-git-gutter-fringe
	emacs-tabspaces
	emacs-kind-icon
	emacs-nerd-icons
	emacs-all-the-icons
	emacs-all-the-icons-dired
	emacs-all-the-icons-completion
	emacs-rainbow-delimiters
	emacs-ligature
	emacs-highlight
	emacs-highlight-symbol
	emacs-highlight-sexp
	emacs-highlight-numbers
	emacs-highlight-escape-sequences
	emacs-rustic
	emacs-go-mode
	emacs-lua-mode
	emacs-terraform-mode
	emacs-fennel-mode
	emacs-cider-mode
	emacs-css-mode
	emacs-web-mode
	emacs-sly
	emacs-sly-asdf
	emacs-ansible
	emacs-org
	emacs-emms
	emacs-dirvish
	emacs-dired-subtree
	emacs-magit
	emacs-super-save))

(define (home-emacs-config-files-service config)
  `(("emacs" 
     ,(local-file (string-append (getenv "HOME") "/dots/home/config/emacs/.emacs.d")
		  #:recursive? #t))))

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

