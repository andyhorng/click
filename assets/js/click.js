import socket from "./socket"

document.addEventListener("DOMContentLoaded", (event) => {
    let channel = socket.channel(`guest:lobby`, {game_id: Gon.assets().id, guest_id: Gon.assets().gid})
    channel.join()
        .receive("ok", resp => {
            console.log("Joined successfully", resp)

            let clicks = resp['clicks']

            let node = document.getElementById("app")
            let app = Elm.Main.embed(node, {name: Gon.assets().name, clicks: clicks})

            app.ports.click.subscribe((n) => {
                channel.push("click", {gid: Gon.assets().gid, game_id: Gon.assets().id})
            })
        })
        .receive("error", resp => { console.log("Unable to join", resp) })

    // handle reset

    // handle user online

});
