/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          red: '#B42332',
          'red-hover': '#981C29',
          'red-light': '#FDF2F3',
          charcoal: '#17212B',
          'charcoal-card': '#1E2B37',
          'charcoal-border': '#2A3B4C',
          amber: '#D99A36',
          'amber-light': '#FEF7ED',
          success: '#16836B',
          'success-light': '#ECFDF5',
          bg: '#F7F8FA',
          slate: '#64748B',
        },
      },
      fontFamily: {
        sans: ['Inter', 'Plus Jakarta Sans', 'system-ui', '-apple-system', 'sans-serif'],
      },
      boxShadow: {
        'card': '0 1px 3px 0 rgba(0, 0, 0, 0.05), 0 1px 2px -1px rgba(0, 0, 0, 0.05)',
        'card-hover': '0 4px 6px -1px rgba(0, 0, 0, 0.08), 0 2px 4px -2px rgba(0, 0, 0, 0.06)',
      },
    },
  },
  plugins: [],
}
