flatiron = require 'flatiron'
{Alfred} =   require './Alfred'

class Program
  constructor: (@options = {}) ->
    @options.name ?= 'salut-c-est-alfred-ton-banquier-generator'
    @options.argv ?=
      'verbose':
        alias:   'v'
        boolean: true
      'voice':
        alias:   'V'
    @options.usage ?= [
      "  Usage: salut-c-est-alfred-ton-banquier-generator [options] method [arguments...]"
      ""
      "    Options:"
      ""
      "       -v, --verbose        verbose"
      "       -V, --voice <voice>  voice"
      ]
    flatiron.app.use flatiron.plugins.cli, @options

  setupHandlers: =>
    flatiron.app.cmd /list-voices/, @listVoices
    flatiron.app.cmd /say (.+)/,    @say

  listVoices: (fn = null) =>
    do @getAlfred
    @alfred.listVoices (err, voices) =>
      for voice in voices
        flatiron.app.log.info voice
    do fn if fn

  say: (words, fn = null) =>
    do @getAlfred
    words = words.split /\ /
    @alfred.say words, (err, data) =>
      flatiron.app.log.info err, data
    do fn if fn

  getAlfred: =>
    @options extends flatiron.app.argv
    @alfred = new Alfred @options
    return @alfred

  run: =>
    do flatiron.app.start

  @getVersion: -> JSON.parse(require('fs').readFileSync "#{__dirname}/../package.json", 'utf8').version

  @run: (options = {}) ->
    prog = new Program options
    do prog.setupHandlers
    do prog.run

module.exports =
  Program:    Program
  getVersion: Program.getVersion
  run:        Program.run
