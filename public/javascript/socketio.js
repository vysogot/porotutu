import { Manager } from "https://cdn.socket.io/4.7.5/socket.io.esm.min.js";

const manager = new Manager("/");
const socket = manager.socket("/websocket");

socket.io.on('open', (err) => {
    console.log(err)
});

socket.io.on('error', (err) => {
    console.log(err)
});