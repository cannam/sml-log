
signature LOG = sig

    datatype level = ERROR | WARN | INFO | DEBUG
    val setLogLevel : level -> unit

    datatype element = ELAPSED_TIME | DATE_TIME | LEVEL | MESSAGE
    type format = { elements: element list, separator: string }
    val setLogFormat : format -> unit
                                
    type arg = string * string list
    type thunk = unit -> arg
    val noLog : arg

    (* The standard log functions take an anonymous function (a thunk)
       as argument. For example:

           info (fn () => ("Loading data from %...", [S filename]))

       The thunk is only dereferenced if the log level is high enough
       for the message to be printed, thus ensuring little or no work
       needs to be done otherwise.
    *)
    val debug : thunk -> unit (* High-volume in inner loops, off by default *)
    val info : thunk -> unit  (* Modest informational stuff, off by default *)
    val warn : thunk -> unit  (* Warnings, on by default *)
    val error : thunk -> unit (* Fatal errors, on by default *)

    (* The _d (direct) variants take arguments directly. For example:

           info_d ("Loading data from %...", [S filename])

       This may be slower in cases where the log level is not high
       enough to actually print the resulting message, simply because
       the work of building the parameters can't be avoided.
    *)
    val debug_d : arg -> unit (* High-volume in inner loops, off by default *)
    val info_d : arg -> unit  (* Modest informational stuff, off by default *)
    val warn_d : arg -> unit  (* Warnings, on by default *)
    val error_d : arg -> unit (* Fatal errors, on by default *)

    (* Data-to-string conversion shorthands: *)
    val I : int -> string
    val R : real -> string
    val B : bool -> string
    val S : string -> string
    val SL : string list -> string
    val RV : real vector -> string
    val RA : real array -> string
    val X : exn -> string
                               
end
