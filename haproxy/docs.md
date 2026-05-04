docker compose exec pg1 patronictl list
docker stop fishlog_pg1
docker compose exec pg2 patronictl list 
+ Cluster: fishlog_cluster (7636052182445432860) --------+-----+------------+-----+
| Member | Host | Role    | State     | TL | Receive LSN | Lag | Replay LSN | Lag |
+--------+------+---------+-----------+----+-------------+-----+------------+-----+
| pg1    | pg1  | Replica | stopped   |    |     unknown |     |    unknown |     |
| pg2    | pg2  | Leader  | running   |  2 |             |     |            |     |
| pg3    | pg3  | Replica | streaming |  2 |   0/4AD54C8 |   0 |  0/4AD54C8 |   0 |
+--------+------+---------+-----------+----+-------------+-----+------------+-----+
docker start fishlog_pg1
+ Cluster: fishlog_cluster (7636052182445432860) --------+-----+------------+-----+
| Member | Host | Role    | State     | TL | Receive LSN | Lag | Replay LSN | Lag |
+--------+------+---------+-----------+----+-------------+-----+------------+-----+
| pg1    | pg1  | Replica | streaming |  2 |   0/4B14508 |   0 |  0/4B14508 |   0 |
| pg2    | pg2  | Leader  | running   |  2 |             |     |            |     |
| pg3    | pg3  | Replica | streaming |  2 |   0/4B14508 |   0 |  0/4B14508 |   0 |
+--------+------+---------+-----------+----+-------------+-----+------------+-----+