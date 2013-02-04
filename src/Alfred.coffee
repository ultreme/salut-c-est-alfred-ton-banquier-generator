fs =   require 'fs'
path = require 'path'
#audiosprite = require 'audiosprite'


class Alfred
  constructor: (@options = {}) ->
    @options.voicesDirectory ?= path.join __dirname, '../voices'
    return @

  listVoices: (fn) =>
    fs.readdir @options.voicesDirectory, fn

  getWordPath: (word) =>
    path.join @options.voicesDirectory, @options.voice, "#{word}.wav"

  say: (words, fn) =>
    cmd = ['sox']
    for word in words
      cmd.push @getWordPath word
    cmd.push "/tmp/test.wav"
    console.log cmd.join ' '

module.exports =
  Alfred: Alfred
