;;; org-gtd.el --- Org-mode GTD review

;; Copyright (C) 2015 Abhi Yerra

;; Author: Abhi Yerra <abhi@berkeley.edu>
;; Version: 1.0
;; Keywords: gtd, orgmode
;; URL: http://github.com/abhiyerra/org-gtd

;;; Commentary:

;; These are utilities to help do GTD under org-mode. One of the major
;; tasks that is done in GTD is the daily review and the weekly
;; review.


(defun org-gtd-daily-review ()
  (interactive)
;; Anything that was due that wasn't done make sue that it can get
;; done and updated. Make sure that it has an appropriate outcome and
;; next-action.
  )

(defun org-gtd-task/delegate-it ()
  (org-deadline '(16 16))
  (org-todo "WAITING")
;; There should be a method here that runs a bunch of custom
;; delgate-it functions.
  )

(defun org-gtd-task/single-stage-project ()
  (org-entry-put (point) "NEXT_ACTION"
                 (read-from-minibuffer
                  (concat (nth 4 (org-heading-components))
                          ". Next Action: ")))
  (if (yes-or-no-p "Defer it?")
      (progn
        (org-schedule '(16 16))
        (org-todo "DEFERRED")
        ;; Move it to the Someday heading
        )
    (if (yes-or-no-p "Delegate it?")
        (org-gtd-task/delegate-it)
      (progn
        (org-deadline '(16 16))
        (org-todo "NEXT-ACTION")))))

(defun org-gtd-task/multi-stage-project ()
  ;; Plan out the occurance to check if it has an outcome and
  ;; next_action.
  (org-todo "PLAN")
  (org-deadline '(16 16)))

(defun org-gtd-task/long-task ()
  (org-entry-put (point)
                 "OUTCOME"
                 (read-from-minibuffer
                  (concat (nth 4 (org-heading-components)) ". Outcome: ")))
  (if (yes-or-no-p "Is it a multi-stage project?")
      (org-gtd-task/multi-stage-project)
    (org-gtd-task/single-stage-project)))

(defun org-gtd-task/non-actionable-task ()
  ;; No-op
  ;; Move this task to Someday
  )

(defun org-gtd-task-review ()
  (interactive)
  (if (yes-or-no-p (concat "Is "
                           (nth 4 (org-heading-components))
                           " an actionable task? "))
      (if (yes-or-no-p "Will it take less than 2 mins?")
          (message "Do it")
        (org-gtd-task/long-task))
    (org-gtd-task/non-actionable-task)
    ))

(defun org-gtd-new-task ()
  (interactive)
  (org-insert-todo-heading "TODO")
  (insert (read-from-minibuffer "What is the action?"))
  (org-gtd-task-review))

;; - [ ] Make sure that there are tags on everything.
(defun org-gtd-review (todo-state)
  (interactive)
  (org-map-entries
   '(lambda ()
      (let ((cur-todo-state (nth 2 (org-heading-components)))
            (cur-title (nth 4 (org-heading-components))))
        (if cur-todo-state
            (progn
              (unless (org-entry-get (point) "OUTCOME")
                (org-entry-put (point) "OUTCOME"
                               (read-from-minibuffer (concat cur-title ". Outcome: "))))
              (unless (org-entry-get (point) "NEXT_ACTION")
                (org-entry-put (point) "NEXT_ACTION"
                               (read-from-minibuffer (concat cur-title ". Next Action: "))))
              ))))
      todo-state 'agenda))

  ;; If something is past the deadline review the nextaction and outcome. Update it.
  ;;                            (if (or (eq (org-entry-get (point) "LastReviewed") nil)
  ;; > (org-entry-get (point) "LastReviewed")  15 days
  ;;                          )
