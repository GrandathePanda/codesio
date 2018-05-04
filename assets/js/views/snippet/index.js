import mainView from '../main'
import CodeMirror from "codemirror"
const main = mainView()
export default () => {
    return {
        mount: function() {
            main.mount()
            const elements = [].slice.call(document.querySelectorAll('.snippet-area'))
            window.CodeMirror = window.CodeMirror || CodeMirror
            this.codeMirrors = elements.map((element) => {
                let lang = element.getAttribute('language')
                let snippet = element.getAttribute('snippet')
                console.log(snippet)
                return window._module.import('http://localhost:8000/'+lang+'/'+lang+'.js').then((res) => {
                    let editor = CodeMirror.fromTextArea(element, {lineNumbers: true, mode: lang, readOnly: 'nocursor', theme: 'blackboard'});
                    editor.getDoc().setValue(snippet)
                    return editor
                })
            })

        },
        unmount: () => {
            main.unmount()
            this.codeMirrors = null
        },
    }
}
