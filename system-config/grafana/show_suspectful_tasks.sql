SELECT 
  sel1.id_job AS job_id, 
  sel2.user,
  sel1.user_cpu_sec, 
  sel1.avg_cpu_freq, 
  sel1.req_min_cpufreq, 
  sel2.cpus_req, 
  sel2.mem_req, 
  sel2.nodes_alloc,
  sel1.consumed_energy
FROM 
(
  SELECT t2.id_job, 
         SUM(t1.user_sec) AS user_cpu_sec, 
         AVG(t1.act_cpufreq) AS avg_cpu_freq, 
         MIN(t1.req_cpufreq_min) AS req_min_cpufreq,
         SUM(t1.time_start) as time_start,
         SUM(t1.time_end) as time_end,
         SUM(t1.consumed_energy) as consumed_energy
  FROM dcc_step_table AS t1 
  LEFT JOIN dcc_job_table AS t2 ON t1.job_db_inx = t2.job_db_inx
  GROUP BY t2.id_job
) AS sel1
JOIN 
(
  SELECT t2.user, 
         t1.id_job, 
         t1.cpus_req, 
         t1.mem_req, 
         t1.nodes_alloc
  FROM dcc_job_table AS t1 
  LEFT JOIN dcc_assoc_table AS t2 ON t1.id_assoc = t2.id_assoc 
  WHERE t1.state != 524288
) AS sel2
ON sel1.id_job = sel2.id_job
WHERE req_min_cpufreq > avg_cpu_freq or (cpus_req > 2 and user_cpu_sec < 0.1 * (time_end - time_start)) or (consumed_energy > 300)
ORDER BY job_id DESC;

