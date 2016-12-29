
fun example () =
    let open Log
    in
        info (fn () => ("Checking for blips...", []));
        warn (fn () => ("Spurious warning: % blips detected in % sector!!",
                        [I 4, S "Zarquil"]));
        info (fn () => ("Done", []))
    end

structure Log = LogWarn

fun example2 () =
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
        "-v"::rest => (Log.setLogLevel Log.INFO ; handle_args rest)
      | [] => (example () ; example2 ())
      | _ => usage ()

fun main () =
    handle_args (CommandLine.arguments ())
    handle Fail msg => TextIO.output (TextIO.stdErr, "Exception: " ^ msg ^ "\n")

    
