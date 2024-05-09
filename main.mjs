import ffi from './.mooncakes/peter-jerry-ye/canvas/import.mjs'
const canvas = document.getElementById("canvas");
const context = canvas.getContext("2d");
const WIDTH = 512;
const HEIGHT = 256;

canvas.width = WIDTH;
canvas.height = HEIGHT;

let memory

const importObject = {
    ...ffi(() => memory),
    canvas: {
        random: (l, r) => {
            return l + Math.floor(Math.random() * (r - l));
        }
    }
};

WebAssembly.instantiateStreaming(
    fetch("target/wasm-gc/release/build/main/main.wasm"),
    importObject
).then((obj) => {
    memory = obj.instance.exports["moonbit.memory"];
    obj.instance.exports._start();
    obj.instance.exports.entry(context);
});