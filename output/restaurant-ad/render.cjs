const fs = require('fs');
const path = require('path');
const http = require('http');
const { spawn } = require('child_process');
const { once } = require('events');
const { chromium } = require('C:/Users/Muhammad suleman/AppData/Local/npm-cache/_npx/e41f203b7505f1fb/node_modules/playwright');
const root = path.resolve(__dirname, '../..');
const mime = {'.html':'text/html; charset=utf-8','.png':'image/png','.jpg':'image/jpeg','.ttf':'font/ttf','.mp3':'audio/mpeg','.wav':'audio/wav','.json':'application/json'};
async function main() {
  const server=http.createServer((req,res)=>{
    const file=path.resolve(root,'.'+decodeURIComponent(req.url.split('?')[0]));
    if (!file.startsWith(root+path.sep)) {res.writeHead(403);return res.end();}
    if (!fs.existsSync(file)||fs.statSync(file).isDirectory()) {res.writeHead(404);return res.end();}
    res.setHeader('Content-Type',mime[path.extname(file)]||'application/octet-stream');fs.createReadStream(file).pipe(res);
  });
  await new Promise(r=>server.listen(9876,'127.0.0.1',r));
  let browser;
  try {
    browser=await chromium.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true,args:['--disable-gpu','--disable-background-timer-throttling','--disable-renderer-backgrounding']});
    const page=await browser.newPage({viewport:{width:1080,height:1920},deviceScaleFactor:1});
    page.on('pageerror',e=>console.error('PAGE ERROR',e.message));
    await page.goto('http://127.0.0.1:9876/output/restaurant-ad/reel.html');
    const loaded=await page.evaluate(()=>window.ready);
    const mode=process.argv[2]||'preview';
    const times=[2,6,10,16,20.8,25,30,36,39,43.2,48,57,61];
    if(mode==='preview') {
      fs.mkdirSync(path.join(__dirname,'preview-reel'),{recursive:true});
      if(loaded.assetErrors.length)throw new Error('Missing assets: '+loaded.assetErrors.join(', '));
      console.log('Verified all '+Object.keys(await page.evaluate(()=>window.assets)).length+' image assets loaded.');
      for(const t of times){await page.evaluate(t=>window.renderFrame(t),t);const data=await page.evaluate(()=>document.querySelector('canvas').toDataURL('image/png').split(',')[1]);fs.writeFileSync(path.join(__dirname,'preview-reel',`frame-${String(t).padStart(2,'0')}.png`),Buffer.from(data,'base64'));}
      const montage=await page.evaluate(async()=>{
        const c=document.createElement('canvas');c.width=1440;c.height=1920;const ctx=c.getContext('2d');ctx.fillStyle='#ddd';ctx.fillRect(0,0,c.width,c.height);
        const times=[2,6,10,16,20.8,25,30,36,39,43.2,48,57];
        for(let i=0;i<times.length;i++){const im=new Image();im.src=`preview-reel/frame-${String(times[i]).padStart(2,'0')}.png`;await im.decode();ctx.drawImage(im,(i%4)*360,Math.floor(i/4)*640,360,640);ctx.fillStyle='#111';ctx.fillRect((i%4)*360,Math.floor(i/4)*640,52,22);ctx.font='14px Arial';ctx.fillStyle='white';ctx.fillText(times[i]+'s',(i%4)*360+8,Math.floor(i/4)*640+16);}
        return c.toDataURL('image/png').split(',')[1];
      });
      fs.writeFileSync(path.join(__dirname,'preview-reel','contact-sheet.png'),Buffer.from(montage,'base64'));console.log('Vertical preview frames ready');
    } else {
      if(loaded && loaded.assetErrors && loaded.assetErrors.length)throw new Error('Missing video assets: '+loaded.assetErrors.join(', '));
      const ffmpeg=process.env.AD_FFMPEG || 'C:/Program Files/PVsyst7.2/ffmpeg.exe';
      const fps=30,duration=62,total=fps*duration;
      const out=path.join(__dirname,'ORB-restaurant-reel-1080x1920.mp4');
      const args=['-hide_banner','-y','-f','image2pipe','-vcodec','mjpeg','-framerate',String(fps),'-i','pipe:0','-i',path.join(__dirname,'voiceover.mp3'),'-i',path.join(__dirname,'music-bed.wav'),'-filter_complex','[1:a]adelay=400|400,apad,volume=1.0[v];[2:a]volume=0.447[m];[v][m]amix=inputs=2:duration=longest:dropout_transition=0,volume=2,alimiter=limit=0.95[a]','-map','0:v','-map','[a]','-t',String(duration),'-c:v','libx264','-preset','medium','-crf','18','-pix_fmt','yuv420p','-c:a','aac','-b:a','192k','-movflags','+faststart',out];
      const encoder=spawn(ffmpeg,args,{windowsHide:true,stdio:['pipe','ignore','pipe']});let log='';encoder.stderr.on('data',x=>{log+=x.toString();if(log.length>20000)log=log.slice(-20000);});
      const done=new Promise((resolve,reject)=>{encoder.once('error',reject);encoder.once('close',code=>code===0?resolve():reject(new Error(log)));});
      encoder.stdin.on('error',e=>console.error('encoder pipe',e.message));
      for(let f=0;f<total;f++){
        const jpeg=await page.evaluate(t=>{window.renderFrame(t);return document.querySelector('canvas').toDataURL('image/jpeg',0.96).split(',')[1];},f/fps);
        if(!encoder.stdin.write(Buffer.from(jpeg,'base64')))await once(encoder.stdin,'drain');
        if(f%150===0)console.log(`Rendering ${Math.round(f/total*100)}% (${f}/${total})`);
      }
      encoder.stdin.end();await done;console.log('EXPORT COMPLETE',out);console.log(log.slice(-1800));
    }
  }finally{if(browser)await browser.close();server.close();}
}
main().catch(e=>{console.error(e);process.exitCode=1;});
