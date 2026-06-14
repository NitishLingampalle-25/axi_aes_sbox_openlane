# axi_aes_sbox_openlane

# AXI-Lite AES S-Box Crypto Accelerator

An end-to-end Physical Design (RTL-to-GDSII) implementation of an AXI-Lite managed AES S-Box cryptographic engine. The design was synthesized, placed, routed, and verified using the open-source **OpenLane compiler** targeted at the **SkyWater 130nm (sky130A)** Process Design Kit (PDK).

## Design Architecture & Specifications
* **Protocol Interface:** AXI4-Lite Slave (32-bit Data Bus)
* **Core Logic:** Advanced Encryption Standard (AES) Substitution-Box (S-Box) using optimized Galois Field ($GF(2^8)$) inversion.
* **Target Manufacturing Node:** SkyWater 130nm High-Density (`sky130_fd_sc_hd`) Standard Cell Library.

---

## Physical Design Flow & Results

The physical implementation was executed interactively through the OpenLane containerized toolchain. The design successfully achieved **Timing Closure** and **0 DRC Violations**.

| Design Phase | Core Metric | Status / Value | Tool / Engine |
| :--- | :--- | :--- | :--- |
| **Synthesis** | Gate Count / Mapping | Clean structural netlist | Yosys / OpenSTA |
| **Floorplanning** | Core Sizing & PDN | 35% Base Sizing / Stable VDD-VGND Grid | OpenROAD / PSM |
| **Placement** | Cell Density | 37% Final Utilization Density | RePlAce |
| **Clock Tree (CTS)** | Clock Skew | **20 ps** ($0.02\text{ ns}$) Skew | TritonCTS |
| **Routing** | DRC Cleanliness | **0 DRC Violations** | FastRoute / TritonRoute |
| **Sign-off STA** | Worst Negative Slack | **0.00** (Setup: $+3.99\text{ ns}$, Hold: $+0.27\text{ ns}$) | OpenSTA (Post-RCX) |

### Key Insights & Trade-offs
1. **Timing Closure:** The initial setup slack was $3.71\text{ ns}$ during synthesis and concluded at a robust $+3.99\text{ ns}$ post-routing, showing excellent physical logic clustering during placement.
2. **CTS Overhead:** Building a balanced clock tree dropped the system skew to a minuscule $20\text{ ps}$, with a typical dynamic power overhead increase from $2.07\text{ mW}$ to $2.33\text{ mW}$.
3. **Electrical Sign-off:** The layout contains a single minor maximum fanout alert. However, because Max Slew and Max Capacitance are completely clean (`0` violations), signal integrity remains uncompromised.

---

## Final GDSII Layout Visualization

The layout below illustrates the complete routed macro cell viewed natively inside **KLayout** using the `sky130A.lyp` layer properties palette. 

* **Thick Blue Outer Paths:** Power Distribution Network (PDN) rings delivering balanced current.
* **Peripheral Label Blocks:** Micro-positioned AXI bus signal interface pins.
* **Internal Grid Array:** High-density arrangement of combined logic switching elements.

# AXI-Lite AES S-Box Crypto Accelerator

An end-to-end Physical Design (RTL-to-GDSII) implementation of an AXI-Lite managed AES S-Box cryptographic engine. The design was synthesized, placed, routed, and verified using the open-source **OpenLane compiler** targeted at the **SkyWater 130nm (sky130A)** Process Design Kit (PDK).

## 🚀 Design Architecture & Specifications
* **Protocol Interface:** AXI4-Lite Slave (32-bit Data Bus)
* **Core Logic:** Advanced Encryption Standard (AES) Substitution-Box (S-Box) using optimized Galois Field ($GF(2^8)$) inversion.
* **Target Manufacturing Node:** SkyWater 130nm High-Density (`sky130_fd_sc_hd`) Standard Cell Library.

---

## 📊 Physical Design Flow & Results

The physical implementation was executed interactively through the OpenLane containerized toolchain. The design successfully achieved **Timing Closure** and **0 DRC Violations**.

| Design Phase | Core Metric | Status / Value | Tool / Engine |
| :--- | :--- | :--- | :--- |
| **Synthesis** | Gate Count / Mapping | Clean structural netlist | Yosys / OpenSTA |
| **Floorplanning** | Core Sizing & PDN | 35% Base Sizing / Stable VDD-VGND Grid | OpenROAD / PSM |
| **Placement** | Cell Density | 37% Final Utilization Density | RePlAce |
| **Clock Tree (CTS)** | Clock Skew | **20 ps** ($0.02\text{ ns}$) Skew | TritonCTS |
| **Routing** | DRC Cleanliness | **0 DRC Violations** | FastRoute / TritonRoute |
| **Sign-off STA** | Worst Negative Slack | **0.00** (Setup: $+3.99\text{ ns}$, Hold: $+0.27\text{ ns}$) | OpenSTA (Post-RCX) |

### Key Insights & Trade-offs
1. **Timing Closure:** The initial setup slack was $3.71\text{ ns}$ during synthesis and concluded at a robust $+3.99\text{ ns}$ post-routing, showing excellent physical logic clustering during placement.
2. **CTS Overhead:** Building a balanced clock tree dropped the system skew to a minuscule $20\text{ ps}$, with a typical dynamic power overhead increase from $2.07\text{ mW}$ to $2.33\text{ mW}$.
3. **Electrical Sign-off:** The layout contains a single minor maximum fanout alert. However, because Max Slew and Max Capacitance are completely clean (`0` violations), signal integrity remains uncompromised.

---

## Final GDSII Layout Visualization

The layout below illustrates the complete routed macro cell viewed natively inside **KLayout** using the `sky130A.lyp` layer properties palette. 

* **Thick Blue Outer Paths:** Power Distribution Network (PDN) rings delivering balanced current.
* **Peripheral Label Blocks:** Micro-positioned AXI bus signal interface pins.
* **Internal Grid Array:** High-density arrangement of combined logic switching elements.

