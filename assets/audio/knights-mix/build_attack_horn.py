"""Original short brass command signal, generated without external samples."""
import math, wave, array, random
from pathlib import Path
rate=44100;duration=1.05;rng=random.Random(71);samples=[];breath=0.0
notes=[(0,.25,196),(.27,.77,293.665)]
for i in range(int(rate*duration)):
 t=i/rate;value=0.0;breath=.93*breath+.07*rng.uniform(-1,1)
 for start,length,f in notes:
  age=t-start
  if 0<=age<length:
   env=min(1,age/.045)*min(1,(length-age)/.19)
   phase=2*math.pi*f*age+.012*math.sin(2*math.pi*4.8*age)
   tone=sum(math.sin(phase*n)*math.exp(-n*.46)/n**.35 for n in range(1,9))
   value+=(tone+.07*breath)*env*.65
 samples.append(value)
# Quiet, short room tail keeps the call from sounding like a dry UI beep.
for i in range(len(samples)-1,-1,-1):
 if i>int(rate*.075):samples[i]+=.13*samples[i-int(rate*.075)]
peak=max(abs(v) for v in samples)
data=array.array('h',(int(v/peak*24500) for v in samples))
with wave.open(str(Path(__file__).with_name('attack_horn.wav')),'wb') as w:
 w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(data.tobytes())
