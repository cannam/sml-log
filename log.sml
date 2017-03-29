
structure Log :> LOG = struct

    val startTime = ref (Time.now ())

    fun resetElapsedTime () = startTime := Time.now ()
                         
    datatype level = ERROR | WARN | INFO | DEBUG

    val level = ref WARN
    fun setLogLevel l = level := l

    datatype element = ELAPSED_TIME | DATE_TIME | LEVEL | MESSAGE
    type format = { elements: element list, separator: string }

    val format = ref {
        elements = [ ELAPSED_TIME, LEVEL, MESSAGE ],
        separator = ": "
    }
    fun setLogFormat f = format := f
                    
    type arg = string list
    type thunk = unit -> arg

    val I = Int.toString
    val R = Real.toString
    fun B b = if b then "true" else "false"
    fun S s = s
    val SL = String.concatWith "\n"
    fun RV v =
        let fun toList v = rev (Vector.foldl (op::) [] v)
        in "[" ^ (String.concatWith "," (map Real.toString (toList v))) ^ "]"
        end
    fun RA a = RV (Array.vector a)
    val T = R o Time.toReal
    val X = exnMessage

    fun tooManyValues str =
        TextIO.output
            (TextIO.stdErr,
             "Logger: WARNING: Too many values in string interpolation for \"" ^
             str ^ "\"")
            
    fun interpolate str values =
        let fun intAux acc chars [] _ = String.implode (rev acc @ chars)
              | intAux acc [] _ _ = (tooManyValues str; intAux acc [] [] false)
              | intAux acc (first::rest) values escaped =
                if first = #"\\" then
                    intAux acc rest values (not escaped)
                else if first = #"%" andalso not escaped then
                    intAux ((rev (String.explode (hd values))) @ acc)
                            rest (tl values) escaped
                else
                    intAux (first::acc) rest values false
        in
            intAux [] (String.explode str) values false
        end

    fun elapsedString () =
        Time.fmt 6 (Time.- (Time.now (), !startTime))

    fun dateString () =
        Date.fmt "%Y-%m-%d %H:%M:%S" (Date.fromTimeLocal (Time.now ()))

    fun levelString ERROR = "ERROR"
      | levelString WARN = "WARNING"
      | levelString INFO = "INFO"
      | levelString DEBUG = "DEBUG"
                      
    val noLog = [""]

    fun print string =
        if string <> "" then TextIO.output (TextIO.stdErr, string ^ "\n")
        else ()

    fun logWith printer level [] = ()
      | logWith printer level (string::args) =
        printer
            let val { elements, separator } = !format
            in
                String.concatWith separator
                                  (map (fn ELAPSED_TIME => elapsedString ()
                                       | DATE_TIME => dateString ()
                                       | LEVEL => levelString level
                                       | MESSAGE => interpolate string args)
                                       elements)
            end

    val log = logWith print

    val logFail =
        let fun printFail msg = (print msg ; raise Fail msg; ())
        in
            logWith printFail
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
                 
    fun fatal f =
        logFail ERROR (f ())
              
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
                 
    fun fatal_d a =
        logFail ERROR a

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

                               
