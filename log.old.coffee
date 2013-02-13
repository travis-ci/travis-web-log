require './../assets/scripts/vendor/ansiparse.js'

Log = (string) ->
  @parts = []
  @listeners = []
  @set(0, string) if string
  @
$.extend Log.prototype,
  trigger: () ->
    listener.notify.apply(listener, arguments) for listener in @listeners
  set: (num, string) ->
    return if @parts[num]
    @parts[num] = part = new Log.Part(@, num, string)
    prev = part.prev()
    for line in part.lines
      @trigger('insert', prev?.num, line.node())
      prev = line

Log.Part = (log, num, string) ->
  @log = log
  @num = num
  @lines = for line, ix in @pull(string).split(/^/m)
    new Log.Line("#{@num}-#{ix}", line)
  @
$.extend Log.Part.prototype,
  pull: (string) ->
    string = prev.original + string if prev = @pop()
    string = string + next.original if next = @shift()
    string
  prev: ->
    num  = @num
    prev = @log.parts[num -= 1]?.lines.slice(-1)[0] until prev || num < 0
    prev
  pop: ->
    if line = @log.parts[@num - 1]?.lines.pop()
      @log.trigger('remove', line.num)
      line
  shift: ->
    if line = @log.parts[@num + 1]?.lines.shift()
      @log.trigger('remove', line.num)
      line

Log.Line = (num, string) ->
  @num = num
  @original = string
  @processed = @deansi(string).replace(/\n/g, '')
  @
$.extend Log.Line.prototype,
  node: ->
    if @original.match(/^<\/?div.*>/)
      @original
    else
      "<p id='#{@num}'><a id=''>1</a>#{@processed}</p>"
  deansi: (string) ->
    Log.Deansi.apply(string)

Log.Deansi =
  apply: (string) ->
    string = string.replace(/.*\033\[K\n/g, '').replace(/\033\(B/g, '').replace(/\033\[\d+G/g, '').replace(/\[2K/g, '')
    result = ''
    ansiparse(string).forEach (part) =>
      result += @span(part.text, @classes(part))
    result.replace(/\033/g, '')

  classes: (part) ->
    result = []
    result.push(part.foreground)         if part.foreground
    result.push("bg-#{part.background}") if part.background
    result.push('bold')                  if part.bold
    result.push('italic')                if part.italic
    result

  span: (string, classes) ->
    if classes?.length
      "<span class='#{classes.join(' ')}'>#{string}</span>"
    else
      string

Log.Renderer = ->
$.extend Log.Renderer.prototype,
  notify: (event, num) ->
    @[event].apply(@, Array.prototype.slice.call(arguments, 1))

  insert: (after, line) ->
    if after
      $(line).insertAfter("#log ##{after}").renumber()
    else
      $('#log').append(line).find('p').renumber()

  remove: (num) ->
    $("#log ##{num}").remove()

$.fn.renumber = ->
  prev = @prev()
  num = if prev.length > 0 then parseInt(prev.find('a')[0].id.replace('L', '')) || 0 else 0
  @find('a').attr('id', "L#{num + 1}").html(num + 1)
  # @next('p').renumber()

console.log(new Array(20).join("\n"))

log = new Log
log.listeners.push(new Log.Renderer)

log.set 0, "$ export BUNDLE_GEMFILE=$PWD/Gemfile\n"
log.set 1, ''
log.set 2, "$ bundle install\n"
log.set 3, "Fetching git://github.com/travis-ci/travis-support.git\n"
log.set 8, "remote: Compressing objects:   2% (12/564)"
log.set 9, "\033[K\n"
log.set 4, "remote: Compressing objects:   0% (1/564)"
log.set 5, "\033[K\n"
log.set 7, "\033[K\n"
log.set 6, "remote: Compressing objects:   1% (6/564)"
log.set 10, "Installing rake (10.0.3)\n"
log.set 11, "Done.\n\n"

log.set 21, "$ \033[32mrake\033[0m\n"
log.set 26, "Done.\n\n"
log.set 25, "-..\033[0m\n"
log.set 22, "\033[33mF.."
log.set 23, "-.."
log.set 24, "..."
