'use strict'

cpu = require './cpu.js'

module.exports = (ndx) ->
  isProfiler = false
  profile =
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
  ndx.app.get '/api/profiler', ndx.authenticate('superadmin'), (req, res) ->
    profile.memory = process.memoryUsage().rss / 1048576
    profile.sqlCacheSize = ndx.database.cacheSize()
    profile.cpu = cpu.cpuLoad()
    res.json profile