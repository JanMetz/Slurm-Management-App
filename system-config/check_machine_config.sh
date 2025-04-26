if test -f /etc/munge/munge.key && sha512sum /etc/munge/munge.key | grep 'cde7fc8b9b582f527d71f2e93c1b7441d08ed04219d6f342e351bd328a301bce0434e2a2b9eb1d4fb68c7bbd1cb48d1518cafb5f71c08a3071ec4d20e50bff83' -q;
then
echo "found munge key";
else 
echo "did not find munge key";
fi;

if test -f /sys/class/net/enp1s0/operstate && cat /sys/class/net/enp1s0/operstate | grep 'up' -q;
then
echo "enp1s0 up";
else
echo "enp1s0 down";
fi;
