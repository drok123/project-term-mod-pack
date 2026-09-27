"""Generate original deterministic machine ambience; no sampled third-party audio."""
import math
from pathlib import Path
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1]
output = ROOT / "42/media/sound/ProjectTerm/distant_machine.wav"
output.parent.mkdir(parents=True, exist_ok=True)
rate, seconds = 22050, 8
rng = random.Random(420030)
samples, noise = [], 0.0
for index in range(rate * seconds):
    t = index / rate
    envelope = math.sin(math.pi * t / seconds) ** 2
    noise = noise * .94 + rng.uniform(-1, 1) * .06
    turbine = math.sin(2 * math.pi * (78 * t + 1.8 * t * t))
    harmonics = .35 * math.sin(2 * math.pi * 159 * t) + .15 * math.sin(2 * math.pi * 321 * t)
    pulse = .75 + .25 * math.sin(2 * math.pi * 2.3 * t)
    value = .30 * envelope * (pulse * (turbine + harmonics) + .8 * noise)
    samples.append(struct.pack('<h', int(max(-1, min(1, value)) * 32767)))
with wave.open(str(output), 'wb') as wav:
    wav.setparams((1, 2, rate, 0, 'NONE', 'not compressed'))
    wav.writeframes(b''.join(samples))
print(f"Generated {output}: mono PCM16, {seconds}s, {rate}Hz")
