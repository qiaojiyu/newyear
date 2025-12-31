from flask import Flask, render_template_string

app = Flask(__name__)

HTML = r"""
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
    background: black;
    height: 100%;
    overflow: hidden;
}

/* ===== 星空背景（放在底层） ===== */
body::before {
    content: "";
    position: fixed;
    inset: -50%;
    background:
        radial-gradient(1px 1px at 20% 30%, white, transparent),
        radial-gradient(1px 1px at 80% 70%, white, transparent),
        radial-gradient(2px 2px at 50% 90%, white, transparent),
        radial-gradient(2px 2px at 10% 80%, white, transparent);
    animation: starMove 90s linear infinite;
    z-index: 0;                 /* ⭐ 关键：不遮挡内容 */
    pointer-events: none;
}

@keyframes starMove {
    to { transform: translate(-400px, -400px); }
}

/* ===== 镂空金色行楷 ===== */
.hollow-gold {
    font-family: "KaiTi","STKaiti","DFKai-SB",serif;
    color: transparent;
    -webkit-text-stroke: 3px gold;
    text-shadow:
        0 0 12px gold,
        0 0 30px orange,
        0 0 60px red;
}

/* ===== 居中容器 ===== */
.center {
    position: absolute;
    top: 50%;
    width: 100%;
    transform: translateY(-50%);
    text-align: center;
    z-index: 2;                 /* ⭐ 在星空之上 */
}

#countdown {
    font-size: min(32vw, 160px);
    transition: transform 0.4s ease;
}

#happy {
    font-size: min(28vw, 140px);
    opacity: 0;
    transform: scale(0.6);
    transition: all 2s ease;
}

/* ===== 提示文字 ===== */
#tip {
    position: fixed;
    bottom: 8%;
    width: 100%;
    text-align: center;
    color: #ccc;
    font-size: 16px;
    z-index: 2;
}

/* ===== 烟花 Canvas ===== */
canvas {
    position: fixed;
    inset: 0;
    z-index: 1;                 /* 在星空之上，在文字之下 */
}
</style>
</head>

<body>

<canvas id="canvas"></canvas>

<audio id="bgm" src="/static/bgm.mp3" loop></audio>
<audio id="boom" src="/static/firecracker.mp3"></audio>

<div class="center">
    <div id="countdown" class="hollow-gold"></div>
    <div id="happy" class="hollow-gold">乔玉姐 · 新 年 快 乐</div>
</div>

<div id="tip">轻点屏幕，开启新年 ✨</div>

<script>
/* ===== 点击后才启动（避免黑屏） ===== */
document.body.addEventListener("click", () => {
    document.getElementById("tip").style.display = "none";
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
    const now = Date.now();
    const diff = Math.floor((target - now) / 1000);

    if (diff <= 10 && diff >= 0 && diff !== last) {
        cd.textContent = diff;
        cd.style.transform = "scale(1.25)";
        setTimeout(() => cd.style.transform = "scale(1)", 250);
        last = diff;
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

function resize() {
    canvas.width = innerWidth;
    canvas.height = innerHeight;
}
resize();
addEventListener("resize", resize);

class Particle {
    constructor(x, y) {
        this.x = x;
        this.y = y;
        this.vx = (Math.random() - 0.5) * 7;
        this.vy = (Math.random() - 0.5) * 7;
        this.life = 100;
        this.color = `hsl(${Math.random()*360},100%,60%)`;
    }
    update() {
        this.x += this.vx;
        this.y += this.vy;
        this.life--;
    }
    draw() {
        ctx.fillStyle = this.color;
        ctx.beginPath();
        ctx.arc(this.x, this.y, 3, 0, Math.PI * 2);
        ctx.fill();
    }
}

let particles = [];

function firework() {
    const x = Math.random() * canvas.width;
    const y = Math.random() * canvas.height * 0.5;
    for (let i = 0; i < 100; i++) {
        particles.push(new Particle(x, y));
    }
}

function animate() {
    ctx.fillStyle = "rgba(0,0,0,0.12)";   // ⭐ 不会刷成黑屏
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    particles.forEach((p, i) => {
        p.update();
        p.draw();
        if (p.life <= 0) particles.splice(i, 1);
    });
    requestAnimationFrame(animate);
}

function startFireworks() {
    setInterval(firework, 600);
    animate();
}
</script>

</body>
</html>
"""

@app.route("/")
def index():
    return render_template_string(HTML)

if __name__ == "__main__":
    # ⭐ Railway / 云端必须这样跑
    app.run(host="0.0.0.0", port=8080)
