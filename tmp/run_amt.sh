 #!/bin/bash
export AMT_PASSWORD="secret_password"
amttool $@
export AMT_PASSWORD=""
