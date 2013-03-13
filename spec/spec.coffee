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
    console.log "P.#{part.id}"
    part.children.each (line) ->
      console.log "  L.#{line.id}"
      line.children.each (span) ->
        console.log "    S.#{span.id} #{span.data.text && JSON.stringify(span.data.text) || ''}#{span.ends && ' ends' || ''}"
  console.log ''


# eval require('fs').readFileSync('./spec/log/deansi.js', 'utf-8')
# eval require('fs').readFileSync('./spec/log/dots.js', 'utf-8')
# eval require('fs').readFileSync('./spec/log/folds.js', 'utf-8')
# # eval require('fs').readFileSync('./spec/log/limit.js', 'utf-8')
# eval require('fs').readFileSync('./spec/log/nodes.js', 'utf-8')
eval require('fs').readFileSync('./spec/log.js', 'utf-8')


env = jasmine.getEnv()
env.addReporter(new ConsoleReporter(jasmine))
env.execute()
