const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
const html=fs.readFileSync('tools/web_shell.html','utf8');
const script=html.split('<script>')[1].split('</script>')[0].replace('$GODOT_CONFIG',JSON.stringify({fileSizes:{'index.wasm':40,'index.pck':60},executable:'index'}));
const nodes={};for(const id of ['canvas','progress','status','error','launch','play'])nodes[id]={hidden:false,addEventListener(name,fn){this[name]=fn},focus(){},remove(){this.removed=true},style:{}};
const events={};let resolveInit,resolvePack,starts=0,resumes=0;
class AudioContext {state='suspended';resume(){resumes++;this.state='running';return Promise.resolve()}}
class Engine {init(){return new Promise(r=>resolveInit=r)} preloadFile(){return new Promise(r=>resolvePack=r)} async start(){starts++;vm.runInContext("new window.AudioContext()",context)}}
const context=vm.createContext({document:{getElementById:id=>nodes[id]},window:{AudioContext,addEventListener:(name,fn)=>events[name]=fn},Engine,location:{protocol:'http:'},requestAnimationFrame:fn=>fn(),setTimeout:()=>1,clearTimeout(){}});
vm.runInContext(script,context);
vm.runInContext('config.onProgress(25,40)',context);assert.equal(nodes.progress.max,100);assert.equal(nodes.progress.value,25);assert.match(nodes.status.textContent,/25%/);
vm.runInContext('config.onProgress(100,100)',context);assert.equal(nodes.progress.hidden,true);assert.match(nodes.status.textContent,/Initializing/);
resolveInit();resolvePack();
setImmediate(async()=>{assert.equal(starts,1);assert.equal(nodes.progress.hidden,true);vm.runInContext('config.onProgress(70,100)',context);assert.match(nodes.status.textContent,/Preparing/);events['little-knights-loading']({detail:'Preparing sprites and terrain…'});assert.match(nodes.status.textContent,/sprites/);events['little-knights-ready']();assert.equal(nodes.launch.removed,undefined);assert.equal(nodes.play.disabled,false);assert.equal(resumes,0);await nodes.play.click();assert.equal(resumes,1);assert.equal(nodes.launch.removed,true);console.log('PASS: byte-based progress, fixed denominator, no fake initialization bar, automatic preparation, first-frame click gate, audio resume on click');});
