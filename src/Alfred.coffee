fs =   require 'fs'
path = require 'path'
#audiosprite = require 'audiosprite'

{call, system} = require './utils'

class Alfred
  constructor: (@options = {}) ->
    @options.voicesDirectory ?= path.join __dirname, '../voices'
    @cache = {}
    return @

  getSox: =>
    return 'sox'

  getPlay: =>
    return 'play'

  listVoices: (fn) =>
    fs.readdir @options.voicesDirectory, fn

  getVoicePath: (voice) =>
    path.join @options.voicesDirectory, voice

  getWordPath: (word, voice = null) =>
    voice ?= @options.voice
    path.join @options.voicesDirectory, voice, "#{word}.wav"

  getDestFile: (file) =>
    file ?= 'alfred.mp3'
    return @options.out || path.join("/tmp", file)

  getVoicesThatHaveWordSync: (theWord) =>
    voices = []
    for voice, words of @cache.voicesWords
      for word in words
        voices.push voice if word is theWord
    return voices

  _say: (words, destFile, fn) =>
    cmd = [@getSox()]
    @listWords (err, voiceWords) =>
      for word in words
        voicesWithWord = @getVoicesThatHaveWordSync word
        voice = voicesWithWord[Math.floor(Math.random() * voicesWithWord.length)]
        file = @getWordPath word, voice
        cmd.push file
      cmd.push destFile
      #console.log cmd
      fn false, cmd

  _sayList: (words, destFile = null, fn) =>
    cmd = [@getSox()]
    @listWords (err, voiceWords) =>
      voices = [voice for voice of voiceWords][0]
      for word in words
        voice = voices[Math.floor(voices.length * Math.random())]
        cmd.push @getWordPath word, voice
      cmd.push destFile
      console.log cmd
      fn false, cmd

  saveSayList: (words, destFile = null, fn) =>
    @_sayList words, destFile, (err, cmd) =>
      [bin, args] = [cmd[0], cmd[1..]]
      console.log bin, args
      call bin, args, (err, data) =>
        console.log "Done. #{destFile}"
        fn err, data

  sayAlfredPass: (length = 42, fn) =>
    words = ['attention_voici_la_passphrase']
    @listWords (err, voiceWords) =>
    chars = []
    chars = chars.concat ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
    chars = chars.concat ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    chars = chars.concat ['!', '#', '%', '&', '(', ')', '+', ',', '-', '_', '^', ';', '=', '@', ']', '[']
    chars = chars.concat ['deux-points', 'pipe', 'point', 'redir-droite', 'redir-gauche', 'etoile', 'interrogation', 'quote']
    #chars = chars.concat ['backslash', '$', 'double-quote', 'slash']
    chars = chars.concat ['bucheron', 'electroencephalogramme', 'electronarcose', 'encyclopedie', 'habituellement', 'hypocondriaque', 'lampadaire', 'mephistophelique', 'noisette', 'ornithorynque', 'radiateur', 'tournevis']
    passphrase_translate =
      backslash:      '\\'
      'deux-points':  ':'
      'double-quote': '"'
      pipe:           '|'
      'redir-droite': '>'
      'redir-gauche': '<'
      slash:          '/'
      etoile:         '*'
      interrogation:  '?'
      quote:          "'"
    for i in [0..length]
      words.push chars[Math.floor(Math.random() * chars.length)]
    words.push 'voila'
    passphrase = []
    for word in words[1...words.length-1]
      passphrase.push if passphrase_translate[word]? then passphrase_translate[word] else word
    passphrase_str = passphrase.join ''
    destFile = @getDestFile "alfred_#{passphrase_str}.mp3"
    @saveSayList words, destFile, (err, data) =>
      system @getPlay(), [destFile]
      console.log passphrase_str

  getVoices: (fn) =>
    if @options.voice
      return fn false, [@options.voice]
    @listVoices fn

  listWords: (fn) =>
    if @cache?.voicesWords
      return fn false, @cache.voicesWords
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
              @cache.voicesWords = voicesWords
              fn false, voicesWords
              #console.log "#{voice}:", words.join(',')

  listVoiceWords: (voice, fn) =>
    fs.readdir @getVoicePath(voice), (err, files) =>
      for k, file of files
        files[k] = files[k][..file.length - 5]
      fn err, files

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
      [bin, args] = [cmd[0], cmd[1..]]
      console.log bin, args
      call bin, args, (err, data) =>
        console.log "Done. #{destFile}"
        fn err, data

  sayRandom: (length, fn = null) =>
    destFile = @getDestFile()
    @saveSayRandom length, destFile, (err, data) =>
      system @getPlay(), [destFile]

  saveSay: (words, destFile = null, fn) =>
    @_say words, destFile, (err, cmd) =>
      [bin, args] = [cmd[0], cmd[1..]]
      console.log bin, args
      call bin, args, (err, data) =>
        console.log "Done. #{destFile}"
        fn err, data

  say: (words, fn = null) =>
    destFile = @getDestFile()
    @saveSay words, destFile, (err, data) =>
      system @getPlay(), [destFile]

module.exports =
  Alfred: Alfred
