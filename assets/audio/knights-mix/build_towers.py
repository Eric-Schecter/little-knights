# CC0 Kenney RPG source samples; three distinct material/timing palettes.
import pathlib,subprocess,json
out=pathlib.Path(__file__).resolve().parent;src=out.parent/'kenney-rpg'
recipes={
 'tower_rapid':([('metalLatch',0,.9),('cloth1',18,.45),('metalClick',70,.35)],'highpass=f=260,lowpass=f=3600,atrim=duration=0.24,afade=t=out:st=0.13:d=0.11'),
 'tower_heavy':([('creak1',0,.65),('doorClose_3',30,.8),('knifeSlice',55,.5)],'asetrate=33075,aresample=44100,highpass=f=65,lowpass=f=2100,atrim=duration=0.65,afade=t=out:st=0.35:d=0.30'),
 'tower_watch':([('cloth3',0,.8),('metalPot2',40,.11)],'highpass=f=400,lowpass=f=3000,aecho=0.7:0.5:55:0.18,atrim=duration=0.48,afade=t=out:st=0.22:d=0.26'),
 'tower_heavy_hit':([('chop',0,.9),('metalLatch',20,.25)],'asetrate=35280,aresample=44100,lowpass=f=2300,atrim=duration=0.3,afade=t=out:st=0.16:d=0.14'),
 'tower_watch_hit':([('cloth1',0,.65),('metalPot1',0,.08)],'highpass=f=300,lowpass=f=2400,atrim=duration=0.30,afade=t=out:st=0.1:d=0.2')}
for name,(layers,post) in recipes.items():
 cmd=['ffmpeg','-v','error','-y'];filters=[]
 for i,(file,delay,vol) in enumerate(layers):
  cmd+=['-i',str(src/(file+'.ogg'))];filters.append(f'[{i}:a]aresample=44100,volume={vol},adelay={delay}|{delay}[s{i}]')
 filters.append(''.join(f'[s{i}]' for i in range(len(layers)))+f'amix=inputs={len(layers)}:normalize=0,'+post+',alimiter=limit=0.8[out]')
 subprocess.run(cmd+['-filter_complex',';'.join(filters),'-map','[out]','-ar','44100','-c:a','pcm_s16le',str(out/(name+'.wav'))],check=True)
(out/'tower-recipes.json').write_text(json.dumps(recipes,indent=2))
