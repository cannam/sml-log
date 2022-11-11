functor CategoryLogBaseFn (ARG : sig
                               val category : string
                           end)
        : LOG where type level = Log.level
= struct

    open Log

    val should : bool option ref = ref NONE
             
    fun shouldLog () =
        case !should of
            SOME s => s
          | NONE => 
            let val s =
                    case OS.Process.getEnv "LOGCATS" of
                        NONE => true
                      | SOME str =>
                        let val cats = (String.tokens (fn #"," => true
                                                        | _ => false)
                                                      str)
                        in
                            List.exists (fn c => c = ARG.category) cats
                            orelse
                            (List.exists (fn c => c = "*") cats andalso
                             (not (List.exists
                                       (fn c => c = "-" ^ ARG.category)
                                       cats)))
                        end
            in
                should := SOME s;
                s
            end
             
    val prefix =
        String.concatWith
            "%%"
            (String.fields
                 (fn #"%" => true | _ => false)
                 (StringInterpolate.interpolate "[%1] " [ARG.category]))

    fun adapt arg =
        case arg of
            [] => []
          | format :: args => (prefix ^ format) :: args
        
    fun log level f =
        if (case (level, shouldLog ()) of
                (ERROR, _) => true
              | (WARN, _) => true
              | (_, s) => s)
        then Log.log level (fn () => adapt (f ()))
        else ()
                    
    fun log_d level arg =
        if (case (level, shouldLog ()) of
                (ERROR, _) => true
              | (WARN, _) => true
              | (_, s) => s)
        then Log.log_d level (adapt arg)
        else ()

end

(** Create a logger that prepends a category name to every line it
    logs, and that logs at debug and info levels only if that category
    is enabled. (Warnings and errors are always logged if the log
    level is appropriate; the category is ignored for these.)

    A category is enabled if any of the following is true:

    1. The LOGCATS environment variable is not set. (i.e. the default
       is to log all categories.)

    2. The LOGCATS environment variable is set to a comma-separated
       list of categories, and the list contains the category in
       question.

    3. The LOGCATS environment variable is set to a comma-separated
       list of categories, one of them is the special category *
       meaning "all", and the list does not contain an entry which is
       the category in question prefixed by the character "-".

    For example, the category "foo" would be logged if LOGCATS was
    unset or was set to any of the strings "foo", "bar,foo", "*",
    "*,-bar", "bar,*", or "*,foo" (though this last one is redundant
    as * already includes foo). The category foo would not be logged
    if LOGCATS was set to "", "bar", "*,-foo", "-foo,*", or
    "*,-bar,-foo" among other things.
*)
functor CategoryLogFn (ARG : sig
                           val category : string
                       end)
        : LOG
    = struct

    structure Base = CategoryLogBaseFn (ARG)
    open Base
            
    val debug = log DEBUG
    val info = log INFO
    val warn = log WARN
    val error = log ERROR
                    
    val debug_d = log_d DEBUG
    val info_d = log_d INFO
    val warn_d = log_d WARN
    val error_d = log_d ERROR

end
