os = require 'os'

cpuAverage = ->
    totalIdle = 0
    totalTick = 0

    cpus = os.cpus()

    for cpu in cpus
        for type of cpu.times
            totalTick += cpu.times[type]

        totalIdle += cpu.times.idle

    idle    = totalIdle / cpus.length
    total   = totalTick / cpus.length
    percent = (1 - totalIdle / totalTick) * 100

    return {
        idle
        total
        percent
    }

###*
 * @return {Object} dif - difference of usage CPU
 * @return {Float}  dif.idle
 * @return {Float}  dif.total
 * @return {Float}  dif.percent
###
cpuLoadInit = =>
    start = cpuAverage()
    return ->
        end = cpuAverage()
        dif = {}

        dif.idle  = end.idle  - start.idle
        dif.total = end.total - start.total

        dif.percent = 1 - dif.idle / dif.total

        return dif

cpuLoad = cpuLoadInit()

module.exports = {
    cpuAverage
    cpuLoad
}