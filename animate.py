"""Render the actual OpenSCAD model as a short mp4: hang, dump, dock."""
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).parent
SCAD = ROOT / "scad" / "tea_infuser.scad"
OUT = ROOT / "export"
FRAMES = OUT / "frames"
EXE = Path(r"C:\Program Files\OpenSCAD\openscad.exe")
N = 36


def run(args):
    subprocess.run(args, check=True)


def main():
    if not EXE.exists():
        sys.exit(f"OpenSCAD not found: {EXE}")
    FRAMES.mkdir(parents=True, exist_ok=True)
    for i in range(N):
        t = i / (N - 1)
        png = FRAMES / f"f{i:03d}.png"
        cam = (
            ["--camera=10,0,55,72,0,35,320"] if t < 0.78
            else ["--camera=0,0,22,60,0,40,280"]
        )
        print(f"frame {i+1}/{N} t={t:.2f}")
        run([
            str(EXE), "-o", str(png),
            "--imgsize=960,540", "--preview", *cam,
            "-D", "part=8", "-D", f"anim_t={t:.4f}",
            str(SCAD),
        ])
    mp4 = OUT / "micro.mp4"
    run([
        "ffmpeg", "-y", "-framerate", "8",
        "-i", str(FRAMES / "f%03d.png"),
        "-c:v", "libx264", "-pix_fmt", "yuv420p",
        "-movflags", "+faststart", str(mp4),
    ])
    print("wrote", mp4)


if __name__ == "__main__":
    main()
