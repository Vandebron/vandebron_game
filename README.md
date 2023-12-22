# Energy Grid Manager Game

## Overview

Welcome to the Energy Grid Manager Game! This is a simulation game where you take on the role of an energy grid manager, tasked with efficiently harnessing renewable energy to power a city. The game is developed using the Godot game engine.

## Features

- **Renewable Energy Sources:** Place solar panels and windmills strategically to harness energy from the sun and wind.
- **Battery Storage:** Manage energy storage by strategically placing batteries to store excess energy for later use.
- **Dynamic Weather System:** The energy production is influenced by the dynamic weather system, affecting the efficiency of solar panels and windmills.
- **Day-Night Cycle:** Experience a realistic day-night cycle, where energy production varies based on the time of day.

## Getting Started

### Prerequisites

Make sure you have the following installed before running the game:

- [Godot Engine](https://godotengine.org/)

## Exporting

### Web

The web version use Godot's Compatibility renderer, which lacks some features compared to Forward+.
If you want to see the outcome before exporting, simply switch your editor to use Compatibility in the top-right corner.

#### Steps

- Go to `Project > Export`
- Select `Web`
- Click `Export Project`
- In the file browser window, uncheck `Export With Debug`
- Optionally apply binary size optimization as outlined below
- Upload it to the web server, wherever that is

#### Binary size optimization

If you install [Binaryen](https://github.com/WebAssembly/binaryen), you can use `wasm-opt` to shrink the `.wasm` file size, which contains all the game's compiled code.

Steps:

- Export the project for Web in Godot `./target/web`
- Open a terminal and navigate it to `./target/web`
- Run `wasm-opt index.wasm -o index.wasm --all-features -Oz`

The file index.wasm should now be smaller.
If you want to compare the before/after, you can also change the output file to `-o index-optimized.wasm`.
