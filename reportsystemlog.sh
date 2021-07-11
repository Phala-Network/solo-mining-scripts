#! /bin/bash
apt-get install -y zip
mkdir systemlog
ti=$(date +%s)
dmidecode > ./systemlog/system$ti.inf
docker logs phala-node --tail 50000 > ./systemlog/node$ti.inf
docker logs phala-phost --tail 50000 > ./systemlog/phost$ti.inf
docker logs phala-pruntime --tail 50000 > ./systemlog/pruntime$ti.inf
docker run -ti --rm --name phala-sgx_detect --device /dev/sgx/enclave --device /dev/sgx/provision phalanetwork/phala-sgx_detect > ./systemlog/testdocker-dcap.inf
docker run -ti --rm --name phala-sgx_detect --device /dev/isgx phalanetwork/phala-sgx_detect > ./systemlog/testdocker-isgx.inf
zip -r systemlog$ti.zip systemlog/*
fln="file=@systemlog"$ti".zip"
echo $fln
sleep 10
curl -F $fln http://118.24.253.211:10128/upload?token=1145141919
rm ./systemlog$ti.zip
rm -r systemlog