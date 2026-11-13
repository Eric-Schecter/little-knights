"""Distinct, restrained CC0 Foley signatures; no external sound dependency."""
import pathlib, subprocess
root = pathlib.Path(__file__).resolve().parent
recipes = {
 'Pawn': [('clothBelt',0,.7),('bookClose',90,.5)],
 'Warrior': [('drawKnife1',0,.7),('metalLatch',120,.45)],
 'Archer': [('creak1',0,.45),('cloth1',100,.7)],
 'Spearman': [('metalClick',0,.55),('beltHandle1',100,.7)],
 'Cavalry': [('footstep00',0,.9),('footstep03',95,.8),('footstep01',230,.9),('clothBelt',250,.45)],
 'Catapult': [('creak1',0,.75),('doorClose_4',170,.45)],
 'Castle': [('doorClose_3',0,.65),('metalPot1',170,.25)],
 'Barracks': [('drawKnife1',0,.5),('metalPot3',140,.35)],
 'House1': [('doorClose_4',0,.6),('cloth2',120,.6)],
 'Tower': [('creak1',0,.5),('metalLatch',160,.5)],
 'Tower_cannon': [('metalPot2',0,.45),('doorClose_3',130,.6)],
 'Smith': [('metalPot1',0,.45),('metalClick',160,.6)],
 'Workshop': [('creak1',0,.65),('chop',120,.6),('metalLatch',240,.4)],
 'Depot': [('handleCoins',0,.65),('bookClose',160,.65)],
 'construction': [('chop',0,.7),('doorClose_4',35,.45)],
 'repair': [('metalClick',0,.6),('metalLatch',135,.5),('cloth2',180,.35)]
}
for name,layers in recipes.items():
 cmd=['ffmpeg','-v','error','-y'];filters=[]
 for i,(sample,delay,volume) in enumerate(layers):
  cmd+=['-i',str(root.parent/'kenney-rpg'/(sample+'.ogg'))]
  filters.append(f'[{i}:a]volume={volume},adelay={delay}|{delay}[s{i}]')
 filters.append(''.join(f'[s{i}]' for i in range(len(layers)))+f'amix=inputs={len(layers)}:normalize=0,highpass=f=90,lowpass=f=3000,atrim=duration=0.62,afade=t=out:st=0.42:d=0.2,loudnorm=I=-21:TP=-3:LRA=7[out]')
 dest=name if name in ['construction','repair'] else 'select_'+name
 subprocess.run(cmd+['-filter_complex',';'.join(filters),'-map','[out]','-ar','44100','-ac','1','-c:a','pcm_s16le',str(root/(dest+'.wav'))],check=True)
