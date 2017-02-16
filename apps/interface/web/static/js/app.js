import "phoenix_html";

import {Socket} from "phoenix";

let canvas, context, scale = 16, interval = 100;

function getPixelRatio(context) {
    var backingStore = context.backingStorePixelRatio ||
            context.webkitBackingStorePixelRatio ||
            context.mozBackingStorePixelRatio ||
            context.msBackingStorePixelRatio ||
            context.oBackingStorePixelRatio ||
            context.backingStorePixelRatio || 1;

    return (window.devicePixelRatio || 1) / backingStore;
};

function setupCanvas() {
    canvas = document.getElementById("canvas");
    context = canvas.getContext("2d");
    let ratio = getPixelRatio(context);
    canvas.width = window.innerWidth * ratio;
    canvas.height = window.innerHeight * ratio;
    canvas.style.width = `${window.innerWidth}px`;
    canvas.style.height = `${window.innerHeight}px`;
    context.scale(ratio, ratio);
    context.fillStyle = 'rgb(0, 0, 0)';
}


function render(positions) {
    context.clearRect(0, 0, canvas.width, canvas.height);
    positions.forEach(({x, y}) => {
        context.fillRect(x * scale, y * scale, scale, scale);
    });
}

function setupSocket() {
    let socket = new Socket("/socket");
    let sent, playing = false;

    socket.connect();

    let channel = socket.channel("life", {});
    channel.join()
        .receive("ok", cells => {
            render(cells.positions);

            channel.on("tick", cells => {
                render(cells.positions);
            });

            $("body").on("keypress", () => {
                playing = !playing;
                sent = Date.now();
                if (playing) {
                    setTimeout(function tick() {
                        channel.push("tick");
                        let duration = Date.now() - sent - interval;
                        if (playing) {
                            setTimeout(tick, interval - duration);
                            sent = Date.now();
                        }
                    }, interval);
                }
            });
        })
        .receive("error", resp => console.error);
}

setupCanvas();
setupSocket();
