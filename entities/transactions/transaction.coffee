this.commit = (seq,context) ->
  done = []

  while (seq.length)
    op = seq.shift()
    try
      op.commit?.call(context)
      done.push(op)
    catch e
      console.log e.error
      while (done.length)
        op = done.pop()
        try
          op.rollback?.call(context)
        finally

      throw e

  while (done.length)
    op = done.pop()
    try
      op.cleanup?.call(context)
    finally
