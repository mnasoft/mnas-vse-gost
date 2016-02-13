;;;; mnas-vse-gost.lisp

(in-package #:mnas-vse-gost)

;;; "mnas-vse-gost" goes here. Hacks and glory await!

;;;;(asdf:oos 'asdf:load-op :mnas-vse-gost) (use-package :mnas-vse-gost)
;;;;(asdf:oos 'asdf:load-op :mnas-string)   (use-package :mnas-string)
;;;;(asdf:oos 'asdf:load-op :hunchentoot)   (use-package :hunchentoot)
;;;;(asdf:oos 'asdf:load-op :cl-who)        (use-package :cl-who)
;;;;(asdf:oos 'asdf:load-op :postmodern)    (use-package :postmodern)

(defparameter *gost-acceptor* nil)

(setf (html-mode) :HTML5)

(defun gost-stop()
  "Выполняет:
2. Остановку web-сервера: *gost-acceptor*
3. Отсоединение от базы данных
"
  (clean-dispatch-table)
  (stop *gost-acceptor*)
  (disconnect-toplevel)) ;; Postmaster disconnection

(defun clean-dispatch-table()
  (if (> (length *dispatch-table*) 1)
      (setf *dispatch-table* (last *dispatch-table*)))
  *dispatch-table*)


(defun do-show-gost-table (name-str designation-str description-str)
  "Выполняет формирование содержимого таблицы содержащей в каждой своей строке:
1. Обозначени   ГОСТ (designation);
2. Наименование ГОСТ (name);
-- 3. Описание     ГОСТ (description).
"
  (let ((out (make-string-output-stream))
	(lines 0))
    (setf lines (second (multiple-value-list
			 (doquery (:select 'designation 'name 'local_path :from 'gost :where
					   (:and (:ilike 'name (string-prepare-to-query name-str))
						 (:ilike 'designation (string-prepare-to-query designation-str))
						 (:ilike 'description (string-prepare-to-query description-str))))
				  (designation name local_path)
				  (format out "<tr><td><a href='~A'>~A</a></td><td>~A</td></tr>~%"
					  (concatenate 'string "http://vsegost.ddns.net/static/" local_path "gost.pdf") designation name)))))
    (format nil "<table>~A</table>~%<p>Всего найдено ~A записей</p>" (get-output-stream-string out) lines)))

(defmacro standard-page ((&key title)  &body body)
  `(with-html-output-to-string (*standard-output* nil :prologue t :indent t)
     (:html
      (:head
       (:meta :chatset "utf-8")
       (:title ,title)
       (:link :type "text/css" :rel "stylesheet" :href "/retro.css"))
      (:body
       (:header
	(:table :width "1000px"
	 (:tr
	  (:td (:a :href "http://mnasoft.ddns.net/"             (:img :src "/static/images/MNASoft.png" :alt "Archlinux"   :class "logo" :height "28px")))
	  (:td :width "300px" "")
	  (:td (:audio :controls "controls" ;; :autoplay "autoplay"
		       (:source  :src "/static/audio/dzhejms_last_-_odinokij_pastuh_(zvukoff.ru).mp3" :type "audio/mpeg")))))
	(:hr))
       (:main ,@body)
       (:footer 
	(:hr)
	(:table :width "1000px"
		(:tr
		 (:td "Поиск ГОСТов")
		 (:td :width "150px" "")
		 (:td
		  (:a :href "https://www.archlinux.org/"             (:img :src "/static/images/ArchlinuxLogo2.png" :alt "Archlinux"   :class "logo" :height "28px"))
		  (:a :href "http://www.gnu.org/software/emacs/"     (:img :src "/static/images/emacs-logo.png"     :alt "GNU Emacs"   :class "logo" :height "28px"))
		  (:a :href "https://common-lisp.net/project/slime/" (:img :src "/static/images/slime-small.png"    :alt "GNU Emacs"   :class "logo" :height "28px"))
		  (:a :href "http://www.postgresql.org/"             (:img :src "/static/images/PostgreSQL_01.png"  :alt "PostgreSQL"  :class "logo" :height "28px"))
		  (:a :href "http://www.sbcl.org/"                   (:img :src "/static/images/SBCL.png"           :alt "SBCL"        :class "logo" :height "28px"))
		  (:a :href "http://weitz.de/hunchentoot/"           (:img :src "/static/images/hunchentoot11.png"  :alt "Hunchentoot" :class "logo" :height "28px")))))
	(:hr))))))

(defmacro define-url-fn ((name) &body body)
  `(progn (defun ,name() ,@body)
     (push (create-prefix-dispatcher ,(format nil "/~(~a~)" name) ',name) *dispatch-table*)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-easy-handler (uri-vsegost :uri "/") ()
      (redirect "/select"))

(defun gost-start()
  (connect-toplevel "namatv" "namatv" mnas-passwd:POSTGRESS@MNASOFT-PI "localhost") ;; Postmaster connaction
  (setf *gost-acceptor* (start (make-instance 'easy-acceptor :port 8000)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
  (define-url-fn (show)
    (let ((name (parameter "name"))
	  (disignation (parameter "disignation"))
	  (description (parameter "description")))
      (standard-page
	  (:title "MNASoft. Отбор ГОСТов")
	(str(do-show-gost-table name disignation description)))
;;;;(unless (or (null name) (zerop (length name))) (add-game name))
;;;;(redirect "/retro-games.htm")
      ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
  (define-url-fn (select)
    (standard-page
	(:title "MNASoft. Отбор ГОСТов")
      (:h1 "Отбор ГОСТов")
      (:h3 "Заполните одно или несколько полей для отбора ГОСТов")
      (:form :action "/show" :method "post"
	     (:table 
	      (:tr (:th "Поле") (:th "Строка для поиска"))
	      (:tr (:td "Обозначение")(:td (:input :type "text" :name "disignation" :class "txt" :style "width:30em" )))
	      (:tr (:td "Наименование")(:td (:input :type "text" :name "name" :class "txt" :style "width:30em")))
	      (:tr (:td "Описание")(:td (:input :type "text" :name "description" :class "txt" :style "width:30em"))))
	     (:p (:input :type "submit" :value "Отобрать" :class "btn")))))
  )

(gost-start)

;;;;(clean-dispatch-table)

;;;;(progn (gost-stop)(gost-start))

;;;;(gost-stop)

;Testing;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;(do-show-gost-table "" "2.305" "")
;;;;(list-show-gost-table "" "2.305" "")

(defun list-show-gost-table (name-str designation-str description-str)
  (let ((rez nil))
    (doquery (:select 'designation 'name 'local_path :from 'gost :where
		      (:and (:ilike 'name (string-prepare-to-query name-str))
			    (:ilike 'designation (string-prepare-to-query designation-str))
			    (:ilike 'description (string-prepare-to-query description-str))))
	(designation name local_path)
      (setf rez (cons (list (concatenate 'string "http://wp7580.ddns.mksat.net/~namatv/2015-12-21-vsegost.com/" local_path "gost.pdf")
			    designation
			    name) rez)))
    rez))


