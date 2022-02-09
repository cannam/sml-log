
signature LOG_TARGET = sig

    type writer = string -> unit
         
    type new_args

    val new : new_args -> writer
                                       
end

