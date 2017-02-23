'use strict'

cpu = require 'cpu'

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
      select: 0
      delete: 0
    cpu: []
  cpu.usage (arr) ->
    profile.cpu = arr
  ndx.database.on 'insert', ->
    profile.db.insert++
  ndx.database.on 'update', ->
    profile.db.update++
  ndx.database.on 'select', ->
    profile.db.select++
  ndx.database.on 'delete', ->
    profile.db.delete++
  ndx.app.use (req, res, next) ->
    startTime = Date.now()
    profile.count.all++
    profile.count[req.method] = (profile.count[req.method] or 0)++
    res.on 'finish', ->
      endTime = Date.now()
      profile.responseTime += endTime - startTime
      profile.status[res.status] = (profile.status[res.status] or 0)++
    next()
  ndx.app.get '/api/profiler', ndx.authenticate('superadmin'), (req, res) ->
    profile.memory = process.memoryUsage().rss / 1048576
    res.json profile