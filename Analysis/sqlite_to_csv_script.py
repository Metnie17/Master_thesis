#!/usr/bin/python3

import sqlite3

filepath = [
	'classification/benchmark_GraftM_class_64',
	'classification/benchmark_sintax_64',
	'benchmark/benchmark_bowtie',
	'benchmark/benchmark_bwa',
	'benchmark/benchmark_graftm',
	'benchmark/benchmark_hammer',
]

for f in filepath:
	con = sqlite3.connect(f'{f}.sqlite')
	cur = con.cursor()

	res = cur.execute("select record_id, ts, stat_num_threads, (stat_utime + stat_stime) / 100, stat_rss * 4096 / (1024*1024), stat_ppid, cmdline from record;")
	res = res.fetchall()

	t0 = res[0][1]

	s = []
	for r in res:
		r = list(r)
		r[1] -= t0
		online = f"{r[0]}; {r[1]:.3f}; {r[2]}; {r[3]}; {r[4]}; {r[5]}; '{r[6]}'\n"
		s.append(online)

	header = 'record_id; ts; num_threads; cpu time; rss; ppid; cmdline\n'
	content = ''.join(s)

	f = open(f'{f}.csv', "w")
	f.write(header + content)
	f.close()
