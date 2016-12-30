
structure Log :> LOG = struct

    val start_time = ref (Time.now ())

    datatype level = ERROR | WARN | INFO | DEBUG

    val level = ref WARN
    fun setLogLevel l = (level := l; start_time := Time.now ())

    datatype element = ELAPSED_TIME | DATE_TIME | LEVEL | MESSAGE
    type format = { elements: element list, separator: string }

    val format = ref {
        elements = [ ELAPSED_TIME, LEVEL, MESSAGE ],
        separator = ": "
    }
    fun setLogFormat f = format := f
                    
    type arg = string * string list
    type thunk = unit -> arg

    val I = Int.toString
    val R = Real.toString
    fun B b = if b then "true" else "false"
    fun S s = s
    val SL = String.concatWith "\n"
    fun RV v =
        let fun to_list v = rev (Vector.foldl (op::) [] v)
        in "[" ^ (String.concatWith "," (map Real.toString (to_list v))) ^ "]"
        end
    fun RA a = RV (Array.vector a)
    val X = exnMessage

    fun tooManyValues str =
        TextIO.output
            (TextIO.stdErr,
             "Logger: WARNING: Too many values in string interpolation for \"" ^
             str ^ "\"")
            
    fun interpolate str values =
        let fun int_aux acc chars [] _ = String.implode (rev acc @ chars)
              | int_aux acc [] _ _ = (tooManyValues str; int_aux acc [] [] false)
              | int_aux acc (first::rest) values escaped =
                if first = #"\\" then
                    int_aux acc rest values (not escaped)
                else if first = #"%" andalso not escaped then
                    int_aux ((rev (String.explode (hd values))) @ acc)
                            rest (tl values) escaped
                else
                    int_aux (first::acc) rest values false
        in
            int_aux [] (String.explode str) values false
        end

    fun elapsed_string () =
        Time.fmt 6 (Time.- (Time.now (), !start_time))

    fun date_string () =
        Date.fmt "%Y-%m-%d %H:%M:%S" (Date.fromTimeLocal (Time.now ()))

    fun level_string ERROR = "ERROR"
      | level_string WARN = "WARNING"
      | level_string INFO = "INFO"
      | level_string DEBUG = "DEBUG"
                      
    val noLog = ("", [])

    fun print string =
        if string <> "" then TextIO.output (TextIO.stdErr, string ^ "\n")
        else ()

    fun log level (string, args) =
        print
            let val { elements, separator } = !format
            in
                String.concatWith separator
                                  (map (fn ELAPSED_TIME => elapsed_string ()
                                       | DATE_TIME => date_string ()
                                       | LEVEL => level_string level
                                       | MESSAGE => interpolate string args)
                                       elements)
            end
              
    fun debug f =
        if !level = DEBUG then
            log DEBUG (f ())
        else ()
              
    fun info f =
        if !level = INFO orelse !level = DEBUG then
            log INFO (f ())
        else ()
                 
    fun warn f =
        if !level = WARN orelse !level = INFO orelse !level = DEBUG then
            log WARN (f ())
        else ()
                 
    fun error f =
        log ERROR (f ())
              
    fun debug_d a =
        if !level = DEBUG then
            log DEBUG a
        else ()
              
    fun info_d a =
        if !level = INFO orelse !level = DEBUG then
            log INFO a
        else ()
                 
    fun warn_d a =
        if !level = WARN orelse !level = INFO orelse !level = DEBUG then
            log WARN a
        else ()
                 
    fun error_d a =
        log ERROR a

end

structure LogDebug :> LOG = Log

structure LogInfo :> LOG = struct
    open Log
    val debug = ignore
    val debug_d = ignore
end

structure LogWarn :> LOG = struct
    open LogInfo
    val info = ignore
    val info_d = ignore
end

structure LogError :> LOG = struct
    open LogWarn
    val warn = ignore
    val warn_d = ignore
end

                               
