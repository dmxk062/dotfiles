import Bar from './windows/bar/bar.js'

const scss = `${App.configDir}/style/main.scss`

const css = "/tmp/ags.css"
console.log(`Loading scss from ${scss}`)
const sassc_out = Utils.exec(`sassc ${scss} ${css}`)
console.log(`Finished loading ${css}`)

App.config({
    style: css,
    windows: [
        Bar(),

        // you can call it, for each monitor
        // Bar(0),
        // Bar(1)
    ],
})

export { }
