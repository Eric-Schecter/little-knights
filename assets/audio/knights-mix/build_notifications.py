"""Original material-based RTS notifications derived from CC0 Kenney samples."""
import subprocess,wave,array
from pathlib import Path
out=Path(__file__).resolve().parent
src=out.parent/'kenney-rpg'
recipes={
 'complete': [('chop',0,.65),('doorClose_3',110,.38),('handleSmallLeather',200,.22)],
 'ready': [('cloth2',0,.55),('beltHandle1',70,.5),('footstep02',190,.55),('footstep04',310,.4)]
}
for name,layers in recipes.items():
 cmd=['ffmpeg','-v','error','-y'];filters=[]
 for i,(clip,delay,gain) in enumerate(layers):
  cmd+=['-i',str(src/(clip+'.ogg'))]
  filters.append(f'[{i}:a]volume={gain},adelay={delay}|{delay}[s{i}]')
 filters.append(''.join(f'[s{i}]' for i in range(len(layers)))+f'amix=inputs={len(layers)}:normalize=0,highpass=f=100,lowpass=f=2800,atrim=duration=0.65,afade=t=in:d=0.008,afade=t=out:st=0.4:d=0.25[out]')
 target=out/(name+'.wav')
 subprocess.run(cmd+['-filter_complex',';'.join(filters),'-map','[out]','-ac','1','-ar','44100','-c:a','pcm_s16le',str(target)],check=True)
 with wave.open(str(target),'rb') as w:
  params=w.getparams();data=array.array('h',w.readframes(w.getnframes()))
 peak=max(abs(v) for v in data);gain=24575/max(1,peak)
 data=array.array('h',(round(v*gain) for v in data))
 with wave.open(str(target),'wb') as w:w.setparams(params);w.writeframes(data.tobytes())
