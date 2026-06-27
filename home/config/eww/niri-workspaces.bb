#!/usr/bin/env bb
;; Feed eww the niri workspace list as JSON, refreshed on every workspace
;; event. eww `deflisten` reads one JSON array per line; the yuck iterates it.

(require '[cheshire.core :as json]
         '[babashka.process :as p]
         '[clojure.string :as str]
         '[clojure.java.io :as io])

(defn snapshot
  "Return the current niri workspaces as an eww-shaped JSON array string."
  []
  (->> (json/parse-string (:out (p/sh "niri" "msg" "--json" "workspaces")) true)
       (sort-by :idx)
       (mapv #(select-keys % [:idx :id :is_focused :is_urgent]))
       json/generate-string))

(defn emit! [] (println (snapshot)) (flush))

(emit!)
(let [proc (p/process ["niri" "msg" "--json" "event-stream"] {:out :stream})]
  (with-open [rdr (io/reader (:out proc))]
    (doseq [line (line-seq rdr)]
      (when (str/includes? line "Workspace")
        (emit!)))))
