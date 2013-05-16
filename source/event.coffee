###
# Base class for events. #

@author [Brian Vaughn](http://www.briandavidvaughn.com)
###
class Event

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  ###
  This is the constructor.
  @param [String] event type/name
  @param [Object] optional event data
  ###
  constructor: (@eventType, @data) ->

  # @property [EventDispatcher] Dispatcher of this Event
  get target: -> @_target
  set target: (@_target) ->