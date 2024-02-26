import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import obfuscatorPlugin from "vite-plugin-javascript-obfuscator";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    obfuscatorPlugin({
      options: {
        // your javascript-obfuscator options
        debugProtection: true,
        seed: 23432,
        // ...  [See more options](https://github.com/javascript-obfuscator/javascript-obfuscator)
      },
    }),
  ],
  base: "./",
  build: {
    outDir: "build",
    // rollupOptions: {
    //   output: {
    //     plugins: [ // <-- use plugins inside output to not merge chunks on one file
    //       obfuscator({
    //         sourceMap: true,
    //         stringArray: false
    //       })
    //     ]
    //   }
    // },
    // target: 'es2019',
  },
});
