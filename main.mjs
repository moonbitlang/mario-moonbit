import ffi from './.mooncakes/peter-jerry-ye/canvas/import.mjs'
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

window.addEventListener("keydown", (e) => {
    if (e.code === "Space") {
        halt = false;
        start();
        return;
    }
});

let memory

const importObject = {
    ...ffi(() => memory),
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
        memory = obj.instance.exports["moonbit.memory"];
        obj.instance.exports._start();
        game_win = obj.instance.exports["game_win"];
        game_lose = obj.instance.exports["game_lose"];
        game_update = obj.instance.exports["game_update"];
        requestAnimationFrameId = requestAnimationFrame(update);
    });
}
start();