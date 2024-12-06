// vite.config.js
import { fileURLToPath, URL } from "node:url";
import dotenv from "file:///C:/Users/Bolasco/Desktop/yawa/110/node_modules/dotenv/lib/main.js";
import { defineConfig } from "file:///C:/Users/Bolasco/Desktop/yawa/110/node_modules/vite/dist/node/index.js";
import vue from "file:///C:/Users/Bolasco/Desktop/yawa/110/node_modules/@vitejs/plugin-vue/dist/index.mjs";
import vueDevTools from "file:///C:/Users/Bolasco/Desktop/yawa/110/node_modules/vite-plugin-vue-devtools/dist/vite.mjs";
var __vite_injected_original_import_meta_url = "file:///C:/Users/Bolasco/Desktop/yawa/110/vite.config.js";
dotenv.config();
var vite_config_default = defineConfig({
  define: {
    "process.env": {}
  },
  plugins: [vue(), vueDevTools()],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", __vite_injected_original_import_meta_url))
    }
  },
  base: "/"
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcuanMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCJDOlxcXFxVc2Vyc1xcXFxCb2xhc2NvXFxcXERlc2t0b3BcXFxceWF3YVxcXFwxMTBcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfZmlsZW5hbWUgPSBcIkM6XFxcXFVzZXJzXFxcXEJvbGFzY29cXFxcRGVza3RvcFxcXFx5YXdhXFxcXDExMFxcXFx2aXRlLmNvbmZpZy5qc1wiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9pbXBvcnRfbWV0YV91cmwgPSBcImZpbGU6Ly8vQzovVXNlcnMvQm9sYXNjby9EZXNrdG9wL3lhd2EvMTEwL3ZpdGUuY29uZmlnLmpzXCI7aW1wb3J0IHsgZmlsZVVSTFRvUGF0aCwgVVJMIH0gZnJvbSAnbm9kZTp1cmwnXHJcbmltcG9ydCBkb3RlbnYgZnJvbSAnZG90ZW52J1xyXG5cclxuaW1wb3J0IHsgZGVmaW5lQ29uZmlnIH0gZnJvbSAndml0ZSdcclxuaW1wb3J0IHZ1ZSBmcm9tICdAdml0ZWpzL3BsdWdpbi12dWUnXHJcbmltcG9ydCB2dWVEZXZUb29scyBmcm9tICd2aXRlLXBsdWdpbi12dWUtZGV2dG9vbHMnXHJcblxyXG5kb3RlbnYuY29uZmlnKClcclxuXHJcbi8vIGh0dHBzOi8vdml0ZS5kZXYvY29uZmlnL1xyXG5leHBvcnQgZGVmYXVsdCBkZWZpbmVDb25maWcoe1xyXG4gIGRlZmluZToge1xyXG4gICAgJ3Byb2Nlc3MuZW52Jzoge30sXHJcbiAgfSxcclxuICBwbHVnaW5zOiBbdnVlKCksIHZ1ZURldlRvb2xzKCldLFxyXG4gIHJlc29sdmU6IHtcclxuICAgIGFsaWFzOiB7XHJcbiAgICAgICdAJzogZmlsZVVSTFRvUGF0aChuZXcgVVJMKCcuL3NyYycsIGltcG9ydC5tZXRhLnVybCkpLFxyXG4gICAgfSxcclxuICB9LFxyXG4gIGJhc2U6ICcvJyxcclxufSlcclxuLy9pIGRvbnQga25vdyBob3cgYnV0IHRoZSBkZXBsb3ltZW50IGZpeGVkXHJcbiJdLAogICJtYXBwaW5ncyI6ICI7QUFBaVMsU0FBUyxlQUFlLFdBQVc7QUFDcFUsT0FBTyxZQUFZO0FBRW5CLFNBQVMsb0JBQW9CO0FBQzdCLE9BQU8sU0FBUztBQUNoQixPQUFPLGlCQUFpQjtBQUw2SixJQUFNLDJDQUEyQztBQU90TyxPQUFPLE9BQU87QUFHZCxJQUFPLHNCQUFRLGFBQWE7QUFBQSxFQUMxQixRQUFRO0FBQUEsSUFDTixlQUFlLENBQUM7QUFBQSxFQUNsQjtBQUFBLEVBQ0EsU0FBUyxDQUFDLElBQUksR0FBRyxZQUFZLENBQUM7QUFBQSxFQUM5QixTQUFTO0FBQUEsSUFDUCxPQUFPO0FBQUEsTUFDTCxLQUFLLGNBQWMsSUFBSSxJQUFJLFNBQVMsd0NBQWUsQ0FBQztBQUFBLElBQ3REO0FBQUEsRUFDRjtBQUFBLEVBQ0EsTUFBTTtBQUNSLENBQUM7IiwKICAibmFtZXMiOiBbXQp9Cg==
