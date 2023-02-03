
(** Format and print information about the size of an SML value, for
    the purpose of identifying space leaks.

    The implementation in size-log-mlton.sml uses MLton.size to
    calculate the size to print; this obviously requires the MLton
    compiler. The implementation in size-log-null.sml does nothing and
    can be used with any compiler!

    Calculation and logging only happen when the LOGSIZE environment
    variable is set to the string "true". Log output goes to the
    "size" log category with INFO log level.
*)
signature SIZE_LOG = sig

    (** If size logging is enabled, report the size of a value. The
        arguments are an identifying tag for the report location, an
        optional ID to be printed, an identifying tag for the value,
        and the value whose size is to be reported.
     *)
    val report : string -> int option -> string -> 'a -> unit
    
end
