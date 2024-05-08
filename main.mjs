const canvas = document.getElementById("canvas");
const context = canvas.getContext("2d");
const WIDTH = 512;
const HEIGHT = 256;

canvas.width = WIDTH;
canvas.height = HEIGHT;

let backg = document.createElement("img");
backg.src = "images/background.png";
let block = document.createElement("img");
block.src = "images/blocks.png";
let items = document.createElement("img");
items.src = "images/items.png";
let enemy = document.createElement("img");
enemy.src = "images/enemies.png";
let small = document.createElement("img");
small.src = "images/mario-small.png";
let large = document.createElement("img");
large.src = "images/mario-large.png";
let panel = document.createElement("img");
panel.src = "images/panel.png";
let round = document.createElement("img");
round.src = "images/ground.png";
let chunk = document.createElement("img");
chunk.src = "images/chunks.png";
let score = document.createElement("img");
score.src = "images/score.png";

let requestAnimationFrameId = null;
let lastTime = 0;
let dropCounter = 0;
let dropInterval = 10;
const scoreDom = document.getElementById("score");

let halt = false;
let game_win = null;
let game_lose = null;
let game_update = null;
let keydown_B = null;
let keydown_up = null;
let keydown_up2 = null;
let keydown_down = null;
let keydown_down2 = null;
let keydown_left = null;
let keydown_left2 = null;
let keydown_right = null;
let keydown_right2 = null;
let keyup_up = null;
let keyup_up2 = null;
let keyup_down = null;
let keyup_down2 = null;
let keyup_left = null;
let keyup_left2 = null;
let keyup_right = null;
let keyup_right2 = null;

window.addEventListener("keydown", (e) => {
    if (e.code === "Space") {
        halt = false;
        start();
        return;
    }

    if (!requestAnimationFrameId) return;
    switch (e.code) {
        case "KeyB":
            keydown_B();
            break;
        case "ArrowUp":
            keydown_up();
            break;
        case "KeyW":
            keydown_up2();
            break;
        case "ArrowDown":
            keydown_down();
            break;
        case "KeyS":
            keydown_down2();
            break;
        case "ArrowLeft":
            keydown_left();
            break;
        case "KeyA":
            keydown_left2();
            break;
        case "ArrowRight":
            keydown_right();
            break;
        case "KeyD":
            keydown_right2();
            break;
    }
});

window.addEventListener("keyup", (e) => {
    if (!requestAnimationFrameId) return;
    switch (e.code) {
        case "KeyB":
            keyup_B();
            break;
        case "ArrowUp":
            keyup_up();
            break;
        case "KeyW":
            keyup_up2();
            break;
        case "ArrowDown":
            keyup_down();
            break;
        case "KeyS":
            keyup_down2();
            break;
        case "ArrowLeft":
            keyup_left();
            break;
        case "KeyA":
            keyup_left2();
            break;
        case "ArrowRight":
            keyup_right();
            break;
        case "KeyD":
            keyup_right2();
            break;
    }
});

const importObject = {
    canvas: {
        get_backg: () => {
            return backg;
        },
        get_block: () => {
            return block;
        },
        get_items: () => {
            return items;
        },
        get_enemy: () => {
            return enemy;
        },
        get_small: () => {
            return small;
        },
        get_large: () => {
            return large;
        },
        get_panel: () => {
            return panel;
        },
        get_round: () => {
            return round;
        },
        get_chunk: () => {
            return chunk;
        },
        get_score: () => {
            return score;
        },
        render_box: (a, b, c, d) => {
            context.strokeStyle = "#FF0000";
            context.strokeRect(a, b, c, d);
        },
        render3: (img, sx, sy) => {
            context.drawImage(img, sx, sy);
        },
        render: (img, sx, sy, sw, sh, dx, dy, dw, dh) => {
            context.drawImage(img, sx, sy, sw, sh, dx, dy, dw, dh);
        },
        random: (l, r) => {
            return l + Math.floor(Math.random() * (r - l));
        },
        clear: () => {
            context.clearRect(0, 0, WIDTH, HEIGHT);
        },
        draw_hud: (score, coins) => {
            context.font = "10px 'Press Start 2P'";
            context.fillText("Score: " + score, WIDTH - 140, 18);
            context.fillText("Coins: " + coins, 120, 18);
        },
        draw_fps: (fps) => {
            context.font = "10px 'Press Start 2P'";
            context.fillText(fps, 10, 18);
        },
        game_win: () => {
            context.rect(0, 0, 512, 256);
            context.fillStyle = "black";
            context.fill();
            context.fillStyle = "white";
            context.font = "20px 'Press Start 2P'";
            context.fillText("You win!", 180, 128);
            // halt = true;
        },
        game_lose: () => {
            context.rect(0, 0, 512, 256);
            context.fillStyle = "black";
            context.fill();
            context.fillStyle = "white";
            context.font = "20px 'Press Start 2P'";
            context.fillText("GAME OVER. You lose!", 60, 128);
            // halt = true;
        },
    },
    spectest: {
        print_char: (x) => console.log(String.fromCharCode(x)),
    },
};

function update(time = 0) {
    const deltaTime = time - lastTime;
    dropCounter += deltaTime;
    if (dropCounter > dropInterval) {
        game_update(time);
        dropCounter = 0;
    }
    lastTime = time;
    if (!halt) {
        requestAnimationFrameId = requestAnimationFrame(update);
    }
}

function start() {
    WebAssembly.instantiateStreaming(
        fetch("target/wasm-gc/release/build/main/main.wasm"),
        importObject
    ).then((obj) => {
        obj.instance.exports._start();
        game_win = obj.instance.exports["game_win"];
        game_lose = obj.instance.exports["game_lose"];
        game_update = obj.instance.exports["game_update"];
        keydown_B = obj.instance.exports["keydown_B"];
        keydown_up = obj.instance.exports["keydown_up"];
        keydown_up2 = obj.instance.exports["keydown_up2"];
        keydown_down = obj.instance.exports["keydown_down"];
        keydown_down2 = obj.instance.exports["keydown_down2"];
        keydown_left = obj.instance.exports["keydown_left"];
        keydown_left2 = obj.instance.exports["keydown_left2"];
        keydown_right = obj.instance.exports["keydown_right"];
        keydown_right2 = obj.instance.exports["keydown_right2"];
        keyup_up = obj.instance.exports["keyup_up"];
        keyup_up2 = obj.instance.exports["keyup_up2"];
        keyup_down = obj.instance.exports["keyup_down"];
        keyup_down2 = obj.instance.exports["keyup_down2"];
        keyup_left = obj.instance.exports["keyup_left"];
        keyup_left2 = obj.instance.exports["keyup_left2"];
        keyup_right = obj.instance.exports["keyup_right"];
        keyup_right2 = obj.instance.exports["keyup_right2"];
        requestAnimationFrameId = requestAnimationFrame(update);
    });
}
start();