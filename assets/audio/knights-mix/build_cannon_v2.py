# Strengthen the existing CC0-derived cannon with a short procedural pressure crack.
from pathlib import Path
import subprocess
p=Path(__file__).resolve().parent
subprocess.run(['ffmpeg','-v','error','-y','-i',str(p/'tower_cannon.wav'),'-f','lavfi','-i','anoisesrc=color=pink:duration=0.22:sample_rate=44100:amplitude=0.7','-filter_complex','[0:a]volume=0.7,equalizer=f=160:t=q:w=0.8:g=5[a];[1:a]highpass=f=220,lowpass=f=3500,afade=t=in:d=0.002,afade=t=out:st=0.015:d=0.205,volume=0.8[b];[a][b]amix=inputs=2:normalize=0,acompressor=threshold=0.2:ratio=3:attack=2:release=90:makeup=1.7,alimiter=limit=0.89:level=false[out]','-map','[out]','-ar','44100','-c:a','pcm_s16le',str(p/'tower_cannon_v2.wav')],check=True)
subprocess.run(['ffmpeg','-v','error','-y','-i',str(p/'tower_cannon_hit.wav'),'-af','equalizer=f=220:t=q:w=0.8:g=4,acompressor=threshold=0.15:ratio=2:attack=5:release=80:makeup=1.6,alimiter=limit=0.8:level=false','-c:a','pcm_s16le',str(p/'tower_cannon_hit_v2.wav')],check=True)
