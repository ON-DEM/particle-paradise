import csv
import struct
from collections import defaultdict
from pathlib import Path

INPUT_DIR = Path("./simulation_data")
OUTPUT_DIR = Path("./real-simulations/data/avalanche")

INPUT_FPS = 10
TARGET_FPS = 10

STEP = max(1, round(INPUT_FPS / TARGET_FPS))

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


def convert_csv_to_bin(input_file: Path, output_file: Path):

    frames = defaultdict(list)
    pid_frames = defaultdict(list)

    print(f"\nReading: {input_file.name}")

    with open(input_file, newline="") as f:
        reader = csv.reader(f)

        for row in reader:

            if len(row) < 6:
                continue

            try:
                time = float(row[0])
                pid = int(row[1])

                x = float(row[2])
                y = float(row[3])
                z = float(row[4])
                size = float(row[5])

            except ValueError:
                continue

            frame = int(round(time * INPUT_FPS))

            # downsample
            if frame % STEP != 0:
                continue

            frames[frame].append((pid, x, y, z, size))
            pid_frames[pid].append(frame)

    frame_keys = sorted(frames.keys())
    frame_count = len(frame_keys)

    particle_count = len({
        pid
        for frame in frame_keys
        for pid, *_ in frames[frame]
    })

    print(f"Frames: {frame_count}")
    print(f"Particles: {particle_count}")

    with open(output_file, "wb") as f:

        # header
        f.write(struct.pack("<II", particle_count, frame_count))

        # placeholder offset table
        offset_table_pos = f.tell()
        f.write(struct.pack("<" + "I" * frame_count, *([0] * frame_count)))

        offsets = []

        for frame in frame_keys:

            offsets.append(f.tell())

            frame_data = frames[frame]

            f.write(struct.pack("<I", len(frame_data)))

            for pid, x, y, z, size in frame_data:
                f.write(struct.pack("<Iffff", pid, x, y, z, size))

        # patch offsets
        end_pos = f.tell()

        f.seek(offset_table_pos)

        for offset in offsets:
            f.write(struct.pack("<I", offset))

        f.seek(end_pos)

    print(f"Wrote: {output_file.name}")


def main():

    csv_files = sorted(INPUT_DIR.glob("*.csv"))

    if not csv_files:
        print(f"No CSV files found in {INPUT_DIR}")
        return

    print(f"Found {len(csv_files)} CSV files")

    for csv_file in csv_files:

        output_file = OUTPUT_DIR / f"{csv_file.stem}.bin"

        try:
            convert_csv_to_bin(csv_file, output_file)

        except Exception as e:
            print(f"FAILED: {csv_file.name}")
            print(e)

    print("\nDone.")


if __name__ == "__main__":
    main()