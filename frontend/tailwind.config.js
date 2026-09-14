/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  darkMode: "class",
  theme: {
    extend: {
      fontFamily: {
        display: ["'Bebas Neue'", "sans-serif"],
        sans: ["Inter", "sans-serif"],
      },
      colors: {
        // Warm, tactile "video-store-at-night" palette — not the generic SaaS blue/slate kit.
        ink: {
          50: "#F7F4EE",
          100: "#EFEAE0",
          200: "#DDD4C2",
          300: "#B8AFA0",
          400: "#8C8272",
          500: "#6B6255",
          600: "#4A4238",
          700: "#332F37",
          800: "#211E24",
          900: "#17151A",
          950: "#0C0B0E",
        },
        marquee: {
          50: "#FDF3E2",
          100: "#FBE7C4",
          200: "#F5CD85",
          300: "#EFB456",
          400: "#E8A33D",
          500: "#C97A1D",
          600: "#A55F16",
          700: "#7C4712",
        },
        ticket: {
          100: "#D9F0EC",
          300: "#8FCFC6",
          400: "#4FA8A0",
          500: "#2E8079",
          600: "#22625C",
        },
        stub: {
          400: "#E2593F",
          500: "#C1432A",
          600: "#9E3521",
        },
      },
      boxShadow: {
        stub: "0 1px 0 rgba(23,19,16,0.04), 0 8px 20px -8px rgba(23,19,16,0.35)",
      },
      keyframes: {
        "flip-reveal": {
          "0%": { transform: "rotateY(0deg)" },
          "45%": { transform: "rotateY(90deg)" },
          "55%": { transform: "rotateY(90deg)" },
          "100%": { transform: "rotateY(0deg)" },
        },
        "rise-in": {
          "0%": { opacity: 0, transform: "translateY(10px)" },
          "100%": { opacity: 1, transform: "translateY(0)" },
        },
        "sheet-up": {
          "0%": { transform: "translateY(100%)" },
          "100%": { transform: "translateY(0)" },
        },
      },
      animation: {
        "flip-reveal": "flip-reveal 0.7s cubic-bezier(.4,.2,.2,1)",
        "rise-in": "rise-in 0.5s cubic-bezier(.16,1,.3,1) both",
        "sheet-up": "sheet-up 0.35s cubic-bezier(.16,1,.3,1)",
      },
    },
  },
  plugins: [],
};
