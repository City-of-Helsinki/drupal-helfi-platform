const isDev = (process.env.NODE_ENV !== 'production');

const path = require('path');
const glob = require('glob');

const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const FriendlyErrorsWebpackPlugin = require('@nuxt/friendly-errors-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const RemoveEmptyScriptsPlugin = require('webpack-remove-empty-scripts');
const SVGSpritemapPlugin = require('svg-spritemap-webpack-plugin');

// Handle entry points.
const Entries = () => {
  let entries = {
    styles: ['./src/scss/styles.scss'],
    // Special handling for some javascript or scss.
    // 'some-component': [
    //   './src/scss/some-component.scss',
    //   './src/js/some-component.js',
    // ],
  };

  const pattern = './src/js/**/*.js';
  const ignore = [
    // Some javascript what is needed to ignore and handled separately.
    // './src/js/component-library.js'
  ];

  glob.sync(pattern, {ignore: ignore}).map((item) => {
    entries[path.parse(item).name] = item }
  );
  return entries;
};

module.exports = {
  entry() {
    return Entries();
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    chunkFilename: 'js/async/[name].chunk.js',
    pathinfo: true,
    filename: 'js/[name].min.js',
    publicPath: '../',
  },
  module: {
    rules: [
      {
        test: /\.svg$/,
        include: [
          path.resolve(__dirname, 'src/icons')
        ],
        type: 'asset/resource',
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: ['babel-loader'],
        type: 'javascript/auto',
      },
      {
        test: /\.(css|sass|scss)$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
          },
          {
            loader: 'css-loader',
            options: {
              sourceMap: isDev,
              importLoaders: 2,
              esModule: false,
            },
          },
          {
            loader: 'postcss-loader',
            options: {
              'postcssOptions': {
                'config': path.join(__dirname, 'postcss.config.js'),
              },
              sourceMap: isDev,
            },
          },
          {
            loader: 'sass-loader',
            options: {
              sourceMap: isDev,
            },
          },
        ],
        type: 'javascript/auto',
      },
    ],
  },
  resolve: {
    modules: [
      path.join(__dirname, "node_modules")
    ],
    extensions: [".js", ".json"],
  },
  plugins: [
    new FriendlyErrorsWebpackPlugin(),
    new RemoveEmptyScriptsPlugin(),
    new CleanWebpackPlugin({
      cleanAfterEveryBuildPatterns: ['dist']
    }),
    new SVGSpritemapPlugin([
      path.resolve(__dirname, 'src/icons/**/*.svg'),
    ], {
      output: {
        filename: './icons/sprite.svg',
        svg: {
          sizes: false
        }
      },
      sprite: {
        prefix: false,
        gutter: 0,
        generate: {
          title: false,
          symbol: true,
          use: true,
          view: '-view'
        }
      },
    }),
    new MiniCssExtractPlugin({
      filename: 'css/[name].min.css',
    }),
  ],
  watchOptions: {
    aggregateTimeout: 300,
  },
  // Tell us only about the errors.
  stats: 'errors-only',
  // Suppress performance errors.
  performance: {
    hints: false,
    maxEntrypointSize: 512000,
    maxAssetSize: 512000
  }
};
