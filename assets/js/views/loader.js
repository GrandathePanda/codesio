import mainView from './main'
import SnippetNewView from './snippet/new'
const views = {
    SnippetNewView

}
export default (viewName) => {
    console.log(viewName)
    return views[viewName] || mainView
}
