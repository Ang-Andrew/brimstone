# Brimstone : implementation of a single-cycle MIPs processor

![Simulation](https://github.com/Ang-Andrew/brimstone/workflows/simulation/badge.svg)

This repository contains verilog sources along with a simulation testbench. The overall architecture is based on [*Digital Design and Computer Architecture*](https://dl.acm.org/doi/book/10.5555/2381028) by David Harris.

## Overview

| Directory/Item | Description                         |
|----------------|-------------------------------------|
| src/           | Verilog source for brimstone        |
| test/          | Test-related sources                |
| scripts/       | Common scripts                      |
| Makefile       | Main Makefile for running testbench |

## Simulation

| Test      | Description                                                                                                                   |
|-----------|-------------------------------------------------------------------------------------------------------------------------------|
| test_core | Simple testbench that test various MIPs operations. Based on example provided by *Digital Design and Computer Architecture*   |

An individual test can be perform by running:
```bash
make <test>
```
Running `make` runs all test in the `test/` directory with the name `test_*.v`
