;;;; mnas-vse-gost.lisp

(in-package #:mnas-vse-gost)
;;; "mnas-vse-gost" goes here. Hacks and glory await!

(defparameter *vse-gost-root* "/2015-12-21-vsegost.com/"
  "Путь к каталогу , содержащему подкаталог Data")

(defparameter *mnas-vse-gost-dispatch-table* nil
  "Таблица диспетчеризации проекта adiabatic-temperature")

(defun gost-stop()
  "Выполняет:
1. Очистку таблицы диспетчеризвции
2. Отсоединение от базы данных
"
  (clean-dispatch-table '*mnas-vse-gost-dispatch-table*)
  (mnasoft-pi-disconnect-toplevel))

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
					  (concatenate 'string *vse-gost-root* local_path "gost.pdf") designation name)))))
    (format nil "<table>~A</table>~%<p>Всего найдено ~A записей</p>" (get-output-stream-string out) lines)))

(defmacro standard-page ((&key title)  &body body)
  `(if (allowed-address-p)
       (with-html-output-to-string (*standard-output* nil :prologue t :indent t)
	 (:html
	  (:head
	   (:meta :chatset "utf-8")
	   (:title ,title)
	   (:link :type "text/css" :rel "stylesheet" :href "/retro.css"))
	  (:body
	   (:header
	    (:table :width "1000px"
		    (:tr
		     (:td (:a :href "http://mnasoft.ddns.net/"             (:img :src "/images/MNASoft.png" :alt "Archlinux"   :class "logo" :height "28px")))
		     (:td :width "300px" "")
		     (:td (:audio :controls "controls" ;; :autoplay "autoplay"
				  (:source  :src (str (nth (mod (random 10000) (length *audio*)) *audio*)) :type "audio/mpeg")))))
	    (:hr))
	   (:main ,@body)
	   (:footer 
	    (:hr)
	    (:table :width "1000px"
		    (:tr
		     (:td "Поиск ГОСТов")
		     (:td :width "150px" "")
		     (:td
		      (:a :href "https://www.archlinux.org/"             (:img :src "/images/ArchlinuxLogo2.png" :alt "Archlinux"   :class "logo" :height "28px"))
		      (:a :href "http://www.gnu.org/software/emacs/"     (:img :src "/images/emacs-logo.png"     :alt "GNU Emacs"   :class "logo" :height "28px"))
		      (:a :href "https://common-lisp.net/project/slime/" (:img :src "/images/slime-small.png"    :alt "GNU Emacs"   :class "logo" :height "28px"))
		      (:a :href "http://www.postgresql.org/"             (:img :src "/images/PostgreSQL_01.png"  :alt "PostgreSQL"  :class "logo" :height "28px"))
		      (:a :href "http://www.sbcl.org/"                   (:img :src "/images/SBCL.png"           :alt "SBCL"        :class "logo" :height "28px"))
		      (:a :href "http://weitz.de/hunchentoot/"           (:img :src "/images/hunchentoot11.png"  :alt "Hunchentoot" :class "logo" :height "28px")))))
	    (:hr)))))))

(define-easy-handler (uri-vsegost :uri "/") ()
      (redirect "/vsegost/select"))

(defun gost-start()
  (mnas-site-start)
  (mnasoft-pi-connect-toplevel)
  (define-url-fn (vsegost/select *mnas-vse-gost-dispatch-table*)
    (standard-page
	(:title "MNASoft. Отбор ГОСТов")
      (:h1 "Отбор ГОСТов")
      (:h3 "Заполните одно или несколько полей для отбора ГОСТов")
      (:form :action "show" :method "post"
	     (:table 
	      (:tr (:th "Поле") (:th "Строка для поиска"))
	      (:tr (:td "Обозначение")(:td (:input :type "text" :name "disignation" :class "txt" :style "width:30em" )))
	      (:tr (:td "Наименование")(:td (:input :type "text" :name "name" :class "txt" :style "width:30em")))
	      (:tr (:td "Описание")(:td (:input :type "text" :name "description" :class "txt" :style "width:30em"))))
	     (:p (:input :type "submit" :value "Отобрать" :class "btn")))))
  (define-url-fn (vsegost/show *mnas-vse-gost-dispatch-table*)
    (let ((name (parameter "name"))
	  (disignation (parameter "disignation"))
	  (description (parameter "description")))
      (standard-page
	  (:title "MNASoft. Отбор ГОСТов")
	(str(do-show-gost-table name disignation description)))))
  )

(gost-start)

;;;; (acceptor-document-root *mnas-site-acceptor*)

;;;; (progn (gost-stop) (gost-start))

;;;; (mnas-site-start)

;;;; (mnas-site-stop)

;;;; *mnas-vse-gost-dispatch-table*

;;;; *dispatch-table*

;;;;Testing;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



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


