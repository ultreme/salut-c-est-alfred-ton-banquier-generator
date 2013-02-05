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

  getVoicePath: (voice) =>
    path.join @options.voicesDirectory, voice

  getWordPath: (word, voice = null) =>
    voice ?= @options.voice
    path.join @options.voicesDirectory, voice, "#{word}.wav"

  getDestFile: =>
    return @options.out || "/tmp/salut-c-est-alfred-ton-banquier.mp3"

  _say: (words, destFile, fn) =>
    cmd = [@getSox()]
    @getVoices (err, voices) =>
      for word in words
        voice = voices[Math.floor(voices.length * Math.random())]
        cmd.push @getWordPath word, voice
      cmd.push destFile
      fn false, cmd

  getVoices: (fn) =>
    if @options.voice
      return fn false, [@options.voice]
    @listVoices fn

  listWords: (fn) =>
    voicesWords = {}
    todo = 0
    @getVoices (err, voices) =>
      for _voice in voices
        do =>
          voice = _voice
          voicesWords[voice] = []
          todo++
          @listVoiceWords voice, (err, words) =>
            unless err
              for word in words
                voicesWords[voice].push word
            unless --todo
              fn false, voicesWords
              #console.log "#{voice}:", words.join(',')

  listVoiceWords: (voice, fn) =>
    fs.readdir @getVoicePath(voice), (err, files) =>
      for k, file of files
        files[k] = files[k][..file.length - 5]
      fn err, files

  getRandomWordPath: =>

  _sayRandom: (length = 10, destFile = null, fn) =>
    cmd = [@getSox()]
    @listWords (err, voiceWords) =>
      voices = [voice for voice of voiceWords][0]
      console.log voices
      console.log length
      for i in [0..length]
        voice = voices[Math.floor(voices.length * Math.random())]
        words = voiceWords[voice]
        word = words[Math.floor(words.length * Math.random())]
        cmd.push @getWordPath word, voice
      cmd.push destFile
      console.log cmd
      fn false, cmd

  saveSayRandom: (length, destFile = null, fn) =>
    @_sayRandom length, destFile, (err, cmd) =>
      console.log 'test'
      [bin, args] = [cmd[0], cmd[1..]]
      console.log bin, args
      call bin, args, (err, data) =>
        console.log "Done. #{destFile}"
        fn err, data

  sayRandom: (length, fn = null) =>
    destFile = @getDestFile()
    @saveSayRandom length, destFile, (err, data) =>
      system 'play', [destFile]

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
