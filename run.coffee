window.App = Ember.Application.create
  rootElement: '#application'

App.Runner = Em.Object.extend
  running: false

  start: (options) ->
    @set 'running', true

    console.log 'Start, options: ', options

    $('#log').empty()

    log = new Log
    log.listeners.push(new Log[options.renderer])

    console.log "Using #{options.renderer}"

    self = this
    $.get "https://api.travis-ci.org/jobs/#{options.jobId}/log.txt", (string) ->
      if options.partition
        parts = self.partition(string)
        parts = parts.slice(0, options.slice) if options.slice
        # randomly split some of the parts into multiple small parts
        # randomly join some of the parts into multi-line ones
        parts = self.randomize(parts) if options.randomize

        set   = (ix, line) -> log.set(ix, line)
        if options.stream
          wait  = 0
          setTimeout set, wait += options.interval, part[0], part[1] for part in parts
        else
          set(part[0], part[1]) for part in parts
      else
        log.set 1, string


  stop: ->
    @set 'running', false

  shuffle: (array, start, count) ->
    for _, i in array.slice(start, start + count)
      j = start + Math.floor(Math.random() * (i + 1))
      i = start + i
      tmp = array[i]
      array[i] = array[j]
      array[j] = tmp

  randomize: (array, step) ->
    @shuffle(array, i, step) for _, i in array by step
    array

  partition: (string) ->
    lines = string.split(/^/m)
    parts = ([i, line] for line, i in lines)
    parts

App.ApplicationController = Em.Controller.extend
  jobId: 4754461
  randomize: true
  stream: true
  partition: true
  interval: 10
  runningBinding: 'runner.running'

  renderers: [
    Em.Object.create(name: 'FragmentRenderer')
    Em.Object.create(name: 'JqueryRenderer'  )
  ]

  init: ->
    @_super.apply this, arguments

    @set 'runner', App.Runner.create()

  toggleText: (->
    if @get('running') then 'Stop' else 'Start'
  ).property('running')

  toggle: ->
    if @get('running')
      @get('runner').stop()
    else
      @get('runner').start
        randomize: @get('randomize')
        stream: @get('stream')
        partition: @get('partition')
        jobId: @get('jobId')
        slice: parseInt(@get('slice'))
        renderer: @get('renderer')
        interval: parseInt(@get('interval'))
