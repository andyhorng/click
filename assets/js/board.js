import socket from './socket'
import {Presence} from 'phoenix'

document.addEventListener("DOMContentLoaded", (event) => {

    let board_node = document.getElementById("board")


    if (board_node) {
        // join 
        let presences = {}
        let channel = socket.channel(`guest:board:${Gon.assets().id}`, {})
        channel.join()
            .receive("ok", resp => {
                console.log("Joined successfully", resp)

                // empty node to avoid duplicated init
                board_node.innerHTML= '';

                let app = Elm.Board.embed(board_node, {total_clicks: resp['total']})
                channel.on("click", () => {
                    app.ports.clicks.send(1)
                })

                setInterval(() => {
                    channel.push("pull_sum", {game_id: Gon.assets().id}, 2)
                        .receive("ok", resp => {
                            app.ports.sum.send(Object.values(resp))
                        })
                }, 1000)

                let lobby = socket.channel("guest:lobby", {})
                lobby.join()
                lobby.on("presence_state", (state) => {
                    presences = Presence.syncState(presences, state)
                    app.ports.online_users.send(Object.keys(presences).length)
                })

                lobby.on("presence_diff", (diff) => {
                    presences = Presence.syncDiff(presences, diff)
                    app.ports.online_users.send(Object.keys(presences).length)
                })

            })
            .receive("error", resp => { console.log("Unable to join", resp) })

    }

});
