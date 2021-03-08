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
  (mnas-disconnect-toplevel))

(defun do-show-gost-table (name-str designation-str description-str)
  "Выполняет формирование содержимого таблицы содержащей в каждой своей строке:
1. Обозначени   ГОСТ (designation);
2. Наименование ГОСТ (name);
-- 3. Описание     ГОСТ (description)
"
  (let ((out (make-string-output-stream))
	(lines 0))
    (setf lines (second (multiple-value-list
			 (doquery (:select 'designation 'name 'local_path :from 'gost :where
					   (:and (:ilike 'name (mnas-string/db:prepare-to-query name-str))
						 (:ilike 'designation (mnas-string/db:prepare-to-query designation-str))
						 (:ilike 'description (mnas-string/db:prepare-to-query description-str))))
				  (designation name local_path)
				  (format out "<tr><td><a href='~A'>~A</a></td><td>~A</td></tr>~%"
					  (concatenate 'string *vse-gost-root* local_path "gost.pdf") designation name)))))
    (format nil "<table>~A</table>~%<p>Всего найдено ~A записей</p>" (get-output-stream-string out) lines)))

;;;; (define-easy-handler (uri-vsegost :uri "/")        ()  (redirect "/vsegost/select"))

(define-easy-handler (uri-/                 :uri "/") ()  (redirect "/vsegost/select"))

(define-easy-handler (uri-/vsegost          :uri "/vsegost") ()  (redirect "/vsegost/select"))

(define-easy-handler (uri-/vsegost/         :uri "/vsegost/") ()  (redirect "/vsegost/select"))

(define-easy-handler (uri-/vsegost/select/  :uri "/vsegost/select/") ()  (redirect "/vsegost/select"))

(defun gost-start()
  (mnas-site-start)
  (mnas-connect-toplevel)
  (define-url-fn (vsegost/select *mnas-vse-gost-dispatch-table*)
    (standard-page ("MNASoft. Отбор ГОСТов" :header (mnas-site-template:header) :footer (mnas-site-template:footer) )
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
      (standard-page ("MNASoft. Отбор ГОСТов" :header (mnas-site-template:header) :footer (mnas-site-template:footer))
	(str(do-show-gost-table name disignation description)))))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
		      (:and (:ilike 'name (mnas-string/db:prepare-to-query name-str))
			    (:ilike 'designation (mnas-string/db:prepare-to-query designation-str))
			    (:ilike 'description (mnas-string/db:prepare-to-query description-str))))
	(designation name local_path)
      (setf rez (cons (list (concatenate 'string "http://wp7580.ddns.mksat.net/~namatv/2015-12-21-vsegost.com/" local_path "gost.pdf")
			    designation
			    name)
		      rez)))
    rez))
