fs =   require 'fs'
path = require 'path'

class Alfred
  constructor: (@options = {}) ->
    @options.voicesDirectory ?= path.join __dirname, '../voices'
    return @

  listVoices: (fn) =>
    fs.readdir @options.voicesDirectory, fn

  getWordPath: (word) =>
    path.join @options.voicesDirectory, @options.voice, "#{word}.wav"

  say: (words, fn) =>
    for word in words
      console.log @getWordPath word

module.exports =
  Alfred: Alfred