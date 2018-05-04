import mainView from '../main'
import CodeMirror from "codemirror"

const main = mainView()
export default () => {
    return {
        mount: function() {
            main.mount()
            const elements = [].slice.call(document.querySelectorAll('.snippet-area'))
            const value = (document.getElementById('language-selector').value).trim('')
            window.CodeMirror = window.CodeMirror || CodeMirror
            this.codeMirrors = elements.map((element) => {
                let lang = element.language
                let snippet = element.snippet
                return window._module.import('http://localhost:8000/'+lang+'/'+lang+'.js').then((res) => {
                    return CodeMirror.fromTextArea(element, { lineNumbers: true, mode: lang, readOnly: 'nocursor', value: snippet});
                })
            })

        },
        unmount: () => {
            main.unmount()
            this.codeMirrors = null
        },
    }
}
