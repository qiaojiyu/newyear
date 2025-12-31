from flask import Flask, render_template_string

app = Flask(__name__)

HTML = """
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<title>新年倒计时</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
html, body {
    margin: 0;
    padding: 0;
    overflow: hidden;
    background: black;
    height: 100%;
}

/* 星空 */
body::before {
    content: "";
    position: fixed;
    width: 200%;
    height: 200%;
    background:
        radial-gradient(1px 1px at 20% 30%, white, transparent),
        radial-gradient(1px 1px at 80% 70%, white, transparent),
        radial-gradient(2px 2px at 50% 90%, white, transparent),
        radial-gradient(2px 2px at 10% 80%, white, transparent);
    animation: starMove 80s linear infinite;
}

@keyframes starMove {
    to { transform: translate(-500px, -500px); }
}

/* 镂空金色行楷 */
.hollow-gold {
    font-family: "KaiTi","STKaiti","DFKai-SB",serif;
    color: transparent;
    -webkit-text-stroke: 3px gold;
    text-shadow:
        0 0 15px gold,
        0 0 30px orange,
        0 0 60px red;
}

/* 居中容器（手机友好） */
.center {
    position: absolute;
    top: 50%;
    width: 100%;
    text-align: center;
    transform: translateY(-50%);
}

/* 倒计时 */
#countdown {
    font-size: min(30vw, 160px);
    transition: transform 0.5s ease;
}

/* 新年快乐 */
#happy {
    font-size: min(26vw, 140px);
    opacity: 0;
    transform: scale(0.5);
    transition: all 2s ease;
}

canvas {
    position: absolute;
    top: 0;
    left: 0;
}
</style>
</head>

<body>

<canvas id="canvas"></canvas>

<audio id="bgm" src="/static/bgm.mp3" loop></audio>
<audio id="boom" src="/static/firecracker.mp3"></audio>

<div class="center">
    <div id="countdown" class="hollow-gold"></div>
    <div id="happy" class="hollow-gold">新 年 快 乐</div>
</div>

<script>
/* ===== 自动全屏（需用户首次点击） ===== */
document.body.addEventListener("click", () => {
    document.documentElement.requestFullscreen?.();
    document.getElementById("bgm").play();
}, { once: true });

/* ===== 真实跨年时间 ===== */
const target = new Date("2026-01-01T00:00:00").getTime();
const cd = document.getElementById("countdown");
const happy = document.getElementById("happy");
const boom = document.getElementById("boom");

let last = -1;

const timer = setInterval(() => {
    const now = new Date().getTime();
    let diff = Math.floor((target - now) / 1000);

    if (diff <= 10 && diff >= 0) {
        if (diff !== last) {
            cd.textContent = diff;
            cd.style.transform = "scale(1.25)";
            setTimeout(()=>cd.style.transform="scale(1)",300);
            last = diff;
        }
    }

    if (diff < 0) {
        clearInterval(timer);
        cd.style.display = "none";
        happy.style.opacity = 1;
        happy.style.transform = "scale(1)";
        boom.play();
        startFireworks();
    }
}, 200);

/* ===== 烟花 ===== */
const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

function resize(){
    canvas.width = innerWidth;
    canvas.height = innerHeight;
}
resize();
onresize = resize;

class P {
    constructor(x,y){
        this.x=x; this.y=y;
        this.vx=(Math.random()-0.5)*7;
        this.vy=(Math.random()-0.5)*7;
        this.life=100;
        this.c=`hsl(${Math.random()*360},100%,60%)`;
    }
    draw(){
        ctx.fillStyle=this.c;
        ctx.beginPath();
        ctx.arc(this.x,this.y,3,0,Math.PI*2);
        ctx.fill();
    }
    move(){
        this.x+=this.vx;
        this.y+=this.vy;
        this.life--;
    }
}
let ps=[];

function fire(){
    let x=Math.random()*canvas.width;
    let y=Math.random()*canvas.height*0.5;
    for(let i=0;i<100;i++) ps.push(new P(x,y));
}

function loop(){
    ctx.fillStyle="rgba(0,0,0,0.25)";
    ctx.fillRect(0,0,canvas.width,canvas.height);
    ps.forEach((p,i)=>{
        p.move(); p.draw();
        if(p.life<=0) ps.splice(i,1);
    });
    requestAnimationFrame(loop);
}

function startFireworks(){
    setInterval(fire,600);
    loop();
}
</script>

</body>
</html>
"""

@app.route("/")
def index():
    return render_template_string(HTML)

if __name__ == "__main__":
    app.run()
