(function() {
  'use strict';
  var cpu;

  cpu = require('cpu');

  module.exports = function(ndx) {
    var profile;
    profile = {
      memory: 0,
      responseTime: 0,
      count: {
        all: 0
      },
      status: {},
      db: {
        insert: 0,
        update: 0,
        select: 0,
        "delete": 0
      },
      cpu: []
    };
    cpu.usage(function(arr) {
      return profile.cpu = arr;
    });
    ndx.database.on('insert', function() {
      return profile.db.insert++;
    });
    ndx.database.on('update', function() {
      return profile.db.update++;
    });
    ndx.database.on('select', function() {
      return profile.db.select++;
    });
    ndx.database.on('delete', function() {
      return profile.db["delete"]++;
    });
    ndx.app.use(function(req, res, next) {
      var startTime;
      startTime = Date.now();
      profile.count.all++;
      profile.count[req.method] = (profile.count[req.method] || 0) + 1;
      res.on('finish', function() {
        var endTime;
        endTime = Date.now();
        profile.responseTime += endTime - startTime;
        return profile.status[res.status] = (profile.status[res.status] || 0) + 1;
      });
      return next();
    });
    return ndx.app.get('/api/profiler', ndx.authenticate('superadmin'), function(req, res) {
      profile.memory = process.memoryUsage().rss / 1048576;
      return res.json(profile);
    });
  };

}).call(this);

//# sourceMappingURL=index.js.map
