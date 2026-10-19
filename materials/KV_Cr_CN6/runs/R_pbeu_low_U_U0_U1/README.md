# PBE+U at U = 1 eV and plain PBE (U = 0), extending the U grid downwards

The agents' U grid (`../A_pbeu_relax_scf_nscf_Ugrid/`, `../B_pbeu_FM_fixed_moment/`) covers U_V, U_Cr in {2, 3, 4} eV. This folder adds U_V = U_Cr = 1 eV and U = 0 (plain PBE). It was computed for this ledger on 2026-10-19, after the campaign.

- **Inputs:** made from the agents' inputs with only the prefix and the Hubbard values changed. The U = 1 files are `../A_pbeu_relax_scf_nscf_Ugrid/KVCr_LCM.in`, `KVCr_LCM_nscf.in` and `KVCr_FM.in`, plus `../B_pbeu_FM_fixed_moment/KVCr_U3_3_FMfix.in`, with `U V-3d 1.0` and `U Cr-3d 1.0`. The U = 0 files are the same inputs with the `HUBBARD` card removed. The geometry is the one relaxed at U = 3 eV, as for the rest of the U grid. Cutoff, smearing, k-meshes (scf 5×5×5, nscf 8×8×8) and starting moments are unchanged.
- **Environment:** a 10-core workstation (Intel i9-10900X), Quantum ESPRESSO 7.5 and Open MPI 5.0.11 from conda-forge, `mpirun -np 10 pw.x -nk 10` through `reproduce/run_qe.sh`. The PseudoDojo pseudopotentials came from `reproduce/get_pseudos.sh`; all matched their sha256 and md5 sums (`run_summary.json`). The same set-up reproduced the agents' U = 3 eV runs (K02–K08, K12) to within 0.01 meV.
- **Outputs:** written by `run_qe.sh` as `*.repro.out` and renamed here. Machine-specific paths in the outputs (input file, pseudopotential directory, scratch directory) were replaced by `<repo>` and `<scratch>`; nothing else was changed.
- **Free ferromagnet at U = 1 (`KVCr_U1_1_FM`):** it converged to a low-moment state with a total moment of 2.44 μB, in which the Cr moment collapsed to 0.11 μB. That state is 690 meV per magnetic ion above the ferromagnet with the moment fixed at 6 (`KVCr_U1_1_FMfix`), so it is not the ferromagnetic reference. It was therefore not run at U = 0. The energy claims use the fixed-moment runs, as K18 does for HSE06.

**Results.** Gap and windows are from the nscf 8×8×8 runs.

| U_V = U_Cr | net moment | V / Cr moment (μB) | gap (eV) | hole window (eV) | electron window (eV) | same spin at both edges | E(FM, M = 6) − E(compensated), per magnetic ion |
|---|---|---|---|---|---|---|---|
| 1 eV | 0.00 | −1.88 / +2.14 | 0.95 | 1.74 | 1.46 | yes | 263.5 meV |
| 0 (PBE) | 0.00 | −1.78 / +1.98 | 0.58 | 1.37 | 1.33 | yes | 364.9 meV |

Claims K09b–K12c in `tools/verify.py`.
