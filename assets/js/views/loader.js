import mainView from './main'
import SnippetNewView from './snippet/new'
import SnippetIndexView from './snippet/index'
import SnippetShowView from './snippet/show'
import SnippetEditView from './snippet/edit'
const views = {
    SnippetNewView,
    SnippetIndexView,
    SnippetShowView,
    SnippetEditView
}

export default (viewName) => {
    return views[viewName] || mainView
}
