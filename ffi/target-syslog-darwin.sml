
(** Log to system using NSLog.
 *)
structure LogTargetSyslog : LOG_TARGET = struct

    val write_to_nslog =
        _import "write_to_nslog" public: string -> unit;

    type target = unit
    type new_args = unit

    fun new () = ()
    fun write ((), s) = write_to_nslog (s ^ String.implode [ chr 0 ])
    fun close () = ()
                    
end
