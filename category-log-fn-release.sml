
(* Release builds using category logging may wish to have this
   included after category-log-fn.sml, in order to eliminate debug
   calls entirely. (Though you may find it makes very little
   difference.)
*)

functor CategoryLogFn (ARG : sig
                           val category : string
                       end)
        : LOG where type level = Log.level
    = struct

    structure Base = CategoryLogBaseFn (ARG)
    open Base
            
    val debug = ignore
    val info = log INFO
    val warn = log WARN
    val error = log ERROR
                    
    val debug_d = ignore
    val info_d = log_d INFO
    val warn_d = log_d WARN
    val error_d = log_d ERROR

end

structure Log = LogInfo
                    
