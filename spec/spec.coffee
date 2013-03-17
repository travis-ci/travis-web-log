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
  html.replace(/<p/gm, '\n<p').replace(/<div/gm, '\n<div').replace(/<\/div/, '\n</div')

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
    part.children.each (node) ->
      bits = []
      bits.push("prev: #{node.prev.id}") if node.prev
      bits.push("next: #{node.next.id}") if node.next
      if node.fold
        bits.push("fold-#{node.event}-#{node.name}")
        console.log "    F.#{node.id} #{bits.join(', ')}"
      else
        bits.push('ends') if node.ends
        bits.push('cr')   if node.cr
        console.log "    S.#{node.id} #{node.text && JSON.stringify(node.text) || ''} #{bits.join(', ')}"
        console.log "      line: [#{(node.line.spans.map (node) -> node.id).join(', ')}]" if node.line
  console.log ''


eval require('fs').readFileSync('./spec/log/deansi.js', 'utf-8')
eval require('fs').readFileSync('./spec/log/dots.js', 'utf-8')
eval require('fs').readFileSync('./spec/log/folds.js', 'utf-8')
eval require('fs').readFileSync('./spec/log/limit.js', 'utf-8')
eval require('fs').readFileSync('./spec/log/nodes.js', 'utf-8')
eval require('fs').readFileSync('./spec/log.js', 'utf-8')

# describe 'Log', ->
#   beforeEach ->
#     log.removeChild(log.firstChild) while log.firstChild
#     @log = new Log()
#     @render = (parts) -> render(@, parts)
#
#   it 'foo', ->
#     rescueing @, ->
#       parts = eval require('fs').readFileSync('./log.parts.js', 'utf-8')
#       console.log format (@render parts) #.slice(-10000)


env = jasmine.getEnv()
env.addReporter(new ConsoleReporter(jasmine))
env.execute()
