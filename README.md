# Brimstone : implementation of a single-cycle MIPs processor

![Simulation](https://github.com/Ang-Andrew/resume/workflows/simulation/badge.svg?branch=master)

This repository contains verilog sources along with a simulation testbenche. The overall architecture is based on *Digital Design and Computer Architecture* by David Harris.

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

An individual test can be perform by doing:
```bash
make <test>
```
Running `make` runs all test in the `test/` directory with the name `test_*.v`