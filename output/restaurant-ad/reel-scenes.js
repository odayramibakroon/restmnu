function centered(s,y,size=78,color=K,weight=900,opacity=1){text(s,520,y,size,color,weight,'center',opacity)}
function heading(a,b,u,dark=false){const p=local(u,.1);centered(a,313+28*(1-p),78,dark?WHITE:K,900,p);const q=local(u,.3);centered(b,418+28*(1-q),80,dark?WHITE:O,950,q)}
function phoneHero(img,u,dark=false){outlineCircle(521,1090,441,dark?WHITE:O,.12,2);const p=local(u,.1,.75);phone(img,307,603+60*(1-p)+Math.sin(u*.95)*5,424,-.015*Math.sin(u*.45),.97+.03*p,p)}
function banner(s,y=1620,dark=false){pill(s,154,y,730,dark?O:WHITE,dark?WHITE:O,32)}
function intro(t){
  const solution=t>=8.2;coverBackground(solution?O:WHITE);header(null,null,solution);
  if(!solution){
    pill('لأصحاب المطاعم',330,239,380,O,'rgba(255,116,0,.10)',31);
    if(t<4.1){centered('صاحب مطعم؟',389,106,K,950,1);centered('ولا طول اليوم بترد؟',518,74,O,900,local(t,.35));}
    else{centered('نفس الأسئلة…',389,91,K,950,local(t,4.1,.4));centered('كل يوم؟',518,110,O,950,local(t,4.35,.4));}
    const p=local(t,.1,.8);phone(assets.menu,313,673+60*(1-p)+Math.sin(t)*5,410,-.025,p*.04+.96,p);
    bubble('المنيو فين؟',104,872,334,t,4.45);
    bubble('بكام؟',629,1140,248,t,5.5,true);
    bubble('نسجّل الأوردر إزاي؟',96,1406,431,t,6.4);
    if(t<4.2)centered('طلباتك تستاهل طريقة أسهل.',1650,34,K,700,local(t,1.4));
  }else{
    const u=t-8.2;heading('خلّي موقعك','يرتّب الطلب.',u,true);
    centered('وإنت ركّز في الطعم.',527,40,WHITE,700,local(u,.65));
    phoneHero(assets.menu,u,true);banner('من أول اختيار… لحد رسالة واتساب',1620,true);
  }
}
function menu(t){const u=t-13;coverBackground(WHITE);header('01','المنيو');heading('كل أطباقك.','في لينك واحد.',u);centered('صور • أسعار • أقسام مرتّبة',525,37,K,700,local(u,.8));phoneHero(assets.menu,u);banner('عميلك يشوف… ويختار براحته.');progress(t)}
function cart(t){const u=t-19.1;coverBackground(O);header('02','السلة',true);heading('العميل يختار.','والأوردر يتنظّم.',u,true);centered('كميات واضحة. وإجمالي قدّامه.',525,35,WHITE,700,local(u,.5));phoneHero(assets.cart,u,true);banner('كل الطلب في سلة واحدة',1620,true);progress(t,true)}
function checkout(t){const u=t-22.5;coverBackground(WHITE);header('03','الطلب');heading('من موقعك…','لواتساب مطعمك.',u);centered(t<27.5?'الاسم • الرقم • عنوان التوصيل':'الطلب وبيانات العميل… في رسالة واحدة',525,t<27.5?35:33,K,700,local(u,.65));phoneHero(blendImages(assets.checkout,assets.checkoutSend,smooth((t-27.5)/.65)),u);banner(t<27.5?'العميل يكتب بياناته ويراجع طلبه':'يفتح واتساب… ويضغط إرسال');progress(t)}
function restaurant(t){const u=t-34;coverBackground(O);header('04','مطعمك',true);heading('مش بس منيو.','دي واجهة مطعمك.',u,true);centered('فروعك • عناوينك • حسابات السوشيال',525,32,WHITE,700,local(u,.65));phoneHero(blendImages(assets.restaurant,assets.restaurantBranches,smooth((t-38)/.65)),u,true);banner('كل طرق التواصل… في مكان واحد',1620,true);progress(t,true)}
function responsive(t){const u=t-41.7;coverBackground(WHITE);header('05','كل الشاشات');
 if(t<44.5){heading('بالعربي…','و English كمان.',u);centered('نفس التجربة. بلغتين.',525,38,K,700,local(u,.6));const p=local(u,.2);phone(assets.menu,111,724+40*(1-p),360,-.028,1,p);phone(assets.english,577,724+40*(1-p),360,.028,1,p);pill('العربية',141,615,300,WHITE,O,31);pill('English',607,615,300,WHITE,O,31);banner('خلّي عميلك يختار لغته.');
 }else{const v=t-44.5;heading('على أي شاشة…','موقعك يظبط.',v);centered('موبايل • تابلت • كمبيوتر',525,38,K,700,local(v,.4));const p=local(v,.05);ctx.save();ctx.globalAlpha=p;laptop(assets.desktop,125,667+40*(1-p),790);ctx.restore();phone(assets.menu,567,987+35*(1-p),275,.025,1,p);ctx.save();ctx.globalAlpha=p;shadow(.16,25,12);rr(171,1122,365,472,27,'#151519');cleanShadow();rr(184,1135,339,446,17,WHITE);ctx.save();ctx.beginPath();ctx.roundRect(184,1135,339,446,17);ctx.clip();drawImageFit(assets.tablet,184,1135,339,446,'contain');ctx.restore();ctx.restore();banner('تصميم يليق بمطعمك.');}
 progress(t)
}
function cta(t){const u=t-52;coverBackground(WHITE);ctx.fillStyle=O;ctx.fillRect(0,0,W,588);outlineCircle(524,339,345,WHITE,.2,2);outlineCircle(524,339,411,WHITE,.1,2);const p=local(u,0,.7);ctx.save();ctx.globalAlpha=p;shadow(.15,36,18);rr(252,284+35*(1-p),536,352,37,WHITE);cleanShadow();drawImageFit(assets.logo,283,310+35*(1-p),474,298,'contain',{x:27,y:258,w:1200,h:750});ctx.restore();centered('خلّي الطلب',815,96,K,950,local(u,.25));centered('أسهل لمطعمك.',937,92,O,950,local(u,.5));centered('تواصلوا معانا',1134,65,K,850,local(u,.8));const q=local(u,1);ctx.save();ctx.globalAlpha=q;rr(126,1231,792,125,27,WHITE,'rgba(255,116,0,.42)',2);text('01096506563',520,1294,70,K,850,'center');rr(126,1394,792,119,27,O);text('giftegy7@gmail.com',520,1454,43,WHITE,750,'center');ctx.restore();centered('منيو. سلة. طلبات على واتساب.',1645,34,K,700,local(u,1.3))}
const scenes=[['intro',intro],['menu',menu],['cart',cart],['checkout',checkout],['restaurant',restaurant],['responsive',responsive],['cta',cta]];
function renderFrame(seconds){const t=clamp(Number(seconds)||0,0,61.999);let ix=0;for(let i=0;i<scenes.length;i++)if(t>=timings[scenes[i][0]])ix=i;ctx.setTransform(1,0,0,1,0,0);ctx.globalAlpha=1;cleanShadow();scenes[ix][1](t);const elapsed=t-timings[scenes[ix][0]];if(ix>0&&elapsed<.35){const edge=H*smooth(elapsed/.35);ctx.save();ctx.beginPath();ctx.rect(0,edge,W,H-edge);ctx.clip();scenes[ix-1][1](timings[scenes[ix][0]]-.001);ctx.restore();ctx.fillStyle=ix%2?O:WHITE;ctx.fillRect(0,Math.max(0,edge-6),W,6)}window.lastFrameTime=t;return canvas}
window.renderFrame=renderFrame;window.assetErrors=assetErrors;window.AD_DURATION=62;
window.ready=Promise.all([document.fonts.load('800 80px AdCairo'),...Object.entries(files).map(([key,url])=>new Promise(resolve=>{const im=new Image();im.onload=()=>{assets[key]=im;resolve()};im.onerror=()=>{assetErrors.push(url);resolve()};im.src=url}))]).then(()=>{window.assets=assets;renderFrame(0);return {assetErrors}});
if(new URLSearchParams(location.search).has('play'))window.ready.then(()=>{const audio=new Audio('voiceover.mp3');document.body.addEventListener('click',()=>audio.play(),{once:true});let start=null;function tick(now){if(start===null)start=now;renderFrame(((now-start)/1000)%62);requestAnimationFrame(tick)}requestAnimationFrame(tick)});
})();
