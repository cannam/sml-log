
(** Log to system using a C wrapper.

    Because we have just has a single low-level write call for logs of
    all levels, we have to write everything with the same syslog level
    (currently hardcoded in target-syslog.c). This could obviously be
    improved.
 *)
structure LogTargetSyslog : LOG_TARGET = struct

    type writer = string -> unit
    type new_args = unit

    val write_to_syslog =
        _import "write_to_syslog" public: string -> unit;

    fun new () =
	fn s => write_to_syslog (s ^ String.implode [ chr 0 ])

    fun isAvailable () = true
                    
end
