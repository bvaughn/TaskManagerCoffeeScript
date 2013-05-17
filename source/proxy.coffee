###
Encapsulates a function and its scope, enabling the function to be later executed within the desired scope.

@method #equals(key, value)
  Compares the current function and scope to those contained in another Proxy.
  @param otherProxy [Proxy] Proxy to compare this one to
  @return [Boolean] Whether or not the two Proxy objects point to the same function and scope

@author [Brian Vaughn](http://www.briandavidvaughn.com)
###
class Proxy

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  ###
  Constructor.
  @param closure [Function] A function
  @param thisScope [Object] Optional "this" scope to apply to the function
  ###
  constructor: ( @closure, @thisScope ) ->
    that = this

    ###
    @private
    ###
    class InnerProxy
      constructor: ->
        @closure = that.closure
        @thisScope = that.thisScope

        return this.closure.apply( this.thisScope, arguments )

    InnerProxy.closure = @closure
    InnerProxy.thisScope = @thisScope
    InnerProxy.equals =
      `function( otherProxy ) {
        return that.thisScope == otherProxy.thisScope &&
               that.closure   == otherProxy.closure;
      }`

    return InnerProxy

  # @property [Function] A function
  get closure: -> @_closure
  set closure: (@_closure) ->

  # @property [Object] Optional "this" scope to apply to the function
  get thisScope: -> @_thisScope
  set thisScope: (@_thisScope) ->