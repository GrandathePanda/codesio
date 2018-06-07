// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
require("babel-polyfill")
import { moduleLoader } from './common.js'
import loadView from './views/loader';
import "phoenix_html"

function handleDOMContentLoaded() {
    // Get the current view name
    window.process = {browser: true};
    window._module = moduleLoader
    const viewName = document.getElementsByTagName('body')[0].dataset.jsViewName;

    // Load view class and mount it
    const viewFactory = loadView(viewName);
    const view = viewFactory();
    view.mount();
    window.currentView = view;
}

function handleDocumentUnload() {
  window.currentView.unmount();
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
window.addEventListener('unload', handleDocumentUnload, false);
// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

