import mainView from './main'
import SnippetNewView from './snippet/new'
import SnippetIndexView from './snippet/index'
import SnippetShowView from './snippet/show'
const views = {
    SnippetNewView,
    SnippetIndexView,
    SnippetShowView
}

export default (viewName) => {
    return views[viewName] || mainView
}
