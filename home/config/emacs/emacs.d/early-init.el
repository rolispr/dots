;; -*- lexical-binding: t -*-
(setq gc-cons-threshold (* 80 1024 1024)
      gc-cons-percentage 0.2
      load-prefer-newer noninteractive
      package-enable-at-startup nil
      native-comp-async-report-warnings-errors nil)
(set-language-environment "UTF-8")
(setq default-input-method nil)
(defvar file-name-handler-alist-old file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'after-init-hook
          #'(lambda ()
              (setq file-name-handler-alist file-name-handler-alist-old)))

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . 0) default-frame-alist)
(setq user-emacs-directory (expand-file-name "~/.config/emacs/"))
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))
