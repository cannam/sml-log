
structure LogTargetLogfile : LOG_TARGET = struct

    type writer = string -> unit

    type new_args = string   

    datatype outstr = UNOPENED | OPENED of TextIO.outstream | FAILED
                        
    fun new filename =
        let val stream : outstr ref = ref UNOPENED
            fun write message =
                case ! stream of
                    FAILED => ()
                  | OPENED str => TextIO.output (str, message ^ "\n")
                  | UNOPENED =>
                    (stream := OPENED (TextIO.openOut filename)
                     handle IO.Io _ =>
                            (TextIO.output
                                 (TextIO.stdErr,
                                  "ERROR: Unable to open log file \"" ^
                                  filename ^ "\" for writing");
                             stream := FAILED);
                     write message)
        in
            fn message =>
               if message = ""
               then ()
               else write message
        end

    fun isAvailable () = true
			     
end
