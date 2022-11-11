
(* Release builds may wish to have this included after log.sml, in
   order to eliminate debug calls entirely. (Though you may find it
   makes very little difference.)

   This is for builds not using category logging; those using category
   logging should include category-log-fn-release.sml after
   category-log-fn.sml instead.
*)
structure Log = LogInfo

