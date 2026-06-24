import csv

INPUT_FILE = "./simulation-data/HourGlass_pit_0.05.csv"
OUTPUT_FILE = "HourGlass_pit_0.05.csv"
END_TIME = 5.1

# Read all rows
with open(INPUT_FILE, "r", newline="") as f:
    reader = csv.reader(f, skipinitialspace=True)
    rows = [row for row in reader if row]

# Get unique timesteps in order
timesteps = []
last_seen = None

for row in rows:
    t = float(row[0])
    if t != last_seen:
        timesteps.append(t)
        last_seen = t

if len(timesteps) < 2:
    raise ValueError("Need at least two timesteps to determine timestep size.")

dt = timesteps[-1] - timesteps[-2]
last_time = timesteps[-1]

print(f"Last timestep: {last_time}")
print(f"Detected dt: {dt}")

# Extract final frame
final_frame = [row[:] for row in rows if float(row[0]) == last_time]

# Create new rows
extended_rows = rows[:]

new_time = last_time + dt

while new_time <= END_TIME:
    for row in final_frame:
        new_row = row[:]
        new_row[0] = f"{new_time:.5f}"
        extended_rows.append(new_row)

    new_time += dt

# Write output
with open(OUTPUT_FILE, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(extended_rows)

print(f"Wrote {len(extended_rows)} rows to {OUTPUT_FILE}")