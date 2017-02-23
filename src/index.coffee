'use strict'

cpu = require './cpu.js'

module.exports = (ndx) ->
  profile =
    memory: 0
    responseTime: 0
    count:
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
  ndx.database.on 'insert', ->
    profile.db.insert++
  ndx.database.on 'update', ->
    profile.db.update++
  ndx.database.on 'delete', ->
    profile.db.delete++
  ndx.database.on 'select', ->
    profile.db.select++
  ndx.app.use (req, res, next) ->
    startTime = Date.now()
    profile.count.all++
    profile.count[req.method] = (profile.count[req.method] or 0) + 1
    res.on 'finish', ->
      endTime = Date.now()
      profile.responseTime += endTime - startTime
      profile.status[res.statusCode] = (profile.status[res.statusCode] or 0) + 1
    next()
  ndx.app.get '/api/profiler', ndx.authenticate('superadmin'), (req, res) ->
    profile.memory = process.memoryUsage().rss / 1048576
    profile.sqlCacheSize = ndx.database.cacheSize()
    profile.cpu = cpu.cpuLoad()
    res.json profile