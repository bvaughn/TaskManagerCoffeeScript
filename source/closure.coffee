###
Encapsulates a function and its scope, enabling the function to be later executed within the desired scope.

@author [Brian Vaughn](http://www.briandavidvaughn.com)
###
class Closure

  ###
  Executes the inner function with the scope specified.
  @param @closure [Function] A function
  @param @scope [Object] The "this" scope to apply to the function
  ###
  constructor: ( @closure, @scope ) ->

  ###
  Executes the inner function with the scope specified.
  Any parameters passed to this method will be passed along to the inner function.
  @return [*] The return value of this Closure's inner function
  ###
  execute: (args...) ->
    return @closure.apply( @scope, arguments )

  ###
  Compares the current function and scope to those contained in another Closure.
  @param otherClosure [Closure] Closure to compare this one to
  @return [Boolean] Whether or not the two Closures point to the same function and scope
  ###
  equals: (otherClosure) ->
    return @closure == otherClosure.closure && @scope == otherClosure.scope