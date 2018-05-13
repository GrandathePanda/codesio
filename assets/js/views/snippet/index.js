import mainView from '../main'
import CodeMirror from "codemirror"
import {Socket} from "phoenix"
import Shuffle from 'shufflejs'
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
                this.setUpShuffle()
            })
            this.channels["search"] = channel
        },
        setUpShuffle: function() {
            const snippetContainer = document.getElementById('snippet-container')
            this.shuffle = new Shuffle(snippetContainer, {
                useTransforms: true,
            })
        },
        setUpFilters: function() {
            const ratings = [].slice.call(document.getElementsByName("rating-filter"))
            const shuffle = this.shuffle
            const sortSelect = document.getElementsByName('sort-suite-selector')[0]
            sortSelect.onchange = function() {
                document.getElementById('sorting-sub-block-age').classList.remove('sorting-subblock-hidden')
            }
            ratings.map((ele) => {
                ele.onclick = function() {
                    shuffle.filter((ele) => {
                        const textArea = ele.getElementsByTagName("textarea")[0]
                        return textArea.getAttribute('rating') == this.value
                    })
                }
            })
            const languageSelector = document.getElementById("language-filter-selector")
            languageSelector.onchange = function() {
                if(this.value === 'All') {
                    shuffle.filter((ele) => true)
                } else {
                    shuffle.filter((ele) => {
                        const textArea = ele.getElementsByTagName("textarea")[0]
                        return this.value === textArea.getAttribute('language')
                    })
                }
            }
            const ageSortPred = function(ele) {
                const textArea = ele.getElementsByTagName("textarea")[0]
                return textArea.getAttribute('created')
            }
            const ageSortSelect = document.getElementsByName("age-sort")[0]
            ageSortSelect.onchange = function() {
                if(this.value === 'Newest') {
                    shuffle.sort({
                        reverse: false,
                        by: ageSortPred
                    })
                } else if(this.value === "Oldest") {
                    shuffle.sort({
                        reverse: true,
                        by: ageSortPred
                    })
                } else {
                    shuffle.sort({
                        by: (ele) => undefined
                    })
                }
            }
        },
        mount: function() {
            this.socket = new Socket("/socket", {params: {token: window.userToken}})
            this.socket.connect()
            this.channels = {}
            main.mount()
            this.displayCodeMirrors()
            this.setUpSearchChannel()
            this.setUpShuffle()
            this.setUpFilters()
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
