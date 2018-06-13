import mainView from '../main'
import CodeMirror from "codemirror"

const main = mainView()
export default () => {
    return {
        mount: function() {
            main.mount()
            const elements = [].slice.call(document.querySelectorAll('.snippet-editor'))
            const value = (document.getElementById('language-selector').value).trim('')
            window.CodeMirror = window.CodeMirror || CodeMirror
            window._module.import('http://localhost:8000/'+value+'/'+value+'.js').then((res) => {
                this.codeMirrors = elements.map((element) => {
                    return CodeMirror.fromTextArea(element, { lineNumbers: true, mode: value, theme: "elegant" });
                })
            })

        },
        unmount: function() {
            main.unmount()
            this.codeMirrors = null
        },
        changeLanguage: function(event) {
            event.preventDefault()
            const value = document.getElementById('language-selector').value.trim('')
            const script = document.getElementById('code-mirror-mode')
            if(script) {
                script.remove()
            }
            window._module.import('http://localhost:8000/'+value+'/'+value+'.js').then((res) => {
                this.codeMirrors.map((editor) => {
                    editor.setOption("mode", value)
                })
            })
        }
    }
}
