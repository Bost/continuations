;; -*- origami-fold-style: triple-braces -*-
;; start & set scheme REPL: `M-x run-geiser' `M-x geiser-set-scheme'
;; folding: M-x origami-forward-toggle-node / z a

;; The Beer {{{
;; ... let's capture this moment for a while...

;; Quick recap on LISP
;; L-I-S t   P-rocessing
;; constant function fc: AnyType (ignored & ignored) -> Number
(define (fc) 1)

;; function of one argument fhw: String (infered) -> String
(define (fhw arg) (string-append "Hello World, " arg))
;; }}}

;; The Motivation {{{
;; Foo.java ... (lein repl)

;; [1] loop-fn is a compound-procedure of one argument `ls'
;; [2] If `ls' is '() then return the identity of `*', finish the current loop
;;     and proceed to the next elem of the `ls'
;; [3] If the first elem of `ls' is `0' then return the absorbing elem of `*',
;;     finish the current loop and proceed to the next elem of the `ls'.
;;     Inefficient :-(
;; [4] Multiply & loop around
;; See also http://www.cs.sfu.ca/CourseCentral/383/havens/notes/Lecture06.pdf"
(define (multiply init-ls)
  "Multiply the elements of a list. Inefficient"
  (let loop-fn ((ls init-ls))                       ;; [1]
    (cond
     ((null? ls) 1)                                 ;; [2]
     ((= (car ls) 0) 0)                             ;; [3]
     (else (* (car ls) (loop-fn (cdr ls)))))))      ;; [4]

(multiply '(1 2 3 4 5))     ;; = 120
(multiply '(7 3 8 0 1 9 5)) ;; = 0
(multiply '())              ;; = 1
;; }}}

;; The Fallacy {{{
(define (to-str arg)
  "Helper function. Convert `arg' to string."
  (cond
   ((string? arg) arg)
   ((number? arg) (number->string arg))
   (else "to-str not implemented for this type")))

(define (multiply init-ls)
  "Inefficient & buggy"
  (string-append
   "The result is: "
   (to-str
    (let loop-fn ((ls init-ls))
      (cond
       ((null? ls) 1)
       ((= (car ls) 0) " a bloody 0. Haha!")
       (else (* (car ls) (loop-fn (cdr ls)))))))))
(multiply '(1 2 3 4 5))     ;; = "The result is: 120"
(multiply '())              ;; = "The result is: 1"
(multiply '(7 3 8 0 1 9 5)) ;; = Wrong type
;; }}}

;; The Better Way {{{
;; [1] Create continuation function `break' wrapping around the current
;;     computation - the `(let loop-fn ...)'
;; [2] loop-fn is a compound-procedure of one arg `ls'
;; [3] If `ls' is '() then return the identity of `*', finish the current loop
;;     and proceed to the next elem of the `ls'
;; [4] Continue with the rest of the computation
;;         `(string-append "The result is: " (to-string ...))'
;;     with the value of current computation being 0 thus effectivelly breaking
;;     out of the loop.
;; [5] Multiply & loop around
;; See also http://www.cs.sfu.ca/CourseCentral/383/havens/notes/Lecture06.pdf"
(define (multiply init-ls)
  "Multiply the elements of a list. Efficient but malevolent."
  (string-append
   "The result is: "
   (to-str
    (call/cc
     (lambda (break)                                         ;; [1]
       (let loop-fn ((ls init-ls))                      ;; [2]
         (cond
          ((null? ls) 1)                                ;; [3]
          ((= (car ls) 0) (break " a bloody 0. Haha!")) ;; [4]
          (else (* (car ls) (loop-fn (cdr ls))))))))))) ;; [5]

(multiply '(1 2 3 4 5))     ;; = "The result is: 120"
(multiply '())              ;; = "The result is: 1"
(multiply '(7 3 8 0 1 9 5)) ;; = "The result is: 0"
;; }}}

;; The Bigger Picture ? {{{
;; go quarry, emacs undo <f12>, batch vs. interactive, compile errors,
;; GUI validation, "smartness"
;; }}}

;; The Wiki {{{
;; https://en.wikipedia.org/wiki/Continuation (see The Beer)
;; `call/cc' alias for `call-with-current-continuation'
;; https://www.gnu.org/software/guile/manual/html_node/Continuations.html
(call-with-current-continuation (lambda (k) 1))  ;; = 1
(call/cc (lambda (k) 1))                         ;; = 1

;; reset & shift: Kenichi Asai - the take function (card deck)
;; }}}

;; The Playground {{{

;; call/cc creates "aborting" continuations that ignore the rest of the
;; computation inside the body of the (lambda (k) ...) when k is invoked. See
;; delimited continuations
(call/cc
 (lambda (k)
   ;; the current computation `(/ 30 5 3)' is aborted, i.e. effectivelly ignored
   (/ 30 5 (k 2) 3)))
;; = 2


(define *k* '())   ;; global definition

(call/cc
 ;; k is the continuation function
 ;; it represents (lambda (v) v)
 ;; and this time it's executed as: (+ 1 3)
 (lambda (k)
   (set! *k* k)
   (+ 1 3)))
;; = 4
(*k* (* 2 3)) ;; executed as ((lambda (v) v) (* 2 3))
;; = 6

(call/cc
 ;; k is the continuation function
 ;; it represents (lambda (v) v)
 ;; and this time it's executed as: 2
 (lambda (k)
   (set! *k* k)
   (+ 1 (k 2) 3)))
;; = 2

(*k* (* 2 3)) ;; executed as ((lambda (v) v) (* 2 3))
;; = 6


;; `begin' is necessary every time you need several forms when the syntax allows only one form.
;; (begin f1 f2 ... fn) evaluates f1 ... fn in turn and then returns the value of fn.
;; `begin' is normally used when there is some side-effect e.g (begin (set! y (+ y 1)) y)


(+
 (call/cc
  ;; k is the continuation function
  ;; it represents (lambda (v) (+ v 5))
  ;; and this time it's executed as: (+ (* 3 4) 5)
  (lambda (k)
    (begin
      (set! *k* k)
      (* 3 4))))
 5)
;; = 17
(*k* (* 2 3)) ;; executed as ((lambda (v) (+ v 5)) (* 2 3))
;; = 11

(+
 (call/cc
  ;; k is the continuation function
  ;; it represents (lambda (v) (+ v 5))
  ;; and this time it's executed as: (+ (* 3 4) 5)
  (lambda (k)
    (begin
      (set! *k* k)
      (k (* 3 4)))))
 5)
;; = 17
(*k* (* 2 3)) ;; executed as ((lambda (v) (+ v 5)) (* 2 3))
;; = 11

(define (foo n)
  (* 2
     (call/cc
      ;; k is the continuation function
      ;; it represents (lambda (v) (* 2 v))
      ;; this time it's executed as: (define (foo n) (* 2 (+ n 1)))
      (lambda (k)
        (begin
          (set! *k* k)
          (+ n 1))))))
foo     ;; = #<procedure foo (n)>
*k*     ;; = ()
(foo 5) ;; = 12   ;; i.e. (* 2 (+ 5 1)) and *k* is set to be (lambda (v) (* 2 v))
*k*     ;; #<continuation 55ccca0827e0>
(*k* 5) ;; = 10



;; https://en.wikipedia.org/wiki/Continuation#Coroutines
;; A naive queue for thread scheduling. It holds a list of continuations
;; "waiting to run".
(define *queue* '())
(define (empty-queue?)
  (null? *queue*))
(define (enqueue x)
  (set! *queue* (append *queue* (list x))))
(define (dequeue)
  (let ((x (car *queue*)))
    (set! *queue* (cdr *queue*))
    x))

;; This starts a new thread running (proc).
(define (fork proc)
  (call/cc
   (lambda (k)
     (enqueue k)
     (proc))))

;; This yields the processor to another thread, if there is one.
(define (yield)
  (call/cc
   (lambda (k)
     (enqueue k)
     ((dequeue)))))

;; This terminates the current thread, or the entire program if there are no
;; other threads left.
(define (thread-exit)
  (if (empty-queue?)
      (exit)
      ((dequeue))))
;; The body of some typical Scheme thread that does stuff:
(define (do-stuff-n-print str)
  (let loop ((n 0))
    (format #t "~A ~A\n" str n)
    (yield)
    (loop (+ n 1))))

;; Create two threads, and start them running.
(fork (do-stuff-n-print "This is AAA"))
(fork (do-stuff-n-print "Hello from BBB"))
(thread-exit)
;; }}}

;; The Clojure {{{
;; Q: Similarity of 1st class Continuations (FCC) & Continuation Passing Style (CPS)?
;; https://github.com/Bost/monad_koans/blob/master/src/koans/5_continuation_monad.clj

;; Threading macros: -> ->> as->

;; https://github.com/swannodette/delimc
;; Q: Parallel computation: reset & shift + future & delay & promise?
;; }}}

;; The FORCE {{{
;; Delimited Continuations for Everyone by Kenichi Asai
;; https://www.youtube.com/watch?v=QNM-njddhIw
(use-modules (ice-9 control))
(+ 5 (reset (+ 2 3)))
(+ 5 (reset (+ 2 (shift k 2)  3)))

;; William Byrd
;; https://www.youtube.com/watch?v=2GfFlfToBCo

;; Or in generall
;; https://www.youtube.com/results?search_query=continuations
;; }}}
