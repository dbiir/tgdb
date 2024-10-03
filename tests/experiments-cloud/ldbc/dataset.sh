scp -r  aeong/ hjm@10.77.110.145:/data2/hjm
docker exec -it 005fbf7a417c /bin/bash
docker cp /data2/hjm/aeong/ 005fbf7a417c:/home/cloud_results/

scp -r  aeong/ hjm@10.77.110.146:/data3
docker exec -it 7d64ba2f33c6 /bin/bash
docker cp /data3/aeong/ 7d64ba2f33c6:/home/cloud_results/

scp -r  aeong/ hjm@10.77.110.147:/home/hjm
docker exec -it 7cb76f77f7f4 /bin/bash
docker cp /home/hjm/aeong/ 7cb76f77f7f4:/home/cloud_results/

scp -r  aeong/ hjm@10.77.110.148:/data4/hjm
docker exec -it fa20c1706872 /bin/bash
docker cp /data4/hjm/aeong/ fa20c1706872:/home/cloud_results/


