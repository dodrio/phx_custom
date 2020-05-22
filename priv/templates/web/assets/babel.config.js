/* eslint-env node */

module.exports = function generateConfig(api) {
  api.cache(true)

  const presets = [
    [
      '@babel/preset-env',
      {
        useBuiltIns: 'entry',
        corejs: 3,
        modules: false,
      },
    ],
  ]

  return {
    presets,
  }
}
