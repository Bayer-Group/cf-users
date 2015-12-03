var webpack = require('webpack');
var path = require('path');
var plugins = [
    new webpack.ProvidePlugin({
        $: "jquery",
        "jQuery": "jquery",
        "window.jQuery": "jquery",
        "window.$" : "jquery",
        "root.jQuery": "jquery"
    }),
    new webpack.ResolverPlugin(
        new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin("bower.json", ["main"])
    )
];
if (process.env.NODE_ENV === 'production') {
    plugins.push(new webpack.optimize.UglifyJsPlugin({
        minimize: true
    }));
}

module.exports = {
    entry: {
        bundle: "./public/scripts/CfUsersBootstrap"
    },
    output: {
        path: __dirname + '/public/scripts/',
        filename: 'bundle.js'
    },
    plugins: plugins,
    module: {
        loaders: [
            {
                test: /.coffee$/,
                loader: "coffee"
            },
            {
                test: /[\/\\]node_modules[\/\\]jquery[\/\\]dist[\/\\]jquery\.js$/,
                loader: "imports?this=>window"
            }
        ]
    },
    devtool: "#source-map",
    resolve: {
        extensions: ['', '.js', '.json', '.coffee'],
        root: [path.join(__dirname, "bower_components")]
    },
    node: {
        child_process: 'empty'
    }
};