;;;; mnas-vse-gost.asd

(asdf:defsystem #:mnas-vse-gost
  :description "Describe mnas-vse-gost here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :serial t
  :depends-on (#:mnas-string #:postmodern #:hunchentoot #:cl-who)
  :components ((:file "package")
               (:file "mnas-vse-gost")))

