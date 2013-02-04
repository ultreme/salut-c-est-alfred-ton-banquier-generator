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

  _say: (words, destFile = null, fn) =>
    cmd = [@getSox()]
    for word in words
      cmd.push @getWordPath word
    cmd.push destFile
    fn false, cmd

  getDestFile: =>
    return "/tmp/test.wav"

  say: (words, fn = null) =>
    destFile = @getDestFile()
    @_say words, destFile, (err, cmd) =>
      call cmd[0], cmd[1..], (err, data) =>
        console.log "Done. #{destFile}"
        system 'play', [destFile]

module.exports =
  Alfred: Alfred
