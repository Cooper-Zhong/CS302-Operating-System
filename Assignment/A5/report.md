# CS302 OS Assignment 5
12110517 Zhong Zhiyuan

## Q1

The page size is `4 KB`, the access time for main memory is `100 ns`, the access time for the TLB is 
`10 ns`, and the average time to handle a page fault, including the time to update the TLB and page table, is `10^8 ns`

sequence: 1333H, 0555H, 2555H

### (1) 
What is the time required to access each of the three virtual addresses mentioned above? 
page size = 4 kb = $2^{12}$ bytes, so offset = 12 bits, the VPN = 4 bits.

1. `1333H`: VPN = 1, offset = `333H`.
    time:
    - TLB miss: 10ns
    - access page table: 100ns, ok, update TLB with VPN 1.
    - access memory: 100ns

    total: 10 + 100 + 100 = 210 ns


2. `0555H`: VPN = 0, offset = `555H`.
    time:
    - TLB miss: 10ns
    - access page table: 100ns, page fault, 10^8 ns, update TLB with VPN 0.
    - TLB hit: 10ns
    - access memory: 100ns

    total: 10 + 100 + 10^8 + 10 + 100 = $(10^8+210)ns$

3. `2555H`: VPN = 2, offset = `555H`.
    time:
    - TLB miss: 10ns
    - access page table: 100ns, ok, update TLB with VPN 2.
    - access memory: 100ns

    total: 10 + 100 + 100 = 210 ns

### (2)

Suppose the operating system permits processes to use only two physical pages with frame numbers `122H` and `233H`, employing LRU replacement algorithm. Given the certain access sequence above, what is the physical address for the virtual address `0555H`?

When accessing `0555H`, page fault happened, previously `1333H` accessed virtual page 1 (physical page `122H`). Thus `233H` in the page table(virtual page 2) will be replaced by `0555H`, the page number is 0, the page Frame number is `233H`. 

The physical address for `0555H` is `233H` concatenated with offset `555H` = `233555H`





## Q2
Here is a computer with a riscv64 architecture, employing the sv39 multi-level paging mechanism.

Assuming there are only three free physical pages in memory, with physical page numbers being 
`0x00000086000`, `0x00000086001`, and `0x00000086002`. When a process requests a physical page, 
the operating system adopts an allocation strategy of assigning physical page numbers from 
largest to smallest. At a certain point, the value in the `Satp` register is `0x8000000000084000`, 
with all PTEs in the root page table being zero. The current process attempts to access the valid 
virtual address `0x0000002123456789`. Please simulate the computer's handling of the page fault 
interrupt, allocate the corresponding physical page, correctly fill in the corresponding page table 
entry, and find the corresponding physical address. 
Complete the following blanks (in hexadecimal, ignoring the actual setting of flag bits in each 
level of page table entries, all flags set to 0 is OK)

**Solution:**

sv39 uses 3 level page tables, so:

virtual address `0x0000002123456789`: `0...0 0010 0001 0010 0011 0100 0101 0110 0111 1000 1001`

A PTE in sv39 is 64 bits = 8 bytes.

| L1          | L2          | L3          | Offset         |
| ----------- | ----------- | ----------- | -------------- |
| 010 0001 00 | 10 0011 010 | 0 0101 0110 | 0111 1000 1001 |

1. The PPN of the satp = `00000084000` (lower 44 bits). The physical address of the root page table is **`0x00000084000000`**, and the value of the __**`0x84`**__th page table entry is **`0x0000 0000 2180 0800`**

PPN of root page table is in `Satp` register: `0x00000084000`, offset is 12 bits which equlas `0x000`. L1 VPN is `01000 0100` = `0x84`. With all PTEs in the root page table being zero, the OS allocates a physical page `0x00000086002` (largest) for the second level page table. `0x86002` = `10000110000000000010`. Converting `0x00000086002` (44 bits) to PTE:  `0010 0001 1000 0000 0000 1000 0000 0000` (binary)= `0x00000000 21800800`. 

2. The physical address of the second level page table is **`0x00000086002000`**, and the value of the __**`0x11a`**__th page table entry is **`0x0000 0000 2180 0400`**

L2 VPN is `1 0001 1010` = `0x11a`, the OS allocates a physical page with page number `0x00000086001` (largest) for the third level page table. `0x86001`= `1000 0110 0000 0000 0001`, `0x00000086001` to PTE: `0010 0001 1000 0000 0000 0100 0000 0000` = `0x00000000 2180 0400`.

3. The physical address of the third level page table is **`0x00000086001000`**, and the value of the __**`0x56`**__th page table entry is **`0x0000 0000 2180 0000`**

L3 VPN is `0 0101 0110` = `0x56`, the OS allocates a physical page with page number `0x00000086000` for the process. `0x00000086000` to PTE: `10000110000000000000 0000000000` = `0x00000000 21800000`.

4. The physical address corresponding to the virtual address `0x0000002123456789` is: `1000 0110 0000 0000 0000` concatenated with offset = `1000 0110 0000 0000 0000 0111 1000 1001` = `0x86000 789` = **`0x00000086000789`** (56 bits). 





