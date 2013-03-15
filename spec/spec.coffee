{$} = require './../vendor/jquery.fake.js'
{jasmine, describe, beforeEach, it, expect} = require './../vendor/jasmine.js'
{ConsoleReporter} = require './../vendor/jasmine.reporter.js'

document = { createDocumentFragment: (->), createElement: (->) }
window = { execScript: (script) -> eval(script) }

eval require('fs').readFileSync('vendor/minispade.js', 'utf-8')
eval require('fs').readFileSync('vendor/ansiparse.js', 'utf-8')
eval require('fs').readFileSync('spec/helpers/jsdom.js', 'utf-8')

document = new exports.Document
log = document.createElement('pre')
log.setAttribute('id', 'log')
document.appendChild(log)

require './../public/js/log.js'
minispade.require 'log'

strip = (string) ->
  string.replace(/^\s+/gm, '').replace(/<a><\/a>/gm, '').replace(/\n/gm, '')

format = (html) ->
  # html.replace(/<div/gm, '\n<div').replace(/<p>/gm, '\n<p>').replace(/<\/p>/gm, '\n</p>').replace(/<span/gm, '\n  <span')
  html.replace(/<p/gm, '\n<p').replace(/<div/gm, '\n<div')

rescueing = (context, block) ->
  try
    block.apply(context)
  catch e
    console.log(line) for line in e.stack.split("\n")

render = (context, parts) ->
  context.log.set(num, part) for [num, part] in parts
  strip document.firstChild.innerHTML

dump = (log) ->
  console.log ''
  log.children.each (part) ->
    prev = part.prev && " prev: #{part.prev.id}" || ''
    next = part.next && " next: #{part.next.id}" || ''
    console.log "P.#{part.id}#{prev}#{next}"
    part.children.each (span) ->
      bits = []
      bits.push("prev: #{span.prev.id}") if span.prev
      bits.push("next: #{span.next.id}") if span.next
      bits.push('ends')                  if span.ends
      console.log "    S.#{span.id} #{span.data.text && JSON.stringify(span.data.text) || ''} #{bits.join(', ')}"
      console.log "      line: [#{(span.line.spans.map (span) -> span.id).join(', ')}]" if span.line
  console.log ''


# eval require('fs').readFileSync('./spec/log/deansi.js', 'utf-8')
# eval require('fs').readFileSync('./spec/log/dots.js', 'utf-8')
eval require('fs').readFileSync('./spec/log/folds.js', 'utf-8')
# eval require('fs').readFileSync('./spec/log/limit.js', 'utf-8')
# eval require('fs').readFileSync('./spec/log/nodes.js', 'utf-8')
# eval require('fs').readFileSync('./spec/log.js', 'utf-8')

env = jasmine.getEnv()
env.addReporter(new ConsoleReporter(jasmine))
env.execute()
