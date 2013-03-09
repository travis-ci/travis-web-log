{$} = require './../vendor/jquery.fake.js'
{jasmine, describe, beforeEach, it, expect} = require './../vendor/jasmine.js'
{ConsoleReporter} = require './../vendor/jasmine.reporter.js'

document = { createDocumentFragment: (->), createElement: (->) }
window = { execScript: (script) -> eval(script) }

eval require('fs').readFileSync('vendor/minispade.js', 'utf-8')
eval require('fs').readFileSync('vendor/ansiparse.js', 'utf-8')
eval require('fs').readFileSync('spec/jsdom.js', 'utf-8')

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
  html.replace(/<\/p>/gm, '</p>\n').replace(/<\/div>/gm, '</div>\n')

rescueing = (context, block) ->
  try
    block.apply(context)
  catch e
    console.log(line) for line in e.stack.split("\n")

render = (context, parts) ->
  context.log.set(num, part) for [num, part] in parts
  strip document.firstChild.innerHTML

describe 'foo', ->
  beforeEach ->
    rescueing @, ->
      log.removeChild(log.firstChild) while log.firstChild
      @log = Log.create(engine: Log.Dom, listeners: [new Log.FragmentRenderer])
      @render = (parts) -> render(@, parts)

  # it 'bar', ->
  #   parts = eval require('fs').readFileSync('./log.parts.js', 'utf-8')
  #   html = @render parts
  #   console.log format html

eval require('fs').readFileSync('./spec/engine/dom.js', 'utf-8')
# eval require('fs').readFileSync('./spec/limit.js', 'utf-8')

env = jasmine.getEnv()
env.addReporter(new ConsoleReporter(jasmine))
env.execute()
