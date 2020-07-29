;;;; samarang.lisp

(in-package #:samarang)

(defparameter +wordset-file+ #P"words_alpha.txt")

(defvar *wordset* (make-hash-table :test 'equal))

;; uses too much memory, ideally it would produce one anagram at a time and
;; would accept a funciton argument to do something with each anagram it
;; generated.

(defun fill-and-insert (idx elem vec buffer)
  (loop :for i :below (length buffer)
     :when (= i idx) :do (setf (aref buffer idx) elem)
     :when (< i idx) :do (setf (aref buffer i)
                               (aref vec i))
     :when (> i idx) :do (setf (aref buffer i)
                               (aref vec (1- i))))  )

(defun thread-through (elem vec)
  (let ((buffer (concatenate 'vector vec (list elem)))) ;; reusable buffer
    (map! (lambda (idx)
            (fill-and-insert idx elem vec buffer)
            buffer)
          (range :from 0 :to (length vec) :inclusive t))))


(defun perms (vec)
  (if (= 1 (length vec)) (seq (list vec))
      (let ((elem (elt vec 0))
            (subperms (perms (make-array (1- (length vec))
                                         :displaced-to vec
                                         :displaced-index-offset 1
                                         :element-type (array-element-type vec)))))
        (inflate! (lambda (subperm) (thread-through elem subperm)) subperms))))


(defun is-word (word)
  (gethash (string-downcase word) *wordset*))

(defun clean-string (string)
  (string-downcase
   (string-trim '(#\space #\newline #\backspace #\tab #\linefeed #\page #\return)
                string)))

(defun load-wordset ()
  (with-open-file (input +wordset-file+)
    (loop :for line = (read-line input nil nil)
          :while line
          :do (setf (gethash (clean-string line) *wordset*) t))))


(defun anagrams-of (word &optional (output *standard-output*))
  (let ((keepers (make-hash-table :test 'equal)))
    (for anagram (map! ($$ (concatenate 'string $1))  (perms word))
      (when (is-word anagram)
        (setf (gethash (string-downcase anagram) keepers) t)))
    (loop :for a :being :the :hash-key :of keepers
          :do (format output "~a~%" a))))

(defun run ()
  (let ((args sb-ext:*posix-argv*))
    (if (not (= 2 (length args)))
        (format t "USAGE: samarang <word>~%")
        (if (< (length (second args)) 11)
            (anagrams-of (second args))
            (format t "SORRY... this was written badly and your word is too long.~%~%")))))


