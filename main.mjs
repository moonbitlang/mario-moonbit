import ffi from './.mooncakes/peter-jerry-ye/canvas/import.mjs'
const canvas = document.getElementById("canvas");
const context = canvas.getContext("2d");
const WIDTH = 512;
const HEIGHT = 256;

canvas.width = WIDTH;
canvas.height = HEIGHT;

let requestAnimationFrameId = null;
let lastTime = 0;
let dropCounter = 0;
let dropInterval = 10;
const scoreDom = document.getElementById("score");

let halt = false;
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
        random: (l, r) => {
            return l + Math.floor(Math.random() * (r - l));
        }
    }
};

function update(time = 0) {
    const deltaTime = time - lastTime;
    dropCounter += deltaTime;
    if (dropCounter > dropInterval) {
        game_update(context, time);
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
        obj.instance.exports.start(context);
        game_update = obj.instance.exports["game_update"];
        requestAnimationFrameId = requestAnimationFrame(update);
    });
}
start();