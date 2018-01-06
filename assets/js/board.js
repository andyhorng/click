import socket from './socket'

document.addEventListener("DOMContentLoaded", (event) => {

    let board_node = document.getElementById("board")


    if (board_node) {
        // join 
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
            })
            .receive("error", resp => { console.log("Unable to join", resp) })

    }

});
