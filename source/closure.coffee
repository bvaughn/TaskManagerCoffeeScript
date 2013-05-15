class Closure

  constructor: ( @closure, @scope ) ->

  execute: ->
    @closure.apply( @scope, arguments )

  equals: (otherClosure) ->
    return @closure == otherClosure.closure && @scope == otherClosure.scope