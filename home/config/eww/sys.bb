#!/usr/bin/env bb
;; Stream system state to eww as one JSON object per line (deflisten reads it,
;; widgets read sys.vol / sys.muted / sys.net). This script does the querying and
;; parsing; the widgets stay declarative.

(require '[babashka.process :as p]
         '[cheshire.core :as json]
         '[clojure.string :as str])

(defn sh [& args]
  (try (str/trim (:out (apply p/sh args))) (catch Exception _ "")))

(defn volume []
  (let [m (re-find #"[0-9]*\.[0-9]+"
                   (sh "wpctl" "get-volume" "@DEFAULT_AUDIO_SINK@"))]
    (if m (int (Math/round (* 100 (Double/parseDouble m)))) 0)))

(defn muted? []
  (str/includes? (sh "wpctl" "get-volume" "@DEFAULT_AUDIO_SINK@") "MUTED"))

(defn network []
  (or (some (fn [line]
              (let [[type state conn] (str/split line #":")]
                (when (and (#{"wifi" "ethernet"} type) (= state "connected"))
                  conn)))
            (str/split-lines
             (sh "nmcli" "-t" "-f" "TYPE,STATE,CONNECTION" "device" "status")))
      ""))

(loop []
  (println (json/generate-string {:vol (volume) :muted (muted?) :net (network)}))
  (flush)
  (Thread/sleep 2000)
  (recur))
