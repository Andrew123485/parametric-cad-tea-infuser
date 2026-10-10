// Clamshell pod on a stem: tea lives in a shallow ball, not a tube.
// Open 140° over the bin — both walls face out, leaf falls. No fingers.
// part: 0 cup  1 bowl  2 top  3 case_body  4 case_cap  6 plate  7 kit  8 anim
part = 0;
anim_t = 0;

$fa = 7;
$fs = 0.5;

cup_h = 100; cup_top_od = 60; cup_top_id = 57;
cup_bot_od = 42; cup_bot_id = 40; cup_wall = 0.45; bead_r = 1.40;

pod_r = 15; wall = 1.3; wall_gap = 3.0; stem_h = 28;
bead_z = 2.4; hook_inner = 1.70; hook_t = 1.50; hook_w = 9.0;
hinge_od = 5.0; hinge_id = 2.05; knuckle_w = 3.2; knuckle_gap = 3.8;
hole_d = 1.7;

case_inner_l = 130; case_inner_w = 56; case_inner_h = 38;
case_wall = 2.0; case_floor = 2.0; lip_h_case = 7; lip_wall = 1.4;
cap_top_th = 2.0; fit = 0.30;
div_x = -22; div_t = 2.4;
body_h = case_floor + case_inner_h;
dry_l = case_inner_l / 2 + div_x - div_t / 2;
wet_l = case_inner_l / 2 - div_x - div_t / 2;

z_bot = cup_h - bead_z - stem_h - 2 * pod_r;
z_center = z_bot + pod_r;
function cup_r(z) = cup_bot_id / 2 + (cup_top_id / 2 - cup_bot_id / 2) * (z / cup_h);
axis_x = cup_r(z_center) - pod_r - wall_gap;
hinge_x = pod_r - 0.4;
bead_x = pod_r + wall_gap + cup_wall + bead_r;

module mesh_holes(dir) {
  // dir +1 top hemisphere, -1 bottom. Skip the hinge (+X) and latch (−X).
  for (lat = [28, 55, 82])
    for (lon = [25, 55, 90, 125, 155, 205, 235, 270, 305, 335])
      rotate([0, dir * lat, lon])
        translate([0, 0, pod_r - 0.8])
          cylinder(d = hole_d, h = wall + 2.2, center = true, $fn = 8);
}

module hemisphere(dir) {
  difference() {
    intersection() {
      difference() {
        sphere(r = pod_r);
        sphere(r = pod_r - wall);
      }
      translate([0, 0, dir * (pod_r / 2 + 0.05)])
        cube([pod_r * 2 + 4, pod_r * 2 + 4, pod_r + 0.1], center = true);
    }
    mesh_holes(dir);
  }
  // equatorial rim
  intersection() {
    difference() {
      cylinder(h = 2.4, r = pod_r, center = true);
      cylinder(h = 3.0, r = pod_r - wall, center = true);
    }
    translate([0, 0, dir * 1.3]) cube([pod_r * 2 + 4, pod_r * 2 + 4, 2.6], center = true);
  }
}

module knuckles(on_bowl) {
  ys = on_bowl
    ? [-(knuckle_gap / 2 + knuckle_w / 2), (knuckle_gap / 2 + knuckle_w / 2)]
    : [0];
  ww = on_bowl ? knuckle_w : knuckle_gap - 0.5;
  for (y = ys)
    translate([hinge_x, y, 0]) rotate([90, 0, 0]) difference() {
      hull() {
        cylinder(d = hinge_od, h = ww, center = true);
        translate([-2.2, on_bowl ? -1.2 : 1.2, 0])
          cube([2.0, 2.4, ww], center = true);
      }
      cylinder(d = hinge_id, h = ww + 1, center = true, $fn = 16);
    }
}

module bowl() {
  difference() {
    union() {
      hemisphere(-1);
      knuckles(true);
      // latch catch on the drink side
      translate([-pod_r + 0.6, 0, -1.0]) cube([2.2, 6.0, 3.2], center = true);
    }
    translate([-pod_r + 0.6, 0, 0.6]) cube([2.6, 4.4, 2.2], center = true);
  }
}

module hook_void() {
  translate([bead_x, bead_z]) circle(r = hook_inner);
  translate([bead_x - 0.4, bead_z - 1.3])
    rotate([0, 0, -42]) square([7.0, 2.4], center = true);
}

module hook_2d() {
  difference() {
    union() {
      hull() {
        translate([3.0, 0.1]) square([1.0, 2.0]);
        translate([bead_x - 3.2, bead_z - 1.8]) square([4.0, 4.2]);
      }
      offset(r = hook_t) hook_void();
      translate([bead_x + 1.3, bead_z - 0.2])
        offset(r = 1.0) square([2.0, 11]);
    }
    hook_void();
    translate([-30, -18]) square([33, 48]);
  }
}

module top() {
  difference() {
    union() {
      hemisphere(1);
      knuckles(false);
      // stem along the cup wall
      hull() {
        translate([pod_r - 3.2, 0, 2]) cube([5.0, 5.2, 2], center = true);
        translate([pod_r - 2.4, 0, pod_r + stem_h - 1])
          cube([4.2, 5.2, 2], center = true);
      }
      translate([0, 0, pod_r + stem_h]) {
        translate([0, hook_w / 2, 0]) rotate([90, 0, 0])
          linear_extrude(height = hook_w, convexity = 8)
            offset(r = 0.3) offset(delta = -0.3) hook_2d();
      }
      // snap tooth
      translate([-pod_r + 0.4, 0, 1.2]) cube([2.0, 4.0, 2.4], center = true);
    }
    translate([-pod_r + 0.4, 0, -0.4]) cube([2.4, 4.6, 2.0], center = true);
  }
}

module infuser(open_a = 0) {
  top();
  translate([hinge_x, 0, 0]) rotate([0, -open_a, 0]) translate([-hinge_x, 0, 0])
    bowl();
}

module stadium(len, wid) {
  r = wid / 2;
  hull() {
    translate([-(len / 2 - r), 0]) circle(r = r);
    translate([+(len / 2 - r), 0]) circle(r = r);
  }
}

module case_body() {
  dry_cx = -(case_inner_l / 2 - dry_l / 2);
  wet_cx = case_inner_l / 2 - wet_l / 2;
  difference() {
    union() {
      linear_extrude(height = body_h - lip_h_case)
        offset(r = case_wall) stadium(case_inner_l, case_inner_w);
      translate([0, 0, body_h - lip_h_case])
        linear_extrude(height = lip_h_case)
          offset(r = lip_wall) stadium(case_inner_l, case_inner_w);
    }
    // dry packet tray — wide, shallow, you dump a bag in
    translate([dry_cx, 0, case_floor])
      linear_extrude(height = 20)
        offset(r = -0.3) stadium(dry_l - 1.2, case_inner_w - 3.0);
    // wet well — oversized toss-in, not a glove
    translate([wet_cx, 0, case_floor])
      linear_extrude(height = body_h)
        offset(r = -0.3) stadium(wet_l - 1.2, case_inner_w - 3.0);
  }
  translate([wet_cx, 0, 0])
    for (y = [-16, 0, 16])
      translate([0, y, case_floor]) cube([wet_l - 16, 1.0, 1.6], center = true);
}

module case_cap() {
  cap_h = cap_top_th + lip_h_case;
  difference() {
    linear_extrude(height = cap_h)
      offset(r = case_wall) stadium(case_inner_l, case_inner_w);
    translate([0, 0, cap_top_th])
      linear_extrude(height = cap_h)
        offset(r = lip_wall + fit) stadium(case_inner_l, case_inner_w);
  }
}

module vending_cup() {
  difference() {
    union() {
      cylinder(h = cup_h, d1 = cup_bot_od, d2 = cup_top_od);
      translate([0, 0, cup_h]) rotate_extrude($fn = 40)
        translate([cup_top_od / 2 - 0.15, 0]) circle(r = bead_r);
      for (i = [0 : 10]) {
        z = cup_h * (0.28 + i * 0.055);
        r = cup_bot_od / 2 + (cup_top_od / 2 - cup_bot_od / 2) * (z / cup_h);
        translate([0, 0, z]) rotate_extrude($fn = 28)
          translate([r, 0]) circle(r = 0.45);
      }
    }
    translate([0, 0, 0.4])
      cylinder(h = cup_h + 1, d1 = cup_bot_id, d2 = cup_top_id);
  }
}

module tea_level() {
  r = cup_r(70);
  translate([0, 0, 70]) cylinder(h = 1.4, r = r - 0.6);
}

module assembly(open_a = 0, lift = 0, slide = 0) {
  % vending_cup();
  color("Goldenrod", 0.32) tea_level();
  color("SeaGreen")
    translate([axis_x + slide, 0, z_center + lift]) infuser(open_a);
}

module kit_open(open_a = 0) {
  wet_cx = case_inner_l / 2 - wet_l / 2;
  color("Khaki") case_body();
  color("Khaki") translate([0, 0, body_h + 10]) case_cap();
  color("SeaGreen")
    translate([wet_cx, 0, case_floor + pod_r + 4])
      rotate([0, 90, 0]) infuser(open_a);
}

module print_plate() {
  bowl();
  translate([40, 0, 0]) rotate([180, 0, 0]) top();
  translate([0, 70, 0]) case_body();
  translate([0, 140, 0]) case_cap();
}

// t: hang → lift → open/dump → hold
module anim() {
  t = anim_t;
  lift = t < 0.20 ? 0 : min(40, (t - 0.20) / 0.12 * 40);
  slide = t < 0.30 ? 0 : min(38, (t - 0.30) / 0.10 * 38);
  open_a = t < 0.42 ? 0 : min(140, (t - 0.42) / 0.26 * 140);
  if (t < 0.78)
    assembly(open_a, lift, slide);
  else {
    drop = min(1, (t - 0.78) / 0.22);
    wet_cx = case_inner_l / 2 - wet_l / 2;
    color("Khaki") case_body();
    color("Khaki") translate([0, 0, body_h + 10]) case_cap();
    color("SeaGreen")
      translate([wet_cx, 0, 55 - drop * (55 - (case_floor + pod_r + 4))])
        rotate([0, 90, 0]) infuser(0);
  }
}

if      (part == 1) bowl();
else if (part == 2) top();
else if (part == 3) case_body();
else if (part == 4) case_cap();
else if (part == 6) print_plate();
else if (part == 7) kit_open();
else if (part == 8) anim();
else if (part == 9) infuser(140);
else                assembly();
