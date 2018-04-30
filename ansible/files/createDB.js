use admin

db.createUser({user: "mongo-admin", pwd: "password", roles:[{role: "root", db: "admin"}]})
