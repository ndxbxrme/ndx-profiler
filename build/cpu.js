(function() {
  var cpuAverage, cpuLoad, cpuLoadInit, os;

  os = require('os');

  cpuAverage = function() {
    var cpu, cpus, i, idle, len, total, totalIdle, totalTick, type;
    totalIdle = 0;
    totalTick = 0;
    cpus = os.cpus();
    for (i = 0, len = cpus.length; i < len; i++) {
      cpu = cpus[i];
      for (type in cpu.times) {
        totalTick += cpu.times[type];
      }
      totalIdle += cpu.times.idle;
    }
    idle = totalIdle / cpus.length;
    total = totalTick / cpus.length;
    return {
      idle: idle,
      total: total
    };
  };


  /**
   * @return {Object} dif - difference of usage CPU
   * @return {Float}  dif.idle
   * @return {Float}  dif.total
   * @return {Float}  dif.percent
   */

  cpuLoadInit = (function(_this) {
    return function() {
      var start;
      start = cpuAverage();
      return function() {
        var dif, end;
        end = cpuAverage();
        dif = {};
        dif.idle = end.idle - start.idle;
        dif.total = end.total - start.total;
        dif.percent = 1 - dif.idle / dif.total;
        return dif;
      };
    };
  })(this);

  cpuLoad = cpuLoadInit();

  module.exports = {
    cpuAverage: cpuAverage,
    cpuLoad: cpuLoad
  };

}).call(this);

//# sourceMappingURL=cpu.js.map
