from fastapi import FastAPI, Request
import subprocess
import re

app = FastAPI()

@app.get("/nodes")
async def post_nodes(req : Request):
    resp = subprocess.check_output(["sinfo", "-h", "-o", "'%T %N'"]).decode()
    arr = resp.strip().split("\n")

    nodes = []

    for entry in arr:
        entry = entry.strip().replace("'", "")
        state, hostname = entry.split(" ")

        if re.search(state, "ALLOCATED|MIXED|RESERVED|POWERING_UP|PLANNED|PERFCTRS", re.IGNORECASE):
            bracket_idx = hostname.find("[")
            if bracket_idx != -1:
                prefix = hostname[:bracket_idx]
                delimit = hostname.find('-', bracket_idx)
                low_idx = int(hostname[bracket_idx + 1 : delimit])
                high_idx = int(hostname[delimit + 1 : -1])

                for idx in range(low_idx, high_idx + 1):
                    nodes.append(prefix + str(idx))
            else:
                nodes.append(hostname)

    return {
        "nodes" : nodes
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host='0.0.0.0', port=8089)
