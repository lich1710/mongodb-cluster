rs.initiate()
sleep(5000)

rs.add( { host: "db1.test.com:27017", priority: 0, votes: 0 } )
sleep(5000)
rs.add( { host: "db2.test.com:27017", priority: 0, votes: 0 } )
