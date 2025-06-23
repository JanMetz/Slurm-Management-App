from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_queue_running"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "#running_tasks" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_queue_completing"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "#completing_tasks" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_queue_pending"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "#pending_tasks" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_queue_configuring"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "#configuring_tasks" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_queue_pending_dependency"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "#pending_dependency_tasks" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_queue_failed"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "#failed_tasks" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_queue_suspended"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "#suspended_tasks" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_queue_preempted"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "#preempted_tasks" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])



from(bucket: "slurm")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "slurm_queue_node_fail"
  )
  |> map(fn: (r) => ({ r with _field: "", _measurement: "#node_fail_tasks" }))
  |> keep(columns: ["_time", "_value", "_field", "_measurement"])
