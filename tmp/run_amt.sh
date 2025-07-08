 #!/bin/bash
HOST=$1;
PWD=$(cat /etc/amt/passwords | sed -nE "s/(^[^#]+)\s+$HOST/\1/p"); #zakladajac format pliku passwords analogiczny do formatu pliku ethers tj haslo, biale znaki, hostname
export AMT_PASSWORD=$PWD
amttool $@
export AMT_PASSWORD=""
