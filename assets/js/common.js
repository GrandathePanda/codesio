/*! (C) 2017 Andrea Giammarchi */
let info = {_:''}
let el = document.getElementById('common-js')
const protoPath = /^(?:[a-z]+:)?\/\//
const npmPath = /^[a-zA-Z_-]/
const __filename = info._ || el.getAttribute('data-main').replace(npmPath, './$&')
const normalize = function (url) {
    if (protoPath.test(url)) return url;
    if (npmPath.test(url)) return gModule._path(url);
    for (var
        path = __filename.slice(0, __filename.lastIndexOf('/')),
        length = url.length,
        c, i = 0, p = 0; i < length; p = i + 1
    ) {
        i = url.indexOf('/', p);
        if (i < 0) {
            i = length;
            path += '/' + url.slice(p);
            if (!/\.js$/i.test(path)) path += '.js';
        } else if (i === 0) {
            path = '';
        } else {
            c = p; p = i;
            while (p && url.charAt(p - 1) === '.') --p;
            switch (i - p) {
                case 0: path += '/' + url.slice(c, i); break;
                case 1: break;
                case 2: path = path.slice(0, path.lastIndexOf('/')); break;
            }
        }
    }
    return path;
}
const onload = function (xhr, path, resolve, existingScript=null) {
    const html = document.documentElement
    const script = existingScript || document.createElement('script')
    script.setAttribute('id', 'code-mirror-mode');
    script.textContent = xhr.responseText
    window._module._ = path;
    resolve(html.appendChild(script));
}
const error = function (path, xhr) {
    throw (gModule._cache[path] = new Error(xhr.statusText));
}
const load = function (path) {
    var remote = path
    const m = /^((?:[a-z]+?:\/\/)?[^/]+)\/([^@]+)@latest(\/.*)?$/.exec(path)
    const resolve = function (exports) { module = exports; }
    var xhr = new XMLHttpRequest()
    var module;
    if (m) {
        // hopefully soon ...
        // xhr.open('GET', 'https://registry.npmjs.org/' + m[2] + '/latest', false);
        // meanwhile ... 
        xhr.open('GET', 'http://www.3site.eu/latest/?@=' + m[2], false);
        xhr.send(null);
        if (xhr.status < 400) module = JSON.parse(xhr.responseText);
        else return error(path, xhr);
        remote = m[1] + '/' + m[2] + '@' + module.version + (m[3] || '');
    }
    xhr = new XMLHttpRequest();
    xhr.open('GET', remote, false);
    xhr.send(module = null);
    if (xhr.status < 400) onload(xhr, path, resolve);
    else error(path, xhr);
    return module;
}
const exports = {}
export const moduleLoader = {
    _cache: Object.create(null),
    _nonce: el.getAttribute('nonce'),
    _path: function (url) {
        var i = url.indexOf('/'), length = url.length;
        return 'https://unpkg.com/' + url.slice(0, i < 0 ? length : i) +
            '@latest' + (i < 0 ? '' : url.slice(i));
    },
    filename: __filename,
    exports: exports,
    require: function (url) {
        var path = normalize(url);
        return gModule._cache[path] || load(path);
    },
    import: function (url) {
        var path = normalize(url);
        return Promise.resolve(
            this._cache[path] ||
            (this._cache[path] = new Promise(
                function (resolve, reject) {
                    var xhr = new XMLHttpRequest();
                    xhr.open('GET', path, true);
                    xhr.onreadystatechange = function () {
                        if (xhr.readyState == 4) {
                            if (xhr.status < 400) onload(xhr, path, resolve);
                            else reject(new Error(xhr.statusText));
                        }
                    };
                    xhr.send(null);
                }
            ))
        );
    }
}
