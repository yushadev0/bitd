/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        brand: {
          50: "#eef4ff",
          100: "#dbe6fe",
          200: "#bfd2fe",
          300: "#93b4fd",
          400: "#608bfa",
          500: "#3d64f4",
          600: "#2743e8",
          700: "#2033d0",
          800: "#212ba8",
          900: "#202a84",
        },
      },
    },
  },
  plugins: [],
};
