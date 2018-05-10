import mainView from '../main'
import CodeMirror from "codemirror"

const main = mainView()
export default () => {
    return {
        mount: function() {
            main.mount()
            const element = document.getElementById("snippet-area")
            const lang = element.getAttribute("language")
            window.CodeMirror = window.CodeMirror || CodeMirror
            window._module.import('http://localhost:8000/'+lang+'/'+lang+'.js').then((res) => {
                this.codeMirror = CodeMirror.fromTextArea(element,
                                                         {
                                                             readOnly: "nocursor",
                                                             lineNumbers: true,
                                                             mode: lang,
                                                             theme: 'blackboard'
                                                         });
                this.codeMirror.getDoc().setValue(element.getAttribute("snippet"))
            })

        },
        unmount: function() {
            main.unmount()
            this.codeMirror = null
        },
    }
}
