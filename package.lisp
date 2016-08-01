;;;; package.lisp

(defpackage #:mnas-vse-gost
  (:use #:cl #:postmodern #:hunchentoot #:cl-who #:mnas-string #:mnas-site)
  (:export gost-start gost-stop))

;;;;(declaim (optimize (space 0) (compilation-speed 0)  (speed 0) (safety 3) (debug 3)))
