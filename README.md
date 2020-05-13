# Brimstone : implementation of a single-cycle MIPs processor (DEPRECATED)

![Simulation](https://github.com/Ang-Andrew/brimstone/workflows/simulation/badge.svg)

This repository contains verilog sources along with a simulation testbench. The overall architecture is based on [*Digital Design and Computer Architecture*](https://dl.acm.org/doi/book/10.5555/2381028) by David Harris.

This repository is now deprecated and no addtional feature will be made. There might be future improvements to the code structure but this project was my introduction into Verilog.

## Overview

| Directory/Item | Description                         |
|----------------|-------------------------------------|
| src/           | Verilog source for brimstone        |
| test/          | Test-related sources                |
| scripts/       | Common scripts                      |
| Makefile       | Main Makefile for running testbench |

## Dependencies
Requires [Icarus Verilog](https://iverilog.fandom.com/wiki/Installation_Guide)

## Simulation

| Test      | Description                                                                                                                   |
|-----------|-------------------------------------------------------------------------------------------------------------------------------|
| test_core | Simple testbench that test various MIPs operations. Based on example provided by *Digital Design and Computer Architecture*   |

An individual test can be perform by running:
```bash
make <test>
```
Running `make` runs all tests in the `test/` directory with the name `test_*.v`
