(ns continuations.delimc
  (:require
   [delimc.core :refer :all]))


;; reset - delimits the continuation
;; shift - clear, bind and execute the continuation

(def cont1 (atom nil))
(def cont2 (atom nil))
(def cont3 (atom nil))
(def cont4 (atom nil))

(reset (+ 1 (apply (fn [a b c]
                     (+ (shift k
                               (reset! cont1 k)
                               (k 1))
                        a b c))
                   3 4 (list 5)))) ;; 14

(@cont1 2) ;; 15

(reset
 (+ 1 (reset (shift k
                    (reset! cont2 k)
                    (k 2)))
    (reset (shift k
                  (reset! cont3 k)
                  (k 3))))) ;; 6

(@cont2 4) ;; 8
(@cont3 10) ;; 15

(reset (str "Hello" (shift k
                           (reset! cont4 k)
                           (k ", today is "))
            "a nice day!")) ; "Hello, today is a nice day"

(@cont4 ", yesterday was ") ; "Hello, yesterday was a nice day"
