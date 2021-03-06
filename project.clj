(defproject org.clojars.bost/continuations :lein-v
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "EPL-2.0 OR GPL-2.0-or-later WITH Classpath-exception-2.0"
            :url "https://www.eclipse.org/legal/epl-2.0/"}
  :dependencies
  [
   [org.clojure/clojure "1.10.0"]
   ;; Forked from https://github.com/swannodette/delimc
   [org.clojars.bost/delimc "0.0.0-38-0x29c5"]
   ]
  :java-source-paths ["java"]
  :plugins
  [
   ;; Drive leiningen project version from git instead of the other way around
   [com.roomkey/lein-v "7.0.0"]
   ;; autorecompile changed java files
   [lein-virgil "0.1.9"]
   ]
  :repl-options {:init-ns continuations.delimc})
