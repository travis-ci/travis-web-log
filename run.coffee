urls = [
  'https://s3.amazonaws.com/archive.travis-ci.org/jobs/4693454/log.txt'
  'https://api.travis-ci.org/jobs/4754461/log.txt'
]

$ ->
  log = new Log
  log.listeners.push(new Log.Renderer)

  $.get urls[1], (lines) ->
    # lines = lines.slice(0, 50000)
    lines = lines.replace(/\r\n/gm, "\n")
    lines = lines.replace(/\r/gm, "\n")
    lines = lines.split(/^/m)

    set = (ix, line) -> log.set(ix, line)
    wait = 0

    for line, ix in lines
      setTimeout set, wait, ix, line
      wait += 50


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
