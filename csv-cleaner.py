import csv
from collections import defaultdict

INPUT = "Run_Baseline.csv"
OUTPUT = "cleaned_baseline.csv"

EXCLUDE_MAX_PID = 799

print("Reading CSV...")

rows = []
pid_frames = defaultdict(list)
all_times = set()

with open(INPUT, newline="") as f:
    reader = csv.reader(f)

    for row in reader:
        if len(row) < 6:
            continue

        try:
            time = float(row[0])
            pid = int(row[1])
        except ValueError:
            continue

        # Remove static object particles
        if 0 <= pid <= EXCLUDE_MAX_PID:
            continue

        rows.append(row)

        pid_frames[pid].append(time)
        all_times.add(time)

final_time = max(all_times)

print(f"Final simulation time: {final_time}")

# Keep only particles that survive until the final frame
valid_pids = set()

removed_pids = []

for pid, times in pid_frames.items():

    last_time = max(times)

    if last_time == final_time:
        valid_pids.add(pid)
    else:
        removed_pids.append((pid, last_time))

print(f"Keeping {len(valid_pids)} particles")
print(f"Removing {len(removed_pids)} particles that disappear early")

# Optional: show first few removed particles for debugging
for pid, last_time in removed_pids[:20]:
    print(f"Removed PID {pid} (last seen at {last_time})")

print("Writing cleaned CSV...")

with open(OUTPUT, "w", newline="") as f:
    writer = csv.writer(f)

    for row in rows:
        pid = int(row[1])

        if pid in valid_pids:
            writer.writerow(row)

print(f"Done -> {OUTPUT}")