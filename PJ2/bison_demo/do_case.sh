make
if [ -e answer ]
then
rm -rf answer
mkdir answer
chmod 777 answer
else
mkdir answer
chmod 777 answer
fi
DIR=$(dirname $(readlink -f $0))
for ((i=1;i<=14;i++))
do
    ./demo tests/case_$i.pcat > ./answer/case_$i.txt
done