import type { Config } from "tailwindcss";
const config: Config = { content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"], theme: { extend: { colors: { academic: "#1a5276", mist: "#f4f7f6" }, fontFamily: { sans: ["Arial", "Tahoma", "sans-serif"] } } }, plugins: [] };
export default config;