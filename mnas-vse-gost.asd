;;;; mnas-vse-gost.asd

(asdf:defsystem #:mnas-vse-gost
  :description "Describe mnas-vse-gost here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :serial t
  :depends-on (#:postmodern #:hunchentoot #:cl-who #:mnas-string #:mnas-site #:mnas-passwd)
  :components ((:file "package")
	       (:file "mnas-vse-gost-audio")
               (:file "mnas-vse-gost")
	       ))

