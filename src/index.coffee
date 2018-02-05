'use strict'

cpu = require './cpu.js'

module.exports = (ndx) ->
  MAX_HISTORY_SIZE = 6 * 30
  isProfiler = false
  history = []
  profile =
    date: new Date().valueOf()
    sockets: 0
    pageViews: 0
    memory: 0
    responseTime: 0
    count:
      total: 0
      all: 0
    status: {}
    db:
      insert: 0
      update: 0
      delete: 0
      select: 0
    cpu: {}
    start: ndx.startTime
    id: ndx.id
    version: ndx.version
    dbVersion: ndx.database.version()
  setTimeout ->
    if ndx.socket
      ndx.socket.on 'connection', ->
        profile.sockets++
      ndx.socket.on 'disconnect', ->
        profile.sockets--
    if ndx.passport
      ndx.passport.on 'refreshLogin', (args, cb) ->
        profile.pageViews++
        cb?()
  setInterval ->
    profile.memory = process.memoryUsage().rss / 1048576
    profile.sqlCacheSize = ndx.database.cacheSize()
    profile.cpu = cpu.cpuLoad()
    profile.server = if ndx.maintenanceMode then 'maintenance' else 'ok'
    history.push JSON.parse JSON.stringify profile
    if history.length > MAX_HISTORY_SIZE
      history.splice 0, history.length - MAX_HISTORY_SIZE
    profile.date = new Date().valueOf()
  , 10000
  ndx.database.on 'insert', (args, cb) ->
    if not isProfiler
      profile.db.insert++
    cb()
  ndx.database.on 'update', (args, cb) ->
    if not isProfiler
      profile.db.update++
    cb()
  ndx.database.on 'delete', (args, cb) ->
    if not isProfiler
      profile.db.delete++
    cb()
  ndx.database.on 'select', (args, cb) ->
    if not isProfiler
      profile.db.select++
    cb()
  ndx.app.use (req, res, next) ->
    isProfiler = false
    startTime = Date.now()
    profile.count.total++
    if req.url is '/api/profiler'
      isProfiler = true
    else
      if req.method isnt 'OPTIONS'
        profile.count.all++
      profile.count[req.method] = (profile.count[req.method] or 0) + 1
    res.on 'finish', ->
      endTime = Date.now()
      profile.responseTime += endTime - startTime
      if isProfiler
        isProfiler = false
        ###
        if req.method isnt 'OPTIONS'
          profile.db.select--
        ###
      else
        profile.status[res.statusCode] = (profile.status[res.statusCode] or 0) + 1
    next()
  ndx.app.get '/api/profiler', ndx.authenticate(), (req, res) ->
    profile.server = if ndx.maintenanceMode then 'maintenance' else 'ok'
    res.json profile
  ndx.app.get '/api/profiler/history', ndx.authenticate(), (req, res) ->
    res.json history