
structure LogTargetSyslog : LOG_TARGET = struct

    type writer = string -> unit
                            
    type new_args = unit

    fun new () =
        (TextIO.output (TextIO.stdErr,
                        "NOTE: Syslog requested but unavailable, " ^
                        "will log to stderr instead\n");
         LogTargetStderr.new ())
                    
end
