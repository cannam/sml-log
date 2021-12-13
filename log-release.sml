
(* Release builds may wish to have this included after log.sml, in
   order to eliminate debug calls entirely. (Though you may find it
   makes very little difference.)

   If you are also using category loggers, include this after log.sml
   but before category-log-fn.sml.
*)
structure Log = LogInfo

