import numpy as np
import matplotlib.pyplot as plt

def plot_ethernet_waveform():
    clock_cycles = np.arange(20)
    
    # START_OF_FRAME: Goes high at cycle 1 and low at cycle 2
    start_of_frame = [0] * 1 + [1] + [0] * 18
    
    # END_OF_FRAME: Goes high at cycle 16 and low at cycle 17
    end_of_frame = [0] * 16 + [1] + [0] * 3
    
    # Data bits: First part is the frame, last part is FCS
    data_in = ["D"] * 15 + ["F"] * 4 + [" "]  # 'D' for Data, 'F' for FCS
    
    fig, ax = plt.subplots(figsize=(10, 4))
    ax.set_ylim(-1.5, 2.5)
    ax.set_xlim(0, 19)
    ax.set_xticks(clock_cycles)
    ax.set_yticks([0, 1, 2])
    ax.set_yticklabels(["START_OF_FRAME", "END_OF_FRAME", "DATA_IN"])
    
    # Plot the signals
    ax.step(clock_cycles, np.array(start_of_frame) + 0, where='post', label='START_OF_FRAME', linewidth=2)
    ax.step(clock_cycles, np.array(end_of_frame) + 1, where='post', label='END_OF_FRAME', linewidth=2)
    
    # Annotate data bits
    for i, bit in enumerate(data_in):
        ax.text(i, 2, bit, ha='center', va='bottom', fontsize=12, fontweight='bold')
    
    # Formatting
    ax.legend()
    ax.grid(True, linestyle='--', alpha=0.6)
    plt.title("Ethernet Frame Reception Waveform")
    plt.show()

plot_ethernet_waveform()