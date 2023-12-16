(require 'json)

(defvar slaythespire-key "key"
  "Encryption key.")

(defvar-local slaythespire--save-file nil)

(defun slaythespire--xor-str-against-key (str key)
  (string-join (seq-map-indexed
                (lambda (a i)
                  (char-to-string (logxor a
                                          (seq-elt key (% i (length key))))))
                str)))

(defun slaythespire--read-file-content (file)
  "Read the content of FILE into a string."
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))

(defun slaythespire-decode (str)
  "return a decoded string"
  (slaythespire--xor-str-against-key (base64-decode-string str) slaythespire-key))

(defun slaythespire-encode (json)
  (base64-encode-string (slaythespire--xor-str-against-key json slaythespire-key)))

(defun slaythespire-open-save-file (file)
  "Huh"
  (interactive "fEnter file path: ")
  (let ((buffer (get-buffer-create (format "*%s*" (file-name-nondirectory file)))))
    (with-current-buffer buffer
      (erase-buffer)
      (insert (slaythespire-decode (slaythespire--read-file-content file)))
      (json-mode)
      (setq-local slaythespire--save-file file)
      (slaythespire-mode))
    (switch-to-buffer buffer)))

(defun slaythespire-save ()
  (interactive)
  (let ((str (buffer-string)))
    (with-temp-file slaythespire--save-file
      (insert (slaythespire-encode str)))))

(defun slaythespire-reload ()
  (interactive)
  (slaythespire-open-save-file slaythespire--save-file))

(define-minor-mode slaythespire-mode
  "Toggle Hungry mode.
...rest of documentation as before..."
  ;; The initial value.
  :init-value nil
  ;; The minor mode bindings.
  :keymap
  (list (cons (kbd "C-c C-c") 'slaythespire-save)
        (cons (kbd "C-c C-r") 'slaythespire-reload)))

(provide 'slaythespire)
