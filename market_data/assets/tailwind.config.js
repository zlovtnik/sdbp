// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/market_data_web.ex",
    "../lib/market_data_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        brand: "#FD4F00",
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]

      // Check if the heroicons directory exists
      if (!fs.existsSync(iconsDir)) {
        throw new Error(
          `Heroicons directory not found: ${iconsDir}\n` +
          `Please install heroicons dependency:\n` +
          `  cd assets && npm install heroicons\n` +
          `Or ensure the heroicons package is properly installed in deps/heroicons/`
        )
      }

      icons.forEach(([suffix, dir]) => {
        let fullDir = path.join(iconsDir, dir)

        // Check if the specific icon directory exists
        if (!fs.existsSync(fullDir)) {
          console.warn(`Heroicons directory not found, skipping ${suffix} icons: ${fullDir}`)
          return
        }

        try {
          fs.readdirSync(fullDir).forEach(file => {
            let name = path.basename(file, ".svg") + suffix
            values[name] = {name, fullPath: path.join(fullDir, file)}
          })
        } catch (error) {
          throw new Error(
            `Failed to read heroicons from ${fullDir}: ${error.message}\n` +
            `Please ensure heroicons is properly installed and the directory structure is intact.`
          )
        }
      })

      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          // Encode SVG for data URI - minimal encoding for SVG in utf8 data URIs
          content = content.replace(/"/g, "'").replace(/%/g, "%25").replace(/#/g, "%23").replace(/{/g, "%7B").replace(/}/g, "%7D").replace(/</g, "%3C").replace(/>/g, "%3E").replace(/&/g, "%26")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    })
  ]
}
