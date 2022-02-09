
structure LogTargetLogfile : LOG_TARGET = struct

    type writer = string -> unit

    type new_args = string   

    fun new filename =
        let val stream = TextIO.openOut filename
        in
            fn s =>
               if s <> ""
               then TextIO.output (stream, s ^ "\n")
               else ()
        end
        handle IO.Io _ =>
               (TextIO.output (TextIO.stdErr,
                               "ERROR: Unable to open logfile \"" ^
                               filename ^ "\" for writing");
                fn s => ())
                        
end
