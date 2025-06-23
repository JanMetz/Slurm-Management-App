select t2.id_job, sum(t1.task_cnt) as task_cnt, sum(t1.user_sec) as user_cpu_sec, avg(t1.act_cpufreq) as avg_cpu_freq, min(t1.req_cpufreq_min) as req_min_cpufreq
from dcc_step_table as t1 left join dcc_job_table as t2 on t1.job_db_inx=t2.job_db_inx
GROUP BY t2.id_job
order by t2.id_job desc
