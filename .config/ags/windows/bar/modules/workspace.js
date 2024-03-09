const hypr = await Service.import("hyprland")

const order = new Map([
    ["web", 1],
    ["web2", 2],
    ["web3", 3],
    ["web4", 4],

    ["main", 10],
    ["games", 300],
    ["srv", 350],
    ["external", 375],
    ["mirror", 385],

    ["special:1", 400],
    ["special:2", 401],
    ["special:3", 402],
    ["special:4", 403],

])

const icons = new Map([
    ["web",  "󰖟  1"],
    ["web2", "󰖟  2"],
    ["web3", "󰖟  3"],
    ["web4", "󰖟  4"],

    ["main",     "󰣇"],
    ["games",    "󰊴"],
    ["srv",      "󰒋"],
    ["external", "󰐮"],
    ["mirror",   "󱇽"],

    ["special:1", "󱓥  1"],
    ["special:2", "󱓥  2"],
    ["special:3", "󰱙"],
    ["special:4", "󰨾"],
])

const WsList = () => Widget.Box({
    class_name: 'workspaces',
    children: hypr.bind("workspaces").transform(ws => {
        return ws.sort((a, b) => {
            return (order.get(a.name) || a.id+10) - (order.get(b.name) || b.id+10)
        }).map(({id, name, lastwindowtitle, windows }) => 
            Widget.Button({
                on_clicked: () => {
                    if (id != hypr.active.workspace.id) {
                        if (name.startsWith("special:")) {
                            hypr.messageAsync(`dispatch togglespecialworkspace ${name.replace("special:","")}`)
                        } else if (name == id) {
                            hypr.messageAsync(`dispatch workspace ${id}`)
                        } else {
                            hypr.messageAsync(`dispatch workspace name:${name}`)
                        }
                    }
                },
                class_names: ["button", "small",
                    name.startsWith("special:") ? "special" : "",
                    id == hypr.active.workspace.id ? "active" : ""],
                setup: self => self.hook(hypr.active.workspace, () => {
                    if (id == hypr.active.workspace.id){
                        self.toggleClassName("active", true)
                    } else {
                        self.toggleClassName("active", false)
                    }
                }),
                child: Widget.Label({
                    label: `${icons.get(name) || name}    ${lastwindowtitle || "empty"}`,
                    max_width_chars: 10,
                    truncate: 'end'
                })
                // child: hypr.bind('prop', hypr.active.client, 'title', activeTitle => Widget.Label({
                //     label: `${icons.get(name) || name}    ${hypr.active.workspace.id == id ? activeTitle : lastwindowtitle || "empty"}`,
                //     max_width_chars: 10,
                //     truncate: "end"
                // })) 
        }))
    })
    
})

const WsNew = () => Widget.Button({
    class_names: ["button", "small", "inactive"],
    on_clicked: () => hypr.messageAsync("dispatch workspace empty"),
    child: Widget.Label({
        label: "󱓺    New"
    })
})

export default () => Widget.Box({
    children: [
        WsList(),
        WsNew(),
    ]
})
