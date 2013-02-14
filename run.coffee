urls = [
  'http://localhost:9292/jobs/4754461/log.txt',
  'https://s3.amazonaws.com/archive.travis-ci.org/jobs/4693454/log.txt',
  'https://api.travis-ci.org/jobs/4754461/log.txt'
]

shuffle = (array, start, count) ->
  for _, i in array.slice(start, start + count)
    j = start + Math.floor(Math.random() * (i + 1))
    i = start + i
    tmp = array[i]
    array[i] = array[j]
    array[j] = tmp

randomize = (array, step) ->
  shuffle(array, i, step) for _, i in array by step
  array

partition = (string) ->
  lines = string.split(/^/m)
  parts = ([i, line] for line, i in lines)
  parts = randomize(parts)
  # randomly split some of the parts into multiple small parts
  # randomly join some of the parts into multi-line ones
  parts

INTERVAL = 0
SLICE = 50

$ ->
  log = new Log
  # log.listeners.push(new Log.JqueryRenderer)
  log.listeners.push(new Log.FragmentRenderer)

  $.get urls[2], (string) ->
    parts = partition(string)
    parts = parts.slice(0, SLICE) if SLICE > 0
    wait  = 0
    set   = (ix, line) -> log.set(ix, line)
    setTimeout set, wait += INTERVAL, part[0], part[1] for part in parts
