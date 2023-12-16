(defvar thanh-key "key")
(defvar-local thanh-save-file nil)

(defun thanh-xor-str-against-key (str key)
  (string-join (seq-map-indexed
                (lambda (a i)
                  (char-to-string (logxor a
                                          (seq-elt key (% i (length key))))))
                str)))

(defun thanh-decode (str)
  "return a decoded string"
  (thanh-xor-str-against-key (base64-decode-string str) thanh-key))

(defun thanh-encode (json)
  (base64-encode-string (thanh-xor-str-against-key json thanh-key)))

(defun thanh-open-save-file (file)
  "Huh"
  (interactive "fEnter file path: ")
  (let ((buffer (get-buffer-create (format "*%s*" (file-name-nondirectory file)))))
    (with-current-buffer buffer
      (erase-buffer)
      (insert (thanh-decode (f-read-text file)))
      (json-mode)
      (setq-local thanh-save-file file)
      (thanh-mode))
    (switch-to-buffer buffer)))

(defun thanh-save ()
  (interactive)
  (let ((str (buffer-string)))
    (with-temp-file thanh-save-file
      (insert (thanh-encode str)))))

(defun thanh-reload ()
  (interactive)
  (thanh-open-save-file thanh-save-file))

(define-minor-mode thanh-mode
  "Toggle Hungry mode.
...rest of documentation as before..."
  ;; The initial value.
  :init-value nil
  ;; The indicator for the mode line.
  ;; The minor mode bindings.
  :keymap
  (list (cons (kbd "C-c C-c") 'thanh-save)
        (cons (kbd "C-c C-r") 'thanh-reload)))
