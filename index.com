```html
<!-- ... existing code ... -->
          crates: (blueprint.crates || []).map(cr => ({
            ...cr,
            vx: 0,
            vy: 0
          })),
          ropes: (blueprint.ropes || []).map(rp => ({
            ...rp,
            angle: 0,
            angVel: 0,
            tipX: rp.anchorX,
            tipY: rp.anchorY + rp.length
          })),
          springs: (blueprint.springs || []).map(sp => ({
            ...sp,
            anim: 0
          })),
          movers: (blueprint.movers || []).map(mv => ({
            ...mv,
            dx: 0,
            dy: 0
          })),
          crushers: (blueprint.crushers || []).map(cr => ({
            ...cr,
            curY: cr.restY
          })),
          fans: (blueprint.fans || []).map(fn => ({ ...fn })),
          conveyors: (blueprint.conveyors || []).map(cv => ({ ...cv })),
          cannons: (blueprint.cannons || []).map(cn => ({ ...cn, cooldown: 0, recoil: 0 })),
          fragiles: (blueprint.fragiles || []).map(fg => ({
            ...fg,
            state: 'solid', // solid | shaking | broken
            timer: 0
          })),
          bumpers: (blueprint.bumpers || []).map(bp => ({ ...bp, pulse: 0 })),
          switches: (blueprint.switches || []).map(sw => ({
            ...sw,
            pressed: false
          })),
          gates: (blueprint.gates || []).map(g => ({
            ...g,
            openAmount: 0
          })),
          hazards: (blueprint.hazards || []).map(h => ({
            ...h,
            angle: 0
          }))
        };
<!-- ... existing code ... -->

```
Let's examine the exact lines in index.html so we produce a clean, unambiguous diff for:
 1. Fixing Stage 9's checkpoint ({ x: 1290, y: 270 } instead of { x: 1460, y: 270 }) + adding new contraptions (fans, conveyors, cannons, fragiles, bumpers, lasers) across all 15 levels!
 2. Allowing PlonkBot to grab **anywhere along the entire rope segment** (from anchor down to tip) using point-to-segment distance, and letting the player climb up/down the rope with UP/DOWN or jump off cleanly!
 3. Updating physics & rendering for all the new interactive contraptions.
Let's apply these updates cleanly to index.html.
```html:PlonkBot Physics Platformer:index.html
<!-- ... existing code ... -->
          checkpoint: () => {
            playTone(523, 659, 0.1, 'triangle', 0.14);
            setTimeout(() => playTone(784, 1046, 0.16, 'triangle', 0.15), 80);
          },
          cannon: () => playTone(140, 42, 0.28, 'sawtooth', 0.2),
          bumper: () => playTone(340, 740, 0.14, 'sine', 0.16),
          crumble: () => playTone(160, 70, 0.18, 'square', 0.11),
          ropeGrab: () => playTone(180, 290, 0.08, 'sine', 0.12),
<!-- ... existing code ... -->
        // STAGE 2: Tarzan Rope Swing, Fragile Bridges & Crate Steps
        {
          name: 'STAGE 2',
          theme: 'tropical',
          hint: 'Grab ANYWHERE on the swinging ropes! Watch out for crumbling wooden planks!',
          spawn: { x: 110, y: 310 },
          checkpoints: [{ x: 1380, y: 370 }],
          goal: { x: 2660, y: 310 },
          trees: [
            { x: 60, y: 370, scale: 1.0 },
            { x: 1420, y: 370, scale: 0.95 },
            { x: 2560, y: 360, scale: 1.05 }
          ],
          platforms: [
            { x: 0, y: 370, w: 420, h: 480, type: 'earth' },
            { x: 760, y: 390, w: 280, h: 480, type: 'earth' },
            { x: 1320, y: 370, w: 460, h: 480, type: 'earth' },
            { x: 2220, y: 360, w: 540, h: 480, type: 'earth' }
          ],
          bridges: [],
          balls: [],
          crates: [
            { x: 1580, y: 330, w: 56, h: 56 },
            { x: 1655, y: 330, w: 56, h: 56 }
          ],
          ropes: [
            { anchorX: 590, anchorY: 85, length: 255, amp: 0.58, speed: 2.3, phase: 0 },
            { anchorX: 1180, anchorY: 80, length: 260, amp: 0.62, speed: 2.4, phase: 1.2 },
            { anchorX: 1990, anchorY: 75, length: 265, amp: 0.65, speed: 2.5, phase: 0.5 }
          ],
          springs: [],
          movers: [],
          crushers: [],
          fans: [],
          conveyors: [],
          cannons: [],
          fragiles: [
            { x: 840, y: 390, w: 120, h: 18 }
          ],
          bumpers: [],
          switches: [],
          gates: [],
          hazards: []
        },

        // STAGE 3: Sunset Canyon — Spring Pads, Wind Fans & Elevated Ledges
        {
          name: 'STAGE 3',
          theme: 'sunset',
          hint: 'Ride the wind updrafts and yellow spring pads onto high canyon cliffs!',
          spawn: { x: 100, y: 340 },
          checkpoints: [{ x: 1450, y: 240 }],
          goal: { x: 2740, y: 210 },
          trees: [
            { x: 55, y: 400, scale: 0.9 },
            { x: 2680, y: 260, scale: 0.95 }
          ],
          platforms: [
            { x: 0, y: 400, w: 480, h: 450, type: 'earth' },
            { x: 480, y: 250, w: 360, h: 600, type: 'earth' },
            { x: 1080, y: 390, w: 320, h: 460, type: 'earth' },
            { x: 1400, y: 240, w: 440, h: 610, type: 'earth' },
            { x: 2040, y: 390, w: 340, h: 460, type: 'earth' },
            { x: 2380, y: 260, w: 460, h: 590, type: 'earth' }
          ],
          bridges: [
            { x: 960, y: 290, length: 250, thickness: 22, angle: 0.18, minAngle: -0.25, maxAngle: 0.35 }
          ],
          balls: [],
          crates: [],
          ropes: [],
          springs: [
            { x: 390, y: 386, w: 54, power: -760, anim: 0 },
            { x: 2290, y: 376, w: 54, power: -760, anim: 0 }
          ],
          movers: [],
          crushers: [],
          fans: [
            { x: 1300, y: 374, w: 74, height: 230, force: -1650 }
          ],
          conveyors: [],
          cannons: [],
          fragiles: [],
          bumpers: [
            { x: 1930, y: 270, r: 24, power: 620 }
          ],
          switches: [],
          gates: [],
          hazards: [
            { type: 'spikes', x: 1140, y: 374, w: 120, h: 16 }
          ]
        },
<!-- ... existing code ... -->
        // STAGE 5: Conveyor Belts, Moving Elevators & Buzzsaw Gauntlet
        {
          name: 'STAGE 5',
          theme: 'sunset',
          hint: 'Watch the conveyor belts pushing you toward patrolling buzzsaws!',
          spawn: { x: 100, y: 320 },
          checkpoints: [{ x: 1480, y: 330 }],
          goal: { x: 2820, y: 260 },
          trees: [{ x: 50, y: 380, scale: 0.9 }],
          platforms: [
            { x: 0, y: 380, w: 420, h: 470, type: 'earth' },
            { x: 920, y: 330, w: 660, h: 520, type: 'earth' },
            { x: 2060, y: 380, w: 340, h: 470, type: 'earth' },
            { x: 2400, y: 310, w: 520, h: 540, type: 'earth' }
          ],
          bridges: [],
          balls: [],
          crates: [],
          ropes: [],
          springs: [
            { x: 2320, y: 366, w: 52, power: -680, anim: 0 }
          ],
          movers: [
            { x: 460, y: 380, w: 130, h: 24, startX: 460, endX: 760, startY: 380, endY: 330, speed: 1.4, phase: 0, dx: 0, dy: 0 },
            { x: 1620, y: 330, w: 130, h: 24, startX: 1620, endX: 1900, startY: 330, endY: 380, speed: 1.5, phase: 1.0, dx: 0, dy: 0 }
          ],
          crushers: [],
          fans: [],
          conveyors: [
            { x: 960, y: 318, w: 160, h: 14, speed: 140 },
            { x: 2100, y: 368, w: 190, h: 14, speed: -150 }
          ],
          cannons: [],
          fragiles: [],
          bumpers: [],
          switches: [],
          gates: [],
          hazards: [
            { type: 'saw', x: 1180, y: 326, r: 28, speed: 0.15 },
            { type: 'saw', x: 1370, y: 326, r: 28, speed: -0.15 },
            { type: 'saw', x: 2560, y: 306, r: 28, speed: 0.16 }
          ]
        },
<!-- ... existing code ... -->
        // STAGE 7: Jungle Vine, Barrel Cannons & Seesaw Expedition
        {
          name: 'STAGE 7',
          theme: 'tropical',
          hint: 'Hop inside the Barrel Cannon to blast across the jungle gorge!',
          spawn: { x: 100, y: 300 },
          checkpoints: [{ x: 1450, y: 360 }],
          goal: { x: 2880, y: 310 },
          trees: [
            { x: 55, y: 360, scale: 1.0 },
            { x: 1480, y: 360, scale: 1.05 },
            { x: 2820, y: 360, scale: 1.0 }
          ],
          platforms: [
            { x: 0, y: 360, w: 360, h: 490, type: 'earth' },
            { x: 1120, y: 360, w: 540, h: 490, type: 'earth' },
            { x: 2040, y: 380, w: 280, h: 470, type: 'earth' },
            { x: 2320, y: 455, w: 105, h: 395, type: 'earth' },
            { x: 2425, y: 360, w: 540, h: 490, type: 'earth' }
          ],
          bridges: [
            { x: 920, y: 365, length: 340, thickness: 22, angle: -0.08, minAngle: -0.35, maxAngle: 0.35 }
          ],
          balls: [
            { x: 2130, y: 344, r: 36, mass: 3.4 }
          ],
          crates: [],
          ropes: [
            { anchorX: 1850, anchorY: 85, length: 250, amp: 0.6, speed: 2.4, phase: 1.4 }
          ],
          springs: [],
          movers: [],
          crushers: [],
          fans: [],
          conveyors: [],
          cannons: [
            { x: 430, y: 295, angle: -0.52, power: 820 }
          ],
          fragiles: [],
          bumpers: [
            { x: 660, y: 215, r: 24, power: 540 }
          ],
          switches: [],
          gates: [],
          hazards: []
        },
<!-- ... existing code ... -->
        // STAGE 9: Skyward Tower Ascent (FIXED SAFE CHECKPOINT + WIND & CANNON)
        {
          name: 'STAGE 9',
          theme: 'tropical',
          hint: 'Use wind turbines, elevators, and ropes to climb the skyward cliffs!',
          spawn: { x: 100, y: 380 },
          checkpoints: [{ x: 1280, y: 270 }],
          goal: { x: 2880, y: 150 },
          trees: [{ x: 50, y: 440, scale: 0.95 }],
          platforms: [
            { x: 0, y: 440, w: 460, h: 420, type: 'earth' },
            { x: 460, y: 310, w: 320, h: 550, type: 'earth' },
            { x: 1220, y: 270, w: 460, h: 590, type: 'earth' },
            { x: 2140, y: 270, w: 320, h: 590, type: 'earth' },
            { x: 2460, y: 200, w: 520, h: 660, type: 'earth' }
          ],
          bridges: [],
          balls: [],
          crates: [],
          ropes: [
            { anchorX: 1900, anchorY: 35, length: 230, amp: 0.62, speed: 2.4, phase: 0 }
          ],
          springs: [
            { x: 2380, y: 256, w: 54, power: -680, anim: 0 }
          ],
          movers: [
            { x: 820, y: 310, w: 130, h: 24, startX: 820, endX: 1060, startY: 310, endY: 270, speed: 1.5, phase: 0, dx: 0, dy: 0 }
          ],
          crushers: [],
          fans: [
            { x: 365, y: 424, w: 76, height: 240, force: -1680 }
          ],
          conveyors: [],
          cannons: [],
          fragiles: [],
          bumpers: [],
          switches: [],
          gates: [],
          hazards: [
            { type: 'saw', x: 1520, y: 266, r: 28, speed: 0.15 }
          ]
        },
<!-- ... existing code ... -->
        // STAGE 12: Archipelago Hopping (Fragile Bridges + Cannons + Ropes)
        {
          name: 'STAGE 12',
          theme: 'tropical',
          hint: 'Sprint across crumbling bridges and launch from cannons across the islands!',
          spawn: { x: 100, y: 310 },
          checkpoints: [{ x: 1580, y: 360 }],
          goal: { x: 3040, y: 260 },
          trees: [
            { x: 50, y: 370, scale: 1.0 },
            { x: 1620, y: 360, scale: 1.0 },
            { x: 2980, y: 310, scale: 1.05 }
          ],
          platforms: [
            { x: 0, y: 370, w: 340, h: 480, type: 'earth' },
            { x: 1480, y: 360, w: 380, h: 490, type: 'earth' },
            { x: 2440, y: 380, w: 260, h: 470, type: 'earth' },
            { x: 2700, y: 310, w: 460, h: 540, type: 'earth' }
          ],
          bridges: [
            { x: 1140, y: 365, length: 320, thickness: 22, angle: 0.06, minAngle: -0.32, maxAngle: 0.32 }
          ],
          balls: [],
          crates: [],
          ropes: [
            { anchorX: 540, anchorY: 85, length: 245, amp: 0.62, speed: 2.4, phase: 0 },
            { anchorX: 2150, anchorY: 85, length: 250, amp: 0.64, speed: 2.5, phase: 1.1 }
          ],
          springs: [
            { x: 2620, y: 366, w: 54, power: -700, anim: 0 }
          ],
          movers: [
            { x: 760, y: 370, w: 130, h: 24, startX: 760, endX: 920, startY: 370, endY: 370, speed: 1.6, phase: 0, dx: 0, dy: 0 }
          ],
          crushers: [],
          fans: [],
          conveyors: [],
          cannons: [],
          fragiles: [
            { x: 1860, y: 360, w: 110, h: 18 },
            { x: 1975, y: 360, w: 110, h: 18 }
          ],
          bumpers: [
            { x: 1400, y: 270, r: 24, power: 580 }
          ],
          switches: [],
          gates: [],
          hazards: []
        },
<!-- ... existing code ... -->
        // STAGE 15: The Ultimate PlonkBot Citadel (Epic Finale with ALL Mechanics!)
        {
          name: 'STAGE 15',
          theme: 'industrial',
          hint: 'ULTIMATE TEST: Conquer cannons, wind, conveyors, ropes, crushers & gates!',
          spawn: { x: 100, y: 300 },
          checkpoints: [
            { x: 1240, y: 380 },
            { x: 2380, y: 380 }
          ],
          goal: { x: 3480, y: 270 },
          trees: [{ x: 50, y: 360, scale: 1.0 }],
          platforms: [
            { x: 0, y: 360, w: 340, h: 490, type: 'earth' },
            { x: 700, y: 380, w: 860, h: 470, type: 'earth' },
            { x: 1340, y: 120, w: 48, h: 160, type: 'stone' },
            { x: 2140, y: 380, w: 680, h: 470, type: 'earth' },
            { x: 3120, y: 320, w: 500, h: 530, type: 'earth' }
          ],
          bridges: [
            { x: 520, y: 370, length: 340, thickness: 22, angle: -0.1, minAngle: -0.35, maxAngle: 0.35 }
          ],
          balls: [
            { x: 220, y: 324, r: 34, mass: 3.2 }
          ],
          crates: [],
          ropes: [
            { anchorX: 1850, anchorY: 85, length: 250, amp: 0.64, speed: 2.5, phase: 0 }
          ],
          springs: [
            { x: 2740, y: 366, w: 54, power: -730, anim: 0 }
          ],
          movers: [
            { x: 2860, y: 330, w: 130, h: 24, startX: 2860, endX: 3010, startY: 330, endY: 320, speed: 1.6, phase: 0, dx: 0, dy: 0 }
          ],
          crushers: [
            { x: 2480, topY: 110, restY: 190, dropY: 305, w: 72, h: 75, speed: 2.7, phase: 0, curY: 190 }
          ],
          fans: [
            { x: 2220, y: 364, w: 72, height: 210, force: -1580 }
          ],
          conveyors: [
            { x: 750, y: 368, w: 220, h: 14, speed: 130 }
          ],
          cannons: [
            { x: 1610, y: 320, angle: -0.45, power: 780 }
          ],
          fragiles: [
            { x: 3020, y: 320, w: 95, h: 18 }
          ],
          bumpers: [
            { x: 3230, y: 235, r: 22, power: 540 }
          ],
          switches: [
            { id: 's15', x: 1060, y: 368, w: 68, h: 12 }
          ],
          gates: [
            { id: 'g15', switchId: 's15', x: 1346, y: 280, w: 34, h: 100 }
          ],
          hazards: [
            { type: 'saw', x: 1175, y: 376, r: 24, speed: 0.16 },
            { type: 'saw', x: 3350, y: 316, r: 26, speed: -0.17 }
          ]
        }
      ];
<!-- ... existing code ... -->
      // PlonkBot Ragdoll-Spring Player Object
      const player = {
        x: 120,
        y: 300,
        vx: 0,
        vy: 0,
        radius: 17,
        halfH: 27,
        facing: 1,
        onGround: false,
        coyoteTimer: 0,
        crouching: false,
        dead: false,
        deadTimer: 0,
        walkCycle: 0,
        grabbedRope: null,
        ropeDist: 0,
        ropeCooldown: 0,
        inCannon: null,
        cannonTimer: 0,
        // Spring-jointed ragdoll offsets for floppy head & limbs
<!-- ... existing code ... -->
      function respawnAtCheckpoint() {
        player.x = activeRespawnPoint.x;
        player.y = activeRespawnPoint.y - 32;
        player.vx = 0;
        player.vy = 0;
        player.onGround = false;
        player.coyoteTimer = 0;
        player.crouching = false;
        player.dead = false;
        player.deadTimer = 0;
        player.grabbedRope = null;
        player.ropeDist = 0;
        player.ropeCooldown = 0.25;
        player.inCannon = null;
        player.cannonTimer = 0;
        player.torsoAngle = 0;
        player.torsoAngVel = 0;
        player.headX = player.x;
        player.headY = player.y - 26;
        player.headVx = 0;
        player.headVy = 0;
        player.pushing = false;
      }

      function loadLevel(idx, keepCheckpoint = false) {
        currentLevelIndex = Math.max(0, Math.min(LEVELS.length - 1, idx));
        const blueprint = LEVELS[currentLevelIndex];

        levelWon = false;
        paused = false;
        screenShake = 0;

        if (!keepCheckpoint) {
          activeRespawnPoint = { ...blueprint.spawn };
        }

        levelState = {
          name: blueprint.name,
          theme: blueprint.theme || 'tropical',
          hint: blueprint.hint,
          goal: { ...blueprint.goal },
          checkpoints: (blueprint.checkpoints || []).map(cp => ({
            ...cp,
            activated: keepCheckpoint && activeRespawnPoint.x === cp.x
          })),
          trees: (blueprint.trees || []).map(t => ({ ...t })),
          platforms: blueprint.platforms.map(p => ({ ...p })),
          bridges: (blueprint.bridges || []).map(b => ({
            ...b,
            angVel: 0,
            torqueAccum: 0
          })),
          balls: (blueprint.balls || []).map(ball => ({
            ...ball,
            vx: 0,
            vy: 0,
            angle: 0,
            angVel: 0
          })),
          crates: (blueprint.crates || []).map(cr => ({
            ...cr,
            vx: 0,
            vy: 0
          })),
          ropes: (blueprint.ropes || []).map(rp => ({
            ...rp,
            angle: 0,
            angVel: 0,
            tipX: rp.anchorX,
            tipY: rp.anchorY + rp.length
          })),
          springs: (blueprint.springs || []).map(sp => ({
            ...sp,
            anim: 0
          })),
          movers: (blueprint.movers || []).map(mv => ({
            ...mv,
            dx: 0,
            dy: 0
          })),
          crushers: (blueprint.crushers || []).map(cr => ({
            ...cr,
            curY: cr.restY
          })),
          fans: (blueprint.fans || []).map(fn => ({ ...fn })),
          conveyors: (blueprint.conveyors || []).map(cv => ({ ...cv })),
          cannons: (blueprint.cannons || []).map(cn => ({
            ...cn,
            cooldown: 0,
            recoil: 0
          })),
          fragiles: (blueprint.fragiles || []).map(fg => ({
            ...fg,
            state: 'solid',
            timer: 0
          })),
          bumpers: (blueprint.bumpers || []).map(bp => ({
            ...bp,
            pulse: 0
          })),
          switches: (blueprint.switches || []).map(sw => ({
            ...sw,
            pressed: false
          })),
          gates: (blueprint.gates || []).map(g => ({
            ...g,
            openAmount: 0
          })),
          hazards: (blueprint.hazards || []).map(h => ({
            ...h,
            angle: 0
          }))
        };
<!-- ... existing code ... -->
      function pointToSegmentInfo(px, py, ax, ay, bx, by) {
        const abx = bx - ax;
        const aby = by - ay;
        const lenSq = abx * abx + aby * aby;
        if (lenSq < 0.0001) return { dist: Math.hypot(px - ax, py - ay), along: 0 };
        const t = Math.max(0.12, Math.min(1.0, ((px - ax) * abx + (py - ay) * aby) / lenSq));
        const closestX = ax + abx * t;
        const closestY = ay + aby * t;
        return {
          dist: Math.hypot(px - closestX, py - closestY),
          along: t * Math.sqrt(lenSq)
        };
      }

      function triggerPlayerDeath() {
        if (player.dead || levelWon) return;
        player.dead = true;
        player.grabbedRope = null;
        player.inCannon = null;
<!-- ... existing code ... -->
        // Decay spring pad, cannon, and bumper animations
        for (const sp of levelState.springs) {
          if (sp.anim > 0) sp.anim = Math.max(0, sp.anim - dt * 4);
        }
        for (const cn of levelState.cannons) {
          if (cn.cooldown > 0) cn.cooldown = Math.max(0, cn.cooldown - dt);
          if (cn.recoil > 0) cn.recoil = Math.max(0, cn.recoil - dt * 4);
        }
        for (const bp of levelState.bumpers) {
          if (bp.pulse > 0) bp.pulse = Math.max(0, bp.pulse - dt * 5);
        }

        // Update crumbling fragile bridges
        for (const fg of levelState.fragiles) {
          if (fg.state === 'shaking') {
            fg.timer -= dt;
            if (fg.timer <= 0) {
              fg.state = 'broken';
              fg.timer = 3.2; // Respawn bridge after 3.2s
              SoundFX.crumble();
            }
          } else if (fg.state === 'broken') {
            fg.timer -= dt;
            if (fg.timer <= 0) {
              fg.state = 'solid';
            }
          }
        }
<!-- ... existing code ... -->
        if (player.ropeCooldown > 0) {
          player.ropeCooldown = Math.max(0, player.ropeCooldown - dt);
        }

        // If player is inside a Barrel Cannon -> aim & blast!
        if (player.inCannon) {
          const cn = player.inCannon;
          player.cannonTimer -= dt;
          player.x = cn.x;
          player.y = cn.y;
          player.vx = 0;
          player.vy = 0;
          player.torsoAngle = cn.angle + Math.PI * 0.5;
          if (player.cannonTimer <= 0 || input.jumpBuffered > 0) {
            input.jumpBuffered = 0;
            player.inCannon = null;
            cn.cooldown = 0.6;
            cn.recoil = 1.0;
            player.vx = Math.cos(cn.angle) * cn.power;
            player.vy = Math.sin(cn.angle) * cn.power;
            player.facing = player.vx >= 0 ? 1 : -1;
            screenShake = 8;
            SoundFX.cannon();
          }
          updateRagdollSprings(dt);
          return;
        }

        // If player is swinging anywhere along a Tarzan rope
        if (player.grabbedRope) {
          const rp = player.grabbedRope;
          // Allow climbing up/down the rope with UP/DOWN!
          if (input.up && !input.down) {
            player.ropeDist = Math.max(36, player.ropeDist - 135 * dt);
          } else if (input.down && !input.up) {
            player.ropeDist = Math.min(rp.length, player.ropeDist + 150 * dt);
          }

          player.x = rp.anchorX + Math.sin(rp.angle) * player.ropeDist;
          player.y = rp.anchorY + Math.cos(rp.angle) * player.ropeDist + 8;
          player.vx = Math.cos(rp.angle) * rp.angVel * player.ropeDist;
          player.vy = -Math.sin(rp.angle) * rp.angVel * player.ropeDist;
          player.torsoAngle = -rp.angle * 0.85;
          if (input.left) player.facing = -1;
          if (input.right) player.facing = 1;

          // Jump off rope with RIGHT/LEFT + UP or Space
          if (input.jumpBuffered > 0) {
            input.jumpBuffered = 0;
            player.grabbedRope = null;
            player.ropeCooldown = 0.32;
            player.vx = player.vx * 1.18 + player.facing * 215;
            player.vy = -495;
            SoundFX.jump();
          }
          updateRagdollSprings(dt);
          return;
        }
<!-- ... existing code ... -->
        // Check rope grab ANYWHERE along the rope segment while airborne!
        if (player.ropeCooldown <= 0 && !player.crouching) {
          for (const rp of levelState.ropes) {
            const seg = pointToSegmentInfo(
              player.x,
              player.y - 8,
              rp.anchorX,
              rp.anchorY,
              rp.tipX,
              rp.tipY
            );
            if (seg.dist < 30) {
              player.grabbedRope = rp;
              player.ropeDist = seg.along;
              input.jumpBuffered = 0;
              SoundFX.ropeGrab();
              return;
            }
          }
        }

        // Check Barrel Cannon entry
        for (const cn of levelState.cannons) {
          if (cn.cooldown <= 0 && Math.hypot(player.x - cn.x, player.y - cn.y) < 34) {
            player.inCannon = cn;
            player.cannonTimer = 0.42;
            input.jumpBuffered = 0;
            return;
          }
        }

        // Check Wind Fan Updraft zones
        for (const fn of levelState.fans) {
          if (Math.abs(dist) < ball.r + 36 && Math.abs(perp) < b.thickness * 0.5 + ball.r) {
            const sign = perp >= 0 ? 1 : -1;
            const overlap = (b.thickness * 0.5 + ball.r) - Math.abs(perp);
            ball.x += nx * sign * overlap;
            ball.y += ny * sign * overlap;

            const vn = ball.vx * nx + ball.vy * ny;
            if (vn * sign < 0) {
              ball.vx -= nx * vn;
              ball.vy -= ny * vn;
            }
            ball.vx += nx * 0.35;
            ball.angVel += (dist * 0.002);
            b.torqueAccum += dist * 0.00018 * ball.mass;
          }
        }

        // Player vs Hinged Bridges
        for (const b of levelState.bridges) {
          const cos = Math.cos(b.angle);
          const sin = Math.sin(b.angle);
          const nx = -sin;
          const ny = cos;

          const relX = player.x - b.x;
          const relY = player.y - b.y;
          const dist = relX * cos + relY * sin;
          const perp = relX * nx + relY * ny;
          const halfLen = b.length * 0.5;
          const halfThick = b.thickness * 0.5;

          if (Math.abs(dist) < halfLen + player.radius * 0.5 && Math.abs(perp) < halfThick + player.radius) {
            const sign = perp >= 0 ? 1 : -1;
            const overlap = (halfThick + player.radius) - Math.abs(perp);
            player.x += nx * sign * overlap;
            player.y += ny * sign * overlap;

            if (sign < 0 && player.vy >= 0) {
              player.vy = 0;
              player.onGround = true;
              b.torqueAccum += dist * 0.00024;
            } else if (sign > 0 && player.vy < 0) {
              player.vy = 0;
            }
          }
        }

        // Player vs Conveyor Belts
        for (const cv of levelState.conveyors) {
          const hit = circleRectResolve(player.x, player.y, player.radius, cv.x, cv.y, cv.w, cv.h);
          if (hit) {
            player.x += hit.nx * hit.overlap;
            player.y += hit.ny * hit.overlap;
            if (hit.ny < -0.65 && player.vy >= 0) {
              player.vy = 0;
              player.onGround = true;
              player.x += cv.speed * dt;
            }
          }
        }

        // Player vs Crumbling Fragile Bridges
        for (const fg of levelState.fragiles) {
          if (fg.state === 'broken') continue;
          const hit = circleRectResolve(player.x, player.y, player.radius, fg.x, fg.y, fg.w, fg.h);
          if (hit) {
            player.x += hit.nx * hit.overlap;
            player.y += hit.ny * hit.overlap;
            if (hit.ny < -0.65 && player.vy >= 0) {
              player.vy = 0;
              player.onGround = true;
              if (fg.state === 'solid') {
                fg.state = 'shaking';
                fg.timer = 0.68;
              }
            }
          }
        }
<!-- ... existing code ... -->
      function drawCrushers() {
        for (const cr of levelState.crushers) {
          ctx.save();
          // Hydraulic piston shaft
          ctx.fillStyle = '#94a3b8';
          ctx.strokeStyle = '#162436';
          ctx.lineWidth = 2.2;
          ctx.fillRect(cr.x - 10, cr.topY - 80, 20, cr.curY - (cr.topY - 80));
          ctx.strokeRect(cr.x - 10, cr.topY - 80, 20, cr.curY - (cr.topY - 80));

          // Heavy Crusher Block
          ctx.fillStyle = '#475569';
          ctx.beginPath();
          ctx.roundRect(cr.x - cr.w * 0.5, cr.curY, cr.w, cr.h, 6);
          ctx.fill();
          ctx.stroke();

          // Hazard yellow/black caution stripe
          ctx.fillStyle = '#ffbe0b';
          ctx.fillRect(cr.x - cr.w * 0.5 + 4, cr.curY + cr.h - 14, cr.w - 8, 10);
          ctx.restore();
        }
      }

      function drawFans() {
        for (const fn of levelState.fans) {
          ctx.save();
          // Updraft air stream streaks
          ctx.strokeStyle = 'rgba(255, 255, 255, 0.55)';
          ctx.lineWidth = 2.4;
          for (let i = 0; i < 4; i++) {
            const sx = fn.x + 12 + i * ((fn.w - 24) / 3);
            const offset = ((worldTime * 240 + i * 55) % fn.height);
            const sy = fn.y - offset;
            ctx.beginPath();
            ctx.moveTo(sx, sy);
            ctx.lineTo(sx, Math.max(fn.y - fn.height, sy - 32));
            ctx.stroke();
          }

          // Fan Housing Base
          ctx.fillStyle = '#334155';
          ctx.strokeStyle = '#162436';
          ctx.lineWidth = 2.4;
          ctx.beginPath();
          ctx.roundRect(fn.x, fn.y - 10, fn.w, 16, 5);
          ctx.fill();
          ctx.stroke();

          // Spinning Fan Blades Top
          ctx.fillStyle = '#38b6ff';
          const bladeW = (fn.w - 14) * (0.5 + 0.5 * Math.abs(Math.sin(worldTime * 18)));
          ctx.fillRect(fn.x + (fn.w - bladeW) * 0.5, fn.y - 14, bladeW, 4);
          ctx.restore();
        }
      }

      function drawConveyors() {
        for (const cv of levelState.conveyors) {
          ctx.save();
          ctx.fillStyle = '#1e293b';
          ctx.strokeStyle = '#0f172a';
          ctx.lineWidth = 2.2;
          ctx.beginPath();
          ctx.roundRect(cv.x, cv.y, cv.w, cv.h, 7);
          ctx.fill();
          ctx.stroke();

          // Moving directional chevrons
          ctx.fillStyle = '#ffbe0b';
          const dir = Math.sign(cv.speed);
          const step = 24;
          const shift = ((worldTime * cv.speed * 0.4) % step + step) % step;
          for (let x = cv.x + 10 + shift; x < cv.x + cv.w - 10; x += step) {
            ctx.beginPath();
            ctx.arc(x, cv.y + cv.h * 0.5, 3, 0, Math.PI * 2);
            ctx.fill();
            if (dir !== 0) {
              ctx.fillRect(x - 2, cv.y + 3, 4, 2);
            }
          }
          ctx.restore();
        }
      }

      function drawCannons() {
        for (const cn of levelState.cannons) {
          ctx.save();
          ctx.translate(cn.x, cn.y);
          ctx.rotate(cn.angle);
          const kick = cn.recoil * 10;

          // Barrel Body
          ctx.fillStyle = '#8b5e34';
          ctx.strokeStyle = '#162436';
          ctx.lineWidth = 2.6;
          ctx.beginPath();
          ctx.roundRect(-24 - kick, -20, 52, 40, 10);
          ctx.fill();
          ctx.stroke();

          // Iron Bands & Muzzle Ring
          ctx.fillStyle = '#334155';
          ctx.fillRect(-10 - kick, -20, 8, 40);
          ctx.fillRect(20 - kick, -22, 10, 44);
          ctx.strokeRect(20 - kick, -22, 10, 44);

          // White launch arrow hint
          ctx.fillStyle = '#ffbe0b';
          ctx.beginPath();
          ctx.moveTo(42, 0);
          ctx.lineTo(32, -7);
          ctx.lineTo(32, 7);
          ctx.closePath();
          ctx.fill();
          ctx.restore();
        }
      }

      function drawFragiles() {
        for (const fg of levelState.fragiles) {
          if (fg.state === 'broken') continue;
          ctx.save();
          const shake = fg.state === 'shaking' ? (Math.random() - 0.5) * 6 : 0;
          ctx.translate(fg.x + shake, fg.y);
          ctx.fillStyle = fg.state === 'shaking' ? '#ef476f' : '#e09f3e';
          ctx.strokeStyle = '#231712';
          ctx.lineWidth = 2.2;
          ctx.beginPath();
          ctx.roundRect(0, 0, fg.w, fg.h, 4);
          ctx.fill();
          ctx.stroke();

          // Crack lines
          ctx.strokeStyle = '#231712';
          ctx.beginPath();
          ctx.moveTo(fg.w * 0.35, 0);
          ctx.lineTo(fg.w * 0.42, fg.h * 0.6);
          ctx.moveTo(fg.w * 0.7, fg.h);
          ctx.lineTo(fg.w * 0.64, fg.h * 0.4);
          ctx.stroke();
          ctx.restore();
        }
      }

      function drawBumpers() {
        for (const bp of levelState.bumpers) {
          ctx.save();
          const r = bp.r + bp.pulse * 7;
          ctx.fillStyle = '#ef476f';
          ctx.strokeStyle = '#162436';
          ctx.lineWidth = 2.6;
          ctx.beginPath();
          ctx.arc(bp.x, bp.y, r, 0, Math.PI * 2);
          ctx.fill();
          ctx.stroke();

          ctx.fillStyle = '#ffbe0b';
          ctx.beginPath();
          ctx.arc(bp.x, bp.y, r * 0.55, 0, Math.PI * 2);
          ctx.fill();
          ctx.restore();
        }
      }
<!-- ... existing code ... -->
        drawMovers();
        drawConveyors();
        drawFragiles();
        drawSprings();
        drawFans();
        drawBumpers();
        drawSwitchAndGates();
        for (const b of levelState.bridges) drawBridge(b);
        drawCrushers();
        drawHazards();
        drawCrates();
        for (const ball of levelState.balls) drawBall(ball);
        if (!player.inCannon) {
          drawPlonkBot(ctx, player.x, player.y, 1, saveState.selectedSkin, null);
        }
        drawCannons();
<!-- ... existing code ... -->

```
