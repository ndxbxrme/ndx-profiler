(function() {
  'use strict';
  var cpu;

  cpu = require('./cpu.js');

  module.exports = function(ndx) {
    var isProfiler, profile;
    isProfiler = false;
    profile = {
      memory: 0,
      responseTime: 0,
      count: {
        total: 0,
        all: 0
      },
      status: {},
      db: {
        insert: 0,
        update: 0,
        "delete": 0,
        select: 0
      },
      cpu: {},
      start: ndx.startTime,
      id: ndx.id,
      version: ndx.version,
      dbVersion: ndx.database.version()
    };
    ndx.database.on('insert', function(args, cb) {
      if (!isProfiler) {
        profile.db.insert++;
      }
      return cb();
    });
    ndx.database.on('update', function(args, cb) {
      if (!isProfiler) {
        profile.db.update++;
      }
      return cb();
    });
    ndx.database.on('delete', function(args, cb) {
      if (!isProfiler) {
        profile.db["delete"]++;
      }
      return cb();
    });
    ndx.database.on('select', function(args, cb) {
      if (!isProfiler) {
        profile.db.select++;
      }
      return cb();
    });
    ndx.app.use(function(req, res, next) {
      var startTime;
      isProfiler = false;
      startTime = Date.now();
      profile.count.total++;
      if (req.url === '/api/profiler') {
        isProfiler = true;
      } else {
        if (req.method !== 'OPTIONS') {
          profile.count.all++;
        }
        profile.count[req.method] = (profile.count[req.method] || 0) + 1;
      }
      res.on('finish', function() {
        var endTime;
        endTime = Date.now();
        profile.responseTime += endTime - startTime;
        if (isProfiler) {
          return isProfiler = false;

          /*
          if req.method isnt 'OPTIONS'
            profile.db.select--
           */
        } else {
          return profile.status[res.statusCode] = (profile.status[res.statusCode] || 0) + 1;
        }
      });
      return next();
    });
    return ndx.app.get('/api/profiler', ndx.authenticate('superadmin'), function(req, res) {
      profile.memory = process.memoryUsage().rss / 1048576;
      profile.sqlCacheSize = ndx.database.cacheSize();
      profile.cpu = cpu.cpuLoad();
      return res.json(profile);
    });
  };

}).call(this);

//# sourceMappingURL=index.js.map
