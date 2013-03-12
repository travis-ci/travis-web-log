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
  html.replace(/<p/gm, '\n<p').replace(/<div/gm, '\n<div')

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

  it 'foo', ->
    rescueing @, ->
      # html = @render [[0, '.'], [1, '.'], [2, '.'], [3, '.']]
      html = @render [[0, '.'], [1, '.'], [3, '.'], [2, '.']]
      console.log format html


  # it 'parts.js', ->
  #   @log.listeners.push(new Log.Folds)
  #   parts = eval require('fs').readFileSync('./log.parts.js', 'utf-8')
  #   html = @render parts
  #   console.log format html

# describe 'folds with multiple folds and strings on the same part', ->
#   beforeEach ->
#     rescueing @, ->
#       log.removeChild(log.firstChild) while log.firstChild
#       @log = Log.create(engine: Log.Dom, listeners: [new Log.FragmentRenderer])
#       @render = (parts) -> render(@, parts)
#     @log.listeners.push(new Log.Folds)
#     @html = strip '''
#       <div id="fold-start-install.1" class="fold-start fold">
#         <span class="fold-name">install.1</span>
#         <p><span id="0-1-0">$ install-1</span></p>
#         <p><span id="1-0-0">foo</span></p>
#       </div>
#       <div id="fold-end-install.1" class="fold-end"></div>
#       <div id="fold-start-install.2" class="fold-start fold">
#         <span class="fold-name">install.2</span>
#         <p><span id="1-3-0">$ install-2</span></p>
#         <p><span id="1-4-0">bar</span></p>
#       </div>
#       <div id="fold-end-install.2" class="fold-end"></div>
#     '''
#
#   it 'ordered', ->
#     parts = [
#       [0, 'fold:start:install.1\r$ install-1\r\n'],
#       [1, 'foo\nfold:end:install.1\rfold:start:install.2\r$ install-2\nbar\n'],
#       [2, 'fold:end:install.2\r\n'],
#     ]
#     expect(@render parts).toBe @html
#
#   it 'unordered 1', ->
#     parts = [
#       [1, 'foo\nfold:end:install.1\rfold:start:install.2\r$ install-2\nbar\n'],
#       [0, 'fold:start:install.1\r$ install-1\r\n'],
#       [2, 'fold:end:install.2\r\n'],
#     ]
#     expect(@render parts).toBe @html
#
#   it 'unordered 2', ->
#     parts = [
#       [2, 'fold:end:install.2\r\n'],
#       [0, 'fold:start:install.1\r$ install-1\r\n'],
#       [1, 'foo\nfold:end:install.1\rfold:start:install.2\r$ install-2\nbar\n'],
#     ]
#     expect(@render parts).toBe @html
#
#   it 'unordered 3', ->
#     parts = [
#       [2, 'fold:end:install.2\r\n'],
#       [1, 'foo\nfold:end:install.1\rfold:start:install.2\r$ install-2\nbar\n'],
#       [0, 'fold:start:install.1\r$ install-1\r\n'],
#     ]
#     expect(@render parts).toBe @html


# eval require('fs').readFileSync('./spec/engine/dom.js', 'utf-8')
# eval require('fs').readFileSync('./spec/limit.js', 'utf-8')

env = jasmine.getEnv()
env.addReporter(new ConsoleReporter(jasmine))
env.execute()
