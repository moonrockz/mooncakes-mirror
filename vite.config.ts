import { defineConfig } from "vite";
import rabbita from "@rabbita/vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  root: "src",
  base: "/mooncakes-mirror/",
  build: {
    outDir: "dist",
    emptyOutDir: true,
  },
  plugins: [rabbita({ mainPkgDir: "src/main" }), tailwindcss()],
});
