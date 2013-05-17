###
Encapsulates a function and its scope, enabling the function to be later executed within the desired scope.

@example How to use a Proxy
  # Imagine we have a class MyClass with a single method, "print".
  function MyClass() {
  	this.myProperty = "foobar";
  }
  MyClass.prototype.print = function( parameter ) {
  	console.log( this.myProperty + ", " + parameter );
  }

  # We could invoke this method on an instance of our class like this:
  var myClass = new MyClass();
  myClass.print( "baz" );

  # But what if we had to pass this method to another object as a parameter?
  # Passing a direct reference to "print" would not be safe,
  # Because we have no way of knowing what scope it will be later executed with.
  # Instead, create and pass a Proxy object like this:
  var myProxy = new Proxy( myClass.print, myClass );

  # The Proxy can be treated like a normal function,
  # But will always have the correct scope regardless of where it is executed.
  # For instance:
  myProxy( "baz" );

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