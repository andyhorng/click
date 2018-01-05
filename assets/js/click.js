import socket from "./socket"

document.addEventListener("DOMContentLoaded", (event) => {
    let node = document.getElementById("app")
    let app = Elm.Main.embed(node, {name: Gon.assets().name})

    app.ports.click.subscribe((n) => {
    })


    let channel = socket.channel(`guest:${Gon.assets().id}`, {})
    channel.join()
        .receive("ok", resp => {
            console.log("Joined successfully", resp)
        })
        .receive("error", resp => { console.log("Unable to join", resp) })

});
