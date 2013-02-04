fs =   require 'fs'
path = require 'path'
#audiosprite = require 'audiosprite'

{call, system} = require './utils'

class Alfred
  constructor: (@options = {}) ->
    @options.voicesDirectory ?= path.join __dirname, '../voices'
    return @

  getSox: =>
    return 'sox'

  listVoices: (fn) =>
    fs.readdir @options.voicesDirectory, fn

  getWordPath: (word) =>
    path.join @options.voicesDirectory, @options.voice, "#{word}.wav"

  getDestFile: =>
    return @options.out || "/tmp/salut-c-est-alfred-ton-banquier.wav"

  _say: (words, destFile = null, fn) =>
    cmd = [@getSox()]
    for word in words
      cmd.push @getWordPath word
    cmd.push destFile
    fn false, cmd

  saveSay: (words, destFile = null, fn) =>
    @_say words, destFile, (err, cmd) =>
      console.log 'test'
      [bin, args] = [cmd[0], cmd[1..]]
      console.log bin, args
      call bin, args, (err, data) =>
        console.log "Done. #{destFile}"
        fn err, data

  say: (words, fn = null) =>
    destFile = @getDestFile()
    @saveSay words, destFile, (err, data) =>
      #console.log err, data
      system 'play', [destFile]

module.exports =
  Alfred: Alfred
