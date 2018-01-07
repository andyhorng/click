import socket from "./socket"
import {Presence} from "phoenix"


document.addEventListener("DOMContentLoaded", (event) => {
    // click node
    let click_node = document.getElementById("click")


    if (click_node) {
        // assume there is game id, guest id
        // join lobby
        let channel = socket.channel(`guest:lobby`, {game_id: Gon.assets().id, guest_id: Gon.assets().gid})
        let presences = {}
        channel.join()
            .receive("ok", resp => {
                console.log("Joined successfully", resp)

                let clicks = resp['clicks']

                // empty node to avoid duplicated init
                click_node.innerHTML= '';
                let app = Elm.Click.embed(click_node, {name: Gon.assets().name, clicks: clicks})

                app.ports.click.subscribe((n) => {
                    channel.push("click", {gid: Gon.assets().gid, game_id: Gon.assets().id})
                })

                channel.on("presence_state", (state) => {
                    presences = Presence.syncState(presences, state)
                    app.ports.online.send(Object.keys(presences).length)
                })

                channel.on("presence_diff", (diff) => {
                    presences = Presence.syncDiff(presences, diff)
                    app.ports.online.send(Object.keys(presences).length)
                })

                channel.on("reset", ({game_id}) => {
                    if (game_id == Gon.assets().id) {
                        window.location.reload(true)
                    }
                })

            })
            .receive("error", resp => { console.log("Unable to join", resp) })
    }
});
