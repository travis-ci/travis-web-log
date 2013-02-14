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

$ ->
  log = new Log
  log.listeners.push(new Log.Renderer)

  $.get urls[2], (string) ->
    parts = partition(string)
    parts = parts.slice(0, 30)
    wait  = 0
    set   = (ix, line) -> log.set(ix, line)
    setTimeout set, wait += 10, part[0], part[1] for part in parts



  # log.set 2, "$ bundle install\n"
  # log.set 0, "$ export BUNDLE_GEMFILE=$PWD/Gemfile\n"
  # log.set 1, ''
  # log.set 21, "$ \x1B[32mrake\x1B[0m\n"
  # log.set 3, "Fetching git://github.com/travis-ci/travis-support.git\n"
  # log.set 8, "remote: Compressing objects:   2% (12/564)"
  # log.set 8, "remote: Compressing objects:   2% (12/564)"
  # log.set 9, "\x1B[K\n"
  # log.set 4, "remote: Compressing objects:   0% (1/564)"
  # log.set 5, "\x1B[K\n"
  # log.set 7, "\x1B[K\n"
  # log.set 10, "Installing rake (10.0.3)\n"
  # log.set 11, "Done\n\n"
  # log.set 6, "remote: Compressing objects:   1% (6/564)"
  # log.set 26, "Done.\n"
  # log.set 25, "-..\x1B[0m\n"
  # log.set 22, "\x1B[33mF.."
  # log.set 23, "-.."
  # log.set 24, "..."

  # log.set 0, "$ export BUNDLE_GEMFILE=$PWD/Gemfile\n"
  # log.set 5, "\x1B[K\n"
  # log.set 4, "remote: Compressing objects:   0% (1/564)"
  # log.set 26, "Done.\n"

  # log.set 2, "...\n"
  # log.set 1, '...'
  # log.set 3, "b\n"

  # log.set 4, "B\n"
  # log.set 1, "..."
  # log.set 2, "\x1B[K\n"
  # log.set 3, "A\n"

  # log.set 4, "B\n"
  # log.set 1, "..."
  # log.set 2, "...\n"
  # log.set 3, "A\n"

  # log.set 2, "B\n"
  # log.set 0, "A\n"
  # log.set 1, ''

  # log.set 0, "a\n..."
  # log.set 1, "...\nb"
