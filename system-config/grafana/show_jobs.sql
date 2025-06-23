select t2.user, t1.id_job, t1.cpus_req, t1.mem_req, t1.nodes_alloc, t1.submit_line,
case 
when t1.state = 0 then "pending"
when t1.state = 1 then "running"
when t1.state = 2 then "suspended"
when t1.state = 3 then "complete"
when t1.state = 4 then "cancelled"
when t1.state = 5 then "failed"
when t1.state = 6 then "timeout"
when t1.state = 7 then "node-fail"
when t1.state = 8 then "preempted"
when t1.state = 9 then "boot-fail"
when t1.state = 10 then "deadline"
when t1.state = 11 then "out-of-memory"
when t1.state = 12 then "requed"
when t1.state = 13 then "requed-hold"
when t1.state = 14 then "resizing"
when t1.state = 15 then "job-reboot"
else "???"
end as state 
from dcc_job_table as t1 left join dcc_assoc_table as t2 on t1.id_assoc=t2.id_assoc 
where (t1.state != 524288) and ('${Username:raw}' = 'All' or  t2.user in (${Username:singlequote}))
order by t1.id_job desc
