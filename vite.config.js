import { defineConfig } from "vite";
import rabbitTEA from "rabbit-tea-vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  root: "src",
  base: "/mooncakes-mirror/",
  build: {
    outDir: "dist",
    emptyOutDir: true,
  },
  plugins: [rabbitTEA(), tailwindcss()],
});
