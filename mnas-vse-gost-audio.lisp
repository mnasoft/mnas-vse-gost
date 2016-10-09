;;;; mnas-vse-gost-audio.lisp

(in-package #:mnas-vse-gost)
;;; "mnas-vse-gost" goes here. Hacks and glory await!

(defparameter *random-audio-state* (make-random-state ))

(defparameter *audio* nil)

(defun audio()
  (if *audio*
      *audio*
      (setf *audio* (directory
		     (concatenate 'string (acceptor-document-root *mnas-site-acceptor*) "audio/*.mp3")
		     :files t :directories nil :follow-links nil))))

(defun random-pathname()
  (nth (random (length (audio)) *random-audio-state*) (audio)))

(defun random-audio ()
  (pathname-directory-subtract (acceptor-document-root *mnas-site-acceptor*) (random-pathname)))

