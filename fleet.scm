;;; Entry: guix deploy target for the lab fleet.
;;;   guix deploy -L src fleet.scm   (optionally `-- NAME ...` for a subset)
(use-modules (dots lab fleet))
%fleet
