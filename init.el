;;; package -- sumary
;;;Commentary:
;;; This is zio-overload first GNU emacs config (test4)
;;; Code:
(setq garbage-collection-messages t)
;; Set garbage collection threshold to 1GB.
(setq gc-cons-threshold #x40000000)
(setq gc-cons-percentage .9)
;;;; lsp performance
(setenv "LSP_USE_PLISTS" "true") ;; in early-init.el
;;;; per https://github.com/emacs-lsp/lsp-mode#performance
(setq read-process-output-max (* 10 1024 1024)) ;; 10mb
(setq gc-cons-threshold 200000000)

(require 'package)
(setq package-enable-at-startup nil
      package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")))
;; (setq gnutls-algorithm-priority "normal:-vers-tls1.3")
(package-initialize)
;;;; custom-font
(set-face-attribute 'default nil
                    ;; :family "Anonymous Pro"
                    :family "JetBrainsMono Nerd Font"
                    :height 95)
;; (set-face-attribute 'variable-pitch nil
;;                     :family "Anonymous Pro")
;; (set-face-attribute 'fixed-pitch nil
;;                     :family "Hack Nerd Font Mono")
;; (add-hook 'text-mode-hook #'variable-pitch-mode)

;;;; set custom themes path (for autothemer and manual themes installations, not used with doom-themes)
(setq custom-theme-directory "~/.emacs.d/themes")
;;;; load custom-theme (not from packages)
;;(load-theme 'automata t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; My packages configurations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; no-littering (always on top)
(setq load-prefer-newer t)
(use-package no-littering
  :ensure t)
;;;; quelpa
(use-package quelpa :ensure t)
(use-package quelpa-use-package :ensure t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Emacs Defaults
;; Customize default emacs
(use-package emacs
  :ensure nil
  :defer
  :hook ((after-init . pending-delete-mode)
         (after-init . toggle-frame-maximized)
         (after-init . (lambda () (scroll-bar-mode -1)))
         (after-init . (lambda () (window-divider-mode -1)))
         (after-init . (lambda () (set-frame-parameter nil 'alpha-background 99)))) ;; to avoid issues with initial frame that was not applying transparency properly.
                                        ;         (after-init . gopar/add-env-vars))
  :custom
  ;; flash the frame to represent a bell.
  (visible-bell t)
  (debugger-stack-frame-as-list )
  (narrow-to-defun-include-comments t)
  (use-short-answers t)
  (confirm-nonexistent-file-or-buffer nil)
  ;; Treat manual switching of buffers the same as programatic
  (switch-to-buffer-obey-display-actions t)
  (switch-to-buffer-in-dedicated-window nil)
  (window-sides-slots '(3 0 3 1))
  ;; Sentences end with 1 space not 2
  (sentence-end-double-space nil)
  ;; make cursor the width of the character it is under
  ;; i.e. full width of a TAB
  (x-stretch-cursor t)
  ;; Stop cursor from going into minibuffer prompt text
  (minibuffer-prompt-properties '(read-only t point-entered minibuffer-avoid-prompt face minibuffer-prompt))
  (history-delete-duplicates t)
  ;; Completion stuff for consult
  (completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (completion-cycle-threshold nil)
  (tab-always-indent 'complete)
  (use-dialog-box nil) ; Lets be consistent and use minibuffer for everyting
  (scroll-conservatively 100)
  (frame-inhibit-implied-resize t)
  ;;   ;(custom-file "~/.emacs.d/ignoreme.el")
  :config
                                        ; (load custom-file)
                                        ; (when (eq system-type 'darwin)
                                        ;   (setq mac-option-key-is-meta nil
                                        ;         mac-command-key-is-meta t
                                        ;         mac-command-modifier 'meta
                                        ;         mac-option-modifier 'none)
                                        ;   )
  (setq-default c-basic-offset 4
                c-default-style "linux"
                indent-tabs-mode nil
                fill-column 120
                tab-width 4)
  ;; Replaced in favor for `use-short-answers`
  ;; (fset 'yes-or-no-p 'y-or-n-p)
  (prefer-coding-system 'utf-8)
  ;; Uppercase is same as lowercase
  (define-coding-system-alias 'UTF-8 'utf-8)
  ;; Enable some commands
  (put 'upcase-region 'disabled nil)
  (put 'downcase-region 'disabled nil)
  (put 'erase-buffer 'disabled nil)
  ;; C-x n <key> useful stuff
  (put 'narrow-to-region 'disabled nil)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (command-query 'save-buffers-kill-terminal "Do you really want to kill emacs?")

  :bind (("C-z" . nil)
         ("C-x C-z" . nil)
         ("C-x C-k RET" . nil)
         ("RET" . newline-and-indent)
         ("C-j" . newline)
         ("M-\\" . cycle-spacing)
                                        ; ;       ("C-x \\" . align-regexp)
         ("C-x C-b" . ibuffer)
         ("M-u" . upcase-dwim)
         ("M-l" . downcase-dwim)
         ("M-c" . capitalize-dwim)
         ("C-S-k" . gopar/delete-line-backward)
         ("C-k" . gopar/delete-line)
         ("M-d" . gopar/delete-word)
         ("<M-backspace>" . gopar/backward-delete-word)
         ("M-e" . gopar/next-sentence)
         ("M-a" . gopar/last-sentence)
                                        ; ;       (";" . gopar/easy-underscore)
         ("C-x k" . (lambda () (interactive) (kill-buffer)))
         ("C-x C-k" . (lambda () (interactive) (bury-buffer))))

  :init
  (defun gopar/copy-filename-to-kill-ring ()
    (interactive)
    (kill-new (buffer-file-name))
    (message "Copied to file name kill ring"))

  (defun gopar/easy-underscore (arg)
    "Convert all inputs of semicolon to an underscore. If given ARG, then it will insert an acutal semicolon."
    (interactive "P")
    (if arg
        (insert ";")
      (insert "_")))

  (defun easy-camelcase (arg)
    (interactive "c")
    ;; arg is between a-z
    (cond ((and (>= arg 97) (<= arg 122))
           (insert (capitalize (char-to-string arg))))
          ;; If it's a new line
          ((= arg 13)
           (newline-and-indent))
          ((= arg 59)
           (insert ";"))
          ;; We probably meant a key command, so lets execute that
          (t (call-interactively
              (lookup-key (current-global-map) (char-to-string arg))))))

  (defun sudo-edit (&optional arg)
    "Edit currently visited file as root. With a prefix ARG prompt for a file to visit. Will also prompt for a file to visit if current buffer is not visiting a file."
    (interactive "P")
    (if (or arg (not buffer-file-name))
        (find-file (concat "/sudo:root@localhost:"
                           (completing-read "Find file(as root): ")))
      (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

  ;; Stolen from https://emacs.stackexchange.com/a/13096/8964
  (defun gopar/reload-dir-locals-for-current-buffer ()
    "Reload dir locals for the current buffer"
    (interactive)
    (let ((enable-local-variables :all))
      (hack-dir-local-variables-non-file-buffer)))

  (defun gopar/delete-word (arg)
    "Delete characters forward until encountering the end of a word. With argument, do this that many times. This command does not push text to `kill-ring'."
    (interactive "p")
    (delete-region
     (point)
     (progn
       (forward-word arg)
       (point))))

  (defun gopar/backward-delete-word (arg)
    "Delete characters backward until encountering the beginning of a word. With argument, do this that many times. This command does not push text to `kill-ring'."
    (interactive "p")
    (gopar/delete-word (- arg)))

  (defun gopar/delete-line ()
    "Delete text from current position to end of line char. This command does not push text to `kill-ring'."
    (interactive)
    (delete-region
     (point)
     (progn (end-of-line 1) (point)))
    (delete-char 1))

  (defadvice gopar/delete-line (before kill-line-autoreindent activate)
    "Kill excess whitespace when joining lines. If the next line is joined to the current line, kill the extra indent whitespace in front of the next line."
    (when (and (eolp) (not (bolp)))
      (save-excursion
        (forward-char 1)
        (just-one-space 1))))

  (defun gopar/delete-line-backward ()
    "Delete text between the beginning of the line to the cursor position. This command does not push text to `kill-ring'."
    (interactive)
    (let (p1 p2)
      (setq p1 (point))
      (beginning-of-line 1)
      (setq p2 (point))
      (delete-region p1 p2)))

  (defun gopar/next-sentence ()
    "Move point forward to the next sentence. Start by moving to the next period, question mark or exclamation. If this punctuation is followed by one or more whitespace
    characters followed by a capital letter, or a '\', stop there. If
    not, assume we're at an abbreviation of some sort and move to the
    next potential sentence end"
    (interactive)
    (re-search-forward "[.?!]")
    (if (looking-at "[    \n]+[A-Z]\\|\\\\")
        nil
      (gopar/next-sentence)))

  (defun gopar/list-git-authors-for-file ()
    "Display all the authors for a given file.
    If file is not in a git repo or file is not a real file (aka buffer), then do nothing."
    (interactive)
    (let* ((file (buffer-file-name))
           (root (when (vc-root-dir) (expand-file-name (vc-root-dir))))
           (file (when (and file root) (s-chop-prefix root file))))
      (when (and root file)
        (message (format "Contributors for %s:\n%s" file (shell-command-to-string
                                                          (format "git shortlog HEAD -s -n %s" file)))))))

  (defun gopar/last-sentence ()
    "Does the same as 'gopar/next-sentence' except it goes in reverse"
    (interactive)
    (re-search-backward "[.?!][   \n]+[A-Z]\\|\\.\\\\" nil t)
    (forward-char))

                                        ; (defvar gopar-ansi-escape-re
                                        ;   (rx (or ?\233 (and ?\e ?\[))
                                        ;       (zero-or-more (char (?0 . ?\?)))
                                        ;       (zero-or-more (char ?\s ?- ?\/))
                                        ;       (char (?@ . ?~))))

                                        ;  (defun gopar/nuke-ansi-escapes (beg end)
                                        ;   (save-excursion
                                        ;      (goto-char beg)
                                        ;      (while (re-search-forward gopar-ansi-escape-re end t)
                                        ;        (replace-match ""))))

  (defun gopar/toggle-window-dedication ()
    "Toggles window dedication in the selected window."
    (interactive)
    (set-window-dedicated-p (selected-window)
                            (not (window-dedicated-p (selected-window))))))

                                        ; (defun gopar/add-env-vars ()
                                        ;   "Setup environment variables that I will need."
                                        ;   (load-file "~/.emacs.d/etc/eshell/set_env.el")
                                        ;   (setq-default eshell-path-env (getenv "PATH"))

                                        ;   (setq exec-path (append exec-path
                                        ;                           `("/usr/local/bin"
                                        ;                             "/usr/bin"
                                        ;                             "/usr/sbin"
                                        ;                             "/sbin"
                                        ;                             "/bin"
                                        ;                             "/Users/gopar/.nvm/versions/node/v16.14.2/bin/"
                                        ;                             )
                                        ;                           (split-string (getenv "PATH") ":")))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; doom-themes
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-miramare t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors"
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode native fontification
  (doom-themes-org-config))
;;;; true transparency
(add-to-list 'initial-frame-alist '(alpha-background . 99))
(add-to-list 'default-frame-alist '(alpha-background . 99))
;;;; doom-modline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config (column-number-mode 1)
  :custom
  (doom-modeline-height 30)
  (doom-modeline-window-width-limit nil)
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-minor-modes nil)
  (doom-modeline-enable-word-count t)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-buffer-modification-icon t)
  ;;(doom-modeline-env-python-executable "python")
  (doom-modeline-time t)
  (doom-modeline-vcs-max-length 50)
  )

;;;; treemacs
(use-package treemacs
  :ensure t
  :bind ("<f5>" . treemacs)
  :custom
  (treemacs-is-never-other-window t)
  :hook
  (treemacs-mode . treemacs-project-follow-mode))

;;;; solaire-mode
(use-package solaire-mode
  :ensure t
  :hook (after-init . solaire-global-mode)
  :config
  (push '(treemacs-window-background-face . solaire-default-face) solaire-mode-remap-alist)
  (push '(treemacs-hl-line-face . solaire-hl-line-face) solaire-mode-remap-alist))

;;;; vertico vertico-postframe
(use-package vertico
  :ensure t
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy)
  :init
  (vertico-mode)
  (setq vertico-cycle t))

(use-package vertico-multiform
  :ensure nil
  :hook (after-init . vertico-multiform-mode)
  :init
  (setq vertico-multiform-commands
        '((consult-line (:not posframe))
          (gopar/consult-line (:not posframe))
          (consult-ag (:not posframe))
          (consult-grep (:not posframe))
          (consult-imenu (:not posframe))
          (xref-find-definitions (:not posframe))
          (t posframe))))

(use-package vertico-posframe
  :ensure t
  :hook (after-init . vertico-posframe-mode)
  :custom
  (vertico-posframe-parameters
   '((left-fringe . 8)
     (right-fringe . 8))))

;;;; spacious-padding
(use-package spacious-padding
  :ensure t
  :hook (after-init . spacious-padding-mode))

;;;; all-the-icons
(use-package all-the-icons
  :ensure t
  :defer
  :if (display-graphic-p))

(use-package all-the-icons-completion
  :ensure t
  :defer
  :hook (marginalia-mode . #'all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))

;;;; electric-pair
(use-package elec-pair
  :ensure nil
  :defer
  :hook (after-init . electric-pair-mode))

;;;; highlight-indentation
(use-package highlight-indentation
  :ensure t
  :defer
  :hook ((prog-mode . highlight-indentation-mode)
         (prog-mode . highlight-indentation-current-column-mode)))

;;;;Corral
(use-package corral
  :ensure t
  :defer
  :bind (("M-9" . corral-parentheses-backward)
         ("M-0" . corral-parentheses-forward)
         ("M-[" . corral-brackets-backward)
         ("M-]" . corral-brackets-forward)
         ("M-\"" . corral-single-quotes-backward)
         ("M-'" . corral-single-quotes-forward)))

;;;;helpful
(use-package helpful
  :ensure t
  :defer
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)))

;;;;which-key
(use-package which-key
  :ensure t
  :hook (after-init . which-key-mode)
  :custom
  (which-key-idle-delay 1))

;;;; prog-mode
(use-package prog-mode
  :ensure nil
  :defer
  :hook ((prog-mode . subword-mode)
         (prog-mode . hl-line-mode)
         (prog-mode . (lambda () (setq-local fill-column 120)))))

;;;;which-function
(use-package which-func
  :ensure nil
  :defer
  :hook (prog-mode . which-function-mode))

;;;;dired
(use-package dired
  :ensure nil
  :defer
  :hook ((dired-mode . dired-hide-details-mode)
         (dired-mode . hl-line-mode))
  :custom
  (dired-do-revert-buffer t)
  (dired-auto-revert-buffer t)
  (delete-by-moving-to-trash t)
  (dired-mouse-drag-files t)
  (dired-dwim-target t)
  ;; (dired-guess-shell-alist-user)
  (dired-listing-switches "-AlhoF --group-directories-first"))

(use-package all-the-icons-dired
  :ensure t
  :defer
  :hook (dired-mode . all-the-icons-dired-mode)
  :custom
  (all-the-icons-dired-monochrome nil))

;; (use-package files
;;   :ensure nil
;;   :custom
;;   (insert-directory-program "gls") ; Will not work if system does not have GNU gls installed
;;   ;; Don't have backup
;;   (backup-inhibited t)
;;   ;; Don't save anything.
;;   (auto-save-default nil)
;;   ;; If file doesn't end with a newline on save, automatically add one.
;;   (require-final-newline t)
;;   :config
;;   (add-to-list 'auto-mode-alist '("Pipfile" . conf-toml-mode)))

;;;;dired-subtree
(use-package dired-subtree
  :ensure t
  :after dired
  :bind (:map dired-mode-map
              ("<tab>" . dired-subtree-toggle)
              ("<C-tab>" . dired-subtree-cycle)
              ("<backtab>" . dired-subtree-remove) ;; Shift + Tab
              ))

;;;;whitespace
(use-package whitespace
  :ensure nil
  :defer
  :hook (before-save . whitespace-cleanup))

;;;; ansi-color
(use-package ansi-color
  :ensure nil
  :defer
  :hook (compilation-filter . gopar/colorize-compilation-buffer)
  :init
  (defun gopar/compilation-nuke-ansi-escapes ()
    (toggle-read-only)
    (gopar/nuke-ansi-escapes (point-min) (point-max))
    (toggle-read-only))

  ;; https://stackoverflow.com/questions/3072648/cucumbers-ansi-colors-messing-up-emacs-compilation-buffer
  (defun gopar/colorize-compilation-buffer ()
    "Colorize the output from compile buffer"
    (read-only-mode -1)
    (ansi-color-apply-on-region (point-min) (point-max))
    (read-only-mode 1)))

;;;;Projectile
(use-package projectile
  :ensure
  :load t
  :commands projectile-project-root
  :hook (after-init . projectile-global-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)

  :custom
  (projectile-indexing-method 'hybrid)  ;; Not sure if this still needed?
  (projectile-per-project-compilation-buffer nil)
  :config
  (setq frame-title-format '(:eval (if (projectile-project-root) (projectile-project-root) "%b")))
  (advice-add 'projectile--run-project-cmd :override #'gopar/projectile--run-project-cmd)
  :init
  ;; Redefinig with my changes since projectil overwrites `compilation-buffer-name-function`
  (cl-defun gopar/projectile--run-project-cmd
      (command command-map &key show-prompt prompt-prefix save-buffers use-comint-mode)
    ;; "Run a project COMMAND, typically a test- or compile command.

    ;; Cache the COMMAND for later use inside the hash-table COMMAND-MAP.

    ;; Normally you'll be prompted for a compilation command, unless
    ;; variable `compilation-read-command'.  You can force the prompt
    ;; by setting SHOW-PROMPT.  The prompt will be prefixed with PROMPT-PREFIX.

    ;; If SAVE-BUFFERS is non-nil save all projectile buffers before
    ;; running the command.

    ;; The command actually run is returned."
    (let* ((project-root (projectile-project-root))
           (default-directory (projectile-compilation-dir))
           (command (projectile-maybe-read-command show-prompt
                                                   command
                                                   prompt-prefix)))
      (when command-map
        (puthash default-directory command command-map)
        (let ((hist (projectile--get-command-history project-root)))
          (cond
           ((eq projectile-cmd-hist-ignoredups t)
            (unless (string= (car-safe (ring-elements hist)) command)
              (ring-insert hist command)))
           ((eq projectile-cmd-hist-ignoredups 'erase)
            (let ((idx (ring-member hist command)))
              (while idx
                (ring-remove hist idx)
                (setq idx (ring-member hist command))))
            (ring-insert hist command))
           (t (ring-insert hist command)))))
      (when save-buffers
        (save-some-buffers (not compilation-ask-about-save)
                           (lambda ()
                             (projectile-project-buffer-p (current-buffer)
                                                          project-root))))
      (when projectile-per-project-compilation-buffer
        (setq compilation-buffer-name-function #'projectile-compilation-buffer-name)
        (setq compilation-save-buffers-predicate #'projectile-current-project-buffer-p))
      (unless (file-directory-p default-directory)
        (mkdir default-directory))
      (projectile-run-compilation command use-comint-mode)
      command))
  )

;;;;devdocs
(use-package devdocs
  :ensure t
  :defer
  :bind ("C-c M-d" . gopar/devdocs-lookup)
  :init
  (add-to-list 'display-buffer-alist
               '("\\*devdocs\\*"
                 display-buffer-in-side-window
                 (side . right)
                 (slot . 3)
                 (window-parameters . ((no-delete-other-windows . t)))
                 (dedicated . t)))

  (defun gopar/devdocs-lookup (&optional ask-docs)
    "Light wrapper around `devdocs-lookup` which pre-populates the function input with thing at point"
    (interactive "P")
    (let ((query (thing-at-point 'symbol t)))
      (devdocs-lookup ask-docs query)))


  :hook (((python-mode python-ts-mode) . (lambda () (setq-local devdocs-current-docs
                                                                '("django~4.2" "django_rest_framework" "python~3.11" "postgresql~11" "sqlite" "flask~3.0"))))
         (web-mode . (lambda () (setq-local devdocs-current-docs '("vue~3"
                                                                   "vue_router~4"
                                                                   "javascript"
                                                                   "typescript"
                                                                   "vitest"
                                                                   "moment"
                                                                   "tailwindcss"
                                                                   "html"
                                                                   "css"))))
         (typescript-mode . (lambda () (setq-local devdocs-current-docs '("vue~3"
                                                                          "vue_router~4"
                                                                          "javascript"
                                                                          "typescript"
                                                                          "vitest"
                                                                          "moment"))))))

;;;;ChatGpt
(use-package chatgpt-shell
  :ensure t
  :commands (chatgpt-shell--primary-buffer chatgpt-shell chatgpt-shell-prompt-compose)
  :bind (("C-x m" . chatgpt-shell)
         ("C-c C-e" . chatgpt-shell-prompt-compose)
         (:map chatgpt-shell-mode-map
               (("RET" . newline)
                ("M-RET" . shell-maker-submit)
                ("M-." . dictionary-lookup-definition)))
         (:map eshell-mode-map
               ("C-c C-e" . chatgpt-shell-prompt-compose)))
  :hook ((chatgpt-shell-mode . (lambda () (setq-local completion-at-point-functions nil)))
         (eshell-first-time-mode . chatgpt-shell-add-??-command-to-eshell))
  :init
  (setq shell-maker-root-path (concat user-emacs-directory "var/"))
  (add-to-list 'display-buffer-alist
               '("\\*chatgpt\\*"
                 display-buffer-in-side-window
                 (side . right)
                 (slot . 0)
                 (window-parameters . ((no-delete-other-windows . t)))
                 (dedicated . t)))
  (setq chatgpt-shell-model-version "gpt-4o-2024-08-06")
  :custom
  (chatgpt-shell-highlight-blocks nil)
  (shell-maker-prompt-before-killing-buffer nil)
  (chatgpt-shell-openai-key
   (auth-source-pick-first-password :host "api.openai.com"))
  (chatgpt-shell-transmitted-context-length 5)
  (chatgpt-shell-model-versions '("gpt-4o-2024-08-06")))

;;;; eshell
(use-package eshell
  :ensure nil
  :hook ((eshell-directory-change . gopar/sync-dir-in-buffer-name)
         (eshell-mode . gopar/eshell-specific-outline-regexp)
         (eshell-mode . gopar/eshell-setup-keybinding)
         (eshell-banner-load . (lambda ()
                                 (setq eshell-banner-message
                                       (concat (shell-command-to-string "fortune -s | cowsay") "\n\n"))))
         (eshell-mode . (lambda ()
                          (setq-local completion-styles '(basic)) ; maybe emacs21?
                          (setq-local corfu-count 10)
                          (setq-local corfu-auto nil)
                          (setq-local corfu-preview-current nil)
                          (setq-local completion-at-point-functions '(pcomplete-completions-at-point cape-file)))))
  :custom
  (eshell-scroll-to-bottom-on-input t)
  (eshell-highlight-prompt nil)
  (eshell-history-size 1024)
  (eshell-hist-ignoredups t)
  (eshell-input-filter 'gopar/eshell-input-filter)
  (eshell-cd-on-directory t)
  (eshell-list-files-after-cd nil)
  (eshell-pushd-dunique t)
  (eshell-last-dir-unique t)
  (eshell-last-dir-ring-size 32)
  :config
  (advice-add #'eshell-add-input-to-history
              :around
              #'gopar/adviced-eshell-add-input-to-history)

  :init
  (defun gopar/eshell-setup-keybinding ()
    ;; Workaround since bind doesn't work w/ eshell??
    (define-key eshell-mode-map (kbd "C-c >") 'gopar/eshell-redirect-to-buffer)
    (define-key eshell-hist-mode-map (kbd "M-r") 'consult-history))

  (defun gopar/adviced-eshell-add-input-to-history (orig-fun &rest r)
    "Cd to relative paths aren't that useful in history. Change to absolute paths."
    (require 'seq)
    (let* ((input (nth 0 r))
           (args (progn
                   (set-text-properties 0 (length input) nil input)
                   (split-string input))))
      (if (and (equal "cd" (nth 0 args))
               (not (seq-find (lambda (item)
                                ;; Don't rewrite "cd /ssh:" in history.
                                (string-prefix-p "/ssh:" item))
                              args))
               (not (seq-find (lambda (item)
                                ;; Don't rewrite "cd -" in history.
                                (string-equal "-" item))
                              args)))
          (apply orig-fun (list (format "cd %s"
                                        (expand-file-name (concat default-directory
                                                                  (nth 1 args))))))
        (apply orig-fun r))))

  (defun gopar/eshell-input-filter (input)
    "Do not save on the following:
       - empty lines
       - commands that start with a space, `ls`/`l`/`lsd`"
    (and
     (eshell-input-filter-default input)
     (eshell-input-filter-initial-space input)
     (not (string-prefix-p "ls " input))
     (not (string-prefix-p "lsd " input))
     (not (string-prefix-p "l " input))))

  (defun eshell/cat-with-syntax-highlighting (filename)
    "Like cat(1) but with syntax highlighting.Stole from aweshell"
    (let ((existing-buffer (get-file-buffer filename))
          (buffer (find-file-noselect filename)))
      (eshell-print
       (with-current-buffer buffer
         (if (fboundp 'font-lock-ensure)
             (font-lock-ensure)
           (with-no-warnings
             (font-lock-fontify-buffer)))
         (let ((contents (buffer-string)))
           (remove-text-properties 0 (length contents) '(read-only nil) contents)
           contents)))
      (unless existing-buffer
        (kill-buffer buffer))
      nil))
  (advice-add 'eshell/cat :override #'eshell/cat-with-syntax-highlighting)

  (defun gopar/sync-dir-in-buffer-name ()
    "Update eshell buffer to show directory path.Stolen from aweshell."
    (let* ((root (projectile-project-root))
           (root-name (projectile-project-name root)))
      (if root-name
          (rename-buffer (format "*eshell %s* %s" root-name (s-chop-prefix root default-directory)) t)
        (rename-buffer (format "*eshell %s*" default-directory) t))))

  (defun gopar/eshell-redirect-to-buffer (buffer)
    "Auto create command for redirecting to buffer."
    (interactive (list (read-buffer "Redirect to buffer: ")))
    (insert (format " >>> #<%s>" buffer)))

  (defun gopar/eshell-specific-outline-regexp ()
    (setq-local outline-regexp eshell-prompt-regexp)))

;;;; eshell syntax highlights
(use-package eshell-syntax-highlighting
  :ensure t
  :config
  (eshell-syntax-highlighting-global-mode +1)
  :init
  (defface eshell-syntax-highlighting-invalid-face
    '((t :inherit diff-error))
    "Face used for invalid Eshell commands."
    :group 'eshell-syntax-highlighting))


;;;; capf autosugest
(use-package capf-autosuggest
  :ensure t
  :hook ((eshell-mode . capf-autosuggest-mode))
  :custom
  (capf-autosuggest-dwim-next-line nil))

;;;; corfu
(use-package corfu
  :ensure t
  ;; Originally, I liked the idea of `corfu-send` but this makes it behave
  ;; in way that is different from 'fish' shell. So lets disable and see
  ;; how we feel about it in the future
  ;; :bind (:map corfu-map
  ;;             ("RET" . corfu-send))
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-auto-prefix 2)          ;; Minimun lenght prefix for completition
  (corfu-auto-delay 0)           ;; No delay completition
  (corfu-popupinfo-delay '(0.5 . 0.2)) ;; Automatically update info popup after numbr of seconds
  (corfu-preview-current 'insert) ;; Insert previewed candidate
  (corfu-preselect 'prompt) ;;
  (corfu-on-exact-match 'insert) ;; Insert when there's only one match
  (corfu-quit-no-match t)        ;; Quit when ther is no match
  :bind (:map corfu-map
              ("M-SPC"      . corfu-insert-separator)
              ("TAB"        . corfu-insert)
              ;; ([tab]        . corfu-insert)
              ("A-TAB"      . corfu-next)
              ("S-TAB"    . corfu-previous)
              ;; ("S-<return>" . corfu-insert)
              ("RET"        . corfu-insert))

  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode)
  :config
  (add-hook 'eshell-mode-hook
            (lambda () (setq-local corfu-quit-at-boundary t
                                   corfu-quit-no-match t
                                   corfu-auto nil)
              (corfu-mode))
            nil
            t)

  (defun corfu-enable-always-in-minibuffer ()
    "Enable Corfu in the minibuffer if Vertico/Mct are not active."
    (unless (or (bound-and-true-p mct--active)
                (bound-and-true-p vertico--input)
                (eq (current-local-map) read-passwd-map))
      ;; (setq-local corfu-auto nil) ;; Enable/disable auto completion
      (setq-local corfu-echo-delay nil ;; Disable automatic echo and popup
                  corfu-popupinfo-delay nil)
      (corfu-mode 1)))

  (add-hook 'minibuffer-setup-hook #'corfu-enable-always-in-minibuffer 1))

;;; dashboard
(use-package dashboard
  :ensure t
  :custom
  ;;(dashboard-startup-banner 'logo)
  (dashboard-startup-banner "/home/zio/.emacs.d/elpa/dashboard-20240923.2345/banners/logo.xpm") ;; we need to convert image to .xpm to avoid background img issues
  (dashboard-center-content t)
  (dashboard-show-shortcuts nil)
  (dashboard-set-heading-icons t)
  (dashboard-icon-type 'all-the-icons)
  (dashboard-set-file-icons t)
  (dashboard-projects-backend 'projectile)
  (dashboard-items '(
                     ;;(vocabulary)
                     (recents . 5)
                     (bookmarks . 5)
                     ;; (monthly-balance)
                     ))
  (dashboard-item-generators '(;; (monthly-balance . gopar/dashboard-ledger-monthly-balances)
                               ;;(vocabulary . gopar/dashboard-insert-vocabulary)
                               (recents . dashboard-insert-recents)
                               (bookmarks . dashboard-insert-bookmarks)
                               ))
  :init
  (defun gopar/dashboard-insert-vocabulary (list-size)
    (dashboard-insert-heading "Word of the Day:"
                              nil
                              (all-the-icons-faicon "newspaper-o"
                                                    :height 1.2
                                                    :v-adjust 0.0
                                                    :face 'dashboard-heading))
    (insert "\n")
    (let ((random-line nil)
          (lines nil))
      (with-temp-buffer
        (insert-file-contents (concat user-emacs-directory "words"))
        (goto-char (point-min))
        (setq lines (split-string (buffer-string) "\n" t))
        (setq random-line (nth (random (length lines)) lines))
        (setq random-line (string-join (split-string random-line) " ")))
      (insert "    " random-line)))

  (defun gopar/dashboard-ledger-monthly-balances (list-size)
    (interactive)
    (dashboard-insert-heading "Monthly Balance:"
                              nil
                              (all-the-icons-faicon "money"
                                                    :height 1.2
                                                    :v-adjust 0.0
                                                    :face 'dashboard-heading))
    (insert "\n")
    (let* ((categories '("Expenses:Food:Restaurants"
                         "Expenses:Food:Groceries"
                         "Expenses:Misc"))
           (current-month (format-time-string "%Y/%m"))
           (journal-file (expand-file-name "~/personal/finances/main.dat"))
           (cmd (format "ledger bal --flat --monthly --period %s %s -f %s"
                        current-month
                        (mapconcat 'identity categories " ")
                        journal-file)))

      (insert (shell-command-to-string cmd))))
  :config
  (dashboard-setup-startup-hook))

;;;; org-mode
(use-package org
  :defer
  :custom
  (org-agenda-include-diary t)
  ;; Where the org files live
  (org-directory "~/.emacs.d/org/")
  ;; Where archives should go
  (org-archive-location (concat (expand-file-name "~/.emacs.d/org/private/org-roam/gtd/archives.org") "::"))
  ;; Make sure we see syntax highlighting
  (org-src-fontify-natively t)
  ;; I dont use it for subs/super scripts
  (org-use-sub-superscripts nil)
  ;; Should everything be hidden?
  (org-startup-folded 'content)
  (org-M-RET-may-split-line '((default . nil)))
  ;; Don't hide stars
  (org-hide-leading-stars nil)
  (org-hide-emphasis-markers nil)
  ;; Show as utf-8 chars
  (org-pretty-entities t)
  ;; put timestamp when finished a todo
  (org-log-done 'time)
  ;; timestamp when we reschedule
  (org-log-reschedule t)
  ;; Don't indent the stars
  (org-startup-indented nil)
  (org-list-allow-alphabetical t)
  (org-image-actual-width nil)
  ;; Save notes into log drawer
  (org-log-into-drawer t)
  ;;
  (org-fontify-whole-heading-line t)
  (org-fontify-done-headline t)
  ;;
  (org-fontify-quote-and-verse-blocks t)
  ;; See down arrow instead of "..." when we have subtrees
  ;; (org-ellipsis "⤵")
  ;; catch invisible edit
  ( org-catch-invisible-edits 'show-and-error)
  ;; Only useful for property searching only but can slow down search
  (org-use-property-inheritance t)
  ;; Count all children TODO's not just direct ones
  (org-hierarchical-todo-statistics nil)
  ;; Unchecked boxes will block switching the parent to DONE
  (org-enforce-todo-checkbox-dependencies t)
  ;; Don't allow TODO's to close without their dependencies done
  (org-enforce-todo-dependencies t)
  (org-track-ordered-property-with-tag t)
  ;; Where should notes go to? Dont even use them tho
  (org-default-notes-file (concat org-directory "notes.org"))
  ;; The right side of | indicates the DONE states
  (org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "IN-PROGRESS(i!)" "WAITING(w!)" "|" "DONE(d!)" "CANCELED(c!)" "DELEGATED(p!)")))
  ;; Needed to allow helm to compute all refile options in buffer
  (org-outline-path-complete-in-steps nil)
  (org-deadline-warning-days 2)
  (org-log-redeadline t)
  (org-log-reschedule t)
  ;; Repeat to previous todo state
  ;; If there was no todo state, then dont set a state
  (org-todo-repeat-to-state t)
  ;; Refile options
  (org-refile-use-outline-path 'file)
  (org-refile-allow-creating-parent-nodes 'confirm))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; WEB-DEVELOPMENT-CONFIG ;;;;

(use-package treesit
  :mode (("\\.tsx\\'" . tsx-ts-mode)
         ("\\.js\\'"  . typescript-ts-mode)
         ("\\.mjs\\'" . typescript-ts-mode)
         ("\\.mts\\'" . typescript-ts-mode)
         ("\\.cjs\\'" . typescript-ts-mode)
         ("\\.ts\\'"  . typescript-ts-mode)
         ("\\.jsx\\'" . tsx-ts-mode)
         ("\\.json\\'" .  json-ts-mode)
         ("\\.Dockerfile\\'" . dockerfile-ts-mode)
         ("\\.prisma\\'" . prisma-ts-mode)
         ;; More modes defined here...
         )
  :preface
  (defun os/setup-install-grammars ()
    "Install Tree-sitter grammars if they are absent."
    (interactive)
    (dolist (grammar
             '((css . ("https://github.com/tree-sitter/tree-sitter-css" "v0.20.0"))
               (bash "https://github.com/tree-sitter/tree-sitter-bash")
               (html . ("https://github.com/tree-sitter/tree-sitter-html" "v0.20.1"))
               (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript" "v0.21.2" "src"))
               (json . ("https://github.com/tree-sitter/tree-sitter-json" "v0.20.2"))
               (python . ("https://github.com/tree-sitter/tree-sitter-python" "v0.20.4"))
               (go "https://github.com/tree-sitter/tree-sitter-go" "v0.20.0")
               (markdown "https://github.com/ikatyang/tree-sitter-markdown")
               (make "https://github.com/alemuller/tree-sitter-make")
               (elisp "https://github.com/Wilfred/tree-sitter-elisp")
               (cmake "https://github.com/uyha/tree-sitter-cmake")
               (c "https://github.com/tree-sitter/tree-sitter-c")
               (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
               (toml "https://github.com/tree-sitter/tree-sitter-toml")
               (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "tsx/src"))
               (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "typescript/src"))
               (yaml . ("https://github.com/ikatyang/tree-sitter-yaml" "v0.5.0"))
               (prisma "https://github.com/victorhqc/tree-sitter-prisma")))
      (add-to-list 'treesit-language-source-alist grammar)
      ;; Only install `grammar' if we don't already have it
      ;; installed. However, if you want to *update* a grammar then
      ;; this obviously prevents that from happening.
      (unless (treesit-language-available-p (car grammar))
        (treesit-install-language-grammar (car grammar)))))

  ;; Optional, but recommended. Tree-sitter enabled major modes are
  ;; distinct from their ordinary counterparts.
  ;;
  ;; You can remap major modes with `major-mode-remap-alist'. Note
  ;; that this does *not* extend to hooks! Make sure you migrate them
  ;; also
  (dolist (mapping
           '((python-mode . python-ts-mode)
             (css-mode . css-ts-mode)
             (typescript-mode . typescript-ts-mode)
             (js-mode . typescript-ts-mode)
             (js2-mode . typescript-ts-mode)
             (c-mode . c-ts-mode)
             (c++-mode . c++-ts-mode)
             (c-or-c++-mode . c-or-c++-ts-mode)
             (bash-mode . bash-ts-mode)
             (css-mode . css-ts-mode)
             (json-mode . json-ts-mode)
             (js-json-mode . json-ts-mode)
             (sh-mode . bash-ts-mode)
             (sh-base-mode . bash-ts-mode)))
    (add-to-list 'major-mode-remap-alist mapping))
  :config
  (os/setup-install-grammars))

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode)
  :bind (:map flycheck-mode-map
              ("M-n" . flycheck-next-error) ; optional but recommended error navigation
              ("M-p" . flycheck-previous-error)))

(use-package lsp-mode
  :diminish "LSP"
  :ensure t
  :hook ((lsp-mode . lsp-diagnostics-mode)
         (lsp-mode . lsp-enable-which-key-integration)
         ((tsx-ts-mode
           typescript-ts-mode
           js-ts-mode) . lsp-deferred))
  :custom
  (lsp-keymap-prefix "C-c l")           ; Prefix for LSP actions
  (lsp-completion-provider :none)       ; Using Corfu as the provider
  (lsp-diagnostics-provider :flycheck)
  (lsp-session-file (locate-user-emacs-file ".lsp-session"))
  (lsp-log-io nil)                      ; IMPORTANT! Use only for debugging! Drastically affects performance
  (lsp-keep-workspace-alive nil)        ; Close LSP server if all project buffers are closed
  (lsp-idle-delay 0.5)                  ; Debounce timer for `after-change-function'
  ;; core
  (lsp-enable-xref t)                   ; Use xref to find references
  (lsp-auto-configure t)                ; Used to decide between current active servers
  (lsp-eldoc-enable-hover t)            ; Display signature information in the echo area
  (lsp-enable-dap-auto-configure t)     ; Debug support
  (lsp-enable-file-watchers nil)
  (lsp-enable-folding nil)              ; I disable folding since I use origami
  (lsp-enable-imenu t)
  (lsp-enable-indentation nil)          ; I use prettier
  (lsp-enable-links nil)                ; No need since we have `browse-url'
  (lsp-enable-on-type-formatting nil)   ; Prettier handles this
  (lsp-enable-suggest-server-download t) ; Useful prompt to download LSP providers
  (lsp-enable-symbol-highlighting t)     ; Shows usages of symbol at point in the current buffer
  (lsp-enable-text-document-color nil)   ; This is Treesitter's job

  (lsp-ui-sideline-show-hover nil)      ; Sideline used only for diagnostics
  (lsp-ui-sideline-diagnostic-max-lines 20) ; 20 lines since typescript errors can be quite big
  ;; completion
  (lsp-completion-enable t)
  (lsp-completion-enable-additional-text-edit t) ; Ex: auto-insert an import for a completion candidate
  (lsp-enable-snippet t)                         ; Important to provide full JSX completion
  (lsp-completion-show-kind t)                   ; Optional
  ;; headerline
  (lsp-headerline-breadcrumb-enable t)  ; Optional, I like the breadcrumbs
  (lsp-headerline-breadcrumb-enable-diagnostics nil) ; Don't make them red, too noisy
  (lsp-headerline-breadcrumb-enable-symbol-numbers nil)
  (lsp-headerline-breadcrumb-icons-enable nil)
  ;; modeline
  (lsp-modeline-code-actions-enable nil) ; Modeline should be relatively clean
  (lsp-modeline-diagnostics-enable nil)  ; Already supported through `flycheck'
  (lsp-modeline-workspace-status-enable nil) ; Modeline displays "LSP" when lsp-mode is enabled
  (lsp-signature-doc-lines 1)                ; Don't raise the echo area. It's distracting
  (lsp-ui-doc-use-childframe t)              ; Show docs for symbol at point
  (lsp-eldoc-render-all nil)            ; This would be very useful if it would respect `lsp-signature-doc-lines', currently it's distracting
  ;; lens
  (lsp-lens-enable nil)                 ; Optional, I don't need it
  ;; semantic
  (lsp-semantic-tokens-enable nil)      ; Related to highlighting, and we defer to treesitter

  :init
  (setq lsp-use-plists t)

  :preface
  (defun lsp-booster--advice-json-parse (old-fn &rest args)
    "Try to parse bytecode instead of json."
    (or
     (when (equal (following-char) ?#)

       (let ((bytecode (read (current-buffer))))
         (when (byte-code-function-p bytecode)
           (funcall bytecode))))
     (apply old-fn args)))
  (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
    "Prepend emacs-lsp-booster command to lsp CMD."
    (let ((orig-result (funcall old-fn cmd test?)))
      (if (and (not test?)                             ;; for check lsp-server-present?
               (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
               lsp-use-plists
               (not (functionp 'json-rpc-connection))  ;; native json-rpc
               (executable-find "emacs-lsp-booster"))
          (progn
            (message "Using emacs-lsp-booster for %s!" orig-result)
            (cons "emacs-lsp-booster" orig-result))
        orig-result)))
  :init
  (setq lsp-use-plists t)
  ;; Initiate https://github.com/blahgeek/emacs-lsp-booster for performance
  (advice-add (if (progn (require 'json)
                         (fboundp 'json-parse-buffer))
                  'json-parse-buffer
                'json-read)
              :around
              #'lsp-booster--advice-json-parse)
  (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command))

(use-package lsp-completion
  :no-require
  :hook ((lsp-mode . lsp-completion-mode)))

(use-package lsp-ui
  :ensure t
  :commands
  (lsp-ui-doc-show
   lsp-ui-doc-glance)
  :bind (:map lsp-mode-map
              ("C-c C-d" . 'lsp-ui-doc-glance))
  :after (lsp-mode evil)
  :config (setq lsp-ui-doc-enable t
                evil-lookup-func #'lsp-ui-doc-glance ; Makes K in evil-mode toggle the doc for symbol at point
                lsp-ui-doc-show-with-cursor nil      ; Don't show doc when cursor is over symbol - too distracting
                lsp-ui-doc-include-signature t       ; Show signature
                lsp-ui-doc-position 'at-point))

(use-package lsp-eslint
  :demand t
  :after lsp-mode)

(use-package lsp-tailwindcss
  :ensure t
  :init (setq lsp-tailwindcss-add-on-mode t)
  :config
  (dolist (tw-major-mode
           '(css-mode
             css-ts-mode
             typescript-mode
             typescript-ts-mode
             tsx-ts-mode
             js2-mode
             js-ts-mode
             clojure-mode))
    (add-to-list 'lsp-tailwindcss-major-modes tw-major-mode)))

;;; APHELEIA
;; auto-format different source code files extremely intelligently
;; https://github.com/radian-software/apheleia
(use-package apheleia
  :ensure apheleia
  :diminish ""
  :defines
  apheleia-formatters
  apheleia-mode-alist
  :functions
  apheleia-global-mode
  :config
  (setf (alist-get 'prettier-json apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath))
  (apheleia-global-mode +1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Ibuffer
;; Ibuffer Icons Sets It'S Own Local Buffer Format And Overrides The =ibuffer-formats= variable.
;; So in order for ibuffer-vc to work, I have to include it in the icons-buffer format -_-
(use-package all-the-icons-ibuffer
  :ensure t
  :defer
  :custom
  (all-the-icons-ibuffer-formats
   `((mark modified read-only locked vc-status-mini
           ;; Here you may adjust by replacing :right with :center or :left
           ;; According to taste, if you want the icon further from the name
           " " ,(if all-the-icons-ibuffer-icon
                    '(icon 2 2 :left :elide)
                  "")
           ,(if all-the-icons-ibuffer-icon
                (propertize " " 'display `(space :align-to 8))
              "")
           (name 18 18 :left :elide)
           " " (size-h 9 -1 :right)
           " " (mode+ 16 16 :left :elide)
           " " (vc-status 16 16 :left)
           " " vc-relative-file)
     (mark " " (name 16 -1) " " filename)))

  :hook (ibuffer-mode . all-the-icons-ibuffer-mode))

(use-package magit
  :ensure t
  :commands magit-get-current-branch
  :defer
  :bind ("C-x g" . magit)
  :hook (magit-mode . magit-wip-mode)
  :custom
  (magit-diff-refine-hunk 'all)
  (magit-process-finish-apply-ansi-colors t)
  :init
  (setq magit-process-finish-apply-ansi-colors t)
  (setq auth-sources '("~/.authinfo.gpg"))
  ;; Define a function to retrieve credentials from auth-source
  (defun my-magit-get-credentials (prompt)
    "Retrieve GitHub credentials dynamically from auth-source for Magit.
The PROMPT is ignored, and the function uses `auth-source` to retrieve credentials."
    (let* ((repo-dir (magit-toplevel))
           (user (magit-get "user.name"))  ; Retrieve the Git user from the repo
           (auth-info (auth-source-search :host "github.com" :user user :require '(:user :secret))))
      (when auth-info
        (let ((secret (plist-get (car auth-info) :secret)))
          (if (functionp secret)
              (funcall secret)  ; Call the function to get the secret
            secret)))))

  (setq magit-process-find-password-functions '(my-magit-get-credentials))

  (defun magit/undo-last-commit (number-of-commits)
    "Undoes the latest commit or commits without loosing changes"
    (interactive "P")
    (let ((num (if (numberp number-of-commits)
                   number-of-commits
                 1)))
      (magit-reset-soft (format "HEAD^%d" num)))))

(use-package forge
  :ensure t
  :after magit)

(use-package git-gutter
  :ensure t
  :hook (after-init . global-git-gutter-mode))

;; https://github.com/purcell/ibuffer-vc/blob/master/ibuffer-vc.el
(use-package ibuffer-vc
  :ensure t
  :hook (ibuffer . (lambda ()
                     (ibuffer-vc-set-filter-groups-by-vc-root)
                     (unless (eq ibuffer-sorting-mode 'alphabetic)
                       (ibuffer-do-sort-by-vc-status)
                       ;; (ibuffer-do-sort-by-alphabetic)
                       )
                     )))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("b9761a2e568bee658e0ff723dd620d844172943eb5ec4053e2b199c59e0bcc22" "6e33d3dd48bc8ed38fd501e84067d3c74dfabbfc6d345a92e24f39473096da3f" "f4d1b183465f2d29b7a2e9dbe87ccc20598e79738e5d29fc52ec8fb8c576fcfd" "93011fe35859772a6766df8a4be817add8bfe105246173206478a0706f88b33d" "88f7ee5594021c60a4a6a1c275614103de8c1435d6d08cc58882f920e0cec65e" "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d" "dfb1c8b5bfa040b042b4ef660d0aab48ef2e89ee719a1f24a4629a0c5ed769e8" "f5f80dd6588e59cfc3ce2f11568ff8296717a938edd448a947f9823a4e282b66" "df782d1d31bc53de4034dacf7dbf574bf7513df8104486738a9b425693451eba" "b754d3a03c34cfba9ad7991380d26984ebd0761925773530e24d8dd8b6894738" "81f53ee9ddd3f8559f94c127c9327d578e264c574cda7c6d9daddaec226f87bb" "e4a702e262c3e3501dfe25091621fe12cd63c7845221687e36a79e17cf3a67e0" "d481904809c509641a1a1f1b1eb80b94c58c210145effc2631c1a7f2e4a2fdf4" "2721b06afaf1769ef63f942bf3e977f208f517b187f2526f0e57c1bd4a000350" "3c08da65265d80a7c8fc99fe51df3697d0fa6786a58a477a1b22887b4f116f62" "48042425e84cd92184837e01d0b4fe9f912d875c43021c3bcb7eeb51f1be5710" "0c83e0b50946e39e237769ad368a08f2cd1c854ccbcd1a01d39fdce4d6f86478" "c20728f5c0cb50972b50c929b004a7496d3f2e2ded387bf870f89da25793bb44" "d2ab3d4f005a9ad4fb789a8f65606c72f30ce9d281a9e42da55f7f4b9ef5bfc6" "daa27dcbe26a280a9425ee90dc7458d85bd540482b93e9fa94d4f43327128077" default))
 '(org-fold-catch-invisible-edits 'show-and-error nil nil "Customized with use-package org")
 '(package-selected-packages
   '(magit autothemer which-key ibuffer-vc dashboard spacious-padding vertico vertico-posframe solaire-mode all-the-icons all-the-icons-nerd-fonts treemacs nerd-icons-completion kanagawa-themes doom-themes doom-modeline)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fringe ((t :background "#2d2b55")))
 '(header-line ((t :box (:line-width 4 :color "#1b1b38" :style nil))))
 '(header-line-highlight ((t :box (:color "#e3e9fa"))))
 '(keycast-key ((t)))
 '(line-number ((t :background "#2d2b55")))
 '(mode-line ((t :box (:line-width 6 :color "#1b1b38" :style nil))))
 '(mode-line-active ((t :box (:line-width 6 :color "#1b1b38" :style nil))))
 '(mode-line-highlight ((t :box (:color "#e3e9fa"))))
 '(mode-line-inactive ((t :box (:line-width 6 :color "#28264c" :style nil))))
 '(tab-bar-tab ((t :box (:line-width 4 :color "#2d2b55" :style nil))))
 '(tab-bar-tab-inactive ((t :box (:line-width 4 :color "#1e1e3f" :style nil))))
 '(tab-line-tab ((t)))
 '(tab-line-tab-active ((t)))
 '(tab-line-tab-inactive ((t)))
 '(vertical-border ((t :background "#2d2b55" :foreground "#2d2b55")))
 '(window-divider ((t (:background "#2d2b55" :foreground "#2d2b55"))))
 '(window-divider-first-pixel ((t (:background "#2d2b55" :foreground "#2d2b55"))))
 '(window-divider-last-pixel ((t (:background "#2d2b55" :foreground "#2d2b55")))))
