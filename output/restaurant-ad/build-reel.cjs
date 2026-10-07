const fs=require('fs');
const path=require('path');
const source=fs.readFileSync(path.join(__dirname,'composition.html'),'utf8');
let base=source.slice(0,source.indexOf('function intro(t)'));
base=base.replace('177.777778vh','56.25vh').replace('aspect-ratio:16/9','aspect-ratio:9/16').replace('width="1920" height="1080"','width="1080" height="1920"').replace('const W=1920,H=1080','const W=1080,H=1920').replace("chef:'chef.png',",'');
base=base.replace("desktop:'screenshots/desktop.png'","desktop:'screenshots/desktop.png',tablet:'screenshots/tablet.png'");
base=base.replace(/function header\([\s\S]*?function glyph\(/,`function header(step,label,dark=false){const c=dark?WHITE:O;line(838,166,908,166,c,5);text('موقع مطعمك',818,164,32,dark?WHITE:K,800);if(step)text(step+' / '+label,104,164,26,dark?WHITE:K,700,'left')}
function footer(dark=false){text('منيو واضح. طلب أسهل.',540,1690,30,dark?WHITE:K,650,'center')}
function progress(t,dark=false){const stops=[13,19.1,22.5,34,41.7];for(let i=0;i<5;i++)rr(427+i*46,1760,32,5,3,t>=stops[i]?(dark?WHITE:O):(dark?'rgba(255,255,255,.25)':'rgba(255,116,0,.2)'))}
function glyph(`);
const vertical=fs.readFileSync(path.join(__dirname,'reel-scenes.js'),'utf8');
fs.writeFileSync(path.join(__dirname,'reel.html'),base+vertical+'\n</script></body></html>');
console.log('Built reel.html: 1080 x 1920; no chef asset or scene.');
