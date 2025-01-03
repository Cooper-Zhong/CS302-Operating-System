# Operating System Assignment 3

12110517, 钟志源

| Process | Estimated CPU Cost | Arrives | Priority |
| ------- | ------------------ | ------- | -------- |
| A       | 6                  | 1       | 1        |
| B       | 1                  | 2       | 2        |
| C       | 3                  | 5       | 3        |
| D       | 2                  | 4       | 4        |

| Time                 | HRRN | FIFO/FCFS | RR  | SJF | Prioriy |
| -------------------- | ---- | --------- | --- | --- | ------- |
| 1                    | A    | A         | A   | A   | A       |
| 2                    | A    | A         | A   | A   | B       |
| 3                    | A    | A         | B   | A   | A       |
| 4                    | A    | A         | A   | A   | D       |
| 5                    | A    | A         | D   | A   | D       |
| 6                    | A    | A         | A   | A   | C       |
| 7                    | B    | B         | C   | B   | C       |
| 8                    | D    | D         | D   | D   | C       |
| 9                    | D    | D         | A   | D   | A       |
| 10                   | C    | C         | C   | C   | A       |
| 11                   | C    | C         | A   | C   | A       |
| 12                   | C    | C         | C   | C   | A       |
| Avg turn-around time | 6.5  | 6.5       | 6.5 | 6.5 | 4.75    |
