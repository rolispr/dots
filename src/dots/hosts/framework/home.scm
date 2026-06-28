;;; Framework home overrides — consumed by (home-setting 'key).
;;; Framework is the LLM host, so the llama-cpp server lives here.

(define-module (dots hosts framework home)
  #:use-module (gnu packages)
  #:use-module (dots packages opentofu)
  #:use-module (dots packages litestream)
  #:export (override-extra-packages))

(define override-extra-packages
  (list (specification->package "llama-cpp")
        opentofu
        litestream
        (specification->package "virt-manager")
        (specification->package "virt-viewer")
        (specification->package "libvirt")    ; brings virsh CLI
        (specification->package "mkcert")
        (specification->package "wezterm")
        (specification->package "github-cli")
        (specification->package "awscli")))
