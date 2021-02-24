echo "replicasetkeyCisco123" > key.txt
mongo -u __system -p "$(tr -d '\011-\015\040' < key.txt)" --authenticationDatabase local




# db.createUser(
#   {
#     user: 'root',
#     pwd: 'root',
#     roles: [ { role: 'root', db: 'admin' } ]
#   }
# );