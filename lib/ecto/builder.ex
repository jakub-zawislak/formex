# form nested

    # {form, substruct} = if Ecto.assoc_loaded? substruct do
    #   {form, substruct}
    # else
    #   struct    = @repo.preload(form.struct, name)
    #   substruct = Map.get(struct, name)

    #   struct = Map.put(struct, name, substruct)
    #   form   = Map.put(form, :struct, struct)

    #   {form, substruct}
    # end
