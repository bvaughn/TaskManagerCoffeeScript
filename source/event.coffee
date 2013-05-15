###
# Base class for events. #
Big thanks to [adrianwiecek](http://adrianwiecek.com/2012/02/24/coffeescript-eventdispatcher/)
###
class Event

  ###
  This is the constructor.
  @param [String] event type/name
  @param [Object] optional event data
  ###
  constructor: (@eventType, @data) ->