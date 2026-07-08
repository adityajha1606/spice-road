#!/usr/bin/env bash
# Spice Road — color preview. Run anywhere to see the full palette with names.

printf "Spice Road Palette\n"
printf "==================\n"

entries=(
  "#14100D|bg"
  "#F2E6D8|fg"
  "#C9B79C|fg_muted"
  "#4A3423|selection"
  "#E8A33D|cursor"
  "#1A1410|black"
  "#B5502D|red"
  "#7C8B3D|green"
  "#E8A33D|yellow"
  "#3E5578|blue"
  "#7B3F61|purple"
  "#2E8C82|cyan"
  "#D9C7A3|white"
  "#6B5D4F|brightBlack"
  "#E8623A|brightRed"
  "#A8BB5C|brightGreen"
  "#F2C14E|brightYellow"
  "#6A87B8|brightBlue"
  "#B0609E|brightPurple"
  "#4FB8AC|brightCyan"
  "#F2E6D8|brightWhite"
  "#B87333|copper"
  "#8C6239|bronze"
  "#D4AF37|gold"
  "#9B2C2C|vermillion"
  "#6B3A1F|henna"
  "#1F2A44|duskIndigo"
  "#14555A|peacockDeep"
)

for entry in "${entries[@]}"; do
  hex="${entry%%|*}"
  name="${entry##*|}"
  r=$(printf "%d" "0x${hex:1:2}")
  g=$(printf "%d" "0x${hex:3:2}")
  b=$(printf "%d" "0x${hex:5:2}")
  printf "\033[48;2;%d;%d;%dm   \033[0m" "$r" "$g" "$b"
  printf " %-16s %s\n" "$name" "$hex"
done