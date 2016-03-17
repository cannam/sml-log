
fun example () =
    let open Log
    in
        info (fn () => ("Checking for blips...", []));
        warn (fn () => ("Spurious warning: % blips detected in % sector!!",
                        [I 4, S "Zarquil"]));
        info (fn () => ("Done", []))
    end

fun usage () =
    let open TextIO in
	output (stdErr,
	    "Usage:\n" ^
            "    example [-v]\n" ^
            "where -v raises the log level from WARNING to INFO\n");
        raise Fail "Incorrect arguments specified"
    end

fun handle_args args =
    case args of
        "-v"::rest => (Log.set_log_level Log.INFO ; handle_args rest)
      | [] => example ()
      | _ => usage ()

fun main () =
    handle_args (CommandLine.arguments ())
    handle Fail msg => TextIO.output (TextIO.stdErr, "Exception: " ^ msg ^ "\n")

    
