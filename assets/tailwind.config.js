module.exports = {
  purge: [
    '../lib/**/*.ex',
    '../lib/**/*.leex',
    '../lib/**/*.eex',
    './js/**/*.js'
  ],
  darkMode: 'class',
  theme: {
    extend: {},
    container: {
      center: true
    }
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
