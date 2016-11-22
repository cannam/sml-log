
signature LOG = sig

    datatype level = ERROR | WARN | INFO | DEBUG

    val I : int -> string
    val R : real -> string
    val B : bool -> string
    val S : string -> string
    val SL : string list -> string
    val RV : real vector -> string
    val RA : real array -> string
                                
    type arg = string * string list
    type thunk = unit -> arg

    val setLogLevel : level -> unit

    val noLog : arg
    val debug : thunk -> unit (* High-volume stuff in inner loops, off by default *)
    val info : thunk -> unit  (* Modest informational stuff, off by default *)
    val warn : thunk -> unit  (* Warnings, on by default *)
    val error : thunk -> unit (* Fatal errors, on by default *)

end
