import socket from "./socket"

document.addEventListener("DOMContentLoaded", (event) => {
    // click node
    let click_node = document.getElementById("click")


    if (click_node) {
        // empty node to avoid duplicated init
        // assume there is game id, guest id
        // join lobby
        let channel = socket.channel(`guest:lobby`, {game_id: Gon.assets().id, guest_id: Gon.assets().gid})
        channel.join()
            .receive("ok", resp => {
                console.log("Joined successfully", resp)

                let clicks = resp['clicks']

                click_node.innerHTML= '';
                let app = Elm.Click.embed(click_node, {name: Gon.assets().name, clicks: clicks})

                app.ports.click.subscribe((n) => {
                    channel.push("click", {gid: Gon.assets().gid, game_id: Gon.assets().id})
                })

            })
            .receive("error", resp => { console.log("Unable to join", resp) })
    }
});
