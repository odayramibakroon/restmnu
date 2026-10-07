const http = require('http');
const fs = require('fs');
const path = require('path');
const { chromium } = require('C:/Users/Muhammad suleman/AppData/Local/npm-cache/_npx/e41f203b7505f1fb/node_modules/playwright');
const output = path.resolve(__dirname, 'screenshots');
const webRoot = path.resolve(__dirname, '../../build/web');
fs.mkdirSync(output, {recursive:true});
const types={'.html':'text/html','.js':'application/javascript','.json':'application/json','.wasm':'application/wasm','.png':'image/png','.webp':'image/webp','.ttf':'font/ttf'};
http.createServer((req,res)=>{
  const rel=decodeURIComponent(new URL(req.url,'http://localhost').pathname).replace(/^\/+/, '');
  let file=path.resolve(webRoot,rel || 'index.html');
  if(!file.startsWith(webRoot+path.sep) && file!==webRoot){res.writeHead(403);return res.end();}
  if(!fs.existsSync(file) || fs.statSync(file).isDirectory())file=path.join(webRoot,'index.html');
  res.setHeader('Content-Type',types[path.extname(file)] || 'application/octet-stream');
  fs.createReadStream(file).pipe(res);
}).listen(8873,'127.0.0.1');
(async()=>{
  const browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',args:['--disable-gpu','--no-sandbox']});
  const context=await browser.newContext({viewport:{width:390,height:844},deviceScaleFactor:2,locale:'ar-EG',colorScheme:'light'});
  const page=await context.newPage();
  page.on('console',m=>{if(m.type()==='error') console.log('PAGE ERROR: '+m.text().slice(0,400));});
  page.on('pageerror',e=>console.log('JS ERROR: '+e.message));
  await page.goto('http://127.0.0.1:8873/',{waitUntil:'domcontentloaded'});
  console.log('BROWSER READY');
  http.createServer(async(req,res)=>{
    try{
      let body='';for await(const c of req)body+=c;
      const a=body?JSON.parse(body):{op:'state'};
      let result;
      if(a.op==='state')result=await page.evaluate(()=>({text:document.body.innerText,html:document.body.innerHTML.slice(-24000)}));
      if(a.op==='click'){if(a.text)await page.getByText(a.text,{exact:!!a.exact}).first().click({timeout:5000});else await page.mouse.click(a.x,a.y);result='clicked';}
      if(a.op==='scroll'){await page.mouse.move(a.x||200,a.y||400);await page.mouse.wheel(a.dx||0,a.dy||0);result='scrolled';}
      if(a.op==='type'){await page.keyboard.insertText(a.text);result='typed';}
      if(a.op==='key'){await page.keyboard.press(a.key);result='key pressed';}
      if(a.op==='viewport'){await page.setViewportSize({width:a.width,height:a.height});result='resized';}
      if(a.op==='shot'){await page.screenshot({path:path.join(output,a.name+'.png'),animations:'disabled'});result=path.join(output,a.name+'.png');}
      if(a.op==='storage')result=await page.evaluate(()=>Object.fromEntries(Object.entries(localStorage)));
      if(a.op==='setStorage'){await page.evaluate(({key,value})=>localStorage.setItem(key,value),a);result='stored locally';}
      if(a.op==='reload'){await page.reload({waitUntil:'domcontentloaded'});result='reloaded';}
      if(a.op==='semantics'){result=await page.evaluate(()=>{const node=document.querySelector('flt-semantics-placeholder');if(node){node.click();return node.outerHTML;}return 'none';});}
      res.setHeader('Content-Type','application/json; charset=utf-8');res.end(JSON.stringify({ok:true,result}));
    }catch(e){res.statusCode=500;res.end(JSON.stringify({ok:false,error:e.message}));}
  }).listen(8874,'127.0.0.1',()=>console.log('CONTROL READY 8874'));
})();
