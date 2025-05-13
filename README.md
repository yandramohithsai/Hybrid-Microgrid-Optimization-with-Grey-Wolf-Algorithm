# ⚡ Optimal Hybrid Renewable Energy System Design Using Grey Wolf Optimizer (GWO)

This project focuses on the optimal sizing of a **Hybrid Renewable Energy System (HRES)**—comprising **solar PV**, **wind turbines**, **diesel generator**, and **battery storage**—for off-grid rural electrification. A **metaheuristic optimization algorithm**, the **Grey Wolf Optimizer (GWO)**, is applied to minimize system cost while ensuring energy reliability.

---

## 🔍 Executive Summary

Connecting remote rural areas to the main power grid is often economically unfeasible. Renewable energy-based microgrids offer a sustainable solution, but their design requires careful optimization to balance cost and performance.

This project presents an optimization framework based on the **Grey Wolf Optimizer (GWO)**—inspired by the social hierarchy and hunting behavior of grey wolves—to determine the optimal configuration of an HRES. The goal is to minimize the **Levelized Cost of Energy (LCOE)** and system capital cost, while ensuring technical feasibility.

The performance of GWO is compared against other metaheuristic algorithms including:
- **Particle Swarm Optimization (PSO)**
- **Cuckoo Search (CS)**
- **Grasshopper Optimization Algorithm (GOA)**
- **HOMER Pro®** simulation tool

Results show that GWO achieves **faster convergence** and **lower system costs**, demonstrating its suitability for off-grid hybrid energy planning.

---

## ⚙️ System Components

- **Photovoltaic (PV) Panels**
- **Wind Turbines (WT)**
- **Diesel Generator (DG)**
- **Battery Energy Storage System (BESS)**

---

## 📈 Objective Function

Minimize:
- Total Net Present Cost (NPC)
- Levelized Cost of Energy (LCOE)
- System capital and operational costs

Subject to:
- Load balance
- Renewable resource availability
- Technical constraints (SOC, DG limits, etc.)

---

## 🚀 Technologies Used

- MATLAB
- HOMER Pro

---

## 🧪 Key Features

- Metaheuristic-based optimization
- Multi-source energy modeling
- Cost and reliability trade-off analysis
- Comparative benchmarking against PSO, CS, GOA, and HOMER

---

## 📁 Project Structure

```bash
├── GWO_Hybrid_Optimization.ipynb   # Main simulation notebook/code
├── README.md
├── data/                           # Load profile, weather data, costs
