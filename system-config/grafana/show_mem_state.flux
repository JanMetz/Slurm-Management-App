from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_node_mem_alloc"
  )
  |> map(fn: (r) => ({ r with _field: "node_mem_alloc", _measurement: "node_mem_alloc" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement", "node"])
