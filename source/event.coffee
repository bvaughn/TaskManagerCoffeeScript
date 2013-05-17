###
Simple event.
This type of object can be dispatched by an `EventDispatcher`.

You can extend this class to implement a custom event if you wish to bundle additional data.

@author [Brian Vaughn](http://www.briandavidvaughn.com)
###
class Event

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  ###
  Constructor.
  @param type [String] Unique `Event` type
  ###
  constructor: ( type ) ->
    @_type = type
    
  # @property [EventDispatcher] Object that dispatched this `Event`
  get dispatcher: -> @_dispatcher
  set dispatcher: (@_dispatcher) ->

  # @property [String] Type of event
  get type: -> @_type