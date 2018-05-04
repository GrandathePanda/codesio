import mainView from './main'
import SnippetNewView from './snippet/new'
import SnippetIndexView from './snippet/index'
const views = {
    SnippetNewView,
    SnippetIndexView
}

export default (viewName) => {
    return views[viewName] || mainView
}
