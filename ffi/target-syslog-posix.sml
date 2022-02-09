
(** Log to syslog using syslog(). As this just has a single write call
    for logs of all levels, it writes everything with level LOG_NOTICE
    (or 5, whatever else that means on this platform). This could
    obviously be improved
*)
structure LogTargetSyslog : LOG_TARGET = struct

    val syslog =
        _import "syslog" public: Int32.int * string * string;

    val format = String.implode [ #"%", #"s", chr 0 ]

    val level = 5

    type target = unit
    type new_args = unit

    fun new () = ()
    fun write ((), s) = syslog (level, format, s ^ String.implode [ chr 0 ])
    fun close () = ()
                    
end
