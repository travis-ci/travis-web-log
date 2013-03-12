describe 'Log.Dom', ->
  beforeEach ->
    rescueing @, ->
      log.removeChild(log.firstChild) while log.firstChild
      @log = Log.create(engine: Log.Dom, listeners: [new Log.FragmentRenderer])
      @render = (parts) -> render(@, parts)

