(in-package :lem-user)
;;(setf *default-package* :lem-user)
(lem-vi-mode:vi-mode)

;;(lem-lsp-mode/lsp-mode::define-language-spec
;;    (rust-spec lem-rust-mode:rust-mode)
;;  :language-id "rust"
;;  :root-uri-patterns '("Cargo.toml")
;;  :command '("rls")
;;  :readme-url "https://github.com/joe-re/sql-language-server"
;;  :install-command "rustup component add rust-analyzer"
;;  :connection-mode :stdio)