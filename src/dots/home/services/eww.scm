;;; eww (widget system): package in the home profile, config under ~/.config/eww,
;;; launched from the compositor startups. The style is generated from the theme
;;; (palette + mono font); the .yuck layout and the babashka feeders are curated
;;; files. Returns home-xdg-configuration-files entries.

(define-module (dots home services eww)
  #:use-module (guix gexp)
  #:use-module (ice-9 format)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (gnu services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu services shepherd)
  #:use-module (dots theme base)
  #:export (eww-style
            eww-capability
            home-eww-broker-service-type))

;;; CSS builders. `d' is one declaration ("prop: val"); `rule' wraps a
;;; selector around declarations; `rules' shares declarations across several
;;; selectors. Colours go inline next to their property -- no positional args.
(define (d prop val) (string-append prop ": " val))
(define (rule sel . decls)
  (string-append sel " {\n  " (string-join decls ";\n  ") ";\n}\n\n"))
(define (rules sels . decls)
  (apply rule (string-join sels ", ") decls))

(define (eww-style-overrides theme)
  "Trailing rules appended after the main sheet so the cascade picks them: the
sidebar reads as frosted glass over the wallpaper instead of a solid slab, and
the echo strip becomes a designed status line with an accent prompt segment."
  (define (c role) (theme-color theme role))
  (string-append
   (rule ".bar"
         (d "background-color" (hex->rgba (c 'bg) 0.72))
         (d "border" (string-append "1px solid " (c 'border)))
         ;; blur only, no spread, kept within the 6px margin so the halo's
         ;; corners stay rounded instead of being clipped square by the surface.
         (d "box-shadow" "0 0 5px 0 #0a0a10"))
   ;; echo: a powerline status line. The strip itself is transparent; only the
   ;; accent cap and the body carry colour, so it reads as a slanted pill that
   ;; ramps out from under the sidebar rather than a full-width box. Left to
   ;; right: lead (transparent, sits under the sidebar) -> tip ( ramps the
   ;; accent up) -> prompt (accent) -> slant ( accent into body) -> body.
   (let ((body (hex->rgba (c 'bg) 0.88))
         (wedge "26px"))                       ; glyph size ~ strip height
     (string-append
      (rule ".echo" (d "background-color" "transparent"))
      ;; the left run that tucks under the sidebar; width >= sidebar + margin
      (rule ".echo-lead" (d "min-width" "70px") (d "background-color" "transparent"))
      ;; leading wedge: accent on transparent, so the cap's left edge is a slant
      (rule ".echo-tip"
            (d "color" (c 'accent)) (d "background-color" "transparent")
            (d "font-size" wedge) (d "margin-right" "-1px"))
      (rule ".echo-prompt"
            (d "background-color" (c 'accent)) (d "color" (c 'accent-fg)))
      (rule ".echo-ico" (d "color" (c 'accent-fg)) (d "font-size" "13px") (d "padding" "0 6px"))
      ;; trailing wedge: accent on the body colour, feeding the cap into the body
      (rule ".echo-slant"
            (d "color" (c 'accent)) (d "background-color" body)
            (d "font-size" wedge) (d "margin" "0 -1px"))
      (rule ".echo-body" (d "background-color" body))
      (rule ".echo-text" (d "color" (c 'fg)) (d "font-size" "13px") (d "padding" "0 12px"))
      (rule ".echo-stat" (d "color" (c 'fg-dim)) (d "font-size" "12px") (d "padding" "0 16px 0 8px"))))))

(define (eww-style theme)
  "Return the eww eww.scss themed from THEME. Read top-down: tunables first,
then bar, popups, and the control panel, each rule self-contained."
  (define (c role) (theme-color theme role))

  ;; --- tunables: change here, not in scattered literals ---------------------
  (define mono     (fonts-mono (theme-fonts theme)))
  (define cell     "40px")   ; bar icon cell: every clickable icon is this wide
  (define cell-pad "9px 0")  ; ... vertical only; width comes from `cell'
  (define cell-rad "12px")
  (define glyph    "16px")   ; uniform bar glyph size
  (define popup-rad "20px")  ; popup window corner
  (define card-rad  "15px")  ; inner card / list / config corner
  (define shadow      "0 2px 6px 2px #0a0a10")
  (define card-shadow "0 2px 3px 2px #06060b")

  (string-append
   ;; reset + global font; transitions on the interactive bits
   (format #f "* { all: unset; font-family: ~s; font-size: 13px; }\n" mono)
   "button, eventbox { transition: background-color 0.25s, color 0.25s; }\n\n"

   ;; ---- bar ----------------------------------------------------------------
   (rule ".bar"
         (d "background-color" (c 'bg)) (d "color" (c 'fg))
         (d "padding" "8px 0") (d "margin" "6px")
         (d "border-radius" "16px") (d "box-shadow" shadow))

   ;; one uniform cell for every clickable bar icon -> a tidy centred column.
   ;; the glyph is centred inside the cell by the ib widget (hexpand label).
   (rules '(".viewer" ".picker" ".launch" ".apps .app" ".icon"
            ".net" ".media" ".ctl" ".workspaces .ws")
          (d "background-color" (c 'bg-alt)) (d "color" (c 'fg-alt))
          (d "min-width" cell) (d "padding" cell-pad)
          (d "border-radius" cell-rad) (d "margin" "3px 0")
          (d "font-size" glyph))
   ;; semantic accents: net = status light; ctl = the system/control panel entry
   (rule ".net" (d "color" (c 'cyan)))
   (rule ".ctl" (d "color" (c 'accent)))
   ;; Per-glyph ink-bearing correction (measured from a screenshot, bar
   ;; center=32). These nerd glyphs each sit at a different x in their advance,
   ;; so no uniform shift aligns them; nudge each to the ~33px column the app
   ;; icons fall on. margin on a centred, hexpanding label shifts it by half.
   (rule ".viewer .bar-glyph" (d "margin-right" "2px"))          ; 33.1 -> 32
   (rule ".picker .bar-glyph" (d "margin-right" "2px"))          ; 33.2
   (rule ".launch .bar-glyph" (d "margin-right" "3px"))          ; 33.5
   (rule ".term .bar-glyph" (d "margin-right" "1px"))            ; 32.5
   (rule ".web .bar-glyph" (d "margin-right" "3px"))             ; 33.6
   (rule ".files .bar-glyph" (d "margin-right" "3px"))           ; 33.3
   (rule ".edit .bar-glyph" (d "margin-right" "6px"))            ; 35.0
   (rule ".icon .bar-glyph" (d "margin-right" "3px"))            ; volume 33.7
   (rule ".media .bar-glyph" (d "margin-right" "5px"))           ; music  34.5
   (rule ".net .bar-glyph" (d "margin-right" "6px"))             ; wifi   35.0
   (rule ".ctl .bar-glyph" (d "margin-right" "4px"))             ; avatar (noisy)
   (rule ".workspaces .ws .bar-glyph" (d "margin-left" "2px"))   ; nums   31.2
   (rule ".workspaces .ws.current"
         (d "color" (c 'accent-fg)) (d "background-color" (c 'accent)))

   (rules '(".viewer:hover" ".picker:hover" ".launch:hover" ".apps .app:hover"
            ".icon:hover" ".net:hover" ".media:hover" ".ctl:hover"
            ".clock:hover" ".workspaces .ws:hover")
          (d "background-color" (c 'bg-active)) (d "color" (c 'accent-fg)))

   (rule ".clock" (d "color" (c 'fg)) (d "margin-top" "6px"))
   ".clock .hour { font-size: 15px; font-weight: bold; }\n"
   (rule ".clock .min" (d "color" (c 'fg-dim)) (d "font-size" "15px"))

   ;; ---- calendar -----------------------------------------------------------
   (rule ".cal-box" (d "background-color" (c 'bg-alt))
         (d "border-radius" card-rad) (d "padding" "10px"))
   (rule "calendar" (d "color" (c 'fg)))
   (rule "calendar:selected" (d "background-color" (c 'accent)) (d "color" (c 'accent-fg)))

   ;; ---- popup chrome shared by every menu ----------------------------------
   (rule ".netmenu"
         (d "background-color" (c 'bg)) (d "color" (c 'fg))
         (d "border-radius" popup-rad) (d "padding" "8px") (d "margin" "8px")
         (d "box-shadow" shadow) (d "min-width" "360px"))

   ;; ---- network menu (card style) ------------------------------------------
   (rule ".nm-card" (d "background-color" (c 'bg-dim)) (d "border-radius" "16px")
         (d "padding" "12px") (d "margin" "6px") (d "box-shadow" card-shadow))
   (rule ".nm-head" (d "padding" "12px 14px"))
   (rule ".nm-head-ico" (d "font-size" "22px") (d "color" (c 'accent)) (d "margin-right" "14px"))
   (rule ".nm-title" (d "font-size" "17px") (d "font-weight" "bold") (d "color" (c 'fg)))
   (rule ".nm-sub" (d "font-size" "13px"))
   (rule ".nm-sub.on" (d "color" (c 'green)))
   (rule ".nm-sub.off" (d "color" (c 'fg-dim)))
   (rule ".nm-list-card" (d "padding" "6px"))
   (rule ".nm-scroll" (d "min-height" "14rem"))
   (rule ".nm-row" (d "background-color" "transparent") (d "border" "none")
         (d "box-shadow" "none") (d "outline" "none")
         (d "border-radius" "12px") (d "padding" "10px 12px") (d "margin" "2px")
         (d "transition" "background-color 0.2s"))
   (rule ".nm-row:hover" (d "background-color" (c 'bg-active)))
   (rule ".nm-row.active" (d "background-color" (c 'bg-alt)))
   (rule ".nm-row.sel" (d "background-color" (c 'bg-active))
         (d "box-shadow" (string-append "inset 3px 0 0 0 " (c 'accent))))
   (rule ".nm-sig" (d "font-size" "14px") (d "color" (c 'fg-dim)))
   (rule ".nm-sig.hi" (d "color" (c 'green)))
   (rule ".nm-sig.mid" (d "color" (c 'yellow)))
   (rule ".nm-sig.lo" (d "color" (c 'red)))
   (rule ".nm-name" (d "font-size" "14px") (d "color" (c 'fg)))
   (rule ".nm-name.active" (d "color" (c 'green)) (d "font-weight" "bold"))
   (rule ".nm-lock" (d "font-size" "12px") (d "color" (c 'fg-dim)))
   (rule ".nm-check" (d "font-size" "13px") (d "color" (c 'green)))
   (rule ".nm-actions" (d "padding" "6px 4px 2px 4px"))
   (rule ".nm-btn" (d "background-color" (c 'bg-active)) (d "color" (c 'fg))
         (d "border" "none") (d "box-shadow" "none") (d "outline" "none")
         (d "padding" "10px 20px") (d "border-radius" "12px")
         (d "transition" "background-color 0.2s, color 0.2s"))
   (rule ".nm-btn:hover" (d "background-color" (c 'bg-alt)))
   (rule ".nm-btn.go" (d "background-color" (c 'accent)) (d "color" (c 'accent-fg)))
   (rule ".nm-btn.no" (d "color" (c 'red)))

   ;; ---- subheader (audio "Output" label) -----------------------------------
   (rule ".nm-subhead" (d "font-size" "13px") (d "color" (c 'fg-dim))
         (d "margin" "2px 4px 8px 4px"))

   ;; ---- sliders shared by the audio + media menus --------------------------
   (rule ".menu-slider trough" (d "background-color" (c 'bg-alt))
         (d "min-height" "8px") (d "border-radius" "5px"))
   (rule ".menu-slider trough highlight" (d "background-color" (c 'accent)) (d "border-radius" "5px"))

   ;; ---- audio menu ---------------------------------------------------------
   (rule ".audio-mute" (d "color" (c 'cyan)) (d "font-size" "20px") (d "padding" "0 4px"))
   (rule ".audio-mute:hover" (d "color" (c 'accent)))
   (rule ".audio-pct" (d "color" (c 'fg-dim)) (d "min-width" "38px"))

   ;; ---- media player (card vocabulary) -------------------------------------
   (rule ".media-info" (d "padding" "2px 2px 12px 2px"))
   (rule ".media-art" (d "min-width" "64px") (d "min-height" "64px")
         (d "border-radius" "12px") (d "background-size" "cover")
         (d "background-position" "center") (d "background-color" (c 'bg-active)))
   (rule ".media-art-ico" (d "font-size" "26px") (d "color" (c 'fg-dim)))
   (rule ".media-title" (d "font-size" "15px") (d "font-weight" "bold") (d "color" (c 'fg)))
   (rule ".media-artist" (d "color" (c 'fg-dim)))
   (rule ".media-times" (d "padding" "6px 2px 2px 2px"))
   (rule ".media-time" (d "font-size" "11px") (d "color" (c 'fg-dim)))
   (rule ".media-ctrl" (d "padding" "10px 0 2px 0"))
   (rule ".media-btn" (d "color" (c 'fg)) (d "font-size" "20px") (d "padding" "6px"))
   (rule ".media-btn:hover" (d "color" (c 'accent)))
   (rule ".media-none-box" (d "padding" "8px"))
   (rule ".media-none" (d "color" (c 'fg-dim)) (d "padding" "14px"))

   ;; ---- control panel: cards (profile / stats / sliders) -------------------
   (rule ".ctlpanel-box" (d "padding" "4px"))
   (rule ".ctl-card" (d "background-color" (c 'bg-dim)) (d "border-radius" "16px")
         (d "padding" "14px") (d "margin" "6px") (d "box-shadow" card-shadow))
   (rule ".ctl-profile" (d "padding" "2px"))
   (rule ".ctl-pfp" (d "background-color" (c 'bg-active)) (d "border-radius" "100%")
         (d "min-width" "58px") (d "min-height" "58px") (d "margin-right" "16px"))
   (rule ".ctl-pfp-ico" (d "font-size" "28px") (d "color" (c 'accent)))
   (rule ".ctl-user" (d "font-size" "24px") (d "font-weight" "bold") (d "color" (c 'accent)))
   (rule ".ctl-uptime" (d "color" (c 'fg-dim)))
   (rule ".ctl-power" (d "background-color" (c 'bg)) (d "border-radius" "14px")
         (d "padding" "12px 8px") (d "margin-top" "14px"))
   (rule ".ctl-power .pw-a" (d "font-size" "22px") (d "padding" "4px 12px") (d "transition" "color 0.25s"))
   (rule ".ctl-power .lock" (d "color" (c 'blue)))
   (rule ".ctl-power .logout" (d "color" (c 'yellow)))
   (rule ".ctl-power .reboot" (d "color" (c 'magenta)))
   (rule ".ctl-power .suspend" (d "color" (c 'cyan)))
   (rule ".ctl-power .off" (d "color" (c 'red)))
   (rule ".ctl-power .pw-a:hover" (d "color" (c 'fg)))

   ;; rings: size comes from the icon font + margin, NOT min-width
   (rule ".ctl-rings" (d "padding" "4px 0"))
   (rule ".ctl-ring-box" (d "background-color" (c 'bg)) (d "border-radius" "14px")
         (d "padding" "10px 8px") (d "margin" "0 4px"))
   (rule ".ctl-ring" (d "background-color" (c 'bg-active)) (d "border-radius" "100px") (d "margin-top" "4px"))
   (rule ".ctl-ring.cpu"  (d "color" (c 'red)))
   (rule ".ctl-ring.ram"  (d "color" (c 'blue)))
   (rule ".ctl-ring.disk" (d "color" (c 'green)))
   (rule ".ctl-ring.temp" (d "color" (c 'yellow)))
   (rule ".ctl-ring-ico" (d "font-size" "18px") (d "margin" "14px"))
   (rule ".ctl-ring-box.cpu .ctl-ring-ico, .ctl-ring-box.cpu .ctl-ring-lbl"   (d "color" (c 'red)))
   (rule ".ctl-ring-box.ram .ctl-ring-ico, .ctl-ring-box.ram .ctl-ring-lbl"   (d "color" (c 'blue)))
   (rule ".ctl-ring-box.disk .ctl-ring-ico, .ctl-ring-box.disk .ctl-ring-lbl" (d "color" (c 'green)))
   (rule ".ctl-ring-box.temp .ctl-ring-ico, .ctl-ring-box.temp .ctl-ring-lbl" (d "color" (c 'yellow)))
   (rule ".ctl-ring-lbl" (d "font-size" "11px") (d "margin-top" "6px"))
   (rule ".ctl-srow" (d "padding" "4px 8px"))
   (rule ".ctl-sico.vol" (d "color" (c 'accent)) (d "font-size" "17px"))
   (rule ".ctl-sico.bri" (d "color" (c 'yellow)) (d "font-size" "17px"))
   (rule ".ctl-scale trough" (d "background-color" (c 'bg))
         (d "min-height" "10px") (d "min-width" "180px") (d "border-radius" "50px"))
   (rule ".ctl-scale.vol trough highlight" (d "background-color" (c 'accent)) (d "border-radius" "10px"))
   (rule ".ctl-scale.bri trough highlight" (d "background-color" (c 'yellow)) (d "border-radius" "10px"))

   ;; ---- echo strip (base; eww-style-overrides restyles it) -----------------
   (rule ".echo" (d "background-color" (c 'bg)))
   (rule ".echo-text" (d "color" (c 'fg)) (d "font-size" "13px") (d "padding" "0 12px 0 64px"))

   (eww-style-overrides theme)))

;;; The .yuck layout is authored as modules for editing, but `include' cannot
;;; work once deployed: home-xdg-configuration-files makes each file its own
;;; store object symlinked separately into ~/.config/eww, so eww canonicalises
;;; eww.yuck to its bare /gnu/store path and a sibling `./bar.yuck' is not there.
;;; So we concatenate the modules into ONE eww.yuck at build time. Edit the
;;; module files; the order below is the order they are stitched.
(define eww-yuck-modules
  '("eww.yuck" "bar.yuck" "network.yuck" "audio.yuck"
    "media.yuck" "control.yuck" "echo.yuck"))

(define (slurp path)
  (call-with-input-file path get-string-all))

(define (drop-includes text)
  "Remove `(include ...)' lines -- modules are concatenated, not included."
  (string-join
   (remove (lambda (line) (string-prefix? "(include" (string-trim line)))
           (string-split text #\newline))
   "\n"))

(define (combined-yuck config-dir)
  (string-join
   (map (lambda (name) (drop-includes (slurp (string-append config-dir "/eww/" name))))
        eww-yuck-modules)
   "\n"))

(define (eww-capability theme config-dir)
  "Return home-xdg-configuration-files entries for eww: the themed style, the
layout (modules concatenated into one eww.yuck), and the babashka feeders.
CONFIG-DIR is the dotfiles config root."
  (define (curated name)
    (list (string-append "eww/" name)
          (local-file (string-append config-dir "/eww/" name))))
  `(("eww/eww.scss"
     ,(plain-file "eww.scss" (eww-style theme)))
    ("eww/eww.yuck"
     ,(plain-file "eww.yuck" (combined-yuck config-dir)))
    ,(curated "broker.bb")
    ,(curated "eww-rpc")
    ,(curated "menu-toggle")
    ,(curated "niri-window-switch.bb")
    ,(curated "brightness")
    ,(curated "brightness-set")))

(define (home-eww-broker-shepherd-service config)
  "Run the eww data broker (broker.bb) as a long-lived shepherd service:
single instance, respawn, stop -- no lock files or pid juggling.  It serves an
nREPL on 127.0.0.1:1667 that eww calls into via eww-rpc."
  (list
   (shepherd-service
    (provision '(eww-broker))
    (documentation "Live babashka broker feeding the eww bar (nREPL :1667).")
    (start #~(make-forkexec-constructor
              (list (string-append (getenv "HOME") "/.guix-home/profile/bin/bb")
                    (string-append (getenv "HOME") "/.config/eww/broker.bb"))
              #:log-file (string-append
                          (or (getenv "XDG_STATE_HOME")
                              (string-append (getenv "HOME") "/.local/state"))
                          "/eww-broker.log")))
    (stop #~(make-kill-destructor))
    (respawn? #t))))

(define home-eww-broker-service-type
  (service-type
   (name 'home-eww-broker)
   (extensions
    (list (service-extension home-shepherd-service-type
                             home-eww-broker-shepherd-service)))
   (default-value #f)
   (description "eww data broker shepherd service.")))
