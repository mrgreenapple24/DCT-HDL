# 16-Point Fast DCT-16 Hardware Engine

This project implements a **16-point Fast Discrete Cosine Transform (DCT)** engine optimized for the **ZedBoard Zynq-7000 FPGA**. The design translates a decimated butterfly algorithm from a Python reference into a high-performance hardware architecture.

---

## 🚀 Core Features

* **Decimated Butterfly Architecture**: Implements a fast algorithm that significantly reduces computational complexity, utilizing only **17 multipliers** instead of the 256 required for standard matrix multiplication.
* **18-Bit High-Precision Data Path**: Utilizes an **18-bit signed fixed-point (Q.8)** representation. This ensures signal integrity and provides necessary headroom to prevent overflow in the DC coefficient ($X_0$).
* **Convergent Rounding**: Incorporates a "round to nearest" logic ($+128$ bias before bit-shifting) in the building blocks to minimize quantization drift and match Python floating-point references.

---

## 📊 Hardware Utilization (ZedBoard)

Targeted for the **Xilinx Zynq-7000 (XC7Z020-1CLG484C)**.

| Resource | Count | Purpose |
| :--- | :--- | :--- |
| **DSP48E1** | 17 | High-speed 18-bit signed multiplications |
| **Adders/Subtractors** | ~52 | Distributed across decimated butterfly stages |
| **Clock Frequency** | 100 MHz | Meets the 10ns period requirement |



---

## 📂 Project Structure

* `rtl/`: Verilog source files including `DCT_building_block.v`, `DCT_2_8.v`, and `DCT_4_8.v`.
* `sim/`: Testbench file featuring the verification array `[1, 3, 5, 7, 9, 17, 19, 21, 22, 18, 18, 16, 8, 6, 4, 2]`.
* `docs/`: Synthesis and Implementation reports generated via Xilinx Vivado.

---

## ✅ Verification

The design has been verified against a Python reference model. The hardware results show a 100% match with the expected rounded values:

* **DC Component ($X_0$)**: 176.0
* **High-Frequency Coefficients**: Accurately processed within $\pm 0.01$ precision.

---

## 🛠️ How to Run

1.  **Open Xilinx Vivado**: Create a new project.
2.  **Select Board**: Set the target board to **ZedBoard Zynq-7000 Evaluation Board**.
3.  **Add Sources**: Add the RTL files from the `rtl/` directory.
4.  **Run Synthesis & Implementation**: Generate the bitstream and review utilization reports.
5.  **Simulate**: Run the provided testbench to verify the 29-cycle output sequence against the reference signal.

---

## 📝 Design Summary

To preserve the full integrity of the image's average brightness, an 18-bit data width was chosen to prevent wrap-around errors in the DC value. The implementation uses a modular `building_block` approach to handle the $J_m$ mirrored vector subtraction and rotational math required by the fast algorithm.
