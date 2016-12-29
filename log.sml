
structure Log : LOG = struct

    datatype level = ERROR | WARN | INFO | DEBUG

    val level = ref WARN
    val start_time = ref (Time.now ())

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
                             
    fun interpolate str values =
        let fun int_aux acc chars [] _ = String.implode (rev acc @ chars)
              | int_aux acc [] _ _ =
                (TextIO.output
                     (TextIO.stdErr,
                      "Logger: WARNING: Too many values in string interpolation for \"" ^ str ^ "\"");
                 int_aux acc [] [] false)
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

    fun time_string () =
        Time.fmt 6 (Time.- (Time.now (), !start_time))
            
    val noLog = ("", [])

    fun setLogLevel l =
        (level := l;
         start_time := Time.now ())
                                       
    fun print string =
        if string <> "" then
            TextIO.output (TextIO.stdErr,
                           (time_string ()) ^ ": " ^ string ^ "\n")
        else ()

    fun log (string, args) =
        print (interpolate string args)
              
    fun debug f =
        if !level = DEBUG then
            log (f ())
        else ()
              
    fun info f =
        if !level = INFO orelse !level = DEBUG then
            log (f ())
        else ()
                 
    fun warn f =
        if !level = WARN orelse !level = INFO orelse !level = DEBUG then
            log (f ())
        else ()
                 
    fun error f =
        log (f ())

end

structure LogDebug : LOG = Log

structure LogInfo : LOG = struct
    open Log
    val debug = ignore
end

structure LogWarn : LOG = struct
    open LogInfo
    val info = ignore
end

structure LogError : LOG = struct
    open LogWarn
    val warn = ignore
end

                               
