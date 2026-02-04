import { defineConfig } from "vite";
import rabbitTEA from "rabbit-tea-vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  root: "src",
  build: {
    outDir: "dist",
    emptyOutDir: true,
  },
  plugins: [rabbitTEA(), tailwindcss()],
});
