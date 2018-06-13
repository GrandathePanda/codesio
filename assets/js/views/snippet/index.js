import mainView from '../main'
import CodeMirror from "codemirror"
import "codemirror/addon/mode/overlay"
import "codemirror/addon/mode/simple"
import "codemirror/mode/css/css"
import {Socket} from "phoenix"
import Shuffle from 'shufflejs'
const main = mainView()
export default () => {
    return {
        setUpSearchChannel: async function() {
            let channel = this.socket.channel("search:*", {})
            let searchBar = document.getElementById("search-box")
            const searchBarListener = event => {
                channel.push("new_search", {body: searchBar.value})
            }
            searchBar.addEventListener("input", searchBarListener)
            await new Promise((resolve, reject) => {
                channel.join()
                    .receive("ok", resp => {
                        console.log("Joined Searches successfully", resp)
                        resolve(resp)
                    })
                    .receive("error", resp => {
                        console.log("Unable to join Searches", resp)
                        reject(resp)
                    })
            })
            const windowScrollListener = (event => {
                if(this.stopPagination || !this.isMounted) {
                    return
                }
                if(window.innerHeight + Math.round(window.scrollY) < document.body.clientHeight) {
                    return
                }
                this.stopPagination = true
                const search = document.getElementById("search-box").value
                const pagination_config = {
                    page: this.page + 1
                }
                channel.push("continued_search", {body: search, pagination_config})
            }).bind(this)
            window.addEventListener("wheel", windowScrollListener)
            channel.on("new_search", ({html}) => {
                const container = document.getElementById("snippet-page-snippet-list")
                container.innerHTML = html
                this.displayCodeMirrors()
                this.setUpShuffle()
                this.page = 1
                this.stopPagination = false
            })
            channel.on("continued_search", ({html}) => {
                if(html == "") {
                    return
                }
                const container = document.getElementById("snippet-page-snippet-list")
                this.removeCodeMirrors()
                this.shuffle.element.insertAdjacentHTML("beforeend", html)
                const newElements = document.querySelectorAll("div:not(.shuffle-item).snippet-area-container")
                this.shuffle.add(Array.prototype.slice.call(newElements))
                this.page += 1
                this.displayCodeMirrors()
            })
            this.activeEventListeners.push(["search-box","wheel", windowScrollListener])
            this.activeEventListeners.push(["window","input", searchBarListener])
            this.channels["search"] = channel
        },
        setUpRatingChannel: function() {
            const userToken = document.getElementsByName("user-token")[0].getAttribute("content")
            if(!userToken) {
                return
            }
            let channel = this.socket.channel("rating:*", {})
            const bodyClickListener = (event) => {
                if(event.target.classList.contains("vote")) {
                    if(!event.target.classList.contains("active")) {
                        if(event.target.classList.contains('up-vote')) {
                            channel.push("upvote", {body: event.target.getAttribute("snippetid")})
                            event.target.src = "/images/curly-bracket-up-active.svg"
                            event.target.classList.add("active")
                            event.target.nextSibling.src = "/images/curly-bracket-down.svg"
                            event.target.nextSibling.classList.remove("active")
                        } else if(event.target.classList.contains('down-vote')) {
                            channel.push("downvote", {body: event.target.getAttribute("snippetid")})
                            event.target.src = "/images/curly-bracket-down-active.svg"
                            event.target.classList.add("active")
                            event.target.previousSibling.src = "/images/curly-bracket-up.svg"
                            event.target.previousSibling.classList.remove("active")
                        }
                    } else {
                        channel.push('unvote', {body: event.target.getAttribute("snippetid")})
                        let src = event.target.src.split('-')
                        src.pop()
                        event.target.src = src.join('-') + '.svg'
                        event.target.classList.remove('active')
                    }
                }
            }
            document.body.addEventListener("click", bodyClickListener)
            channel.on("rating_change", payload => {
                const rating = (payload.rating).toFixed(1)
                document.getElementById(payload.snippet_id).setAttribute("rating", rating)
                document.getElementById("rating-"+payload.snippet_id).innerText = rating
            })
            channel.join()
                .receive("ok", resp => { console.log("Joined Ratings successfully", resp) })
                .receive("error", resp => { console.log("Unable to join Ratings", resp) })
            this.activeEventListeners.push(["document", "click", bodyClickListener])
            this.channels["rating"] = channel
        },
        setUpShuffle: function() {
            const snippetContainer = document.getElementById('snippet-page-snippet-list')
            this.shuffle = new Shuffle(snippetContainer, {
                useTransforms: true,
                isCentered: true,
                gutterWidth: 20
            })
        },
        appendToShuffle: function() {

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
                        reverse: true,
                        by: ageSortPred
                    })
                } else if(this.value === "Oldest") {
                    shuffle.sort({
                        reverse: false,
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
            main.mount()
            const userToken = document.getElementsByName("user-token")[0].getAttribute("content")
            this.socket = new Socket("/socket", {params: {}})
            if(userToken) {
                this.socket = new Socket("/socket", {params: {token: userToken}})
            }
            this.activeEventListeners = []
            this.page = 1
            this.stopPagination = false
            this.socket.connect()
            this.channels = {}
            this.displayCodeMirrors()
            this.setUpSearchChannel()
            this.setUpRatingChannel()
            this.setUpShuffle()
            this.setUpFilters()
            this.isMounted = true
        },
        removeCodeMirrors: function() {
            if(this.codeMirrors !== undefined) {
                this.codeMirrors.forEach((mirror) => {
                    mirror.toTextArea()
                })
                this.codeMirrors = undefined
            }
        },
        displayCodeMirrors: async function() {
            const elements = [].slice.call(document.querySelectorAll('.snippet-area'))
            window.CodeMirror = window.CodeMirror || CodeMirror
            this.codeMirrors = await Promise.all(elements.map((element) => {
                let lang = element.getAttribute('language')
                let snippet = element.getAttribute('snippet')
                return window._module.import('http://localhost:8000/'+lang+'/'+lang+'.js').then((res) => {
                    let editor = CodeMirror.fromTextArea(element, {lineNumbers: true, mode: lang, readOnly: true, theme: 'elegant'});
                    editor.getDoc().setValue(snippet)
                    return editor
                })
            }))
            setTimeout(((event) => { this.stopPagination = false }).bind(this), 1500)
        },
        unbindEventListeners: function() {
            this.activeEventListeners.forEach(([elementid, type, fn]) => {
                if(elementid === "window") {
                    window.removeEventListener(type, fn)
                } else if(elementid === "document") {
                    document.removeEventListener(type, fn)
                } else {
                    document.getElementById(elementid).removeEventListener(type, fn)
                }
            })
        },
        unmount: function() {
            this.codeMirrors = null
            this.socket.disconnect()
            this.socket = null
            this.unbindEventListeners()
            main.unmount()
        },
    }
}
