import Workspaces from './modules/workspace.js'


const Left = () => Widget.Box({
    children: [
        Workspaces()
    ]
})
const Center = () => Widget.Box({
    children: [
        Widget.Label({label: "test"})
    ]
})
const Right = () => Widget.Box({
    children: []
})


export default (monitor) => Widget.Window({
    monitor,
    class_name: "ags-bar",
    name: "ags-bar${monitor||0}",
    exclusivity: "exclusive",
    anchor: ["top", "left", "right"],
    keymode: "on-demand",
    child: Widget.CenterBox({
        start_widget: Left(),
        center_widget: Center(),
        end_widget: Right()
    })
})
