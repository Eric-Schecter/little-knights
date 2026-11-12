import subprocess,json, pathlib
out=pathlib.Path(__file__).resolve().parent;src=out.parent/'kenney-rpg'
recipes={
'mine':([('chop',0,0.7),('metalClick',20,0.14)],'lowpass=f=1700,atrim=duration=0.24,afade=t=out:st=0.13:d=0.11'),
'hit':([('chop',0,0.8),('cloth2',0,0.35)],'lowpass=f=2600,atrim=duration=0.24,afade=t=out:st=0.14:d=0.1'),
'metal':([('chop',0,0.85),('metalLatch',0,0.2)],'lowpass=f=2400,atrim=duration=0.24,afade=t=out:st=0.14:d=0.1'),
'bolt':([('cloth1',0,0.8),('metalClick',0,0.18)],'highpass=f=180,lowpass=f=4000,atrim=duration=0.2,afade=t=out:st=0.10:d=0.10'),
'death':([('dropLeather',0,1),('cloth3',50,0.5)],'lowpass=f=2200,afade=t=out:st=0.35:d=0.25'),
'collapse':([('creak1',0,0.65),('doorClose_3',160,0.9),('chop',270,0.7),('doorClose_4',400,0.6),('dropLeather',600,0.5)],'lowpass=f=2000,afade=t=out:st=0.8:d=0.5'),
'complete':([('bookClose',0,0.5),('handleCoins',100,0.5)],'lowpass=f=3200,atrim=duration=0.65,afade=t=out:st=0.45:d=0.2'),
'ready':([('clothBelt',0,0.6),('drawKnife1',100,0.45)],'lowpass=f=3000,atrim=duration=0.55,afade=t=out:st=0.35:d=0.2'),
'command':([('beltHandle1',0,0.65)],'lowpass=f=2200,atrim=duration=0.22,afade=t=out:st=0.12:d=0.1')}
for name,(layers,post) in recipes.items():
 cmd=['ffmpeg','-v','error','-y'];filters=[]
 for i,(file,delay,volume) in enumerate(layers):
  cmd+=['-i',str(src/(file+'.ogg'))];filters.append(f'[{i}:a]volume={volume},adelay={delay}|{delay}[s{i}]')
 filters.append(''.join(f'[s{i}]' for i in range(len(layers)))+f'amix=inputs={len(layers)}:normalize=0,'+post+',alimiter=limit=0.85[out]')
 subprocess.run(cmd+['-filter_complex',';'.join(filters),'-map','[out]','-c:a','pcm_s16le',str(out/(name+'.wav'))],check=True)
(out/'recipes.json').write_text(json.dumps(recipes,indent=2))
