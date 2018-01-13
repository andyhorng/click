import socket from './socket'
import {Presence} from 'phoenix'


let init_anim_counter = (id) => {
    var numAnim = new CountUp(id, 0, 0, 0, 2)
    numAnim.start()
    return numAnim
}

document.addEventListener("DOMContentLoaded", (event) => {

    let board_node = document.getElementById("board")


    if (board_node) {
        // join 
        let presences = {}
        let channel = socket.channel(`guest:board:${Gon.assets().id}`, {})

        let onlineGuestsCounter = init_anim_counter("online_guests")
        let totalClicksCounter = init_anim_counter("total_clicks")
        let totalClicksNum = 0

        channel.join()
            .receive("ok", resp => {
                console.log("Joined successfully", resp)

                // empty node to avoid duplicated init
                board_node.innerHTML= '';

                totalClicksCounter.update(resp['total'])
                totalClicksNum += resp['total']

                let app = Elm.Board.embed(board_node, {total_clicks: resp['total']})
                channel.on("click", () => {
                    app.ports.clicks.send(1)
                    totalClicksNum += 1
                    totalClicksCounter.update(totalClicksNum)
                })

                app.ports.start.subscribe((s) => {
                    channel.push("start_over", {"game_id": Gon.assets().id})
                })

                setInterval(() => {
                    channel.push("pull_sum", {game_id: Gon.assets().id}, 2)
                        .receive("ok", resp => {
                            console.log(resp)
                            app.ports.sum.send(Object.keys(resp).map((key, ix) => {
                                return {
                                    id: key,
                                    name: resp[key].name,
                                    count: resp[key].count
                                }
                            }))
                        })
                }, 1000)

                let lobby = socket.channel("guest:lobby", {})
                lobby.join()
                lobby.on("presence_state", (state) => {
                    presences = Presence.syncState(presences, state)
                    app.ports.online_users.send(Object.keys(presences).length)
                    onlineGuestsCounter.update(Object.keys(presences).length)
                })

                lobby.on("presence_diff", (diff) => {
                    presences = Presence.syncDiff(presences, diff)
                    app.ports.online_users.send(Object.keys(presences).length)
                    onlineGuestsCounter.update(Object.keys(presences).length)
                })

            })
            .receive("error", resp => { console.log("Unable to join", resp) })

    }

});

