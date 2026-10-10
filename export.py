import subprocess
import sys
from pathlib import Path

import trimesh

ROOT = Path(__file__).parent
SCAD = ROOT / "scad" / "tea_infuser.scad"
OUT = ROOT / "export"
OUT.mkdir(exist_ok=True)
EXE = Path(r"C:\Program Files\OpenSCAD\openscad.exe")

PARTS = [
    (1, "bowl", ["--camera=0,0,-4,65,0,30,70"]),
    (2, "top", ["--camera=8,0,28,65,0,35,110"]),
    (3, "case_body", ["--camera=0,0,20,60,0,30,220"]),
    (4, "case_cap", ["--camera=0,0,6,65,0,40,200"]),
]


def run(args):
    print(">", " ".join(args))
    subprocess.run(args, check=True)


def pack_glb():
    bowl = trimesh.load(OUT / "bowl.stl")
    top = trimesh.load(OUT / "top.stl")
    body = trimesh.load(OUT / "case_body.stl")
    cap = trimesh.load(OUT / "case_cap.stl")

    infuser = trimesh.util.concatenate([bowl, top])
    infuser.export(OUT / "infuser.glb")

    cap_h = cap.extents[2]
    cap.apply_transform(trimesh.transformations.rotation_matrix(3.14159265, [1, 0, 0]))
    cap.apply_translation([0, 0, body.extents[2] + cap_h])
    case = trimesh.util.concatenate([body, cap])
    case.export(OUT / "case.glb")

    infuser_pack = infuser.copy()
    infuser_pack.apply_translation([0, 70, 0])
    kit = trimesh.util.concatenate([case, infuser_pack])
    kit.export(OUT / "kit.glb")
    print("GLB infuser/case/kit", infuser.extents.round(1))


def preview_pngs():
    import matplotlib.pyplot as plt

    jobs = [
        ("bowl.stl", "preview_bowl.png", -40, 22),
        ("top.stl", "preview_top.png", -45, 18),
        ("case_body.stl", "preview_case.png", -50, 22),
        ("infuser.glb", "preview_infuser.png", -45, 16),
        ("kit.glb", "preview_kit.png", -55, 18),
    ]
    for src, dst, azim, elev in jobs:
        mesh = trimesh.load(OUT / src)
        if isinstance(mesh, trimesh.Scene):
            mesh = mesh.to_geometry()
        v, f = mesh.vertices, mesh.faces
        fig = plt.figure(figsize=(7, 7), facecolor="#F4F0E8")
        ax = fig.add_subplot(111, projection="3d")
        ax.set_facecolor("#F4F0E8")
        ax.plot_trisurf(
            v[:, 0], v[:, 1], v[:, 2], triangles=f,
            color="#6E8F73", shade=True, linewidth=0, antialiased=False,
        )
        c = (v.max(0) + v.min(0)) / 2
        r = (v.max(0) - v.min(0)).max() / 2 * 1.05
        ax.set_xlim(c[0] - r, c[0] + r)
        ax.set_ylim(c[1] - r, c[1] + r)
        ax.set_zlim(c[2] - r, c[2] + r)
        ax.view_init(elev=elev, azim=azim)
        ax.set_axis_off()
        fig.savefig(OUT / dst, dpi=130, bbox_inches="tight", facecolor=fig.get_facecolor())
        plt.close()
        print("preview", dst)


def main():
    if not EXE.exists():
        sys.exit(f"OpenSCAD not found: {EXE}")
    for n, name, cam in PARTS:
        print(f"STL {name}")
        run([str(EXE), "-o", str(OUT / f"{name}.stl"), "-D", f"part={n}", str(SCAD)])
        run([
            str(EXE), "-o", str(OUT / f"{name}.png"),
            "--imgsize=1200,900", "--preview", *cam, "-D", f"part={n}", str(SCAD),
        ])
    print("PNG assembly")
    run([
        str(EXE), "-o", str(OUT / "assembly.png"),
        "--imgsize=1600,1200", "--preview", "--camera=10,0,55,72,0,35,320",
        "-D", "part=0", str(SCAD),
    ])
    print("PNG dump")
    run([
        str(EXE), "-o", str(OUT / "dump.png"),
        "--imgsize=1400,1000", "--preview", "--viewall", "--autocenter",
        "-D", "part=9", str(SCAD),
    ])
    print("PNG kit")
    run([
        str(EXE), "-o", str(OUT / "kit_open.png"),
        "--imgsize=1600,1200", "--preview", "--camera=0,0,22,60,0,40,280",
        "-D", "part=7", str(SCAD),
    ])
    pack_glb()
    preview_pngs()
    print("done")


if __name__ == "__main__":
    main()
