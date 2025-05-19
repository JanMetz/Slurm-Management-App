#!/bin/bash
scontrol create Reservation="zajecia_dydaktyczne" StartTime=07:00:00 Duration=14:59:00 user=root flags=ignore_jobs Nodes=ALL
