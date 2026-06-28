;;; Entry: the operating-system for this host.
;;;   guix system -L src reconfigure system.scm   (the update-system alias)
(use-modules (dots system base))
(operating-system-for-host)
