import mainView from '../main'
import CodeMirror from "codemirror"
import {Socket} from "phoenix"
const main = mainView()
export default () => {
    return {
        setUpSearchChannel: function() {
            let channel = this.socket.channel("search:*", {})
            let searchBar = document.getElementById("search-box")
            searchBar.addEventListener("input", event => {
                channel.push("new_search", {body: searchBar.value})
            })

            channel.join()
                .receive("ok", resp => { console.log("Joined successfully", resp) })
                .receive("error", resp => { console.log("Unable to join", resp) })
            channel.on("new_search", ({html}) => {
                const container = document.getElementById("snippet-container")
                container.innerHTML = html
                this.displayCodeMirrors()
            })
            this.channels["search"] = channel
        },
        mount: function() {
            this.socket = new Socket("/socket", {params: {token: window.userToken}})
            this.socket.connect()
            this.channels = {}
            main.mount()
            this.displayCodeMirrors()
            this.setUpSearchChannel()
        },
        displayCodeMirrors: function() {
            const elements = [].slice.call(document.querySelectorAll('.snippet-area'))
            window.CodeMirror = window.CodeMirror || CodeMirror
            this.codeMirrors = Promise.all(elements.map((element) => {
                let lang = element.getAttribute('language')
                let snippet = element.getAttribute('snippet')
                return window._module.import('http://localhost:8000/'+lang+'/'+lang+'.js').then((res) => {
                    let editor = CodeMirror.fromTextArea(element, {lineNumbers: true, mode: lang, readOnly: 'nocursor', theme: 'blackboard'});
                    editor.getDoc().setValue(snippet)
                    return editor
                })
            }))
        },
        unmount: function() {
            this.codeMirrors = null
            this.socket.disconnect()
            this.socket = null
            main.unmount()
        },
    }
}
