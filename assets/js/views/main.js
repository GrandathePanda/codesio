import "phoenix_html"
export default () => {
    return {
        mount: function() {
            tagifyJS()
        },

        unmount: function() {

        }
    }
}
