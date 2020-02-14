const { basename, parse } = require('path')
const { src, dest, watch } = require('gulp')
const log = require('fancy-log')
const less = require('gulp-less')
const csso = require('gulp-csso')
const Autoprefix = require('less-plugin-autoprefix')
const sourcemaps = require('gulp-sourcemaps')

const dir = process.env.WATCHING_DIR || '${WATCHING_DIR}'
const mainFile = `${dir}/style.less`

function compileLess() {
    return src(mainFile)
        .pipe(sourcemaps.init())
        .on('end', () => log('Tranpiling Less CSS file ' + basename(mainFile)))
        .pipe(less({
            plugins: [
                new Autoprefix({ browsers: ['ie 6', '> 1%', 'last 2 versions'] }),
            ]
        }))
        .on('end', () => log('Less CSS file ' + basename(mainFile) + ' transpiled!'))
        .pipe(csso({
            forceMediaMerge: process.env.FORCE_MEDIA_MERGE || '${FORCE_MEDIA_MERGE}',
        }))
        .on('end', () => log('Minifying CSS file ' + basename(mainFile)))
        .pipe(sourcemaps.write(`..${dir}`))
        .pipe(dest(dir))
        .on('end', () => log('CSS file ' + parse(mainFile).name + '.css minified!'))
}

exports.compileLess = compileLess
exports.less = compileLess

exports.default = () => {
    compileLess()
    watch(`${dir}/**/*.less`).on('change', (path) => {
        log(`${path} changed!`)
        compileLess()
    }).on('ready', () => log('Watching Less CSS files…'))
}
