# http://adrianwiecek.com/2012/02/24/coffeescript-eventdispatcher/
#Base class for events.
class Event
  constructor: (@eventType, @data) ->