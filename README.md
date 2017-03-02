# ndx-profiler
### collects stats about the performance of [ndx-framework](https://github.com/ndxbxrme/ndx-framework) apps
install with  
`npm install --save ndx-profiler`  

### app monitor
you can use [ndx-appmonitor](https://github.com/ndxbxrme/ndx-appmonitor) to monitor the status of your app in realtime  
`src/server/app.coffee`
```coffeescript
require 'ndx-server'
.config
  database: 'db'
.use 'ndx-cors'
.use 'ndx-profiler'
.use 'ndx-user-roles'
.use 'ndx-auth'
.use 'ndx-superadmin'
.start()
```
to monitor local apps git clone [ndx-appmonitor](https://github.com/ndxbxrme/ndx-appmonitor) then run it with grunt  
for live apps you can use [this pen](http://codepen.io/ndxbxrme/full/evNyGV/)