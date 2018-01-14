import socket from './socket'
import {Presence} from 'phoenix'


let pull_sum = (channel, app) => {
    setTimeout(() => {
        channel.push("pull_sum", {game_id: Gon.assets().id}, 2, 3000)
            .receive("ok", resp => {
                console.log(resp)
                app.ports.sum.send(Object.keys(resp).map((key, ix) => {
                    return {
                        id: key,
                        name: resp[key].name,
                        count: resp[key].count
                    }
                }))
                pull_sum(channel, app)
            })
            .receive("error", (reasons) => console.log("create failed", reasons) )
            .receive("timeout", () => {
                console.log("Networking issue...")
                pull_sum(channel, app)
            } )
    }, 500)
}


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

                app.ports.start.subscribe((s) => {
                    channel.push("start_over", {"game_id": Gon.assets().id})
                })

                pull_sum(channel, app)

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

