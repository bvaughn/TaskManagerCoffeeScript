###
# Base class for events. #
Big thanks to [adrianwiecek](http://adrianwiecek.com/2012/02/24/coffeescript-eventdispatcher/)
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