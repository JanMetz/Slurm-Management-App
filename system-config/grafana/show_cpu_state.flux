from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_node_cpu_alloc"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "node_cpu_alloc" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement", "node"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
   r._measurement == "slurm_node_cpu_idle"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "node_cpu_idle" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement", "node"])
