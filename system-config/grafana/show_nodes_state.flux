from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_nodes_idle"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "idle_nodes" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_nodes_resv"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "reserved_nodes" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_nodes_alloc"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "allocated_nodes" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_nodes_comp"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "comp_nodes" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_nodes_down"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "down_nodes" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_nodes_drain"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "drain_nodes" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_nodes_err"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "err_nodes" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_nodes_fail"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "fail_nodes" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_nodes_maint"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "maint_nodes" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])
