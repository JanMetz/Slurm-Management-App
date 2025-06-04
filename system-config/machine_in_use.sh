echo "UWAGA! Ta maszyna jest aktualnie w trakcie wykonywania obliczen jako czesc klastra slurm! Czy na pewno chcesz sie zalogowac? [Yes/no]"
read opt

while ! echo $opt | grep -E -q 'Yes|No';
do
    read opt;
done;

if [ $opt == "no" ]; then
    exit
fi
